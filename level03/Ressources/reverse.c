#include <string.h>
#include <stdio.h>
#include <stdlib.h>

int isCongratulations(char *str)
{
    char congrats[] = "Congratulations!";

    return strncmp(str, congrats, 0x11) == 0;
}

void xor_reverse(char *buff, int key)
{
    char ciphertext[] = "Q}|u`sfg~sf{}|a3";
    int ciphertextlen = strlen(ciphertext);
    int i;

    memset(buff, '\0', ciphertextlen);
    strncpy(buff, ciphertext, ciphertextlen);
    i = 0;
    while (i < ciphertextlen)
    {
        buff[i] = buff[i] ^ key;
        i++;
    }
}

int main(int argc, char **argv)
{
    int ref = 0x1337d00d;
    int input = 0;
    int key = 0;
    char *buff;

    while (key <= 0x14)
    {
        buff = (char *)malloc(20);
        xor_reverse(buff, key);
        printf("%#.2x: %.*s\n", key, 0x11, buff);
        if (isCongratulations(buff))
        {
            input = ref - key;
            printf("\n%#x - %#x = %#x\n", ref, key, input);
            printf("Password (input) is %#x => %d\n", input, input);
            free(buff);
            return EXIT_SUCCESS;
        }
        free(buff);
        key++;
    }
    return EXIT_FAILURE;
}