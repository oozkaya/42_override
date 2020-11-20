/* source: https://www.hacktion.be/buffer-overflow-variable-environnement/ */
/* gcc getenv.c -o getenv64*/
/* gcc -m32 getenv.c -o getenv32*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[])
{
    char *ptr;

    if (argc < 3)
    {
        printf("Usage: ./getenv <environment variable> <target name program>\n");
        exit(EXIT_FAILURE);
    }

    ptr = getenv(argv[1]);
    if (ptr)
        ptr += strlen(argv[0]) - strlen(argv[2]);

    printf("%p", ptr);

    return EXIT_SUCCESS;
}
