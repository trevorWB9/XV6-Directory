#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"

int
main(int argc, char *argv[])
{
    int devZeroFd = open("dev/zero", O_RDONLY);
    if(0 > devZeroFd) {
        printf(2, "Error: Unable to open dZero\n");
    }
    else {
        char buffer[512] = {'\0'};
        read(devZeroFd, buffer, 512);
        printf(1, "Read <%s>\n", buffer);
        close(devZeroFd);
        devZeroFd = -1;
    }
    exit();
}