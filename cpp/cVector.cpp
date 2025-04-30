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
}

bool cVector::IsInSphere(double* v, double* c, double r, int d)
{
  // Postup: 
  // 1. Spočítejte Euklidovskou vzdálenost mezi vektorem v a středem koule c.
  // 2. Pokud je tato vzdálenost <= poloměr koule r, pak vraťte true, 
  //    jinak vraťte false.
}
