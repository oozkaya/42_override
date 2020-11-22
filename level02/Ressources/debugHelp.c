// https://catonmat.net/simple-ld-preload-tutorial-part-two
// gcc -Wall -fPIC -shared -o helpDebug.so helpDebug.c -ldl
// export LD_PRELOAD=/tmp/helpDebug.so

#define _GNU_SOURCE

#include <stdio.h>
#include <dlfcn.h>
#include <string.h>

FILE *fopen(const char *path, const char *mode)
{
    if (strcmp(path, "/home/users/level03/.pass") == 0)
    {
        printf("My fopen (:\n");
        return (FILE *)99;
    }

    FILE *(*original_fopen)(const char *, const char *);
    original_fopen = dlsym(RTLD_NEXT, "fopen");
    return (*original_fopen)(path, mode);
}

size_t fread(void *buffer, size_t blocSize, size_t blocCount, FILE *stream)
{
    if (stream == (FILE *)99)
    {
        printf("My fread (:\n");
        strcpy(buffer, "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\n");
        return 0x29;
    }

    size_t (*original_fread)(void *, size_t, size_t, FILE *);
    original_fread = dlsym(RTLD_NEXT, "fread");
    return (*original_fread)(buffer, blocSize, blocCount, stream);
}

int fclose(FILE *stream)
{
    if (stream == (FILE *)99)
    {
        printf("My fclose (:\n");
        return 0;
    }

    size_t (*original_fclose)(FILE *);
    original_fclose = dlsym(RTLD_NEXT, "fclose");
    return (*original_fclose)(stream);
}
