# Level03 - 32 bits - Reverse engineering cipher text

## Local script usage

Requirements:

- `gdb-peda`

You can setup requirements with the script: [scripts/installUtils.sh](../../scripts/installUtils.sh)

```shell
./scripts/installUtils.sh
./level03/Ressources/main.sh
```

## Passwords and token

|         |                                            |
| ------- | ------------------------------------------ |
| level03 | `Hh74RPnuQ9sa5JAEXgNWCqz7sXGnh5J5M9KfPg3H` |
| level04 | `kgv3tkEb9h2mLkRsPkXRfc2mHbjMxQzvb2FrgKkf` |

## Steps to resolve on VM

See our assembly interpretation in [source file](../source.c)

This one consists of reverse an encrypted text:

```C
  char ciphertext[] = "Q}|usfg~sf{}|a3";
```

A XOR operator with a `key` is applied on each bytes of the string :

```c
  int len = strlen(ciphertext);
  int i = 0;

  while (i < len)
  {
      ciphertext[i] = ciphertext[i] ^ key;
      i += 1;
  }
```

If the uncipher text is "Congratulations!", a shell is executed.

We need to find the key and then add the constant `0x1337d00d`

We know the key is less or equal than `0x14`

We wrote a [C-program](./reverse.c) to reverse the binary. Lets execute it:

```shell
./a.out
  00: Q}|u`sfg~sf{}|a3
  0x01: P|}targfrgz|}`2
  0x02: S~wbqde|qdy~c1
  0x03: R~vcped}pex~b0
  0x04: Uyxqdwbczwbyxe7
  0x05: Txypevcb{vc~xyd6
  0x06: W{zsfu`axu`}{zg5
  0x07: Vz{rgta`yta|z{f4
  0x08: Yut}h{nov{nsuti;
  0x09: Xtu|izonwzortuh:
  0x0a: [wvjylmtylqwvk9
  0x0b: Zvw~kxmluxmpvwj8
  0x0c: ]qpyljkrjwqpm?
  0x0d: \pqxm~kjs~kvpql>
  0x0e: _sr{n}hip}husro=
  0x0f: ^rszo|ihq|itrsn<
  0x10: Amlepcvwncvkmlq#
  0x11: @lmdqbwvobwjlmp"
  0x12: Congratulations!

  0x1337d00d - 0x12 = 0x1337cffb
  Password (input) is 0x1337cffb => 322424827
```

So the key is 0x12 and the input is 0x1337cffb (322424827 in decimal)

Lets try

```shell
~/level03
  ***********************************
  *               level03         **
  ***********************************
  Password:322424827

$ whoami
  level04
$ cat /home/users/level04/.pass
  kgv3tkEb9h2mLkRsPkXRfc2mHbjMxQzvb2FrgKkf
```

## Sources

### ASM

- [How to get asm to jump to a variable address in c?](https://stackoverflow.com/a/19827976)
- [What does the “rep stos” x86 assembly instruction sequence do?](https://stackoverflow.com/questions/3818856/what-does-the-rep-stos-x86-assembly-instruction-sequence-do)

### C

- [Man printf](https://linux.die.net/man/3/printf)
- [Man puts](https://linux.die.net/man/3/puts)
- [Man rand](https://linux.die.net/man/3/rand)
- [Man scanf](https://linux.die.net/man/3/scanf)
- [Man strncmp](https://linux.die.net/man/3/strncmp)
- [Man srand](https://linux.die.net/man/3/srand)
- [Man strlen](https://linux.die.net/man/3/strlen)
- [Man system](https://linux.die.net/man/3/system)
- [Man time](https://linux.die.net/man/2/time)
