#include <stdio.h>
#include <math.h>
#include <vector>

#include "template_math_cpp.h"
#include "fftw3.h"


#include "mtpsd.h"

#ifndef PI
#define PI 3.14159265
#endif




int main( int argc, const char* argv[] ) {
	
	double f = 20.0;
	double w = 2*PI*f;
	const uint_t n = 200;
	std::vector<double> x(n);
	//double *x = new double[n];
	
	for(size_t i=0; i<n; i++) {
		x.at(i) = sin(i*w/n);
		printf("%f \t %f \n", ((double)i)/n , x.at(i));
	}
	printf("\n");
	printf("\n");

	mtpsd<double> spectrum(x.data(), n, 1.5);
	try {
		spectrum.compute();
	} catch (ERR e) {
		printf("ERROR: %s\n", e.getmsg());
	}

	for (uint_t i=0; i<n; i++) {
		printf("%f \t %f \n", spectrum.freq(i), spectrum(i));
	}
	
}
