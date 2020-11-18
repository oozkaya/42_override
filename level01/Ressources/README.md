# Level01 -

## Local script usage

```shell
Usage: ./main.sh
```

## Passwords and token

|         |                                            |
| ------- | ------------------------------------------ |
| level01 | `uSq2ehEGT6c9S24zbshexZQBXUGrncxn5sD5QfGL` |
| level02 | ``                                         |

## Steps to resolve on VM

Note: We will use `gdb-peda`. You can setup peda with the script: [scripts/installPeda.sh](../../scripts/installPeda.sh)

See our assembly interpretation in [source file](../source.c)

```shell
gdb-peda$ pattern create 500 input
gdb-peda$ run <<< "dat_wil\n$(cat input)"
gdb-peda$ pattern search
  Registers contain pattern buffer:
  EIP+0 found at offset: 326


```

## Sources

### ASM

- [What does the “rep stos” x86 assembly instruction sequence do?](https://stackoverflow.com/questions/3818856/what-does-the-rep-stos-x86-assembly-instruction-sequence-do)

### C

- [Man fgets](https://linux.die.net/man/3/fgets)
- [Man memset](https://linux.die.net/man/3/memset)
- [Man printf](https://linux.die.net/man/3/printf)
- [Man puts](https://linux.die.net/man/3/puts)
- [Man strncmp](https://linux.die.net/man/3/strncmp)
