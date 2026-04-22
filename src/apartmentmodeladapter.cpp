#include "apartmentmodeladapter.h"

#include <QDir>
#include <QFileInfo>
#include <QLocale>
#include <QStandardPaths>

namespace {

constexpr int kFeatureCount = 12;
constexpr int kBootstrapEpochs = 1600;
constexpr double kBootstrapLearningRate = 0.0045;
const QString kDefaultDatasetPath = QStringLiteral(":/assets/moscow_apartments_2023.csv");
const QString kWeightsDirectory = QStringLiteral("model_data/moscow_2023");

Matrix convertToMatrix(const std::vector<double> &inputs)
{
    Matrix matrix(1, static_cast<int>(inputs.size()));
    for (size_t index = 0; index < inputs.size(); ++index) {
        matrix.data[0][index] = inputs[index];
    }
    return matrix;
}

Matrix denormalizeOutput(const Matrix &normalizedOutput, double minValue, double maxValue)
{
    Matrix denormalized = normalizedOutput;
    const double range = maxValue - minValue;

    for (int row = 0; row < denormalized.numRows(); ++row) {
        for (int column = 0; column < denormalized.numCols(); ++column) {
            denormalized.data[row][column] = denormalized.data[row][column] * range + minValue;
        }
    }

    return denormalized;
}

} // namespace

ApartmentModelAdapter::ApartmentModelAdapter(QObject *parent)
    : ApartmentModelAdapter(kDefaultDatasetPath, true, true, parent)
{
}

ApartmentModelAdapter::ApartmentModelAdapter(const QString &datasetPath,
                                             bool usePersistentWeights,
                                             bool bootstrapModel,
                                             QObject *parent)
    : QObject(parent)
    , model({kFeatureCount, 28, 14, 1})
    , data(readCSV(datasetPath))
    , usePersistentWeights_(usePersistentWeights)
    , bootstrapModel_(bootstrapModel)
{
    loadOrBootstrapModel();
}

QString ApartmentModelAdapter::predictPrice(const std::vector<double> &inputs) const
{
    const auto locale = QLocale(QLocale::Russian, QLocale::Russia);
    return locale.toString(static_cast<qlonglong>(predictPriceValue(inputs)));
}

double ApartmentModelAdapter::predictPriceValue(const std::vector<double> &inputs) const
{
    Matrix inputMatrix = convertToMatrix(inputs);
    normalizeInput(inputMatrix);

    const Matrix outputMatrix = model.forward(inputMatrix);
    const Matrix denormalized = denormalizeOutput(outputMatrix, data.yMin, data.yMax);
    return denormalized.data[0][0];
}

std::vector<double> ApartmentModelAdapter::trainModel(
    int epochs,
    double learningRate,
    const std::function<void(int, double)> &updateProgress)
{
    const std::vector<double> history = model.train(data.X, data.Y, epochs, learningRate, updateProgress);

    if (usePersistentWeights_) {
        model.saveWeights(weightsDirectory().toStdString());
    }

    return history;
}

void ApartmentModelAdapter::normalizeInput(Matrix &inputMatrix) const
{
    for (int column = 0; column < inputMatrix.numCols(); ++column) {
        const double stdDev = data.stdDevsX[column];
        if (stdDev == 0.0) {
            continue;
        }

        for (int row = 0; row < inputMatrix.numRows(); ++row) {
            inputMatrix.data[row][column] =
                (inputMatrix.data[row][column] - data.meansX[column]) / stdDev;
        }
    }
}

const CsvTableData &ApartmentModelAdapter::dataset() const
{
    return data;
}

void ApartmentModelAdapter::loadOrBootstrapModel()
{
    if (usePersistentWeights_ && weightFilesPresent()) {
        model.loadWeights(weightsDirectory().toStdString());
        return;
    }

    if (!bootstrapModel_) {
        return;
    }

    model.train(data.X, data.Y, kBootstrapEpochs, kBootstrapLearningRate, [](int, double) {});

    if (usePersistentWeights_) {
        model.saveWeights(weightsDirectory().toStdString());
    }
}

bool ApartmentModelAdapter::weightFilesPresent() const
{
    const QString baseDirectory = weightsDirectory();
    return QFileInfo::exists(QDir(baseDirectory).filePath(QStringLiteral("weights_layer_0.csv")))
        && QFileInfo::exists(QDir(baseDirectory).filePath(QStringLiteral("biases_layer_0.csv")));
}

QString ApartmentModelAdapter::weightsDirectory() const
{
    QString baseDirectory = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    if (baseDirectory.isEmpty()) {
        baseDirectory = QDir::currentPath();
    }

    return QDir(baseDirectory).filePath(kWeightsDirectory);
}
