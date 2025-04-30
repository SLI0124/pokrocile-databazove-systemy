#include "cSpRTreeNode.h"

int cmp(const void* i1, const void* i2)
{
	int ret = 0;
	double d1 = ((cItem*)i1)->Dist;
	double d2 = ((cItem*)i2)->Dist;

	if (d1 < d2) {
		ret = -1;
	}
	else if (d1 > d2) {
		ret = 1;
	}
	return ret;
}

cSpRTreeNode::cSpRTreeNode()
{
	mData = nullptr;
}

cSpRTreeNode::cSpRTreeNode(int d, bool innerNode, cDynamicMemory *memory)
{
	Init(d, innerNode, memory);
}

void cSpRTreeNode::Init(int d, bool innerNode, cDynamicMemory* memory)
{
	mInnerNode = innerNode;
	mItemSize = cSpRTreeItem::GetSize(d);
	int dataSize = mItemSize * ItemCapacity;
	char* mem = memory->New(dataSize);
	mData = new (mem)char[mItemSize * ItemCapacity];
	mCount = 0;
}


void cSpRTreeNode::Delete(cDynamicMemory* memory)
{
	if (mData != nullptr)
	{
		memory->Delete(mData);
		mData = nullptr;
	}
}

bool cSpRTreeNode::Find(double* v, int d, int &inCount, int &lnCount)
{
	if (mInnerNode)	{
		return FindInnerNode(v, d, inCount, lnCount);
	}
	else {
		return FindLeafNode(v, d, lnCount);
	}
}

bool cSpRTreeNode::Insert(double* v, int d)
{
	bool ret = true;
	if (mCount < ItemCapacity)
	{
		char* item = GetItem(mCount);
		cSpRTreeItem::SetVector(item, v, d);
		cSpRTreeItem::SetRadius(item, 0.0);
		mCount++;
	}
	else {
		ret = false;
	}
	return ret;
}

bool cSpRTreeNode::Insert(double* v, double r, cSpRTreeNode* child, int d)
{
	bool ret = true;
	if (mCount < ItemCapacity)
	{
		char* item = GetItem(mCount);
		cSpRTreeItem::SetVector(item, v, d);
		cSpRTreeItem::SetRadius(item, r);
		cSpRTreeItem::SetPointer(item, (char*)child);
		mCount++;
	}
	else {
		ret = false;
	}
	return ret;
}

bool cSpRTreeNode::Insert(cSpRTreeItem* item, int d)
{
	bool ret = true;
	if (mCount < ItemCapacity)
	{
		char* it = GetItem(mCount);
		item->SetTo(it, mItemSize);
		mCount++;
	}
	else {
		ret = false;
	}
	return ret;
}

bool cSpRTreeNode::Insert(char* item)
{
	bool ret = true;
	if (mCount < ItemCapacity)
	{
		char* i = GetItem(mCount);
		memcpy(i, item, mItemSize);
		mCount++;
	}
	else {
		ret = false;
	}
	return ret;
}

bool cSpRTreeNode::FindInnerNode(double* v, int d, int &inCount, int& lnCount)
{
  // Postup:
  // 1. Inkrementace proměnné inCount, která značí kolik vnitřních uzlů 
  //    bylo během zpracování dotazu zpracováno.
  // 2. Průchod všemi položkami uzlu od 0 do mCount a volání metody
  //    cVector::IsInSphere() pro vektor v a region položky uzlu.
  //   Využijte metody:
  //   - GetItem(i) - získání i. položky uzlu
  //   - cSpRTreeItem::GetVector() - získání vektoru double* (středu 
  //       d-rozměrné koule) z položky uzlu
  //   - cSpRTreeItem::GetRadius() - získání poloměru regionu (d-rozměrné
  //       koule) z položky uzlu
  // 3. Pokud cVector::IsInSphere() vrátí true, pak získejte z položky uzlu
  //    ukazatel cSpRTreeItem::GetPointer(), přetypujte na cSpRTreeNode*
  //    a pro takto získaný ukazatel na potomka zavolejte metodu Find().
  // 4. Pokud Find() vrátí true, nastavte návratovou hodnotu na true 
  //    a metodu ukončete.

  // 1.
  inCount++;

  // 2.
  for (int i = 0; i < mCount; i++)
  {
	double* v2 = cSpRTreeItem::GetVector(GetItem(i));
	double r = cSpRTreeItem::GetRadius(GetItem(i));
	if (cVector::IsInSphere(v, v2, r, d))
	{
	  // 3.
	  cSpRTreeNode* child = (cSpRTreeNode*)cSpRTreeItem::GetPointer(GetItem(i));
	  // 4.
	  if (child->Find(v, d, inCount, lnCount))
	  {
		return true;
	  }
	}
  }

  return false;
}

