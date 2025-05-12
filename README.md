# Roger's Developing Environment Files

- All the files are settled in `~/.dotfiles/`
- use `bash setup_link.sh` to establish the actual links.

## Extra

### Fix tmux messing with conda

- [reference](https://gist.github.com/ekreutz/995bb95e428358b9efa2b2f80b02143c)
- Problem: When running a conda environment and opening tmux on macOS, a utility called path_helper is run again. Essentially, the shell is initialized twice which messes up the `${PATH}` so that the wrong Python version shows up within tmux.
- Solution: If using bash, edit `/etc/profile` and add one line. (For zsh, edit `/etc/zprofile`)
    ```bash
    if [ -x /usr/libexec/path_helper ]; then
    PATH="" # <- ADD THIS LINE (right before path_helper call)
    eval `/usr/libexec/path_helper -s`
    fi
    ```
