#include <omp.h> 
#include <stdio.h>
#include<time.h>

int num_steps = 100000;
double step;

void main () {
    clock_t start, end;
    int i;
    double x, pi, sum = 0.0; 
    step = 1.0/(double) num_steps; 
    start = clock();
    #pragma omp parallel for private(x) reduction(+ : sum) num_threads(8)
    for ( i = 0; i < num_steps; i++ ) { 
        x = (i+0.5)*step; 
        sum = sum + 4.0/(1.0+x*x);
    }
    pi = step * sum;    
    end = clock();
    printf("pi = %f\n",pi);
    printf("elapsed time : %ld ms\n", end - start);
    //elapsed time : 750 ms
}