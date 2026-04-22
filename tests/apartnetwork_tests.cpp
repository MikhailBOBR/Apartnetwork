#include <QtTest>

#include "../src/apartmentmodeladapter.h"
#include "../src/model/ApartmentModel.h"
#include "../src/model/DataParser.h"

namespace {

double meanSquaredError(const Matrix &predicted, const Matrix &expected)
{
    double sum = 0.0;
    for (int row = 0; row < predicted.numRows(); ++row) {
        const double diff = predicted.data[row][0] - expected.data[row][0];
        sum += diff * diff;
    }
    return sum / static_cast<double>(predicted.numRows());
}

} // namespace

class ApartnetworkTests : public QObject
{
    Q_OBJECT

private slots:
    void parserLoadsDataset();
    void modelTrainingReducesLoss();
    void adapterRespectsApartmentQuality();
};

void ApartnetworkTests::parserLoadsDataset()
{
    const CsvTableData data = readCSV(QStringLiteral(":/test-assets/moscow_apartments_2023.csv"));

    QCOMPARE(data.X.numCols(), 12);
    QVERIFY(data.X.numRows() >= 700);
    QCOMPARE(data.X.numRows(), data.Y.numRows());
    QCOMPARE(static_cast<int>(data.records.size()), data.X.numRows());
    QVERIFY(data.Y.min() >= 0.0);
    QVERIFY(data.Y.max() <= 1.0);
}

void ApartnetworkTests::modelTrainingReducesLoss()
{
    Matrix input(6, 2);
    input.data = {
        {25.0, 1.0},
        {32.0, 1.0},
        {45.0, 2.0},
        {58.0, 2.0},
        {71.0, 3.0},
        {90.0, 4.0}
    };

    Matrix target(6, 1);
    target.data = {
        {8.5},
        {10.0},
        {14.5},
        {18.0},
        {22.5},
        {29.0}
    };

    ApartmentModel model({2, 6, 1});
    const double mseBefore = meanSquaredError(model.forward(input), target);
    const std::vector<double> history = model.train(input, target, 500, 0.0008, [](int, double) {});
    const double mseAfter = meanSquaredError(model.forward(input), target);

    QVERIFY(!history.empty());
    QVERIFY(mseAfter < mseBefore);
    QVERIFY(history.back() < history.front());
}

void ApartnetworkTests::adapterRespectsApartmentQuality()
{
    ApartmentModelAdapter adapter(QStringLiteral(":/test-assets/moscow_apartments_2023.csv"),
                                  false,
                                  true);

    const std::vector<double> budgetFlat = {
        55.0, 2.0, 3.0, 9.0, 18.0, 245000.0, 0.0, 0.0, 1984.0, 0.0, 0.0, 0.0
    };
    const std::vector<double> premiumFlat = {
        55.0, 2.0, 12.0, 24.0, 6.0, 650000.0, 2.0, 2.0, 2022.0, 1.0, 1.0, 1.0
    };

    const double budgetPrice = adapter.predictPriceValue(budgetFlat);
    const double premiumPrice = adapter.predictPriceValue(premiumFlat);

    QVERIFY(budgetPrice > 0.0);
    QVERIFY(premiumPrice > budgetPrice * 1.8);
}

QTEST_GUILESS_MAIN(ApartnetworkTests)

#include "apartnetwork_tests.moc"
