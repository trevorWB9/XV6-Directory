#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"
#include "types.h"

int main(int argc, char *argv[])
{
    int oldPrio = nice(getpid(), 42);
    printf(1, "Old Priority was : %d \n", oldPrio);
    exit();
}