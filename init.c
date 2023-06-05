// init: The initial user-level program

#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"

char *argv[] = { "sh", 0 };

int
main(void)
{
  int pid, wpid;
  if(open("console", O_RDWR) < 0){
    mknod("console", 1, 1);
    open("console", O_RDWR);
  }
  dup(0);  // stdout
  dup(0);  // stderr

  //Changed here
  mkdir("dev");
  if(open("dev/null", O_RDONLY) < 0){
    mknod("dev/null", 7, 1);
    open("dev/null", O_RDONLY);
  }
  if(open("dev/zero", O_WRONLY) < 0){
    mknod("dev/zero", 8, 1);
    open("dev/zero", O_WRONLY);
  }
  if(open("dev/ticks", O_RDONLY) < 0){
    mknod("dev/ticks", 9, 1);
    open("dev/ticks", O_RDONLY);
  }
  if(open("hello", O_RDWR) < 0){
    mknod("hello", 6, 1);
    open("hello", O_RDWR);
  }
  for(;;){
    printf(1, "init: starting sh\n");
    pid = fork();
    if(pid < 0){
      printf(1, "init: fork failed\n");
      exit();
    }
    if(pid == 0){
      exec("sh", argv);
      printf(1, "init: exec sh failed\n");
      exit();
    }
    while((wpid=wait()) >= 0 && wpid != pid)
      printf(1, "zombie!\n");
  }
}
