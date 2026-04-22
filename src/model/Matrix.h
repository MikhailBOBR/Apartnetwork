//
// Created by User on 18.12.2023.
//

#ifndef MATRIX_H
#define MATRIX_H
#include <functional>
#include <string>
#include <vector>


class Matrix {
public:
    std::vector<std::vector<double>> data;

    Matrix();

    Matrix(int rows, int cols, bool randomize = false);

    static Matrix multiply(const Matrix &a, const Matrix &b);

    static Matrix applyFunction(const Matrix &matrix,  std::function<double(double)> function);

    static Matrix elementWiseMultiply(const Matrix& a, const Matrix& b);

    static Matrix transpose(const Matrix& matrix);

    static Matrix sumRows(const Matrix& matrix);

    int numRows() const;
    int numCols() const;

    std::vector<double> mean() const;

    std::vector<double> stdDev(const std::vector<double>& means) const;

    double max() const;

    double min() const;

    Matrix operator+(const Matrix &other) const;

    Matrix operator-(const Matrix& other) const;

    Matrix operator*(double scalar) const;
};

void loadMatrix(Matrix& matrix, const std::string& filename);
void saveMatrix(const Matrix& matrix, const std::string& filename);

#endif //MATRIX_H
