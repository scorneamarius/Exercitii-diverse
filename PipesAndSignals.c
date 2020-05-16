Se considera un program in C ce contine doua procese(parinte si fiu).Procesul parinte va trimite printr-un pipe timp de 5s caracterul 'a' procesului fiu, in plus, la fiecare secunda , o sa trimite si semnalul SIGUSR1.
Procesul fiu va citi caracterele din pipe si va realiza o statistica ce va contine numarul total de caractere precum si numarul de caractere primite dupa fiecare semnal SIGUSR1.
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#include <signal.h>
int nrSignal=0;
int child;
int parent;
int nrTotal;
int nrPerS;
int v[100];
int i=0;
void handler_SIGUSR1(int x){
    i=i+1;
}
void handler_SIGALRM(int x){
    
    if(nrSignal<4)
    { 
        kill(child,10);
        alarm(1);
        nrSignal++;
    }
    else
    {
        exit(4);
    }
}
int main(){
    int pid;
    int pfd[2]; // pipe folosit pentru transmiterea caracterului 'a'
    int pfpid[2]; // pipe folosit pentru transmiterea pid-ului de la child la parent
    pipe(pfd);
    pipe(pfpid);
    if((  pid=fork()) < 0)
    {
        perror("Eroare");
        exit(-1);
    }
    
    if(pid==0) // cod fiu
    {  
        struct sigaction sa;
        sa.sa_handler=handler_SIGUSR1;
        sigemptyset(&(sa.sa_mask));
        sa.sa_flags=0;
        if((sigaction(SIGUSR1,&sa,NULL))==-1)
        {
            perror("sigaction child failed!");
            exit(-1);
        }
        
        close(pfpid[0]); // inchid capatul de citire
        
        int childPid=getpid(); // pid-ul child-ului
        write(pfpid[1],&childPid,4); // transmitem prin pipe
        
        close(pfd[1]); /* inchide capatul de scriere; */
        char buffRead;
        while(read(pfd[0],(&buffRead),1)!=0){
            nrTotal++;
            v[i]++;
        }
        printf("\nIn total au fost trimise %d caractere de a \n",nrTotal);
        printf("Statistica privind trimiterea semnalului SIGUSR1 si receptia caracterelor a: \n");
        for(int j=0;j<5;j++)
        {
            if(j==0)
            {
                printf("Nr de caractere transmise inainte de primul SIGUSR1 este %d \n",v[j]);
            }
            else
            {
                printf("Nr de caractere transmise inainte de al %d -lea SIGUSR1 este %d \n",j+1,v[j]);
            }
        }
    }
    else // cod parinte
    {
        parent=getpid();
        close(pfd[0]); /* inchide capatul de citire; */
        close(pfpid[1]) ; // inchid capatul de scriere
        read(pfpid[0],&child,4);
        
        struct sigaction sigStruct;
        sigStruct.sa_handler=handler_SIGALRM;
        sigemptyset(&(sigStruct.sa_mask));
        sigStruct.sa_flags=0;
        if((sigaction(SIGALRM,&sigStruct,NULL))==-1)
        {
            perror("sigaction parent failed");
            exit(2);
        }
        alarm(1);
        char buffWrite='a';
        while(1){
            //
            write(pfd[1],&buffWrite,sizeof(buffWrite));
        }        
    }
}
