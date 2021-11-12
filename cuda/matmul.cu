#include <stdio.h>
__global__ void MatrixMulDevice(float *A, float *B, float *C, int dim) {
    // perform matrix multiplication on device
    for(int i=0;i<blockDim.x/gridDim.x;i++){
        //used block distribution method. get 32 elements in one thread 
        int tmpSum=0;
        for(int j=0;j<dim;j++){
            tmpSum += A[blockIdx.x*dim*blockDim.x/gridDim.x + i*dim +j] * B[threadIdx.x+j*dim];
        }
        C[blockIdx.x*dim*blockDim.x/gridDim.x + i*dim+ threadIdx.x] = tmpSum;
    }
    
}

void MatrixMulHost (float *A, float *B, float *C, int dim) {
    // perform matrix multiplication on host
    float a, b, sum;
    for(int i = 0; i < dim; i++) {
        for(int j = 0; j < dim; j++) {
            sum = 0.0;
            for(int k = 0; k < dim; k++) {
                a = A[ i * dim + k ];
                b = B[ k * dim + j ];
                sum += a * b;
            }
            C[ i * dim + j ] = sum;
        }
    }
}
int main(void) {
    // I/O to load matrices A and B
    float *A, *B, *C, *d_A, *d_B, *d_C, *answer;
    int dim = 128;
    A = new float[dim*dim];
    B = new float[dim*dim];
    C = new float[dim*dim];
    d_A = new float[dim*dim];
    d_B = new float[dim*dim];
    d_C = new float[dim*dim];
    answer = new float[dim*dim];

    // initialize matrices A and B on host
    for(int i=0;i<dim*dim;i++){
       A[i] = float(i%dim);
    }
    for(int p=0;p<dim*dim;p++){
        B[p] = 1.0;
    }
 
    // define thread hierarchy
    int nblocks = 4;
    int tpb = 128;

    // allocate device memory
    size_t memSize;
    memSize = dim * dim * sizeof(float);
    cudaMalloc( (void**) &d_A, memSize );
    cudaMalloc( (void**) &d_B, memSize );
    cudaMalloc( (void**) &d_C, memSize );

    // initialize device memory
    cudaMemcpy(d_A, A, memSize, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, B, memSize, cudaMemcpyHostToDevice);

    // launch kernel, perform matrix multiplication on device
    dim3 dimGrid(nblocks);
    dim3 dimBlock(tpb);
    MatrixMulDevice<<<dimGrid, dimBlock>>>(d_A, d_B, d_C, dim);

    // retrieve results
    cudaMemcpy(C, d_C, memSize, cudaMemcpyDeviceToHost);

    // verify the CUDA kernel’s result
    MatrixMulHost(A, B, answer,dim);
    int error=0;
    for(int i=0;i<dim*dim;i++){
        if(answer[i]!=C[i]){
            error++;
        }
    }
    printf("Error : %d\n",error);
}  