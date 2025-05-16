<h1 align="center">Roger Fan's dotfiles</h1>

<div align="center">
  <a href="https://github.com/obsidian-nvim/obsidian.nvim/pulse">
    <img alt="Last commit" src="https://img.shields.io/github/last-commit/rogerfan48/dotfiles?style=for-the-badge&logo=github&logoColor=D9E0EE&labelColor=302D41&color=9fdf9f">
  </a>

  <a href="https://github.com/neovim/neovim/releases/latest">
    <img alt="Latest Neovim" src="https://img.shields.io/github/v/release/neovim/neovim?style=for-the-badge&logo=neovim&logoColor=D9E0EE&label=Neovim&labelColor=302D41&color=99d6ff&sort=semver">
  </a>

  <a href="http://www.lua.org/">
    <img alt="Made with Lua" src="https://img.shields.io/badge/Built%20with%20Lua-grey?style=for-the-badge&logo=lua&logoColor=D9E0EE&label=Lua&labelColor=302D41&color=b3b3ff">
  </a>

  <a href="https://github.com/rogerfan48/dotfiles">
      <img alt="Size" src="https://img.shields.io/github/repo-size/rogerfan48/dotfiles?style=for-the-badge&logo=dotenv&color=DDB6F2&logoColor=D9E0EE&labelColor=302D41">
  </a>
</div>

<hr>

![dotfiles_demo](https://github.com/user-attachments/assets/06ec6058-c8d5-4912-80a2-f26a99832c4d)

<hr>

- All the files are settled in `~/.dotfiles/`
- use `bash setup_link.sh` to establish actual links.

## Features

- **Plugin Management**: Effortlessly manage, update and lazy-load plugins with [lazy.nvim](https://github.com/folke/lazy.nvim).  
- **Session Management**: Auto-save and restore working sessions via [auto-session](https://github.com/rmagatti/auto-session).  
- **Theme**: Enjoy a gorgeous, fully-customisable colourscheme with [catppuccin](https://github.com/catppuccin/nvim).  
- **Status & Tab Lines**: Sleek status line from [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) and tab management with [bufferline.nvim](https://github.com/akinsho/bufferline.nvim).  
- **File Explorer**: Navigate your project tree with [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim).  
- **Fuzzy Finding**: Lightning-fast file & symbol search using [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) + [telescope-fzf-native](https://github.com/nvim-telescope/telescope-fzf-native.nvim) and [telescope-ui-select](https://github.com/nvim-telescope/telescope-ui-select.nvim).  
- **Autocompletion & Snippets**: Smart completion powered by [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) (+ [cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp)) and snippets from [LuaSnip](https://github.com/L3MON4D3/LuaSnip) with [friendly-snippets](https://github.com/rafamadriz/friendly-snippets).  
- **Language Server & Tools**: LSP features via [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) with automatic installation from [mason.nvim](https://github.com/mason-org/mason.nvim) + [mason-lspconfig](https://github.com/mason-org/mason-lspconfig).  
- **Formatting**: Keep code pristine with [conform.nvim](https://github.com/stevearc/conform.nvim).  
- **Linting**: On-the-fly diagnostics through [nvim-lint](https://github.com/mfussenegger/nvim-lint).  
- **Git Integration**: Stage, preview and browse history using [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) and a full TUI with [lazygit.nvim](https://github.com/kdheepak/lazygit.nvim).  
- **Flutter Development**: First-class Flutter workflow via [flutter-tools.nvim](https://github.com/akinsho/flutter-tools.nvim).  
- **Markdown & Notes**: Live preview with [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim), rich rendering from [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) and second-brain management using [obsidian.nvim](https://github.com/epwalsh/obsidian.nvim).  
- **UI Enhancements**: Modern command-line, pop-ups and notifications courtesy of [noice.nvim](https://github.com/folke/noice.nvim), [dressing.nvim](https://github.com/stevearc/dressing.nvim) and [nui.nvim](https://github.com/MunifTanjim/nui.nvim).  
- **Editing Productivity**: Faster editing with [Comment.nvim](https://github.com/numToStr/Comment.nvim), [better-escape.nvim](https://github.com/max397574/better-escape.nvim), [nvim-surround](https://github.com/kylechui/nvim-surround), [nvim-autopairs](https://github.com/windwp/nvim-autopairs), [todo-comments.nvim](https://github.com/folke/todo-comments.nvim) and [substitute.nvim](https://github.com/gbprod/substitute.nvim).  
- **Syntax Highlighting**: Advanced parsing & rainbow parentheses via [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) and [rainbow-delimiters.nvim](https://github.com/HiPhish/rainbow-delimiters.nvim).  


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
