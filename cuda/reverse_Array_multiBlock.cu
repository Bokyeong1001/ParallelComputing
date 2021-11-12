#include <stdio.h>

__global__ void reverseArrayMultiBlock(int *d_a, int *d_b) {
    int tid;
    tid = blockIdx.x * blockDim.x + threadIdx.x;
    for(int i =0; i<512; i++){
        d_b[tid * 512 + i] = d_a[blockDim.x * blockDim.x - 1 - tid * 512 - i];
    }
}
// reverse an array using GPU
int main() {
    int *h_a; // pointer for host memory
    int *h_b;
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
    h_b = (int*) malloc(memSize);
    cudaMalloc( (void**) &d_a, memSize );
    cudaMalloc( (void**) &d_b, memSize );
    // initialize host arrays, copy to device
    for (int i = 0; i < dimA; i++) {
        h_a[i] = i;
    }
    cudaMemcpy(d_a, h_a, memSize, cudaMemcpyHostToDevice); 
    // launch kernel
    dim3 dimGrid(nblocks);
    dim3 dimBlock(tpb);
    reverseArrayMultiBlock<<< dimGrid, dimBlock >>>(d_a, d_b);
    // retrieve results
    cudaMemcpy(h_b, d_b, memSize, cudaMemcpyDeviceToHost);
    int error=0;
    for(int i=0;i<dimA;i++){
        if(h_b[i]!=h_a[dimA-1-i]){
            error++;
        }
    }
    printf("%d\n",error);
}