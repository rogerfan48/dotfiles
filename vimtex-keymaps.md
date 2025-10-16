# Vimtex Keymaps Note

## Command

- `<localleader>li:` - `n`: vimtex-info
- `<localleader>lI:` - `n`: vimtex-info-full
- `<localleader>lt:` - `n`: vimtex-toc-open
- `<localleader>lT:` - `n`: vimtex-toc-toggle
- `<localleader>lq:` - `n`: vimtex-log
- `<localleader>lv:` - `n`: vimtex-view
- `<localleader>lr:` - `n`: vimtex-reverse-search
- `<localleader>ll:` - `n`: vimtex-compile
- `<localleader>lL:` - `nx`: vimtex-compile-selected
- `<localleader>lk:` - `n`: vimtex-stop
- `<localleader>lK:` - `n`: vimtex-stop-all
- `<localleader>le:` - `n`: vimtex-errors
- `<localleader>lo:` - `n`: vimtex-compile-output
- `<localleader>lg:` - `n`: vimtex-status
- `<localleader>lG:` - `n`: vimtex-status-all
- `<localleader>lc:` - `n`: vimtex-clean
- `<localleader>lC:` - `n`: vimtex-clean-full
- `<localleader>lm:` - `n`: vimtex-imaps-list
- `<localleader>lx:` - `n`: vimtex-reload
- `<localleader>lX:` - `n`: vimtex-reload-state
- `<localleader>ls:` - `n`: vimtex-toggle-main
- `<localleader>la:` - `n`: vimtex-context-menu

## Manipulation

### environment - e

- `yse` - `n`: vimtex-env-surround-line
- `yse` - `o`: vimtex-env-surround-operator
- `yse` - `x`: vimtex-env-surround-visual
- `dse` - `n`: vimtex-env-delete
- `cse` - `n`: vimtex-env-change

#### enumerate <-> itemize

- `tse` - `n`: vimtex-env-toggle

### command - c

- `ysc` - `nox` : vimtex-cmd-create
- `dsc` - `n`: vimtex-cmd-delete
- `csc` - `n`: vimtex-cmd-change

### math - m

- `dsm` - `n`: vimtex-math-delete
- `csm` - `n`: vimtex-math-change
- `tsm` - `n`: vimtex-env-toggle-math

### delimiter - d

- `dsd` - `n`: vimtex-delim-delete
- `csd` - `n`: vimtex-delim-change-math
- `tsd` - `nx`: vimtex-delim-toggle-modifier
- `tSD` - `nx`: vimtex-delim-toggle-modifier-reverse

### star

- `tss` - `n`: vimtex-env-toggle-star
- `tsc` - `n`: vimtex-cmd-toggle-star

### Miscellaneous

- `tsf` - `nx`: vimtex-cmd-toggle-frac - toggle between `\frac{num}{den}` and `num/den`
- `tsb` - `n`: vimtex-env-toggle-break - toggle the `\\` at the end of line
- `]]` - `i`: vimtex-delim-close - close the current environment or delimiter (insert mode)
