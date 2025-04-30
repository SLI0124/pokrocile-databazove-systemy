#include "cSpRTreeItem.h"

cSpRTreeItem::cSpRTreeItem()
{
	mData = nullptr;
}

cSpRTreeItem::cSpRTreeItem(int d, cDynamicMemory* memory)
{
	Init(d, memory);
}

void cSpRTreeItem::Init(int d, cDynamicMemory* memory)
{
	mData = memory->New(GetSize(d));
}

void cSpRTreeItem::Delete(cDynamicMemory* memory)
{
	if (mData != nullptr)
	{
		memory->Delete(mData);
		mData = nullptr;
	}
}