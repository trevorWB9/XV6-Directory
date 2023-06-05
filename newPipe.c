#include "types.h"
#include "stat.h"
#include "user.h"

int main(int argc, const char *argv[])
{
    int p[2];
    pipe(p);
    
    if(fork() == 0) {
        //Child Process
        close(0);
        dup(p[0]);
        close(p[0]);
        close(p[1]);
        exec("wc", (char ** const)argv);
    } else {
        //Parent Process
        close(p[0]);
        close(p[1]);
        wait();     // wait for child process to finish
    }
    exit();
}
