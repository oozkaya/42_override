# Level02 - 64 bits - Format string attack

## Local script usage

Requirements:

- `gdb-peda`
- `getenv64`

You can setup requirements with the script: [scripts/installUtils.sh](../../scripts/installUtils.sh)

```shell
./scripts/installUtils.sh
./level01/Ressources/main.sh
```

## Passwords and token

|         |                                            |
| ------- | ------------------------------------------ |
| level02 | `PwBLgNa8p8MTKW57S7zxVAQCxnCpV8JqTTs9XEBv` |
| level02 | ``                                         |

## Steps to resolve on VM

See our assembly interpretation in [source file](../source.c)

```shell
gdb-peda$ b*main+148 # before fopen
gdb-peda$ run
gdb-peda$ p $rbp-0x70 # username
  $1 = (void *) 0x7fffffffe470
gdb-peda$ p $rbp-0xa0 # flag
  $2 = (void *) 0x7fffffffe440
gdb-peda$ telescope 0x7fffffffe440
0000| 0x7fffffffe440 --> 0x0 # _
0008| 0x7fffffffe448 --> 0x0 #  |
0016| 0x7fffffffe450 --> 0x0 #  |
0024| 0x7fffffffe458 --> 0x0 #  |
0032| 0x7fffffffe460 --> 0x0 #  |
0040| 0x7fffffffe468 --> 0x0 #  |
0048| 0x7fffffffe470 --> 0x0 # _| +6 addresses
0056| 0x7fffffffe478 --> 0x0

objdump -R ./level02 | grep "system\|exit"
  0000000000601228 R_X86_64_JUMP_SLOT  exit
  00000000006011f8 R_X86_64_JUMP_SLOT  system

# 0x0000000000400a8a <+630>:	call   0x4006b0 <system@plt>                # system("/bin/sh");
# x/a 0x0000000000400a8a
# 0x400a8a <main+630>:    0xb8fffffc21e8

b*main+153 # after fopen
run
x/16x $rbp-0x70 # username
  0x7fffffffe470: 0x0000000000000000      0x0000000000000000
  0x7fffffffe480: 0x0000000000000000      0x0000000000000000
  0x7fffffffe490: 0x0000000000000000      0x0000000000000000
  0x7fffffffe4a0: 0x0000000000000000      0x0000000000000000
  0x7fffffffe4b0: 0x0000000000000000      0x0000000000000000
  0x7fffffffe4c0: 0x0000000000000000      0x0000000000000000
  0x7fffffffe4d0: 0x0000000000000000      0x0000000000000000
  0x7fffffffe4e0: 0x0000000000000000      0x00007ffff7a3d7ed

p 0x7fffffffe4e8 - 0x7fffffffe470
  $5 = 0x78
```

## Sources

### ASM

- [What does the “rep stos” x86 assembly instruction sequence do?](https://stackoverflow.com/questions/3818856/what-does-the-rep-stos-x86-assembly-instruction-sequence-do)

### C

- [Man exit](https://linux.die.net/man/3/exit)
- [Man fgets](https://linux.die.net/man/3/fgets)
- [Man fclose](https://linux.die.net/man/3/fclose)
- [Man fopen](https://linux.die.net/man/3/fopen)
- [Man fread](https://linux.die.net/man/3/fread)
- [Man fwrite](https://linux.die.net/man/3/fwrite)
- [Man memset](https://linux.die.net/man/3/memset)
- [Man printf](https://linux.die.net/man/3/printf)
- [Man puts](https://linux.die.net/man/3/puts)
- [Man strncmp](https://linux.die.net/man/3/strncmp)
- [Man strcspn](https://linux.die.net/man/3/strcspn)
- [Man system](https://linux.die.net/man/3/system)
