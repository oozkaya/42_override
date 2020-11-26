# Level05 - 32 bits -

## Local script usage

Requirements:

- `gdb-peda`
- `getenv32`

You can setup requirements with the script: [scripts/installUtils.sh](../../scripts/installUtils.sh)

```shell
./scripts/installUtils.sh
./level05/Ressources/main.sh
```

## Passwords and token

|         |                                            |
| ------- | ------------------------------------------ |
| level05 | `3v8QLcN5SAhPaZZfEasfmXdwyR59ktDEMAwHF3aN` |
| level06 | ``                                         |

## Steps to resolve on VM

See our assembly interpretation in [source file](../source.c)

## Sources

### ASM

- [What does the “rep stos” x86 assembly instruction sequence do?](https://stackoverflow.com/questions/3818856/what-does-the-rep-stos-x86-assembly-instruction-sequence-do)
- [FR - Ecrivez votre premier shellcode en asm x86 ! (Exemple 2 : execve(/bin/sh))](https://zestedesavoir.com/articles/158/ecrivez-votre-premier-shellcode-en-asm-x86/#2-exemple-2-execve-bin-sh)

### C

#### Questions

- [how does ptrace catch fork's system call?](https://stackoverflow.com/questions/20440118/how-does-ptrace-catch-forks-system-call)

#### Man

- [Man exit](https://linux.die.net/man/3/exit)
- [Man fgets](https://linux.die.net/man/3/fgets)
- [Man printf](https://linux.die.net/man/3/printf)
