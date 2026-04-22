#include "predictionviewmodel.h"

#include <QtConcurrent>

#include <QLocale>

#include <algorithm>
#include <cmath>
#include <limits>

namespace {

struct DistrictOption {
    QString label;
    double index;
};

const std::vector<DistrictOption> kDistrictOptions = {
    {QStringLiteral("ЦАО"), 650000.0},
    {QStringLiteral("ЗАО"), 360000.0},
    {QStringLiteral("СЗАО"), 340000.0},
    {QStringLiteral("ЮЗАО"), 315000.0},
    {QStringLiteral("САО"), 300000.0},
    {QStringLiteral("СВАО"), 280000.0},
    {QStringLiteral("ЮАО"), 270000.0},
    {QStringLiteral("ВАО"), 255000.0},
    {QStringLiteral("ЮВАО"), 245000.0},
    {QStringLiteral("Новая Москва"), 210000.0}
};

double districtIndex(const QString &label)
{
    const auto it = std::find_if(kDistrictOptions.begin(), kDistrictOptions.end(),
                                 [&label](const DistrictOption &option) { return option.label == label; });
    return it == kDistrictOptions.end() ? 280000.0 : it->index;
}

int conditionCode(const QString &condition)
{
    if (condition == QStringLiteral("Требует ремонта")) {
        return 0;
    }
    if (condition == QStringLiteral("Косметический ремонт")) {
        return 1;
    }
    return 2;
}

int buildingTypeCode(const QString &buildingType)
{
    if (buildingType == QStringLiteral("Панель")) {
        return 0;
    }
    if (buildingType == QStringLiteral("Кирпич")) {
        return 1;
    }
    return 2;
}

QLocale russianLocale()
{
    return QLocale(QLocale::Russian, QLocale::Russia);
}

QString formatRubles(double value)
{
    return russianLocale().toString(static_cast<qlonglong>(std::llround(value))) + QStringLiteral(" ₽");
}

QString formatMillions(double value)
{
    return QString::number(value / 1000000.0, 'f', 1) + QStringLiteral(" млн ₽");
}

QString formatThousands(double value)
{
    return QString::number(value / 1000.0, 'f', value >= 1000000.0 ? 0 : 1) + QStringLiteral(" тыс. ₽/м²");
}

QString priceBandLabel(double totalPrice)
{
    if (totalPrice < 10000000.0) {
        return QStringLiteral("Бюджетный сегмент Москвы 2023");
    }
    if (totalPrice < 25000000.0) {
        return QStringLiteral("Средний городской сегмент");
    }
    if (totalPrice < 50000000.0) {
        return QStringLiteral("Повышенный комфорт / бизнес");
    }
    return QStringLiteral("Премиальный диапазон");
}

QVariantMap makeInsight(const QString &title, const QString &value, const QString &caption)
{
    return QVariantMap{
        {QStringLiteral("title"), title},
        {QStringLiteral("value"), value},
        {QStringLiteral("caption"), caption}
    };
}

QVariantMap makePreset(const QString &title,
                       double area,
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
                       bool newBuild)
{
    return QVariantMap{
        {QStringLiteral("title"), title},
        {QStringLiteral("area"), area},
        {QStringLiteral("rooms"), rooms},
        {QStringLiteral("floor"), floor},
        {QStringLiteral("floorsTotal"), floorsTotal},
        {QStringLiteral("metroMinutes"), metroMinutes},
        {QStringLiteral("builtYear"), builtYear},
        {QStringLiteral("district"), district},
        {QStringLiteral("condition"), condition},
        {QStringLiteral("buildingType"), buildingType},
        {QStringLiteral("parking"), parking},
        {QStringLiteral("balcony"), balcony},
        {QStringLiteral("newBuild"), newBuild}
    };
}

} // namespace

PredictionViewModel::PredictionViewModel(QObject *parent)
    : QObject(parent)
    , adapter(new ApartmentModelAdapter(this))
{
    initializeStaticData();
}

