#include <omp.h> 
#include <stdio.h>
#include<time.h>

int num_steps = 100000;
double step;
#define NUM_THREADS 4
void main () {
    clock_t start, end;
    int i, nthreads;
    double pi = 0.0;
    step = 1.0/(double) num_steps; 
    omp_set_num_threads(NUM_THREADS);
    start = clock();
    #pragma omp parallel 
    {
        double x; 
        int id = omp_get_thread_num();
        int nthrds = omp_get_num_threads();
        double tmpsum = 0.0;
        int b_size = num_steps / nthrds;
        for (int i = id * b_size; i < (id+1) * b_size; i++){
            x = (i+0.5)*step; 
            tmpsum += 4.0/(1.0+x*x);
        }
        #pragma omp critical
        {
            pi += tmpsum * step;
        }
    }
    end = clock();
    printf("pi = %f\n",pi);
    printf("elapsed time : %ld ms\n", end - start);
    //elapsed time : 824 ms
}