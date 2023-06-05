#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"

int main(int argc, const char *argv[])
{
    int udCount = 0;
    int otherCount = 0;
    if (1 >= argc)
    {
        printf(1, "Usage: %s <path>\n", argv[0]);
    }
    else
    {
        for (int i = 1; i < argc; i++)
        {
            const char *path = argv[i];
            int fd = open(path, O_RDONLY);
            if (0 > fd)
            {
                printf(1, "Opening to file: %d\n", path);
            }
            else
            {
                char buffer[1] = {0};
                int status = 0;
                do
                {
                    status = read(fd, buffer, 1);
                    if (buffer[0] == 68 || buffer[0] == 85 || buffer[0] == 117 || buffer[0] == 100)
                    {
                        udCount++;
                    }
                    else
                    {
                        otherCount++;
                    }
                } while (0 < status);

                if (0 > status)
                {
                    printf(1, "Writing to file: %d\n", path);
                }
            }
            close(fd);
        }
        printf(1, "Number of UD's: %d\n", udCount);
        printf(2, "Number of others: %d\n", otherCount);
    }

    if (udCount >= 1)
    {
        return 0;
    }
    else
    {
        return 1;
    }
}