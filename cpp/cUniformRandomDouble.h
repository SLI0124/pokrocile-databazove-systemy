#pragma once

#include <random>

// Returns random double in half-open range [low, high).
// https://stackoverflow.com/questions/2704521/generate-random-double-numbers-in-c
class UniformRandomDouble
{
    std::random_device _rd{};
    std::mt19937 _gen{ _rd() };
    std::uniform_real_distribution<double> _dist;

public:

    UniformRandomDouble() {
        set(0.0, 1.0);
    }

    UniformRandomDouble(double low, double high) {
        set(low, high);
    }

    // Update the distribution parameters for half-open range [low, high).
    void set(double low, double high) {
        std::uniform_real_distribution<double>::param_type param(low, high);
        _dist.param(param);
    }

    double get() {
        return _dist(_gen);
    }
};
