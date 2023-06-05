#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"

int
main(int argc, char *argv[])
{
    int devHelloFd = open("hello", O_RDONLY);
    if(0 > devHelloFd) {
        printf(2, "Error: Unable to open dHello\n");
    }
    else {
        char buffer[512] = {'\0'};
        read(devHelloFd, buffer, 512);
        printf(1, "Read <%s>\n", buffer);
        close(devHelloFd);
        devHelloFd = -1;
    }
    exit();
}