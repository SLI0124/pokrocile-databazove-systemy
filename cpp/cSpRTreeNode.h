#pragma once

#include <string>
#include <cfloat>

#include "cDynamicMemory.h"
#include "cVector.h"
#include "cSpRTreeItem.h"

class cItem
{
public:
	int Order;
	int Dist;
};

int cmp(const void* p, const void* q);

class cSpRTreeNode
{
private:
	char* mData;
	int mItemSize;
	int mCount;
	bool mInnerNode;

	static const int ItemCapacity = 100;

private:

	bool FindInnerNode(double* v, int d, int &inCount, int &lnCount);
	bool FindLeafNode(double* v, int d, int &lnCount);
	
	int RangeQueryInnerNode(double* c, double r, int d, int &resultSize);
	int RangeQueryLeafNode(double* c, double r, int d, int &resultSize);

	void CopyFrom(cSpRTreeNode* node, int d);

public:
	cSpRTreeNode();
	cSpRTreeNode(int d, bool innerNode, cDynamicMemory* memory);

	void Init(int d, bool innerNode, cDynamicMemory* memory);
	void Delete(cDynamicMemory* memory);

	int Insert_FindRegion(double* v, int d);
	bool Insert(double* v, double radius, cSpRTreeNode* child, int d);
	bool Insert(double* v, int d);
	bool Insert(char* item);
	bool Insert(cSpRTreeItem *item, int d);

	bool Find(double* v, int d, int &inCount, int &lnCount);
	int RangeQuery(double* c, double r, int d, int &resultSize);

	void Split(int d, cSpRTreeNode* newNode, cSpRTreeItem* regionOld, cSpRTreeItem* regionNew, cDynamicMemory* memory);

	void ComputeRegion(cSpRTreeItem* item, int d);

	inline char* GetData();
	inline int GetItemSize();
	inline int GetCount();
	inline bool GetInnerNode();
	inline char* GetItem(int order);

	inline void SetInnerNode(bool innerNode);
};

inline char* cSpRTreeNode::GetData()
{
	return mData;
}

inline int cSpRTreeNode::GetItemSize()
{
	return mItemSize;
}

inline int cSpRTreeNode::GetCount()
{
	return mCount;
}

inline bool cSpRTreeNode::GetInnerNode()
{
	return mInnerNode;
}

inline char* cSpRTreeNode::GetItem(int order)
{
	return mData + order * mItemSize;
}

inline void cSpRTreeNode::SetInnerNode(bool innerNode)
{
	mInnerNode = innerNode;
}
