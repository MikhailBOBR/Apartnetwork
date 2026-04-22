//
// Created by User on 18.12.2023.
//

#ifndef APARTMENTMODEL_H
#define APARTMENTMODEL_H
#include <string>
#include <vector>

#include "Layer.h"
#include "Matrix.h"


class ApartmentModel {
public:
    std::vector<Layer> layers;

    explicit ApartmentModel(const std::vector<int>& layer_sizes);

    Matrix forward(const Matrix& input_data);

    void backward(const Matrix& y, const Matrix& output, double learning_rate);
    std::vector<double> train(const Matrix& X, const Matrix& y, int epochs, double learning_rate, std::function<void(int, double)> updateProgress);

    void saveWeights(const std::string& directory) const;
    void loadWeights(const std::string& directory);
private:
    static double meanSquaredError(const Matrix& error);
};




#endif //APARTMENTMODEL_H
