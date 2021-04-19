# DALIAS

```
#    _       _  o         
#  __)) ___  )) _  ___  __
# ((_( ((_( (( (( ((_( _))
```
Dynamic aliases management.

## Goal.

I needed a quick way to create aliases on the go without having to source any script or .shellrc.  
So I wrote **dalias** for this purpose. Simply put, it creates a script containing the  
command to be aliased, makes it executable and add a symlink to "$HOME/.local/bin" so it is  
immediately ready to use.

## Dependencies.

bash coreutils

## Install.

Clone this repository: `git clone https://gitlab.com/teegre/dalias.git`

Then: `make install`

## Uninstall.

`make uninstall`

## Usage

```
dalias
dalias new <name> <command> [arguments]
dalias del <name>
dalias ls
dalias help
```

## Options.

Invoked without options, **dalias** prints the list of existing aliases.

Other options are:

*  new: create a new dynamic alias.
*  del: delete an existing alias.
*  ls: print alias list.
*  help: show help and exit.

## Examples

To create a dynamic alias called *da* for **dalias**:

`dalias new da dalias '"$@"'`

The `'"$@"'` is mandatory since we want be able to pass options.

Let's try it:

```
> da ls
da    → dalias "$@"
```
