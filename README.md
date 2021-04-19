# DALIAS

```
    _       _  o         
  __)) ___  )) _  ___  __
 ((_( ((_( (( (( ((_( _))
```
Dynamic aliases.

## Description.

I needed a quick way to create aliases on the go without having to source any script.  
So I wrote **dalias** for this purpose. Simply put, it creates a script containing the "aliased"  
command with its parameters, makes it executable and adds a symlink to "$HOME/.local/bin" so it is    
immediately ready to use.

## Dependencies.

bash coreutils

## Install.

Clone this repository: `git clone https://gitlab.com/teegre/dalias.git`

Then: `make install`

Make sure you have a directory called `.local/bin` in your home directory, and that it is included in your `$PATH`.

## Uninstall.

`make uninstall`

## Usage

```
dalias do <name> <command> [arguments]
dalias mv <name> <newname>
dalias rm <name>
dalias dp <file>
dalias ls [name|glob]
dalias help
```

## Options.

Invoked without options, **dalias** reads from standard input.

Available options are:

*  do: create/update.
*  mv: rename.
*  rm: delete.
*  dp: dump existing aliases into a file.
*  ls: print dynamic alias list.
*  help: show help and exit.

## Examples

To create a dynamic alias called *da* for **dalias**:

```
> dalias do da dalias '"$@"'
da: dynamic alias created.
```

The `'"$@"'` is mandatory since we want be able to pass options.

Let's try it:

```
> da ls
da=dalias "$@"
```
Now let's create aliases for every dalias command:
```
> da do dado dalias do '"$@"'
dado: dynamic alias created.
> da do damv dalias mv '"$@"'
damv: dynamic alias created.
> da do darm dalias rm '"$@"'
darm: dynamic alias created.
> da do dals dalias ls '"$@"'
dals: dynamic alias created.
```

## Batch aliasing.

Since **dalias** reads from stdin, it is possible to create a bunch of aliases from a file.  
The syntax is as follow:

`dalias < file` or `cat file | dalias`

Each line of the file must contain **dalias** commands formatted like this:

`<dalias command> <name> [<command> [arguments]]`

Let's take our last example:

```
# aliases.txt
do dado dalias do "$@"
do damv dalias mv "$@"
do darm dalias rm "$@"
do dadp dalias dp "$@"
do dals dalias ls "$@"
```

Note: since we are *not* on the *command line*, *single quotes are not needed*.

Finally, entering the command: `dalias < aliases.txt` will create all the aliases automatically.

If an error is encountered, **dalias** stops and indicates on which line the error occured.

## Save dynamic aliases into a file.

You may want to save your aliases, for instance, to use them on another computer.

To do so: `dalias dp <file>`