bool cSpRTreeNode::FindLeafNode(double* v, int d, int &lnCount)
{
  // Postup:
  // 1. Inkrementace proměnné lnCount, která značí kolik listových uzlů 
  //    bylo během zpracování dotazu zpracováno.
  // 2. Průchod všemi položkami uzlu (vectory) od 0 do mCount a volání
  //    metody cVector::IsInSphere() pro vektor v vektor položky uzlu.
  //   Využijte metody:
  //   - GetItem(i) - získání i. položky uzlu
  //   - cSpRTreeItem::GetVector() - získání vektoru double* z položky uzlu
  // 3. Pokud cVector::IsInSphere() vrátí true, pak nastavte návratovou
  //    hodnotu na true a metodu ukončete.

  // 1.
  lnCount++;

  // 2.
  for (int i = 0; i < mCount; i++)
  {
	double* v2 = cSpRTreeItem::GetVector(GetItem(i));
	if (cVector::IsInSphere(v, v2, cSpRTreeItem::GetRadius(GetItem(i)), d))
	{
	  // 3.
	  return true;
	}
  }

  return false;
}

/*
 * Node split: half items are moved to newNode, others remains in this node. 
 * Region items, oldRegion and newRegion, are set for both nodes.
 */
void cSpRTreeNode::Split(int d, cSpRTreeNode* newNode, cSpRTreeItem* oldRegion, cSpRTreeItem* newRegion, cDynamicMemory* memory)
{
	double* v1 = cSpRTreeItem::GetVector(GetItem(0));

	// First Step: compute the most distance vector - pivot
	double maxDist = 0.0;
	int maxDistOrder = 0;
	for (int i = 1; i < mCount; i++)
	{
		double *v2 = cSpRTreeItem::GetVector(GetItem(i));
		double dist = cVector::EuclideanDistance(v1, v2, d);
		if (dist > maxDist)
		{
			maxDist = dist;
			maxDistOrder = i;
		}
	}

	// Second Step: the half most close vectors to the pivot
	// build one node, other vectors build the second node
	char* pivotItem = GetItem(maxDistOrder);
	double* pivotVector = cSpRTreeItem::GetVector(pivotItem);

	char* m = memory->New((mCount - 1) * sizeof(cItem));
	cItem* itemArray = new (m)cItem[mCount - 1];
	int cnt = 0;

	for (int i = 0; i < mCount; i++)
	{
		if (i == maxDistOrder)
		{
			continue;
		}
		double* v2 = cSpRTreeItem::GetVector(GetItem(i));
		double dist = cVector::EuclideanDistance(pivotVector, v2, d);
		itemArray[cnt].Order = i;
		itemArray[cnt].Dist = dist;
		cnt++;
	}
	// sort the array
	qsort(itemArray, mCount - 1, sizeof(cItem), cmp);

	// create a temporary node
	cSpRTreeNode oldNode;
	oldNode.Init(d, GetInnerNode(), memory);

	int halfCount = mCount / 2 - 1;
	// copy the closest vectors
	for (int i = 0; i < halfCount; i++)
	{
		newNode->Insert(GetItem(itemArray[i].Order));
	}
	// and add the pivot
	newNode->Insert(pivotItem);

	// copy the most distance vectors
	for (int i = halfCount; i < mCount - 1; i++)
	{
		oldNode.Insert(GetItem(itemArray[i].Order));
	}

	// now copy ln2 back to this node
	CopyFrom(&oldNode, d);

	// build region items for both nodes
	ComputeRegion(oldRegion, d);
	newNode->ComputeRegion(newRegion, d);

	memory->Delete((char*)itemArray);
	oldNode.Delete(memory);
}

void cSpRTreeNode::CopyFrom(cSpRTreeNode* n, int d)
{
	mCount = n->GetCount();
	mInnerNode = n->GetInnerNode();
	mItemSize = n->GetItemSize();
	memcpy(mData, n->GetData(), mCount * mItemSize);
}

/*
 * Find the region where the vector should be inserted.
 * If necessary, update radius of the region.
 * Returns the order of the region.
 */
int cSpRTreeNode::Insert_FindRegion(double* v, int d)
{
	double minDist = DBL_MAX;
	int minDistOrder = 0;

	// First step: find the region
	for (int i = 0; i < mCount; i++)
	{
		double* v2 = cSpRTreeItem::GetVector(GetItem(i));
		double dist = cVector::EuclideanDistance(v, v2, d);
		if (dist < minDist)
		{
			minDist = dist;
			minDistOrder = i;
		}
	}
	// Second step: update the radius of the region
	double r = cSpRTreeItem::GetRadius(GetItem(minDistOrder));
	if (r < minDist)
	{
		cSpRTreeItem::SetRadius(GetItem(minDistOrder), minDist);
	}
	return minDistOrder;
}

/*
 * Compute region for the node and set pointer in the region item to the node.
 */
void cSpRTreeNode::ComputeRegion(cSpRTreeItem* region, int d)
{
	// First step: compute center of the region as the arithmetic mean of all vectors
	double* rV = region->GetVector();
	for (int i = 0; i < d; i++)
	{
		rV[i] = 0;
		for (int j = 0; j < mCount; j++)
		{
			rV[i] += cSpRTreeItem::GetVector(GetItem(j))[i];
		}
		rV[i] /= mCount;
	}

	// Second step: compute radius r to match all vectors to the region
	double rR = 0.0;
	for (int i = 0; i < mCount; i++)
	{
		double* v = cSpRTreeItem::GetVector(GetItem(i));
		double r = cSpRTreeItem::GetRadius(GetItem(i));
		double dist = cVector::EuclideanDistance(rV, v, d) + r;
		if (dist > rR)
		{
			rR = dist;
		}
	}
	region->SetRadius(rR);
	region->SetPointer((char*)this);
}