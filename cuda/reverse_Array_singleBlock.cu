#include <stdio.h>
__global__ void initArray(int *A, int *B) {
    int tid;
    tid = blockIdx.x * blockDim.x + threadIdx.x;
    B[tid] = A[blockDim.x - 1 - tid];
}
// initialize an array using GPU 
int main() {
    int *h_a; // pointer for host memory
    int *h_b; // pointer for host memory
    int *d_a; // pointer for device memory
    int *d_b; // pointer for device memory
    // define thread hierarchy
    int num_blocks = 1;
    int num_th_per_blk = 256;
    // allocate host and device memory
    size_t memSize;
    memSize = num_blocks * num_th_per_blk * sizeof(int);
    h_a = (int*) malloc(memSize);
    h_b = (int*) malloc(memSize);
    for(int i=0;i<num_th_per_blk;i++){
        h_a[i]=i;
    }

    cudaMalloc( (void**) &d_a, memSize);
    cudaMalloc( (void**) &d_b, memSize);
    cudaMemcpy(d_a, h_a, memSize, cudaMemcpyHostToDevice); 
    // launch kernel
    dim3 dimGrid(num_blocks);
    dim3 dimBlock(num_th_per_blk);
    initArray<<< dimGrid, dimBlock >>>(d_a,d_b);
    // retrieve results
    cudaMemcpy(h_b, d_b, memSize, cudaMemcpyDeviceToHost) ; 
    int error=0;
    for(int i=0;i<num_th_per_blk;i++){
        if(h_b[i]!=h_a[num_th_per_blk-1-i]){
            error++;
        }
    }
    printf("%d\n",error);
}