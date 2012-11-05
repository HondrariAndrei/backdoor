#include <stdio.h>
#include <stdlib.h>

#define MASK    "systemd"

int main(int argc, char* argv[])
{
    /* Mask the Process Name */
    memset(argv[0], 0, strlen(argv[0]));
    strcpy(argv[0], MASK);
    prctl(PR_SET_NAME, MASK, 0, 0);
    
    /* Raise Privilages */
    setuid(0);
    setgid(0);

    return 0;
}
