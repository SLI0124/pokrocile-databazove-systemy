#pragma once

#include <string>

class cVector
{
public:
	static void Copy(double* dst, double* src, int d);
	static double EuclideanDistance(double* v1, double* v2, int dim);
	static bool IsInSphere(double* v, double* c, double r, int d);
};