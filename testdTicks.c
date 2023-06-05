#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"

int
main(int argc, char *argv[])
{
    int devTicksFd = open("dev/ticks", O_RDONLY);
    if(0 > devTicksFd) {
        printf(2, "Error: Unable to open dTicks\n");
    }
    else {
        char buffer[512] = {'\0'};
        read(devTicksFd, buffer, 512);
        printf(1, "Read <%s>\n", buffer);
        close(devTicksFd);
        devTicksFd = -1;
    }
    exit();
}