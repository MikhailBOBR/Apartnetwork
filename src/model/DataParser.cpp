#include "DataParser.h"

#include <QFile>
#include <QStringList>
#include <QTextStream>

#include <stdexcept>

namespace {

void normalizeTarget(Matrix &target, double minValue, double maxValue)
{
    const double range = maxValue - minValue;
    for (int row = 0; row < target.numRows(); ++row) {
        for (int column = 0; column < target.numCols(); ++column) {
            target.data[row][column] = range == 0.0
                ? 0.0
                : (target.data[row][column] - minValue) / range;
        }
    }
}

void normalizeFeatures(Matrix &matrix)
{
    const std::vector<double> means = matrix.mean();
    const std::vector<double> stdDevs = matrix.stdDev(means);

    for (int row = 0; row < matrix.numRows(); ++row) {
        for (int column = 0; column < matrix.numCols(); ++column) {
            if (stdDevs[column] != 0.0) {
                matrix.data[row][column] = (matrix.data[row][column] - means[column]) / stdDevs[column];
            }
        }
    }
}

} // namespace

CsvTableData readCSV(const QString &filename)
{
    QFile file(filename);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        throw std::runtime_error("Cannot open dataset file");
    }

    QTextStream input(&file);
    const QString headerLine = input.readLine().trimmed();
    if (headerLine.isEmpty()) {
        throw std::runtime_error("Dataset file is empty");
    }

    const QStringList headers = headerLine.split(',');
    if (headers.size() < 2) {
        throw std::runtime_error("Dataset header must contain target and features");
    }

    std::vector<QString> featureNames;
    featureNames.reserve(headers.size() - 1);
    for (int index = 1; index < headers.size(); ++index) {
        featureNames.push_back(headers.at(index).trimmed());
    }

    std::vector<ApartmentRecord> records;
    std::vector<std::vector<double>> features;
    std::vector<std::vector<double>> targets;

    while (!input.atEnd()) {
        const QString line = input.readLine().trimmed();
        if (line.isEmpty()) {
            continue;
        }

        const QStringList columns = line.split(',');
        if (columns.size() != headers.size()) {
            throw std::runtime_error("Dataset row has invalid column count");
        }

        bool targetOk = false;
        const double price = columns.at(0).trimmed().toDouble(&targetOk);
        if (!targetOk) {
            throw std::runtime_error("Invalid target value");
        }

        std::vector<double> rowFeatures;
        rowFeatures.reserve(columns.size() - 1);
        for (int index = 1; index < columns.size(); ++index) {
            bool featureOk = false;
            const double value = columns.at(index).trimmed().toDouble(&featureOk);
            if (!featureOk) {
                throw std::runtime_error("Invalid feature value");
            }
            rowFeatures.push_back(value);
        }

        records.push_back({price, rowFeatures});
        features.push_back(rowFeatures);
        targets.push_back({price});
    }

    if (records.empty()) {
        throw std::runtime_error("Dataset must contain at least one record");
    }

    Matrix matrixX(static_cast<int>(features.size()), static_cast<int>(featureNames.size()));
    Matrix matrixY(static_cast<int>(targets.size()), 1);

    for (size_t row = 0; row < features.size(); ++row) {
        matrixX.data[row] = features[row];
        matrixY.data[row] = targets[row];
    }

    const double yMax = matrixY.max();
    const double yMin = matrixY.min();
    const std::vector<double> means = matrixX.mean();
    const std::vector<double> stdDevs = matrixX.stdDev(means);

    normalizeFeatures(matrixX);
    normalizeTarget(matrixY, yMin, yMax);

    return {matrixX, matrixY, yMax, yMin, means, stdDevs, featureNames, records};
}
