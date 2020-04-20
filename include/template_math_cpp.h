#ifndef TEMPLATE_MATH_CPP_H
#define TEMPLATE_MATH_CPP_H

#include "fftw3.h"
#include "template_math.h"


namespace tmath {
    // pointwise multiplication
    template <> 
    void pw_mult<fftw_complex, double>
        (const fftw_complex* a, const double* b, unsigned int n, fftw_complex* ab);

    //scale by a double value
    template <>
    void scale<fftw_complex>
        (const fftw_complex* a, double b, unsigned int n, fftw_complex* ab);
}


#endif // !TEMPLATE_MATH_CPP_H
