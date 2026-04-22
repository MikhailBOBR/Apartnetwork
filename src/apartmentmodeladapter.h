#ifndef APARTMENTMODELADAPTER_H
#define APARTMENTMODELADAPTER_H

#include <QObject>
#include <QString>

#include <functional>
#include <vector>

#include "./model/ApartmentModel.h"
#include "./model/DataParser.h"

class ApartmentModelAdapter : public QObject
{
    Q_OBJECT

public:
    explicit ApartmentModelAdapter(QObject *parent = nullptr);
    ApartmentModelAdapter(const QString &datasetPath,
                          bool usePersistentWeights,
                          bool bootstrapModel,
                          QObject *parent = nullptr);

    QString predictPrice(const std::vector<double> &inputs) const;
    double predictPriceValue(const std::vector<double> &inputs) const;
    std::vector<double> trainModel(int epochs,
                                   double learningRate,
                                   const std::function<void(int, double)> &updateProgress);
    void normalizeInput(Matrix &inputMatrix) const;
    const CsvTableData &dataset() const;

private:
    void loadOrBootstrapModel();
    bool weightFilesPresent() const;
    QString weightsDirectory() const;

    ApartmentModel model;
    CsvTableData data;
    bool usePersistentWeights_{true};
    bool bootstrapModel_{true};
};

#endif // APARTMENTMODELADAPTER_H
