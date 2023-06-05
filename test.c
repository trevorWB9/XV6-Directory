#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"
#include "types.h"
//This is the line that i emailed my proffessor about, code wont run if these files are included
//#include "sleeplock.h"
//#include <pthread.h>




int main(int argc, char *argv[])
{
    int pid;
    int x,y,a,b;
    if(argc <2)
    {
        x = 1; 
    }else
    {
        x = atoi(argv[1]);
    }

    if(x < 0 || x > 5)
    {
        x = 2;
    }

    y = 0;
    pid = 0;

    for(a = 0; a < x; a++)
    {
        
        pid = fork();
        //printf(1, "pid %d \n", pid);
        if(pid<0)
        {
            //Error if pid = 0
            printf(1, "%d failed to fork\n", getpid());
        }else if(pid>0)
        {
            //Create parent process
            printf(1, "Parent %d creating child %d\n",getpid(), pid);
            //Aquire lock and hold, then child will have lock, just show that the child stops the parent with lower priority 

            wait();
        }else
        {
            //Create Child process
            printf(1, "Child %d created\n",getpid(), pid);
            for(y = 0; y < 400000; y+=1)
	            b = b + 100 * 5; //Useless calculation to consume CPU Time
                break;
        }
    }
    exit();
}