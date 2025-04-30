#include "cVectorDb.h"

cVectorDb::cVectorDb(int d, int n)
{
	mData = new double[d * n];
	mD = d;
	mN = n;
}

cVectorDb::~cVectorDb()
{
	if (mData != nullptr)
	{
		delete mData;
		mData = nullptr;
	}
}

bool cVectorDb::Read(const char *fileName, bool skipFirstLine)
{
	std::ifstream data(fileName);
	std::string line;

	if (skipFirstLine)
	{
		std::getline(data, line);
	}

	for (int i = 0; i < mN; i++)
	{
		std::getline(data, line);
		std::stringstream lineStream(line);
		std::string cell;
		double* p = mData + i * mD;

		while (std::getline(lineStream, cell, ','))
		{
			*p = stod(cell);
			p++;
		}
	}
	return true;
}

double cVectorDb::EuclideanDistance(int o1, int o2)
{
	double x = 0;
	double *v1, *v2;
	v1 = GetVector(o1);
	v2 = GetVector(o2);
	for (int i = 0; i < mD; i++)
	{
		x += pow((v1[i] - v2[i]), 2);
	}
	return sqrt(x);
}

double cVectorDb::ParallelEuclideanDistance_reduction(int o1, int o2)
{
	double d = 0.0;
	double* v1, * v2;
	v1 = GetVector(o1);
	v2 = GetVector(o2);
	#pragma omp parallel for reduction(+:d)
	for (int i = 0; i < mD; i++)
	{
		d += pow((v1[i] - v2[i]), 2);
	}
	d = sqrt(d);
	return d;
}

void cVectorDb::GenerateRandom(int order, UniformRandomDouble& rnd)
{
	double* vector = GetVector(order);
	for (int i = 0; i < mD; i++)
	{
		vector[i] = rnd.get();
	}
}

double* cVectorDb::GetVector(int order)
{
	return mData + (mD * order);
}

void cVectorDb::GenerateRandom()
{
	UniformRandomDouble rnd;
	rnd.set(0, 1);
	for (int i = 0; i < mN; i++)
	{
		GenerateRandom(i, rnd);
	}
}