void PredictionViewModel::predictPrice(double area,
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
                                       bool newBuild)
{
    emit operationInProgress(true);

    if (area <= 0.0 || rooms <= 0 || floor <= 0 || floorsTotal <= 0 || floor > floorsTotal
        || metroMinutes < 0 || builtYear < 1950 || builtYear > 2023) {
        lastPrediction_ = makeErrorResult(QStringLiteral("Заполните поля корректными значениями."));
        emit lastPredictionChanged();
        emit predictionReady(lastPrediction_);
        emit operationInProgress(false);
        return;
    }

    const std::vector<double> inputs = {
        area,
        static_cast<double>(rooms),
        static_cast<double>(floor),
        static_cast<double>(floorsTotal),
        static_cast<double>(metroMinutes),
        districtIndex(district),
        static_cast<double>(conditionCode(condition)),
        static_cast<double>(buildingTypeCode(buildingType)),
        static_cast<double>(builtYear),
        parking ? 1.0 : 0.0,
        balcony ? 1.0 : 0.0,
        newBuild ? 1.0 : 0.0
    };

    const double totalPrice = adapter->predictPriceValue(inputs);
    const double pricePerSquareMeter = totalPrice / area;

    lastPrediction_ = QVariantMap{
        {QStringLiteral("isError"), false},
        {QStringLiteral("headline"), QStringLiteral("Оценка для квартиры в Москве, 2023")},
        {QStringLiteral("totalPriceText"), formatMillions(totalPrice)},
        {QStringLiteral("totalPriceFullText"), formatRubles(totalPrice)},
        {QStringLiteral("pricePerSquareMeterText"), formatThousands(pricePerSquareMeter)},
        {QStringLiteral("segmentText"), priceBandLabel(totalPrice)},
        {QStringLiteral("summary"),
         QStringLiteral("%1-комн., %2 м², %3, %4 мин до метро")
             .arg(rooms)
             .arg(QString::number(area, 'f', 1))
             .arg(district)
             .arg(metroMinutes)}
    };

    emit lastPredictionChanged();
    emit predictionReady(lastPrediction_);
    emit operationInProgress(false);
}

void PredictionViewModel::trainModel(int epochs, double learningRate)
{
    const int safeEpochs = std::clamp(epochs, 50, 5000);
    const double safeLearningRate = std::clamp(learningRate, 0.0001, 0.05);

    trainingCurve_.clear();
    bestMse_ = -1.0;
    emit trainingCurveChanged();
    emit bestMseChanged();
    emit trainingStarted();

    QtConcurrent::run([this, safeEpochs, safeLearningRate]() {
        adapter->trainModel(safeEpochs, safeLearningRate, [this](int epoch, double mse) {
            QMetaObject::invokeMethod(this, [this, epoch, mse]() {
                trainingCurve_.append(QVariantMap{
                    {QStringLiteral("x"), epoch},
                    {QStringLiteral("y"), mse}
                });
                emit trainingCurveChanged();

                if (bestMse_ < 0.0 || mse < bestMse_) {
                    bestMse_ = mse;
                    emit bestMseChanged();
                }

                emit trainingProgress(epoch, mse);
            }, Qt::QueuedConnection);
        });

        QMetaObject::invokeMethod(this, [this]() {
            emit trainingFinished();
        }, Qt::QueuedConnection);
    });
}

QVariantMap PredictionViewModel::lastPrediction() const
{
    return lastPrediction_;
}

QVariantList PredictionViewModel::marketHighlights() const
{
    return marketHighlights_;
}

QVariantList PredictionViewModel::marketScatter() const
{
    return marketScatter_;
}

QVariantList PredictionViewModel::districtIndices() const
{
    return districtIndices_;
}

QVariantList PredictionViewModel::presets() const
{
    return presets_;
}

QVariantList PredictionViewModel::trainingCurve() const
{
    return trainingCurve_;
}

double PredictionViewModel::bestMse() const
{
    return bestMse_;
}

QString PredictionViewModel::datasetDescription() const
{
    return datasetDescription_;
}

