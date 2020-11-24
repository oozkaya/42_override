# Level04 - 32 bits -

## Local script usage

Requirements:

- `gdb-peda`
- `getenv32`

You can setup requirements with the script: [scripts/installUtils.sh](../../scripts/installUtils.sh)

```shell
./scripts/installUtils.sh
./level04/Ressources/main.sh
```

## Passwords and token

|         |                                            |
| ------- | ------------------------------------------ |
| level04 | `kgv3tkEb9h2mLkRsPkXRfc2mHbjMxQzvb2FrgKkf` |
| level05 | ``                                         |

## Steps to resolve on VM

See our assembly interpretation in [source file](../source.c)

## Sources

### ASM

- [What does the “rep stos” x86 assembly instruction sequence do?](https://stackoverflow.com/questions/3818856/what-does-the-rep-stos-x86-assembly-instruction-sequence-do)

### C

- [Man fork](https://linux.die.net/man/3/fork)
- [Man gets](https://linux.die.net/man/3/gets)
- [Man kill](https://linux.die.net/man/3/kill)
- [Man memset](https://linux.die.net/man/3/memset)
- [Man prctl](https://linux.die.net/man/2/prctl)
- [Man ptrace](https://linux.die.net/man/2/ptrace)
- [Man puts](https://linux.die.net/man/3/puts)
- [Man wait](https://linux.die.net/man/2/wait)
