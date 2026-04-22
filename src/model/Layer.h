//
// Created by User on 18.12.2023.
//

#ifndef LAYER_H
#define LAYER_H
#include "Matrix.h"

#include <functional>


class Layer {
public:
    Matrix weights;
    Matrix biases;
    Matrix output;
    Matrix input;
    Matrix error;
    Matrix delta;

    std::function<double(double)> activation_function;
    std::function<double(double)> derivative_function;

    Layer(int input_size, int output_size, std::function<double(double)> activation, std::function<double(double)> derivative);

    Matrix forward(const Matrix& input_data);

    Matrix backward(const Matrix& output_error, double learning_rate);
};

#endif //LAYER_H
