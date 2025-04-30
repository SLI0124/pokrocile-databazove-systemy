#pragma once

#include <iomanip>

#include "cSpRTreeNode.h"
#include "cDynamicMemory.h"

class cPathItem
{
public:
	cSpRTreeNode* Node;
	char* Item;
};

class cSpRTree
{
private:
	int mD;
	int mLeafItemCount;
	int mHeight;
	int mItemSize;
	int mInnerNodeCount;
	int mLeafNodeCount;
	cSpRTreeNode* mRootNode;
	cDynamicMemory* mMemory;

private:
	void InsertFirstItem(double* v);
	void Insert(cSpRTreeItem *item, cSpRTreeNode* oldNode, cSpRTreeItem* oldRegion, cSpRTreeNode* newNode, cSpRTreeItem* newRegion);
	void CreateNewRoot(cSpRTreeItem* oldRegion, cSpRTreeItem* newRegion);

public:
	cSpRTree(int d);
	~cSpRTree();

	bool Insert(double *v);
	bool Find(double* v);
};