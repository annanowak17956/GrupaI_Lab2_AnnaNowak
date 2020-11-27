#include "common/book.h"
#define N 10
/*void add(int *a, int *b, int *c) {
	int tid = 0; //To jest CPU nr zero, a wi�c zaczynamy od zera
	while (tid < N) {
		c[tid] = a[tid] + b[tid];
		tid += 1; // Mamy tylko jeden CPU, a wi�c zwi�kszamy o jeden
	}
}
int main(void) {
	int a[N], b[N], c[N];
	//Zape�nienie tablic a i b danymi za pomoc� CPU
	for (int i = 0; i < N; i++) {
		a[i] = -i;
		b[i] = i * i;
	}
	add(a, b, c);
	// Wy�wietlenie wynik�w
	for (int i = 0; i < N; i++) {
		printf("%d + %d = %d\n", a[i], b[i], c[i]);
	}
	return 0;*/

__global__ void add(int* a, int* b, int* c) {
	int tid = blockIdx.x; // Dzia�anie na danych znajduj�cych si� pod tym indeksem
	if (tid < N)
		c[tid] = a[tid] + b[tid];
}

int main(void) {
	int a[N], b[N], c[N];
	int *dev_a, *dev_b, *dev_c;
	// Alokacja pami�ci na GPU
	HANDLE_ERROR(cudaMalloc((void**)&dev_a, N * sizeof(int)));
	HANDLE_ERROR(cudaMalloc((void**)&dev_b, N * sizeof(int)));
	HANDLE_ERROR(cudaMalloc((void**)&dev_c, N * sizeof(int)));
	//Zape�nienie tablic a i b na CPU
	
	for (int i = 0; i < N; i++) {
		a[i] = -i;
		b[i] = i * i;
	}
	//Kopiowanie tablic a i b do GPU
	HANDLE_ERROR(cudaMemcpy(dev_a, a, N * sizeof(int),
		cudaMemcpyHostToDevice));
	HANDLE_ERROR(cudaMemcpy(dev_b, b, N * sizeof(int),
		cudaMemcpyHostToDevice));
	add<<< N, 1 >>>(dev_a, dev_b, dev_c);
		// Kopiowanie tablicy c z GPU do CPU
		HANDLE_ERROR(cudaMemcpy(c, dev_c, N * sizeof(int),
			cudaMemcpyDeviceToHost));
		// Wy�wietlenie wyniku
		for (int i = 0; i < N; i++) {
			printf("%d + %d = %d\n", a[i], b[i], c[i]);
		}
		// Zwolnienie pami�ci alokowanej na GPU
		cudaFree(dev_a);
		cudaFree(dev_b);
		cudaFree(dev_c);

	return 0;
}