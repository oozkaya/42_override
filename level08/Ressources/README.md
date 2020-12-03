# Level08 - 64 bits - Serial decoding

## Local script usage

Requirements:

- `gdb-peda`

You can setup requirements with the script: [scripts/installUtils.sh](../../scripts/installUtils.sh)

```shell
./scripts/installUtils.sh
./level08/Ressources/main.sh
```

## Passwords and token

|         |                                            |
| ------- | ------------------------------------------ |
| level08 | `7WJ6jFBzrcjEYXudxnM3kdW7n3qyxR6tk2xGrkSC` |
| level09 | `fjAwpJNs2vvkFLRebEvAQ2hFZ4uQBWfHRsP62d8S` |

## Steps to resolve on VM

First of all, the program needs one argument, which is a file. It will basically do a backup of its content inside the `backups` folder, and write the logs inside `.log`.

First it will open `./backups/.log` and write `LOG: Starting back up: ` + argv[1].  
Secondly it will open argv[1], with only read permissions.  
Then it will concatenate `./backups/` with argv[1], and open it.

After that it will write the content of argv[1] inside the `./backups/` + argv[1] path, and finally will write `LOG: Finished back up ` + argv[1].

So the main idea we could have would be to open `/home/users/level09` but it doesn't find the right pass when opening the `./backups/` + argv[1]

```shell
./level08 /home/users/level09/.pass
    ERROR: Failed to open ./backups//home/users/level09/.pass
```

Let's try to work on the /tmp folder where we have more rights. Firt we recreate `./backups/.log`

```shell
cd /tmp
mkdir backups; cd backups
touch .log
```

If we try the same as above, we will have the same error, because the path `./backups//home/users/level09/.pass` doesn't exist. `open` will only create the file if it doesn't exist but not the parent folders. So let's do it :

```shell
mkdir -p backups/home/users/level09
~/level08 /home/users/level09/.pass
cat backups/home/users/level09/.pass
    fjAwpJNs2vvkFLRebEvAQ2hFZ4uQBWfHRsP62d8S
```

## Sources

### Shell

- [mkdir -p](https://unix.stackexchange.com/questions/49263/recursive-mkdir)

### C

- [open](http://manpagesfr.free.fr/man/man2/open.2.html)
- [fopen](http://manpagesfr.free.fr/man/man3/fopen.3.html)
- [write](http://manpagesfr.free.fr/man/man2/write.2.html)