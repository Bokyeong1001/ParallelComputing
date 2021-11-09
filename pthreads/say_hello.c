#include<stdio.h>
#include<stdlib.h>
#include<pthread.h>

void* say_hello(void *tid){
    printf("hello world from thread %d\n", *((int *)tid));
    free(tid);
    pthread_exit((void *)NULL);
}

int main(int argc, char *argv[]){
    pthread_t my_threads[10];
    void *thread_status;
    int *param;
    for(int t = 0; t < 10; t++){
        param = malloc(sizeof(int));
        *param = t;
        pthread_create(&my_threads[t], NULL, say_hello, (void *)param);
    }
    for(int t = 0; t < 10; t++){
        pthread_join(my_threads[t], &thread_status);
    }
}