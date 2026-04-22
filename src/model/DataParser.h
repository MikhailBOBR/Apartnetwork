#ifndef DATA_PARSER_H
#define DATA_PARSER_H

#include <QString>
#include <vector>

#include "Matrix.h"

struct ApartmentRecord {
    double price{};
    std::vector<double> features;
};

struct CsvTableData {
    Matrix X;
    Matrix Y;
    double yMax{};
    double yMin{};
    std::vector<double> meansX;
    std::vector<double> stdDevsX;
    std::vector<QString> featureNames;
    std::vector<ApartmentRecord> records;
};

CsvTableData readCSV(const QString &filename);

#endif // DATA_PARSER_H
