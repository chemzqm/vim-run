# Vim-run

Run a custom command in vim with current buffer and see the result side-by-side

## Usage

Config the command by filetype:

``` vim
let g:vim_run_command_map = {
  \'javascript': 'node',
  \'php': 'php',
  \'python': 'python',
  \}
```

Or config the command for the current buffer, which have higher priority

``` vim
let b:run_cmd = 'mocha'
```

Run command with:

``` vim
:Run
```

Toggle command autorun on save:

``` vim
:AutoRun
```

