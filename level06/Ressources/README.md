# Level06 - 32 bits - Serial decoding

## Local script usage

Requirements:

- `gdb-peda`

You can setup requirements with the script: [scripts/installUtils.sh](../../scripts/installUtils.sh)

```shell
./scripts/installUtils.sh
./level06/Ressources/main.sh
```

## Passwords and token

|         |                                            |
| ------- | ------------------------------------------ |
| level05 | `h4GtNnaMs2kZFN92ymTr2DcJHAzMfzLW25Ep59mq` |
| level06 | `GbcPDRgsFK77LNnnuh7QyFYA2942Gp8yKj9KrWD8` |

## Steps to resolve on VM

The program asks for a login and a serial. After that it does several complex calculations based on the login. At the end the result is compare to the serial.
If it's good, then we call `system("/bin/sh")`.

However while we were doing the debugging with GDB, there was a protection with `ptrace`. To bypass it, just break before and `set $eax=0` after its call.
After that, the only thing remaining will be to check result after the calculations. Then break at the before the comparison, and get the value (`b *auth+286` and `x /d $ebp-0x10`).

In our example, for a login of `ABCDEF` we need a serial of `6231554`.

```shell
~/level06 
    ***********************************
    *		level06		  *
    ***********************************
    -> Enter Login: ABCDEF
    ***********************************
    ***** NEW ACCOUNT DETECTED ********
    ***********************************
    -> Enter Serial: 6231554
    Authenticated!
    $ whoami
    level07
    $ cat /home/users/level07/.pass
    GbcPDRgsFK77LNnnuh7QyFYA2942Gp8yKj9KrWD8
```

## Sources

### Assembly

- [MOVZX & MOVSX](https://www.youtube.com/watch?v=idrazNPk7cQ)
- [MUL with upper and lower bits](https://stackoverflow.com/questions/25550035/mul-operation-in-assembly)
- [SHR](https://www.aldeid.com/wiki/X86-assembly/Instructions/shr)
- [IMUL](https://www.gladir.com/LEXIQUE/ASM/imul.htm)
- [TEST](https://en.wikipedia.org/wiki/TEST_(x86_instruction))

### Hack

- [Bit Shift Calculator](https://bit-calculator.com/bit-shift-calculator)
