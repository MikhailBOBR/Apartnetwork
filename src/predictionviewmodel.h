#ifndef PREDICTIONVIEWMODEL_H
#define PREDICTIONVIEWMODEL_H

#include <QObject>
#include <QVariantList>
#include <QVariantMap>

#include "apartmentmodeladapter.h"

class PredictionViewModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantMap lastPrediction READ lastPrediction NOTIFY lastPredictionChanged)
    Q_PROPERTY(QVariantList marketHighlights READ marketHighlights CONSTANT)
    Q_PROPERTY(QVariantList marketScatter READ marketScatter CONSTANT)
    Q_PROPERTY(QVariantList districtIndices READ districtIndices CONSTANT)
    Q_PROPERTY(QVariantList presets READ presets CONSTANT)
    Q_PROPERTY(QVariantList trainingCurve READ trainingCurve NOTIFY trainingCurveChanged)
    Q_PROPERTY(double bestMse READ bestMse NOTIFY bestMseChanged)
    Q_PROPERTY(QString datasetDescription READ datasetDescription CONSTANT)

public:
    explicit PredictionViewModel(QObject *parent = nullptr);

    Q_INVOKABLE void predictPrice(double area,
                                  int rooms,
                                  int floor,
                                  int floorsTotal,
                                  int metroMinutes,
                                  int builtYear,
                                  const QString &district,
                                  const QString &condition,
                                  const QString &buildingType,
                                  bool parking,
                                  bool balcony,
                                  bool newBuild);
    Q_INVOKABLE void trainModel(int epochs, double learningRate);

    QVariantMap lastPrediction() const;
    QVariantList marketHighlights() const;
    QVariantList marketScatter() const;
    QVariantList districtIndices() const;
    QVariantList presets() const;
    QVariantList trainingCurve() const;
    double bestMse() const;
    QString datasetDescription() const;

signals:
    void predictionReady(const QVariantMap &result);
    void operationInProgress(bool inProgress);
    void trainingProgress(int epoch, double mse);
    void trainingStarted();
    void trainingFinished();
    void lastPredictionChanged();
    void trainingCurveChanged();
    void bestMseChanged();

private:
    void initializeStaticData();
    QVariantMap makeErrorResult(const QString &message) const;

    ApartmentModelAdapter *adapter{nullptr};
    QVariantMap lastPrediction_;
    QVariantList marketHighlights_;
    QVariantList marketScatter_;
    QVariantList districtIndices_;
    QVariantList presets_;
    QVariantList trainingCurve_;
    double bestMse_{-1.0};
    QString datasetDescription_;
};

#endif // PREDICTIONVIEWMODEL_H
