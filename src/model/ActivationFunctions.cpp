//
// Created by User on 18.12.2023.
//

#include "ActivationFunctions.h"

#include <algorithm>

// Activation functions
double relu(double x) {
    return std::max(0.0, x);
}

double relu_derivative(double x) {
    return x > 0 ? 1.0 : 0.0;
}

double linear(double x) {
    return x;
}

double linear_derivative(double x) {
    return 1.0;
}
