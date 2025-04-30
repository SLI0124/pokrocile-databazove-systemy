#pragma once

#include <string.h>

#include "cDynamicMemory.h"

class cSpRTreeItem
{
private:
	char* mData;

	static const int Offset_Radius = 0;
	static const int Offset_Pointer = sizeof(double);
	static const int Offset_Vector = Offset_Pointer + sizeof(char*);

public:
	cSpRTreeItem();
	cSpRTreeItem(int d, cDynamicMemory* memory);

	void Init(int d, cDynamicMemory* memory);
	void Delete(cDynamicMemory* memory);

	inline static int GetSize(int d);

	inline char* GetData();

	inline double GetRadius();
	inline char* GetPointer();
	inline double* GetVector();

	inline void Set(double* v, double r, char* p, int d);
	inline void SetFrom(cSpRTreeItem *item, int itemSize);
	inline void SetTo(char* item, int itemSize);

	inline void SetRadius(double r);
	inline void SetPointer(char* p);
	inline void SetVector(double *v, int d);

	inline static double GetRadius(char* data);
	inline static char* GetPointer(char* data);
	inline static double* GetVector(char* data);

	inline static void SetRadius(char* data, double r);
	inline static void SetPointer(char* data, char* p);
	inline static void SetVector(char* data, double* v, int d);
};

inline char* cSpRTreeItem::GetData()
{
	return mData;
}

inline int cSpRTreeItem::GetSize(int d)
{
	return Offset_Vector + sizeof(double) * d;
}

inline double cSpRTreeItem::GetRadius()
{
	return GetRadius(mData);
}

inline double cSpRTreeItem::GetRadius(char* data)
{
	return *((double*)data + Offset_Radius);
}

inline char* cSpRTreeItem::GetPointer()
{
	return GetPointer(mData);
}

inline char* cSpRTreeItem::GetPointer(char* data)
{
	char** p = (char**)(data + Offset_Pointer);
	return *p;
}

inline double* cSpRTreeItem::GetVector()
{
	return GetVector(mData);
}

inline double* cSpRTreeItem::GetVector(char* data)
{
	return (double*)(data + Offset_Vector);
}

// Set this from the item.
inline void cSpRTreeItem::SetFrom(cSpRTreeItem* item, int itemSize)
{
	memcpy(mData, item->GetData(), itemSize);
}

inline void cSpRTreeItem::Set(double*v, double r, char* p, int d)
{
	SetVector(v, d);
	SetRadius(r);
	SetPointer(p);
}

// Set this to the item.
inline void cSpRTreeItem::SetTo(char* item, int itemSize)
{
	memcpy(item, mData, itemSize);
}

inline void cSpRTreeItem::SetRadius(double r)
{
	SetRadius(mData, r);
}

inline void cSpRTreeItem::SetRadius(char* data, double r)
{
	*((double*)data + Offset_Radius) = r;
}

inline void cSpRTreeItem::SetPointer(char* p)
{
	SetPointer(mData, p);
}

inline void cSpRTreeItem::SetPointer(char* data, char* p)
{
	char** tp = (char**)(data + Offset_Pointer);
	*tp = p;
}

inline void cSpRTreeItem::SetVector(double* v, int d)
{
	SetVector(mData, v, d);
}

inline void cSpRTreeItem::SetVector(char* data, double* v, int d)
{
	memcpy(data + Offset_Vector, (char*)v, sizeof(double) * d);
}


