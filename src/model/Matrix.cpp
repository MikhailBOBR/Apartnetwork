#include "Matrix.h"

#include <QDir>
#include <QFileInfo>
#include <QStandardPaths>

#include <cmath>
#include <fstream>
#include <functional>
#include <random>
#include <sstream>
#include <stdexcept>
#include <string>

namespace {

std::mt19937 &matrixGenerator()
{
    static std::mt19937 generator(2023);
    return generator;
}

QString resolveStoragePath(const std::string &filePath)
{
    const QString candidate = QString::fromStdString(filePath);
    if (QDir::isAbsolutePath(candidate)) {
        return candidate;
    }

    QString baseDirectory = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    if (baseDirectory.isEmpty()) {
        baseDirectory = QDir::currentPath();
    }

    return QDir(baseDirectory).filePath(candidate);
}

void ensureDirectoryExists(const QString &filePath)
{
    QDir directory;
    directory.mkpath(QFileInfo(filePath).absolutePath());
}

} // namespace

Matrix::Matrix() = default;

Matrix::Matrix(int rows, int cols, bool randomize)
{
    data.resize(rows, std::vector<double>(cols, 0.0));
    if (!randomize) {
        return;
    }

    std::normal_distribution<> distribution(0.0, 1.0);
    for (int row = 0; row < rows; ++row) {
        for (int column = 0; column < cols; ++column) {
            data[row][column] = distribution(matrixGenerator()) / std::sqrt(static_cast<double>(rows));
        }
    }
}

int Matrix::numRows() const
{
    return static_cast<int>(data.size());
}

int Matrix::numCols() const
{
    return data.empty() ? 0 : static_cast<int>(data.front().size());
}

std::vector<double> Matrix::mean() const
{
    std::vector<double> means(numCols(), 0.0);
    for (int column = 0; column < numCols(); ++column) {
        for (int row = 0; row < numRows(); ++row) {
            means[column] += data[row][column];
        }
        means[column] /= static_cast<double>(numRows());
    }
    return means;
}

std::vector<double> Matrix::stdDev(const std::vector<double> &means) const
{
    std::vector<double> stdDevs(numCols(), 0.0);
    for (int column = 0; column < numCols(); ++column) {
        for (int row = 0; row < numRows(); ++row) {
            const double diff = data[row][column] - means[column];
            stdDevs[column] += diff * diff;
        }
        stdDevs[column] = std::sqrt(stdDevs[column] / static_cast<double>(numRows()));
    }
    return stdDevs;
}

double Matrix::max() const
{
    double maxValue = data[0][0];
    for (int row = 0; row < numRows(); ++row) {
        for (int column = 0; column < numCols(); ++column) {
            if (data[row][column] > maxValue) {
                maxValue = data[row][column];
            }
        }
    }
    return maxValue;
}

double Matrix::min() const
{
    double minValue = data[0][0];
    for (int row = 0; row < numRows(); ++row) {
        for (int column = 0; column < numCols(); ++column) {
            if (data[row][column] < minValue) {
                minValue = data[row][column];
            }
        }
    }
    return minValue;
}

Matrix Matrix::multiply(const Matrix &a, const Matrix &b)
{
    if (a.numCols() != b.numRows()) {
        throw std::invalid_argument("Matrix dimensions must match for multiplication");
    }

    Matrix result(a.numRows(), b.numCols());
    for (int row = 0; row < result.numRows(); ++row) {
        for (int column = 0; column < result.numCols(); ++column) {
            for (int index = 0; index < a.numCols(); ++index) {
                result.data[row][column] += a.data[row][index] * b.data[index][column];
            }
        }
    }

    return result;
}

Matrix Matrix::applyFunction(const Matrix &matrix, std::function<double(double)> function)
{
    Matrix result(matrix.numRows(), matrix.numCols());
    for (int row = 0; row < matrix.numRows(); ++row) {
        for (int column = 0; column < matrix.numCols(); ++column) {
            result.data[row][column] = function(matrix.data[row][column]);
        }
    }
    return result;
}

