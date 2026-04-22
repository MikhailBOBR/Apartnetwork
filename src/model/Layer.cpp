#include "Matrix.h"
#include "Layer.h"

#include <algorithm>
#include <utility>

Layer::Layer(
    int input_size,
    int output_size,
    std::function<double(double)> activation,
    std::function<double(double)> derivative
)
    : weights(input_size, output_size, true),
      biases(1, output_size),
      activation_function(std::move(activation)),
      derivative_function(std::move(derivative)) {
}

Matrix Layer::forward(const Matrix &input_data)
{
    input = input_data;
    output = Matrix::applyFunction(Matrix::multiply(input, weights) + biases, activation_function);
    return output;
}

Matrix Layer::backward(const Matrix &output_error, double learning_rate)
{
    error = output_error;
    delta = Matrix::elementWiseMultiply(error, Matrix::applyFunction(output, derivative_function));
    Matrix input_error = Matrix::multiply(delta, Matrix::transpose(weights));
    Matrix weights_error = Matrix::multiply(Matrix::transpose(input), delta);
    const double scale = learning_rate / static_cast<double>(std::max(1, input.numRows()));

    weights = weights + weights_error * scale;
    biases = biases + Matrix::sumRows(delta) * scale;
    return input_error;
}
