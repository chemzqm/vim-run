# Vim-run

Run a custom command in vim with current buffer and see the result side-by-side

## TODO
* syntax support for runresult

## Usage

Config the command by filetype:

``` vim
let g:vim_run_command_map = {
  \'javascript': 'node',
  \'php': 'php',
  \'python': 'python',
  \}
```

Run command with:

``` vim
:Run
```

Or you can specify the command after `Run`:

``` vim
:Run yourcommand
```

`yourcommand` will be used in the following `Run` and `Autorun` if they called with empty command argument

Run command with range:

``` vim
:1,10Run
```

Run command with visual select:

``` vim
:'<,'>RunRange
```

Toggle command autorun on save of current file:

``` vim
:AutoRun
```

