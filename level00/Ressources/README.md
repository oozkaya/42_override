# Level00 - Disassemble and find the solution

## Local script usage

```shell
Usage: ./main.sh
```

## Passwords and token

|         |                                            |
| ------- | ------------------------------------------ |
| level00 | `level00`                                  |
| level01 | `uSq2ehEGT6c9S24zbshexZQBXUGrncxn5sD5QfGL` |

## Steps to resolve on VM

Note: We will use `gdb-peda`. You can setup peda with the script: [scripts/installPeda.sh](../../scripts/installPeda.sh)

See our assembly interpretation in [source file](../source.c)

Just put `5276` (`0x149c`) in the scanf prompt. Then the shell is executed.

```shell
~/level00
***********************************
*            -Level00 -           *
***********************************
Password:5276

Authenticated!
$ whoami
  level01
$ cat /home/users/level01/.pass
  uSq2ehEGT6c9S24zbshexZQBXUGrncxn5sD5QfGL
```

## Sources

### C

- [Man printf](https://linux.die.net/man/3/printf)
- [Man puts](https://linux.die.net/man/3/puts)
- [Man scanf](https://linux.die.net/man/3/scanf)
- [Man system](https://linux.die.net/man/3/system)
