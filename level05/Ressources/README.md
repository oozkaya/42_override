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

```shell
b*main+195
run <<< "AAAAAA"
telescope 20
[------------------------------------stack-------------------------------------]
0000| 0xffffd590 --> 0xffffd5b8 ("aaaaaa\n")        # _
0004| 0xffffd594 --> 0x64 ('d')                     #  |
0008| 0xffffd598 --> 0xf7fcfac0 --> 0xfbad2288      #  |
0012| 0xffffd59c --> 0xf7ec3af9 (test   eax,eax)    #  |
0016| 0xffffd5a0 --> 0xffffd5df --> 0x48520f7       #  |
0020| 0xffffd5a4 --> 0xffffd5de --> 0x8520f7fc      #  |
0024| 0xffffd5a8 --> 0x0                            #  |
0028| 0xffffd5ac --> 0xffffffff                     #  |
0032| 0xffffd5b0 --> 0xffffd664 --> 0x86d22783      #  |
0036| 0xffffd5b4 --> 0x0                            #  |
0040| 0xffffd5b8 ("aaaaaa\n")                       # _| offset 10
0044| 0xffffd5bc --> 0xa6161 ('aa\n')
[------------------------------------------------------------------------------]

~/level05
(stdin) AAAA%10$p
  aaaa0x61616161


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
```
