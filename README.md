# SAVCOM

```
 ___  __ ___   _____ ___  _ __ ___
/ __|/ _` \ \ / / __/ _ \| '_ ` _ \
\__ \ (_| |\ V / (_| (_) | | | | | |
|___/\__,_| \_/ \___\___/|_| |_| |_|
```
Save commands

## Description.

**Savcom** is a tool for managing command shortcuts efficiently, allowing users to create, modify, list, and delete them easily.

## Dependencies.

bash coreutils

## Install.

Clone this repository:

`$ git clone https://github.com/teegre/savcom.git`

Then:

`$ cd savcom`

And:

`# make install`

**Important**: Make sure you have a directory called `.local/bin` in your home directory, and that it is included in your `$PATH`.
Also make sure `$EDITOR` environment variable is set to your favorite text editor.

To create default shortcuts for **savcom**, run this command:

`savcom < com/default`

## Uninstall.

[Remove all shortcuts](#remove)

`# make uninstall`

## Usage

```
savcom do <name> <command>
savcom do <name> '<command> <arguments>'
savcom ed <name>
savcom cp <name> <newname>
savcom mv <name> <newname>
savcom rm <name>
savcom dp <file>
savcom ls [name|"glob"]
savcom fix
savcom help
savcom version
savcom < <file>
cat <file> | savcom
```

## Options.

Invoked without argument, **savcom** reads from standard input.

Available commands are:

*  do: create/replace. (cdo)
*  ed: edit. (ced)
*  cp: copy. (ccp)
*  mv: rename. (cmv)
*  rm: delete. (crm)
*  dp: dump existing shortcuts into a file. (cdp)
*  ls: print/search shortcut list. (cls)
*  fix: fix missing shortcut links.
*  help: show help and exit.
*  version: show program version and exit.

## Examples

### To create a shortcut called *sco* for **savcom**:

```
$ savcom do sco savcom '"$@"'
sco: command shotcut created.
```

The `'"$@"'` is mandatory here, since we want be able to pass options to **savcom**.  
Also notice the surrounding single quotes. They are needed to prevent the shell from interpreting "$@".

It is good practice to quote commands, like so:

```
$ savcom do ma 'if [ -f ./manage.py ]; then ./manage.py "$@"; else echo "Not a Django project directory!"; fi'
ma: command shortcut created.
```

Otherwise it gets a little tricky :
```
$ savcom do ma if \[ -f ./manage.py \]\; then ./manage.py '"$@"'\; else echo '"Not a Django project directory!"'\; fi
ma: command shortcut created.
```

This shortcut launches Django's command-line utility *manage.py* if it can be found in the current directory.

Now, to invoke a shortcut, simply type it on the command line, i.e: 

```
$ sco version
savcom version 0.2.1.
```

### Save command shortcuts into a file:

`savcom dp shortcuts.txt`

### Remove all shortcuts: <a name="remove"></a>

```
while read -r; do echo "rm $REPLY" | cut -d '=' -f 1 | savcom; done < <(savcom ls)
```

### Restore shortcuts from a file:
`savcom < shortcuts.txt`

For more info, please read `man savcom`.
