#pragma once

#include <stdio.h>

class cDMemStat
{
public:
	int NewCount;
	int DeleteCount;
	int NewHitCount;
	int NewSizeMisCount;
	double SumSizeMisRatio;

	void Clear() 
	{
		NewCount = 0;
		DeleteCount = 0;
		NewHitCount = 0;
		NewSizeMisCount = 0;
		SumSizeMisRatio = 0.0;
	}
};

struct cFreeMemItem
{
	int size;
	char* mem;
};

class cDynamicMemory
{
	char** mBlock;
	cFreeMemItem* mFreeMem;

	static const int BlockSize = 1000000;
	static const int BlocksArrayCapacity = 1000;
	static const int FreeMemCapacity = 10000;
	static const int MemVarSize = 4;
	static const int AdaptRatioStepCount = FreeMemCapacity / 2;

	int mCurrentBlock;
	int mOrderInBlock;
	int mFreeMemOrder;
	float mMaxSizeMisRatio;
	int mAdaptRatioStep;

	cDMemStat mDMemStat;

private:
	char* FreeMemSearch(int size);

public:
	cDynamicMemory();
	~cDynamicMemory();

	void Delete(char* mem);
	char* New(int size);

	static inline int GetSize(char* mem);

	void PrintStat();
};

inline int cDynamicMemory::GetSize(char* mem)
{
	return *((int*)(mem - MemVarSize));
}