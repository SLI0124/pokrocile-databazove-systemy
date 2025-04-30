#include <iostream>
#include <chrono>

#include "cVectorDb.h"
#include "cSpRTree.h"

using namespace std;

void ReadDatafile(cVectorDb* vectorDb, const char* dataFilename);
void BuildSpRTree(cVectorDb* vectorDb, cSpRTree* spRtree);
float SequentialScanTest(cVectorDb* vectorDb, int d);
float PointQueryTest(cVectorDb* vectorDb, cSpRTree* spRtree);
void RangeQueryTest(cVectorDb* vectorDb, cSpRTree* spRTree, int d);

int main()
{
    int n = 1000000;   // 10000 for mnist_test.csv
    int d = 11;        // 28 * 28 + 1 for mnist_test.csv
    const char* dataFilename = "poker.csv";

    cVectorDb vectorDb(d, n);
    cSpRTree spRTree(d);

    cout << "d=" << d << ", n=" << n << endl;

    ReadDatafile(&vectorDb, dataFilename);
    BuildSpRTree(&vectorDb, &spRTree);
    float seqScanThr = SequentialScanTest(&vectorDb, d);
    float pqThr = PointQueryTest(&vectorDb, &spRTree);

    cout << "Throughput ratio: " << (pqThr / seqScanThr) << "x" << endl;

    // Run range query tests
    RangeQueryTest(&vectorDb, &spRTree, d);

    return 0;
}

void ReadDatafile(cVectorDb* vectorDb, const char* dataFilename)
{
    cout << "Reading the data file: " << dataFilename << " ... ";
    auto start = chrono::steady_clock::now();

    vectorDb->Read(dataFilename, true);

    auto end = chrono::steady_clock::now();
    cout << "Time [ms]: " << chrono::duration_cast<chrono::milliseconds>(end - start).count() << endl;
}

void BuildSpRTree(cVectorDb* vectorDb, cSpRTree *spRTree)
{
    cout << "Building SpRTree ... ";
    auto start = chrono::steady_clock::now();

    for (int j = 0; j < vectorDb->Count(); j++)
    {
        double* v = vectorDb->GetVector(j);
        spRTree->Insert(v);
        /*
        // For test purpose only
        if (!spRtree->Find(v))
        {
            printf("Critical Error: Insert vector is not found in the SphereRTree!\n");
        */
    }

    auto end = chrono::steady_clock::now();
    cout << "Time [ms]: " << chrono::duration_cast<chrono::milliseconds>(end - start).count() << endl;
}

float SequentialScanTest(cVectorDb* vectorDb, int d)
{
    bool find;
    int scanCount = 0;
    auto start = chrono::steady_clock::now();

    std::cout << std::fixed;
    std::cout << std::setprecision(1);

    for (int i = 0; i < vectorDb->Count(); i += 300)
    {
        if (i % 1000 == 0) {
            cout << "Array Sequential Scan Test: #Scans: " << scanCount << ", Rate: " << (((float)i / vectorDb->Count()) * 100) << "% ... \r";
        }

        double* u = vectorDb->GetVector(i);
        find = false;

        for (int j = 0; j < vectorDb->Count(); j++)
        {
            double* v = vectorDb->GetVector(j);

            if (cVector::IsInSphere(u, v, 0.0, d))
            {
                find = true;
                break;
            }
        }
        scanCount++;

        if (!find)
        {
            cout << "Critical Error: Sequential Array: the vector of the order " << i << " is not found!" << endl;
        }
    }

    auto end = chrono::steady_clock::now();
    int procTime = chrono::duration_cast<chrono::milliseconds>(end - start).count();
    float seqScanThr = ((float)scanCount / ((float)procTime / 1000));

    cout << "Array Sequential Scan Test: #Scans: " << scanCount << ", Time [ms]: " << procTime << 
        ", Throughput [ops/s]: " << seqScanThr << endl;

    return seqScanThr;
}

