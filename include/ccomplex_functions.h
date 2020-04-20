#ifndef CCOMPLEX_FUNCTIONS_H
#define CCOMPLEX_FUNCTIONS_H
#include "fftw3.h"
#include <complex>


double cabs(const fftw_complex z);


double cabs(const double z);

double cabs(std::complex<double> z);

#endif // !CCOMPLEX_FUNCTIONS_H
