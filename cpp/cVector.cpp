#include "cVector.h"

void cVector::Copy(double* dst, double* src, int d)
{
	memcpy(dst, src, d * sizeof(double));
}

double cVector::EuclideanDistance(double* v1, double* v2, int dim)
{
  // Postup:
  // 1. Projděte oba vektory od 0 do d-1 a počítejte rozdíl 
  //    souřadnic v aktuální dimenzi.
  // 2. Srovnejte výkon pow a násobení rozdílu souřadnic 
  //    pro získání 2. mocniny rozdílu souřadnic.
  // 3. Počítejte součet a po ukončení cyklu odmocněte pomocí sqrt 
  //    a tuto hodnotu vraťte.

  double sum = 0.0;
  // 1.
  for (int i = 0; i < dim; i++)
  {
    // 2.
    double diff = v1[i] - v2[i];
    // Způsob 1: použití násobení pro výkon
    sum += diff * diff;
    
    // Způsob 2: použití pow funkce (pomalejší)
    // sum += pow(diff, 2.0);
  }

  // 3.
  return sqrt(sum);
}

bool cVector::IsInSphere(double* v, double* c, double r, int d)
{
  // Postup: 
  // 1. Spočítejte Euklidovskou vzdálenost mezi vektorem v a středem koule c.
  // 2. Pokud je tato vzdálenost <= poloměr koule r, pak vraťte true, 
  //    jinak vraťte false.

  // 1.
  double dist = EuclideanDistance(v, c, d);
  
  // 2.
  return dist <= r;
}

bool cVector::AreIntersected(double* c1, double r1, double* c2, double r2, int d)
{
  // Postup:
  // 1. Spočítejte Euklidovskou vzdálenost mezi středy koulí c1 a c2
  // 2. Koule se protínají, pokud je vzdálenost mezi středy <= součet poloměrů
  
  // 1.
  double dist = EuclideanDistance(c1, c2, d);
  
  // 2.
  return dist <= (r1 + r2);
}
