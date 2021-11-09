#include <stdio.h>
__global__ void initArray(int *A) {
    int tid;
    tid = blockIdx.x * blockDim.x + threadIdx.x;
    A[tid] = blockDim.x - tid;
}
// initialize an array using GPU 
int main() {
    int *h_a; // pointer for host memory
    int *answer;
    int *d_a; // pointer for device memory
    // define thread hierarchy
    int num_blocks = 1;
    int num_th_per_blk = 256;
    // allocate host and device memory
    size_t memSize;
    memSize = num_blocks * num_th_per_blk * sizeof(int);
    h_a = (int*) malloc(memSize);
    answer = (int*) malloc(memSize);
    for(int i=0;i<num_th_per_blk;i++){
        answer[i]=num_th_per_blk-i;
    }
    cudaMalloc( (void**) &d_a, memSize);
    // launch kernel
    dim3 dimGrid(num_blocks);
    dim3 dimBlock(num_th_per_blk);
    initArray<<< dimGrid, dimBlock >>>(d_a);
    // retrieve results
    cudaMemcpy(h_a, d_a, memSize, cudaMemcpyDeviceToHost) ; 
    int error=0;
    for(int i=0;i<num_th_per_blk;i++){
        if(answer[i]!=h_a[i]){
            error++;
        }
    }
    printf("%d\n",error);
}