Matrix Matrix::operator+(const Matrix &other) const
{
    if (numRows() == other.numRows() && numCols() == other.numCols()) {
        Matrix result(numRows(), numCols());
        for (int row = 0; row < numRows(); ++row) {
            for (int column = 0; column < numCols(); ++column) {
                result.data[row][column] = data[row][column] + other.data[row][column];
            }
        }
        return result;
    }

    if (other.numRows() == 1 && numCols() == other.numCols()) {
        Matrix result(numRows(), numCols());
        for (int row = 0; row < numRows(); ++row) {
            for (int column = 0; column < numCols(); ++column) {
                result.data[row][column] = data[row][column] + other.data[0][column];
            }
        }
        return result;
    }

    if (numRows() == other.numRows() && other.numCols() == 1) {
        Matrix result(numRows(), numCols());
        for (int row = 0; row < numRows(); ++row) {
            for (int column = 0; column < numCols(); ++column) {
                result.data[row][column] = data[row][column] + other.data[row][0];
            }
        }
        return result;
    }

    throw std::invalid_argument("Incompatible matrix dimensions for addition");
}

Matrix Matrix::operator-(const Matrix &other) const
{
    if (numRows() != other.numRows() || numCols() != other.numCols()) {
        throw std::invalid_argument("Matrix dimensions must match for subtraction");
    }

    Matrix result(numRows(), numCols());
    for (int row = 0; row < numRows(); ++row) {
        for (int column = 0; column < numCols(); ++column) {
            result.data[row][column] = data[row][column] - other.data[row][column];
        }
    }
    return result;
}

Matrix Matrix::operator*(double scalar) const
{
    Matrix result(numRows(), numCols());
    for (int row = 0; row < numRows(); ++row) {
        for (int column = 0; column < numCols(); ++column) {
            result.data[row][column] = data[row][column] * scalar;
        }
    }
    return result;
}

Matrix Matrix::elementWiseMultiply(const Matrix &a, const Matrix &b)
{
    if (a.numRows() != b.numRows() || a.numCols() != b.numCols()) {
        throw std::invalid_argument("Matrix dimensions must match for element-wise multiplication");
    }

    Matrix result(a.numRows(), a.numCols());
    for (int row = 0; row < a.numRows(); ++row) {
        for (int column = 0; column < a.numCols(); ++column) {
            result.data[row][column] = a.data[row][column] * b.data[row][column];
        }
    }
    return result;
}

Matrix Matrix::transpose(const Matrix &matrix)
{
    Matrix result(matrix.numCols(), matrix.numRows());
    for (int row = 0; row < matrix.numRows(); ++row) {
        for (int column = 0; column < matrix.numCols(); ++column) {
            result.data[column][row] = matrix.data[row][column];
        }
    }
    return result;
}

Matrix Matrix::sumRows(const Matrix &matrix)
{
    Matrix result(1, matrix.numCols());
    for (int column = 0; column < matrix.numCols(); ++column) {
        double sum = 0.0;
        for (int row = 0; row < matrix.numRows(); ++row) {
            sum += matrix.data[row][column];
        }
        result.data[0][column] = sum;
    }
    return result;
}

void saveMatrix(const Matrix &matrix, const std::string &filename)
{
    const QString filePath = resolveStoragePath(filename);
    ensureDirectoryExists(filePath);

    std::ofstream file(filePath.toStdString());
    if (!file.is_open()) {
        throw std::runtime_error("Unable to open matrix file for writing");
    }

    for (int row = 0; row < matrix.numRows(); ++row) {
        for (int column = 0; column < matrix.numCols(); ++column) {
            file << matrix.data[row][column]
                 << (column == matrix.numCols() - 1 ? "\n" : ",");
        }
    }
}

void loadMatrix(Matrix &matrix, const std::string &filename)
{
    const QString filePath = resolveStoragePath(filename);
    std::ifstream file(filePath.toStdString());
    if (!file.is_open()) {
        return;
    }

    std::string line;
    int row = 0;
    while (std::getline(file, line) && row < matrix.numRows()) {
        std::stringstream stream(line);
        std::string value;
        int column = 0;
        while (std::getline(stream, value, ',') && column < matrix.numCols()) {
            matrix.data[row][column++] = std::stod(value);
        }
        ++row;
    }
}
