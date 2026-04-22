#include "ApartmentModel.h"

#include <algorithm>

#include "ActivationFunctions.h"

ApartmentModel::ApartmentModel(const std::vector<int> &layer_sizes)
{
    for (size_t i = 0; i < layer_sizes.size() - 2; ++i) {
        layers.emplace_back(layer_sizes[i], layer_sizes[i + 1], relu, relu_derivative);
    }
    layers.emplace_back(layer_sizes[layer_sizes.size() - 2], layer_sizes.back(), linear, linear_derivative);
}

Matrix ApartmentModel::forward(const Matrix &input_data)
{
    Matrix output = input_data;
    for (Layer &layer : layers) {
        output = layer.forward(output);
    }
    return output;
}

void ApartmentModel::backward(const Matrix &y, const Matrix &output, double learning_rate)
{
    Matrix output_error = y - output;
    Matrix error = output_error;
    for (auto it = layers.rbegin(); it != layers.rend(); ++it) {
        error = it->backward(error, learning_rate);
    }
}

std::vector<double> ApartmentModel::train(const Matrix &X,
                                          const Matrix &y,
                                          int epochs,
                                          double learning_rate,
                                          std::function<void(int, double)> updateProgress)
{
    std::vector<double> mses;
    mses.reserve(std::max(epochs, 0));

    const int reportStep = std::max(1, epochs / 40);
    for (int epoch = 1; epoch <= epochs; ++epoch) {
        Matrix output = forward(X);
        backward(y, output, learning_rate);

        const Matrix error = y - output;
        double mse = meanSquaredError(error);
        mses.push_back(mse);

        if (epoch == 1 || epoch == epochs || epoch % reportStep == 0) {
            updateProgress(epoch, mse);
        }
    }

    return mses;
}

double ApartmentModel::meanSquaredError(const Matrix &error)
{
    double sum = 0.0;
    for (int i = 0; i < error.numRows(); ++i) {
        for (int j = 0; j < error.numCols(); ++j) {
            sum += error.data[i][j] * error.data[i][j];
        }
    }
    return sum / (error.numRows() * error.numCols());
}

void ApartmentModel::saveWeights(const std::string &directory) const
{
    for (size_t i = 0; i < layers.size(); ++i) {
        saveMatrix(layers[i].weights, directory + "/weights_layer_" + std::to_string(i) + ".csv");
        saveMatrix(layers[i].biases, directory + "/biases_layer_" + std::to_string(i) + ".csv");
    }
}

void ApartmentModel::loadWeights(const std::string &directory)
{
    for (size_t i = 0; i < layers.size(); ++i) {
        loadMatrix(layers[i].weights, directory + "/weights_layer_" + std::to_string(i) + ".csv");
        loadMatrix(layers[i].biases, directory + "/biases_layer_" + std::to_string(i) + ".csv");
    }
}