float PointQueryTest(cVectorDb* vectorDb, cSpRTree* spRTree)
{
    int pqCount = 0;
    auto start = chrono::steady_clock::now();

    for (int i = 0; i < vectorDb->Count(); i += 10)
    {
        if (i % 1000 == 0) {
            cout << "SpRTree Point Query Test: #Queries: " << pqCount << ", Rate: " << (((float)i / vectorDb->Count()) * 100) << "% ... \r";
        }

        double* v = vectorDb->GetVector(i);
        if (!spRTree->Find(v))
        {
            cout << "Critical Error: SpRTree:: Find(): the vector of the order " << i << " is not found!" << endl;
        }

        pqCount++;
    }

    auto end = chrono::steady_clock::now();
    int procTime = chrono::duration_cast<chrono::milliseconds>(end - start).count();
    float pqThr = ((float)pqCount / ((float)procTime / 1000));

    cout << "SpRTree Point Query Test: #Queries: " << pqCount << ", Time [ms]: " << procTime <<
        ", Throughput [ops/s]: " << pqThr << endl;

    return pqThr;
}

void RangeQueryTest(cVectorDb* vectorDb, cSpRTree* spRTree, int d)
{
    cout << "\nRunning Range Query Tests with varying radius\n";
    cout << "----------------------------------------------\n";
    
    // Number of test queries
    const int numQueries = 100;
    
    // Initial radius and other parameters
    double radius = 11.0;
    bool thresholdFound = false;
    double prevRatio = 0.0;
    double incrementValue = 0.1;
    
    // Select random vectors from the database for our query centers
    vector<int> queryIndices;
    for (int i = 0; i < vectorDb->Count(); i += vectorDb->Count() / numQueries) {
        queryIndices.push_back(i);
    }
    
    // Make sure we have exactly numQueries indices
    while (queryIndices.size() > numQueries) {
        queryIndices.pop_back();
    }
    
    cout << fixed << setprecision(2);
    cout << "Radius\tAvg Result Size\tSpRTree Time (ms)\tSeq Scan Time (ms)\tRatio\n";
    
    // Continue testing until we find the threshold where SpRTree becomes slower
    while (!thresholdFound) {
        int totalResultSize = 0;
        
        // Test SpRTree range query
        auto spRTreeStart = chrono::steady_clock::now();
        for (int i = 0; i < queryIndices.size(); i++) {
            double* queryCenter = vectorDb->GetVector(queryIndices[i]);
            int resultSize = 0;
            spRTree->RangeQuery(queryCenter, radius, resultSize);
            totalResultSize += resultSize;
        }
        auto spRTreeEnd = chrono::steady_clock::now();
        int spRTreeTime = chrono::duration_cast<chrono::milliseconds>(spRTreeEnd - spRTreeStart).count();
        
        // Test sequential scan for the same queries
        auto seqScanStart = chrono::steady_clock::now();
        for (int i = 0; i < queryIndices.size(); i++) {
            double* queryCenter = vectorDb->GetVector(queryIndices[i]);
            int count = 0;
            
            // Scan the entire database
            for (int j = 0; j < vectorDb->Count(); j++) {
                double* v = vectorDb->GetVector(j);
                if (cVector::IsInSphere(v, queryCenter, radius, d)) {
                    count++;
                }
            }
        }
        auto seqScanEnd = chrono::steady_clock::now();
        int seqScanTime = chrono::duration_cast<chrono::milliseconds>(seqScanEnd - seqScanStart).count();
        
        double avgResultSize = (double)totalResultSize / numQueries;
        double ratio = (double)spRTreeTime / seqScanTime;
        
        cout << radius << "\t" << avgResultSize << "\t\t" 
             << spRTreeTime << "\t\t\t" << seqScanTime << "\t\t\t" 
             << ratio << (ratio > 1.0 ? " (SpRTree slower)" : "") << endl;
        
        // If SpRTree is slower than sequential scan, we've found our threshold
        if (ratio > 1.0 && prevRatio < 1.0) {
            cout << "\nThreshold found: When radius = " << radius 
                 << " with average result size " << avgResultSize 
                 << ", the SpRTree range query becomes slower than sequential scan." << endl;
            thresholdFound = true;
        }
        
        prevRatio = ratio;
        radius += incrementValue;
    }

    cout << "----------------------------------------------\n";
    cout << "Final threshold radius: " << radius - incrementValue << endl;
}