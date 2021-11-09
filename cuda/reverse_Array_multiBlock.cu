#include <stdio.h>

__global__ void reverseArrayMultiBlock(int *d_a, int *d_b) {
    d_b[blockDim.x - 1 - threadIdx.x] = d_a[threadIdx.x];
}
// reverse an array using GPU
int main() {
    int *h_a; // pointer for host memory
    int *answer;
    int *d_a; // pointer for device input
    int *d_b; // pointer for device output
    int dimA = 1024*1024; // size of array
    // define thread hierarchy
    int nblocks = 2;
    int tpb = 1024;
    // allocate host and device memory
    size_t memSize;
    memSize = dimA * sizeof(int);
    h_a = (int*) malloc(memSize);
    cudaMalloc( (void**) &d_a, memSize );
    cudaMalloc( (void**) &d_b, memSize );
    // initialize host arrays, copy to device
    for (int i = 0; i < dimA; i++) {
        h_a[i] = i;
    }
    answer = (int*) malloc(memSize);
    for(int i=0;i<dimA;i++){
        answer[i]=dimA-i;
    }
    cudaMemcpy(d_a, h_a, memSize, cudaMemcpyHostToDevice); 
    // launch kernel
    dim3 dimGrid(nblocks);
    dim3 dimBlock(tpb);
    reverseArrayMultiBlock<<< dimGrid, dimBlock >>>(d_a, d_b);
    // retrieve results
    cudaMemcpy(h_a, d_b, memSize, cudaMemcpyDeviceToHost);
    int error=0;
    for(int i=0;i<dimA;i++){
        if(answer[i]!=h_a[i]){
            error++;
        }
    }
    printf("%d\n",error);
}