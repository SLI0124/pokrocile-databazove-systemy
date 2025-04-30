#pragma once

#include <omp.h>
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>

#include "cUniformRandomDouble.h"

using namespace std;

class cVectorDb
{
private:
	double* mData;  // vectors
	int mN;         // the number of vectors
	int mD;         // the space dimension

private:
	void GenerateRandom(int order, UniformRandomDouble& rnd);

public:
	cVectorDb(int d, int n);
	~cVectorDb();

	bool Read(const char *fileName, bool skipFirstLine);

	inline int Count() const;

	double* GetVector(int order);
	void GenerateRandom();

	double EuclideanDistance(int o1, int o2);
	double ParallelEuclideanDistance_reduction(int o1, int o2);
};

inline int cVectorDb::Count() const
{
	return mN;
}