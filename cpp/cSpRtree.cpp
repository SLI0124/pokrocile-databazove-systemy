#include "cSpRTree.h"

cSpRTree::cSpRTree(int d)
{
	mD = d;
	mLeafItemCount = 0;
	mHeight = 0;
	mInnerNodeCount = 0;
	mLeafNodeCount++;

	mItemSize = cSpRTreeItem::GetSize(d);

	mMemory = new cDynamicMemory();
	mRootNode = nullptr;
}

cSpRTree::~cSpRTree()
{
	if (mMemory != nullptr)
	{
		delete mMemory;
		mMemory = nullptr;
	}
}

bool cSpRTree::Insert(double* v)
{
	if (mLeafItemCount == 0) {
		InsertFirstItem(v);
		return true;
	}

	cSpRTreeNode* node = mRootNode;
	cSpRTreeNode* newLeafNode = nullptr, *newInnerNode = nullptr;
	cSpRTreeItem newRegion, oldRegion, region;
	bool split = false;

	// Allocate the stack for the path to the leaf node
	char* m = mMemory->New((mHeight + 1) * sizeof(cPathItem));
	cPathItem* path = new (m)cPathItem[mHeight + 1];

	// Step: Go down: update regions in inner nodes 
	// and insert vector in the leaf node
	for (int l = 0; l <= mHeight; l++)
	{
		path[l].Node = node; // add current node in the path

		if (node->GetInnerNode())
		{
			int order = node->Insert_FindRegion(v, mD);
			path[l].Item = node->GetItem(order); // add current item in the path 
			// read the child node
			node = (cSpRTreeNode*)cSpRTreeItem::GetPointer(node->GetItem(order));
		}
		else
		{
			if (!node->Insert(v, mD))
			{
				// when split appears, create 1 node
				char* mem = mMemory->New(sizeof(cSpRTreeNode));
				newLeafNode = new (mem)cSpRTreeNode(mD, false, mMemory);
				mLeafNodeCount++;

				// and create 3 temporary region items
				newRegion.Init(mD, mMemory);
				oldRegion.Init(mD, mMemory);
				region.Init(mD, mMemory);

				// set the inserted vector into region
				region.Set(v, 0.0, nullptr, mD);

				node->Split(mD, newLeafNode, &oldRegion, &newRegion, mMemory);
				Insert(&region, node, &oldRegion, newLeafNode, &newRegion);

				split = true;
			}
			break;
		}
	}

	if (split)
	{
		// Step: Go down: propagate new regions created during the split
		for (int l = mHeight - 1 ; l >= 0 ; l--)
		{
			node = path[l].Node;
			char* item = path[l].Item;

			oldRegion.SetTo(item, mItemSize); // update the item from the old node

			if (!node->Insert(&newRegion, mD))
			{
				region.SetFrom(&newRegion, mItemSize); // backup the new region
				// create new inner node
				char* mem = mMemory->New(sizeof(cSpRTreeNode));
				newInnerNode = new (mem)cSpRTreeNode(mD, true, mMemory);
				mInnerNodeCount++;

				node->Split(mD, newInnerNode, &oldRegion, &newRegion, mMemory);
				Insert(&region, node, &oldRegion, newInnerNode, &newRegion);

				if (node == mRootNode)
				{
					CreateNewRoot(&oldRegion, &newRegion);
				}
			}
			else {
				break; // split is not propagated? finish the insert
			}
		}
	}

	mMemory->Delete((char*)path);
	region.Delete(mMemory);
	oldRegion.Delete(mMemory);
	newRegion.Delete(mMemory);

	mLeafItemCount++;
	return true;
}

/*
 * When the first item is interted in the tree, create root node and one child leaf node. 
 */
void cSpRTree::InsertFirstItem(double* v)
{
	char* mem = mMemory->New(sizeof(cSpRTreeNode));
	mRootNode = new (mem)cSpRTreeNode(mD, true, mMemory);

	mem = mMemory->New(sizeof(cSpRTreeNode));
	cSpRTreeNode* leafNode = new (mem)cSpRTreeNode(mD, false, mMemory);

	mRootNode->Insert(v, 0.0, leafNode, mD);
	leafNode->Insert(v, mD);

	mHeight = 1;
	mInnerNodeCount++;
	mLeafNodeCount++;
	mLeafItemCount++;
}

/*
 * After split select node where vector is inserted and update the region. 
 */
void cSpRTree::Insert(cSpRTreeItem* item, cSpRTreeNode* oldNode, cSpRTreeItem* oldRegion, cSpRTreeNode* newNode, cSpRTreeItem* newRegion)
{
	// Select the leaf node where vector should be inserted
	double d1 = cVector::EuclideanDistance(oldRegion->GetVector(), item->GetVector(), mD);
	double d2 = cVector::EuclideanDistance(newRegion->GetVector(), item->GetVector(), mD);

	cSpRTreeNode* node = nullptr;
	cSpRTreeItem* region = nullptr;
	double d = 0.0;

	if (d1 < d2)
	{
		node = oldNode;
		region = oldRegion;
		d = d1;
	}
	else {
		node = newNode;
		region = newRegion;
		d = d2;
	}

	node->Insert(item, mD);
	node->ComputeRegion(region, mD); // after insert, recompute the region item
}

/*
 * When the root node is split, create the new root node. 
 */
void cSpRTree::CreateNewRoot(cSpRTreeItem* oldRegion, cSpRTreeItem* newRegion)
{
	char* mem = mMemory->New(sizeof(cSpRTreeNode));
	cSpRTreeNode *n = new (mem)cSpRTreeNode(mD, true, mMemory);

	n->Insert(oldRegion, mD);
	n->Insert(newRegion, mD);
	mRootNode = n;
	mInnerNodeCount++;
	mHeight++;
}

bool cSpRTree::Find(double* v)
{
	int inCount = 0, lnCount = 0;
	bool ret = mRootNode->Find(v, mD, inCount, lnCount);
	return ret;
}
