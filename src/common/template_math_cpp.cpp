#include "template_math_cpp.h"


namespace tmath {
    // pointwise multiplication
    template <>
    void pw_mult<fftw_complex, double>
        (const fftw_complex* a, const double* b, unsigned int n, fftw_complex* ab) {

        for (unsigned int ii = 0; ii < n; ii++) {
            ab[ii][0] = a[ii][0] * b[ii];
            ab[ii][1] = a[ii][1] * b[ii];
        }
    }

    //scale by a double value
    template <>
    void scale<fftw_complex>
        (const fftw_complex* a, double b, unsigned int n, fftw_complex* ab) {
        for (unsigned int ii = 0; ii < n; ii++) {
            ab[ii][0] = a[ii][0] * b;
            ab[ii][1] = a[ii][1] * b;
        }
    }
}