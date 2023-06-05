1. You can create a seperate list of processes that are ready to run
2. You could do a binary search for processes that are ready to run
3. If a process decides to keep a lock, the lock will not switch and anotherCPU might decide to run this process after its state is changed. This wll result in having 2 CPU's running simultaneously on the same stack.
4. A ZOMBIE process can be created by calling a parent and child process and if the child wakes up before the parent process, the child is put in a ZOMBIE state untill the parent process finishes.
5. Xv6 does not use Preemptive schedualing because it does not have any kind of priority in its schedualing. If a system uses a priority varible to help schedual important processes then it is a preemptive schedualer. Xv6 does not use any priority so it is excluded.
