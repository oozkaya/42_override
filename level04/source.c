// 32bit, executable stack, no stack protector
// gcc -m32 -g -z execstack -fno-stack-protector source.c

#include <signal.h>
#include <stdio.h>
#include <string.h>
#include <sys/prctl.h>
#include <sys/ptrace.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

// pid_t fork(void);
// char *gets(char *s);
// int kill(pid_t pid, int sig);
// void *memset(void *s, int c, size_t n);
// int prctl(int option, unsigned long arg2, unsigned long arg3, unsigned long arg4, unsigned long arg5);
// long ptrace(enum __ptrace_request request, pid_t pid, void *addr, void *data);
// int puts(const char *s);
// pid_t wait(int *status);

#define DEATH_ON_SIGNAL_VALUE 1

int main(int argc, char **argv)
{
    pid_t pid;
    char buf[100];
    int child_user_content;
    int status;

    pid = fork();
    memset(buf, '\0', 0x20);
    child_user_content = 0;
    status = 0;
    if (pid)
    {
        prctl(PR_SET_PDEATHSIG, DEATH_ON_SIGNAL_VALUE);
        ptrace(PTRACE_TRACEME, NULL, NULL, NULL);
        puts("Give me some shellcode, k");
        gets(buf);
        return 0;
    }
    while (child_user_content != 0xb)
    {
        wait(&status);
        pid_t isStatusEqualsZero = status & 0x7f == 0;
        pid_t isStatusGreaterThanZero = (((status & 0x7f) + 1) / 2) > 0;
        if (isStatusEqualsZero || isStatusGreaterThanZero)
        {
            puts("child is exiting...");
            return 0;
        }
        child_user_content = ptrace(PTRACE_PEEKUSER, pid, 0x2c, NULL);
    }
    puts("no exec() for you");
    kill(pid, SIGKILL);
    return 0;
}

