#include<stdio.h>
#include<stdlib.h>
#include<pthread.h>
#define NUM_THREADS 8

void* PrintHello(void *thread_id){
    printf("\n%d: Hello World!\n",thread_id);
    pthread_exit(NULL);
}

int main(int argc, char *argv[]){
    pthread_t threads[NUM_THREADS];
    int args[NUM_THREADS];
    int rc, t;
    for(t=0;t<NUM_THREADS;t++){
        printf("Creating thread %d\n",t);
        args[t]=t;
        rc=pthread_create(&threads[t],NULL,PrintHello,(void *)args[t]);
        if(rc){
            printf("ERROR: pthread_create rc is %d\n",rc);
            exit(-1);
        }
    }
    pthread_exit(NULL);
}