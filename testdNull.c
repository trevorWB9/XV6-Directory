#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"

int
main(int argc, char *argv[])
{
    int devNulFd = open("dev/null", O_WRONLY);
    if(0 > devNulFd) {
        printf(2, "Error: Unable to open dNull\n");
    }
    else {
        char buffer[512] = {'\0'};
        write(devNulFd, buffer, 512);
        printf(1, "Write <%s>\n", buffer);
        close(devNulFd);
        devNulFd = -1;
    }
    exit();
}