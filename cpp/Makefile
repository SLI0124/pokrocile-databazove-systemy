CXX = g++
CXXFLAGS = -std=c++17 -Wall -g -fopenmp
SRC = cDynamicMemory.cpp cSpRtree.cpp cSpRTreeItem.cpp cSpRTreeNode.cpp cVector.cpp cVectorDb.cpp SpRTree.cpp
OBJ = $(SRC:.cpp=.o)
EXE = main

all: $(EXE)

$(EXE): $(OBJ)
	$(CXX) $(OBJ) -o $(EXE) $(CXXFLAGS)  # Add $(CXXFLAGS) here for linking as well

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

clean:
	rm -f $(OBJ) $(EXE)

.PHONY: all clean
