#include <omp.h> 
#include <stdio.h>
#include<time.h>

int num_steps = 100000;
double step;
#define NUM_THREADS 4
void main () {
    clock_t start, end;
    int i, nthreads;
    double pi = 0.0, sum[ NUM_THREADS ];
    step = 1.0/(double) num_steps; 
    omp_set_num_threads(NUM_THREADS);
    start = clock();
    #pragma omp parallel 
    {
        int i, id, nthrds;
        double x; 
        id = omp_get_thread_num();
        nthrds = omp_get_num_threads();
        if (id == 0) nthreads = nthrds;
        sum[ id ] = 0.0;
        for ( i = id; i < num_steps; i += nthrds ) { 
            x = (i+0.5)*step; 
            sum[ id ] += 4.0/(1.0+x*x);
        }
    }
    for( i = 0; i < nthreads; i++ ) { 
        pi += sum[ i ] * step; 
    }
    end = clock();
    printf("pi = %f\n",pi);
    printf("elapsed time : %ld ms\n", end - start);
    //elapsed time : 8041 ms
}