#include "ccomplex_functions.h"
#include <cmath>

double cabs(const fftw_complex z) {
    return std::sqrt(z[0] * z[0] + z[1] * z[1]);
}


double cabs(const double z) {
    return std::abs(z);
}


double cabs(std::complex<double> z) {
    return std::abs(z);
}