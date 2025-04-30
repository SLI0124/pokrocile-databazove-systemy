#include "cDynamicMemory.h"

cDynamicMemory::cDynamicMemory()
{
	mBlock = new char*[BlocksArrayCapacity];
	for (int i = 0; i < BlocksArrayCapacity; i++)
	{
		if (i == 0) {
			mBlock[0] = new char[BlockSize];
		}
		else {
			mBlock[i] = nullptr;
		}
	}
	mCurrentBlock = 0;
	mOrderInBlock = 0;

	mFreeMem = new cFreeMemItem[FreeMemCapacity];
	mFreeMemOrder = 0;
	mMaxSizeMisRatio = 1.1;
	mAdaptRatioStep = 0;

	mDMemStat.Clear();
}

cDynamicMemory::~cDynamicMemory()
{
	for (int i = 0; i < BlocksArrayCapacity; i++)
	{
		if (mBlock[i] != nullptr)
		{
			delete mBlock[i];
			mBlock[i];
		}
	}
	delete[]mBlock;

	if (mFreeMem != nullptr)
	{
		delete mFreeMem;
		mFreeMem = nullptr;
	}
}

char* cDynamicMemory::New(int size)
{
	mDMemStat.NewCount++;

	char* mem = FreeMemSearch(size);

	if (mem == nullptr)
	{
		if (mOrderInBlock + size + MemVarSize >= BlockSize)
		{
			// There is no memory in the current block, allocate the next one
			if (mCurrentBlock >= BlocksArrayCapacity - 1)
			{
				printf("Critical Error: cDynamicMemory::New(): There is no space for another block, size: %d!\n", size);
				return nullptr;
			}
			// Add the rest of the memory in the current block in the FreeMem
			int rest = BlockSize - (mOrderInBlock - MemVarSize);
			char *p = mBlock[mCurrentBlock] + mOrderInBlock;
			*((int*)(p)) = rest;
			p += MemVarSize;
			Delete(p);

			// Start the next block
			mCurrentBlock++;
			mBlock[mCurrentBlock] = new char[BlockSize];
			mOrderInBlock = 0;
			mem = New(size);
		}
		else
		{
			mem = mBlock[mCurrentBlock] + mOrderInBlock;
			*((int*)(mem)) = size; // write the size of the memory
			mem += MemVarSize;
			mOrderInBlock += (size + MemVarSize);
		}
	}
	return mem;
}

void cDynamicMemory::Delete(char* mem)
{
	mDMemStat.DeleteCount++;

	if (mFreeMemOrder >= FreeMemCapacity - 1)
	{
		printf("Critical Error: There is no space for the delete memory, Avg. Size Mis Ratio: %.2f!\n", mDMemStat.SumSizeMisRatio/mDMemStat.NewSizeMisCount);
		return;
	}

	int size = GetSize(mem);
	int i = 0;
	for (; i < mFreeMemOrder; i++)
	{
		if (mFreeMem[i].size > size)
		{
			// the place for the deleted memory found
			break;
		}
	}
	// move items to the right - make a free space for the item
	for (int j = mFreeMemOrder; j > i; j--)
	{
		mFreeMem[j] = mFreeMem[j - 1];
	}
	// set the deleted item
	mFreeMem[i].size = size;
	mFreeMem[i].mem = mem;
	mFreeMemOrder++;
}

/*
 * Try to find a memory <= size in FreeMem. 
 */
char* cDynamicMemory::FreeMemSearch(int size)
{
	char* mem = nullptr;

	if (mFreeMemOrder == 0)
	{
		return mem;
	}

	int lo = 0, hi = mFreeMemOrder;
	int o = -1;

	// use binary search to find the memory
	while (hi > lo)
	{
		int m = (lo + hi) / 2;
		if (size > mFreeMem[m].size)
		{
			lo = m + 1;
		}
		else {
			hi = m;
			o = m;
		}
	}

	float sr = -1.0;
	if (o != -1)
	{
		sr = ((float)mFreeMem[o].size / size);
		if (sr < mMaxSizeMisRatio)
		{
			// Otherwise move items to the left.
			mem = mFreeMem[o].mem;
			for (int i = o; i < mFreeMemOrder - 1; i++)
			{
				mFreeMem[i] = mFreeMem[i + 1];
			}
			mFreeMemOrder--;

			mDMemStat.NewHitCount++;
		}
		else {
			mDMemStat.NewSizeMisCount++;
			mDMemStat.SumSizeMisRatio += sr;
			mAdaptRatioStep++;

			// The half of  FreeMem is full then adapt mMaxSizeMisRatio
			if (mAdaptRatioStep > AdaptRatioStepCount && mFreeMemOrder > FreeMemCapacity / 2)
			{
				float osr = mMaxSizeMisRatio;
				mMaxSizeMisRatio = mDMemStat.SumSizeMisRatio / mDMemStat.NewSizeMisCount;
				printf("cDynamicMemory::FreeMemSearch(): Adapt mMaxSizeMisRatio: %.2f - > %.2f!\n", osr, mMaxSizeMisRatio);
				mAdaptRatioStep = 0;
			}
		}
	}
	return mem;
}

void cDynamicMemory::PrintStat()
{
	int mb = 1024 * 1024;
	printf("----------- cDynamicMemory Statistics ----------\n");
	printf("#Blocks Used: %d\n", (mCurrentBlock + 1));
	printf("Memory [MB]: Allocated: %.2f Used: %.2f\n", ((float)((mCurrentBlock + 1) * BlockSize)) / mb, 
		((float)(mCurrentBlock * BlockSize + mOrderInBlock) / mb));
	printf("FreeMem Count: %d\n", mFreeMemOrder - 1);
	printf("#Count: New: %d, NewHit: %d, Delete: %d\n", mDMemStat.NewCount, mDMemStat.NewHitCount, mDMemStat.DeleteCount);
}