// main
//    0x080486c8 <+0>:     push   ebp
//    0x080486c9 <+1>:     mov    ebp,esp
//    0x080486cb <+3>:     push   edi
//    0x080486cc <+4>:     push   ebx
//    0x080486cd <+5>:     and    esp,0xfffffff0
//    0x080486d0 <+8>:     sub    esp,0xb0                      # 176
//    0x080486d6 <+14>:    call   0x8048550 <fork@plt>          # fork();
//    0x080486db <+19>:    mov    DWORD PTR [esp+0xac],eax      # pid
//    0x080486e2 <+26>:    lea    ebx,[esp+0x20]                # buf
//    0x080486e6 <+30>:    mov    eax,0x0
//    0x080486eb <+35>:    mov    edx,0x20
//    0x080486f0 <+40>:    mov    edi,ebx
//    0x080486f2 <+42>:    mov    ecx,edx
//    0x080486f4 <+44>:    rep stos DWORD PTR es:[edi],eax      # => memset(buf ,'\0', 0x20);
//    0x080486f6 <+46>:    mov    DWORD PTR [esp+0xa8],0x0      # child_user_content
//    0x08048701 <+57>:    mov    DWORD PTR [esp+0x1c],0x0      # status
//    0x08048709 <+65>:    cmp    DWORD PTR [esp+0xac],0x0      # cmp pid, 0
//    0x08048711 <+73>:    jne    0x8048769 <main+161>
//    0x08048713 <+75>:    mov    DWORD PTR [esp+0x4],0x1       # signal value
//    0x0804871b <+83>:    mov    DWORD PTR [esp],0x1           # PR_SET_PDEATHSIG
//    0x08048722 <+90>:    call   0x8048540 <prctl@plt>         # prctl(PR_SET_PDEATHSIG, SIGNAL_VALUE);
//    0x08048727 <+95>:    mov    DWORD PTR [esp+0xc],0x0
//    0x0804872f <+103>:   mov    DWORD PTR [esp+0x8],0x0
//    0x08048737 <+111>:   mov    DWORD PTR [esp+0x4],0x0
//    0x0804873f <+119>:   mov    DWORD PTR [esp],0x0           # PTRACE_TRACEME
//    0x08048746 <+126>:   call   0x8048570 <ptrace@plt>        # ptrace(PTRACE_TRACEME, NULL, NULL, NULL);
//    0x0804874b <+131>:   mov    DWORD PTR [esp],0x8048903     # "Give me some shellcode, k"
//    0x08048752 <+138>:   call   0x8048500 <puts@plt>          # puts("Give me some shellcode, k");
//    0x08048757 <+143>:   lea    eax,[esp+0x20]                # buf
//    0x0804875b <+147>:   mov    DWORD PTR [esp],eax
//    0x0804875e <+150>:   call   0x80484b0 <gets@plt>          # gets(buf);
//    0x08048763 <+155>:   jmp    0x804881a <main+338>
//    0x08048768 <+160>:   nop
//    0x08048769 <+161>:   lea    eax,[esp+0x1c]                # &status
//    0x0804876d <+165>:   mov    DWORD PTR [esp],eax
//    0x08048770 <+168>:   call   0x80484f0 <wait@plt>          # wait(&status);
//    0x08048775 <+173>:   mov    eax,DWORD PTR [esp+0x1c]      # status
//    0x08048779 <+177>:   mov    DWORD PTR [esp+0xa0],eax      # isStatusEqualsZero
//    0x08048780 <+184>:   mov    eax,DWORD PTR [esp+0xa0]
//    0x08048787 <+191>:   and    eax,0x7f                      # status & 0x7
//    0x0804878a <+194>:   test   eax,eax                       # status & 0x7 == 0
//    0x0804878c <+196>:   je     0x80487ac <main+228>
//    0x0804878e <+198>:   mov    eax,DWORD PTR [esp+0x1c]      # status
//    0x08048792 <+202>:   mov    DWORD PTR [esp+0xa4],eax      # isStatusGreaterThanZero
//    0x08048799 <+209>:   mov    eax,DWORD PTR [esp+0xa4]
//    0x080487a0 <+216>:   and    eax,0x7f                      # status & 0x7f
//    0x080487a3 <+219>:   add    eax,0x1                       # + 1
//    0x080487a6 <+222>:   sar    al,1                          # al >> 1 => / 2
//    0x080487a8 <+224>:   test   al,al                         # == 0
//    0x080487aa <+226>:   jle    0x80487ba <main+242>          # if <= 0 jump
//    0x080487ac <+228>:   mov    DWORD PTR [esp],0x804891d     # "child is exiting..."
//    0x080487b3 <+235>:   call   0x8048500 <puts@plt>          # puts("child is exiting...");
//    0x080487b8 <+240>:   jmp    0x804881a <main+338>
//    0x080487ba <+242>:   mov    DWORD PTR [esp+0xc],0x0
//    0x080487c2 <+250>:   mov    DWORD PTR [esp+0x8],0x2c
//    0x080487ca <+258>:   mov    eax,DWORD PTR [esp+0xac]      # pid
//    0x080487d1 <+265>:   mov    DWORD PTR [esp+0x4],eax
//    0x080487d5 <+269>:   mov    DWORD PTR [esp],0x3           # PTRACE_PEEKUSER
//    0x080487dc <+276>:   call   0x8048570 <ptrace@plt>        # ptrace(PTRACE_PEEKUSER, pid, 0x2c, NULL);
//    0x080487e1 <+281>:   mov    DWORD PTR [esp+0xa8],eax      # child_user_content
//    0x080487e8 <+288>:   cmp    DWORD PTR [esp+0xa8],0xb      # cmp child_user_content, 0xb
//    0x080487f0 <+296>:   jne    0x8048768 <main+160>          # while child_user_content != 0xb
//    0x080487f6 <+302>:   mov    DWORD PTR [esp],0x8048931     # "no exec() for you"
//    0x080487fd <+309>:   call   0x8048500 <puts@plt>          # puts("no exec() for you");
//    0x08048802 <+314>:   mov    DWORD PTR [esp+0x4],0x9       # SIGKILL
//    0x0804880a <+322>:   mov    eax,DWORD PTR [esp+0xac]      # pid
//    0x08048811 <+329>:   mov    DWORD PTR [esp],eax
//    0x08048814 <+332>:   call   0x8048520 <kill@plt>          # kill(pid, SIGKILL);
//    0x08048819 <+337>:   nop
//    0x0804881a <+338>:   mov    eax,0x0
//    0x0804881f <+343>:   lea    esp,[ebp-0x8]
//    0x08048822 <+346>:   pop    ebx
//    0x08048823 <+347>:   pop    edi
//    0x08048824 <+348>:   pop    ebp
//    0x08048825 <+349>:   ret
