# DALIAS

```
    _       _  o         
  __)) ___  )) _  ___  __
 ((_( ((_( (( (( ((_( _))
```
Dynamic aliases.

## Description.

I needed a quick way to create aliases on the fly without having to source any script.  
So I wrote **dalias** for this purpose.

Simply put, it creates a script containing the "aliased" command with its parameters  
(stored in `$HOME/.config/dalias/aliases`), makes it executable and adds a symlink  
to it in "$HOME/.local/bin" so it is immediately ready to use in any shell.

## Dependencies.

bash coreutils

## Install.

Clone this repository: `git clone https://github.com/teegre/dalias.git`

Then:

`make install`

**Important**: Make sure you have a directory called `.local/bin` in your home  
directory, and that it is included in your `$PATH`. Also make sure `$EDITOR`  
environment variable is set to your favorite text editor.

## Uninstall.

`make uninstall`

## Usage

```
dalias do <name> <command> [arguments]
dalias ed <name>
dalias cp <name> <newname>
dalias mv <name> <newname>
dalias rm <name>
dalias dp <file>
dalias ls [name|glob]
dalias help
dalias version
```

## Options.

Invoked without argument, **dalias** reads from standard input.

Available commands are:

*  do: create/replace.
*  ed: edit.
*  cp: rename.
*  mv: rename.
*  rm: delete.
*  dp: dump existing aliases into a file.
*  ls: print/search dynamic alias list.
*  help: show help and exit.
*  version: show program version and exit.

## Examples

To create a dynamic alias called *da* for **dalias**:

```
> dalias do da dalias '"$@"'
da: dynamic alias created.
```

The `'"$@"'` is mandatory here, since we want be able to pass options to **dalias**.  
Also notice the surrounding single quotes. They are needed to prevent the shell from interpreting "$@".

Save aliases into a file: `dalias dp aliases.txt`

Remove all aliases:

```
while read -r; do echo "rm $REPLY" | cut -d '=' -f 1 | dalias; done < <(dalias ls)
```

Restore aliases from file: `dalias < aliases.txt`

For more info, please read `man dalias`.