void PredictionViewModel::initializeStaticData()
{
    const CsvTableData &dataset = adapter->dataset();

    double totalPrice = 0.0;
    double minPrice = std::numeric_limits<double>::max();
    double maxPrice = 0.0;
    double totalPricePerSqm = 0.0;

    for (const ApartmentRecord &record : dataset.records) {
        const double area = record.features[0];
        totalPrice += record.price;
        totalPricePerSqm += record.price / area;
        minPrice = std::min(minPrice, record.price);
        maxPrice = std::max(maxPrice, record.price);
    }

    const double sampleCount = static_cast<double>(dataset.records.size());
    const double averagePrice = totalPrice / sampleCount;
    const double averagePricePerSqm = totalPricePerSqm / sampleCount;

    marketHighlights_ = QVariantList{
        makeInsight(QStringLiteral("Записей"), QString::number(dataset.records.size()), QStringLiteral("квартир в выборке")),
        makeInsight(QStringLiteral("Средняя цена"), formatMillions(averagePrice), QStringLiteral("по встроенной базе")),
        makeInsight(QStringLiteral("Средняя цена за м²"), formatThousands(averagePricePerSqm), QStringLiteral("ориентир по выборке")),
        makeInsight(QStringLiteral("Диапазон"), QStringLiteral("%1 - %2").arg(formatMillions(minPrice), formatMillions(maxPrice)), QStringLiteral("от доступного до премиума"))
    };

    const int step = std::max(1, static_cast<int>(dataset.records.size() / 120));
    for (int index = 0; index < static_cast<int>(dataset.records.size()); index += step) {
        const ApartmentRecord &record = dataset.records[static_cast<size_t>(index)];
        marketScatter_.append(QVariantMap{
            {QStringLiteral("x"), record.features[0]},
            {QStringLiteral("y"), record.price / 1000000.0},
            {QStringLiteral("accent"), record.features[11] > 0.5}
        });
    }

    for (const DistrictOption &option : kDistrictOptions) {
        districtIndices_.append(QVariantMap{
            {QStringLiteral("label"), option.label},
            {QStringLiteral("value"), option.index},
            {QStringLiteral("caption"), QStringLiteral("внутренний индекс округа")}
        });
    }

    presets_ = QVariantList{
        makePreset(QStringLiteral("Стартовая 1-комнатная"), 37.0, 1, 6, 14, 11, 2008,
                   QStringLiteral("СВАО"), QStringLiteral("Косметический ремонт"),
                   QStringLiteral("Панель"), false, true, false),
        makePreset(QStringLiteral("Семейная 3-комнатная"), 72.0, 3, 10, 19, 9, 2014,
                   QStringLiteral("ЮЗАО"), QStringLiteral("Евро / дизайнерский"),
                   QStringLiteral("Монолит"), true, true, false),
        makePreset(QStringLiteral("Новый дом у метро"), 58.0, 2, 17, 28, 6, 2022,
                   QStringLiteral("ЗАО"), QStringLiteral("Евро / дизайнерский"),
                   QStringLiteral("Монолит"), true, true, true)
    };

    datasetDescription_ =
        QStringLiteral("Синтетическая выборка из %1 квартир Москвы, откалиброванная под рыночные диапазоны 2023 года.")
            .arg(dataset.records.size());

    lastPrediction_ = QVariantMap{
        {QStringLiteral("isError"), false},
        {QStringLiteral("headline"), QStringLiteral("Оценка ещё не выполнена")},
        {QStringLiteral("totalPriceText"), QStringLiteral("Выберите параметры квартиры")},
        {QStringLiteral("totalPriceFullText"), QStringLiteral("Модель уже инициализирована на базе Москвы 2023")},
        {QStringLiteral("pricePerSquareMeterText"), QStringLiteral("Будет рассчитано после прогноза")},
        {QStringLiteral("segmentText"), QStringLiteral("Используйте пресеты или заполните форму вручную")},
        {QStringLiteral("summary"), datasetDescription_}
    };
}

QVariantMap PredictionViewModel::makeErrorResult(const QString &message) const
{
    return QVariantMap{
        {QStringLiteral("isError"), true},
        {QStringLiteral("headline"), QStringLiteral("Не удалось рассчитать стоимость")},
        {QStringLiteral("totalPriceText"), message},
        {QStringLiteral("totalPriceFullText"), QStringLiteral("Проверьте площадь, этажность и год постройки")},
        {QStringLiteral("pricePerSquareMeterText"), QStringLiteral("Требуются корректные входные данные")},
        {QStringLiteral("segmentText"), QStringLiteral("Исправьте форму и повторите расчёт")},
        {QStringLiteral("summary"), datasetDescription_}
    };
}
