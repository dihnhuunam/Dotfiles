# Dotfiles

Personal dotfiles for setting up an Ubuntu development environment. This repository focuses on terminal tooling, Zsh, WezTerm, Neovim, Nerd Fonts, and common packages for C/C++, Python, Qt, and OpenGL work.

## Support

- Ubuntu is the primary target, especially Ubuntu desktop environments with `apt`, `sudo`, `ibus`, and `gsettings`.
- Other distributions may work partially, but `package/ubuntu.sh` is written specifically for Ubuntu.
- Installation requires internet access and may prompt for your `sudo` password.

## Repository Structure

```text
.
├── install.sh
├── nvim
│   └── .config
│       └── nvim
│           ├── init.lua
│           └── lua
│               ├── helps.lua
│               ├── options.lua
│               └── plugins
│                   ├── catppuccin.lua
│                   ├── lsp-configs.lua
│                   ├── neotree.lua
│                   ├── telescope.lua
│                   └── treesitter.lua
├── lib
│   └── log.sh
├── package
│   ├── font.sh
│   ├── ubuntu.sh
│   ├── wezterm.sh
│   └── zsh.sh
├── wezterm
│   └── .config
│       └── wezterm
│           └── wezterm.lua
└── zsh
    └── .zshrc
```

## Quick Start

```bash
git clone https://github.com/dihnhuunam/Dotfiles.git ~/Dotfiles
cd ~/Dotfiles
bash install.sh
```

Back up an existing `~/.zshrc` before running the installer: `install.sh` removes it before linking the repository version. Move existing WezTerm and Neovim configurations to backup locations to avoid Stow conflicts.

After the script finishes, open a new terminal or log out and back in so the default shell and linked configuration are applied.

## What the Installer Does

`install.sh` runs these steps:

1. Installs Ubuntu packages from `package/ubuntu.sh`.
2. Restarts IBus when `ibus` is installed.
3. Installs JetBrainsMono Nerd Font.
4. Installs Oh My Zsh, Zsh plugins, and changes the default shell to Zsh.
5. Installs WezTerm from the official WezTerm apt repository.
6. Attempts to set WezTerm as the default terminal on GNOME.
7. Removes the existing `~/.zshrc` and uses GNU Stow to link the `zsh`, `wezterm`, and `nvim` configuration packages into `$HOME`.

## Installed Packages

`package/ubuntu.sh` installs these package groups:

- Basics: `git`, `gh`, `curl`, `wget`, `unzip`, `zip`, `tar`, `ca-certificates`, `gpg`, `fontconfig`, `stow`, `zsh`.
- GitLab CLI: `glab`; Ubuntu 24.04 and newer use `apt`, older Ubuntu versions use `snap`.
- C/C++: `build-essential`, `cmake`, `ninja-build`, `pkg-config`, `ccache`, `gdb`, `valgrind`, `clang`, `clangd`, `clang-format`, `clang-tidy`, `lldb`, `cppcheck`.
- Python: `python3`, `python3-full`, `python3-pip`, `python3-dev`, `python3-venv`, `python3-pylsp`, `pipx`, plus `cmakelang` (including `cmake-format`) through `pipx`.
- Qt runtime/helpers: `libxcb-cursor0`, `libxcb-cursor-dev`.
- OpenGL: `libgl1-mesa-dev`, `libglu1-mesa-dev`, `mesa-common-dev`, `mesa-utils`, `freeglut3-dev`, `libglfw3-dev`, `libglew-dev`, `libftgl-dev`.
- Boost: `libboost-all-dev`.
- Utilities: `ripgrep`, `fd-find`, `fzf`, `tree`, `htop`, `neovim`, `tree-sitter-cli`, `fastfetch`, `ibus-unikey`, `cloud-guest-utils`, `gparted`, `open-vm-tools`, `open-vm-tools-desktop`, `openssh-server`.

## Zsh

`package/zsh.sh` installs:

- Oh My Zsh into `~/.oh-my-zsh`.
- `zsh-syntax-highlighting`.
- `zsh-autosuggestions`.
- Zsh as the default shell with `chsh -s "$(which zsh)"`.

`zsh/.zshrc` configures:

- Oh My Zsh theme: `robbyrussell`.
- Plugins: `git`, `zsh-autosuggestions`, `zsh-syntax-highlighting`.
- `~/.local/bin` and `/opt/nvim-linux-x86_64/bin` in `PATH`.
- Qt 6.9.3 environment paths under `~/Qt/6.9.3/gcc_64`; the scripts do not install this Qt SDK.
- `nvim` as the default editor when available, otherwise `vim`.
- Short aliases: `home`, `work`, `ll`, `cls`, `gs`, `ga`, `gc`, `gp`, `gl`, `..`, `...`.

## WezTerm

`package/wezterm.sh` adds the `https://apt.fury.io/wez/` apt repository and installs the `wezterm` package.

`wezterm/.config/wezterm/wezterm.lua` configures:

- `JetBrainsMono Nerd Font Mono`, font size `12.5`, and disabled ligatures.
- Dark terminal colors, `0.9` background opacity, and a blinking bar cursor.
- Hidden tab bar and `10000` lines of scrollback.
- Default shell: `zsh`.
- Launcher entries for `Zsh`, `Bash`, and `Htop`.

Useful WezTerm key bindings:

| Key | Action |
| --- | --- |
| `Ctrl+Backspace` | Send Ctrl+W to delete the previous word |
| `Ctrl+Shift+C` | Copy |
| `Ctrl+Shift+V` | Paste |
| `Ctrl+Shift+P` | Command palette |
| `Ctrl+Shift+Space` | Quick select |
| `Ctrl+Shift+X` | Copy mode |
| `Ctrl+Shift+L` | Launcher |
| ``Alt+\`` | Split pane right |
| ``Alt+Shift+\`` | Split pane left |
| `Alt+-` | Split pane down |
| `Alt+Shift+-` | Split pane up |
| `Alt+Arrow` | Move focus between panes |
| `Alt+p` | Select pane |
| `Alt+Shift+P` | Swap with selected pane |
| `Alt+Shift+h/j/k/l` | Resize pane |
| `Alt+Enter` | Toggle pane zoom |
| `Alt+w` | Close current pane |

## Neovim

The `nvim` Stow package links its configuration into `~/.config/nvim`.

- `init.lua` bootstraps `lazy.nvim` and loads editor options, keymap help, and plugins.
- Editor defaults include relative line numbers, four-space indentation, persistent undo, and Space as the leader key.
- Plugins include Catppuccin Macchiato, Neo-tree, and Telescope with the native FZF sorter.
- Treesitter enables syntax highlighting and indentation for C, C++, and Python, with `c`, `cpp`, `python`, `lua`, `vim`, and `vimdoc` parsers installed automatically.
- The Treesitter configuration uses the `master` branch for Neovim 0.10/0.11 and tree-sitter CLI 0.25.x compatibility; see the [upstream requirements](https://github.com/nvim-treesitter/nvim-treesitter/blob/master/README.md#requirements). `package/ubuntu.sh` installs `tree-sitter-cli` through apt (the executable is `tree-sitter`); older Ubuntu releases may require a separate CLI installation if the package is unavailable.
- The first launch needs internet access to download the plugin manager and plugins. The native sorter builds with `make`; the installer includes `build-essential` and `ripgrep` for building and searching.

After changing the Treesitter plugin branch, run `:Lazy sync` and restart Neovim. Use `:TSInstallInfo` to check parsers and `:TSUpdate` to update them. The first parser installation needs internet access and a C compiler, provided by `build-essential`.

Useful Neovim key bindings (`<leader>` is Space):

| Key / command | Action |
| --- | --- |
| `:Key` | Open editor keymap help; press `q` to close |
| `<leader>w` / `<leader>q` | Save file / quit window |
| `<leader>e` | Toggle Neo-tree |
| `<leader>ff` / `<leader>fF` | Find files / include Git-ignored files |
| `<leader>fg` | Search project text |
| `<leader>fb` / `<leader>fh` / `<leader>ft` | Find buffers / help / Telescope pickers |
| `Ctrl+h/j/k/l` | Navigate windows |
| `<leader>sv` / `<leader>sh` | Split vertically / horizontally |
| `<leader>bn` / `<leader>bp` / `<leader>bd` | Next / previous / delete buffer |

## Font

`package/font.sh` downloads JetBrainsMono Nerd Font from the latest `ryanoasis/nerd-fonts` release and extracts it into:

```text
~/.local/share/fonts/JetBrainsMonoNerdFont
```

It then runs `fc-cache` to refresh the font cache.

## Linking Configs With Stow

`install.sh` automatically links `zsh`, `wezterm`, and `nvim` into `$HOME`. To link them manually, run these commands from the repository root:

```bash
stow --dir "$PWD" --target "$HOME" zsh
stow --dir "$PWD" --target "$HOME" wezterm
stow --dir "$PWD" --target "$HOME" nvim
```

To remove the links:

```bash
stow -D --dir "$PWD" --target "$HOME" zsh
stow -D --dir "$PWD" --target "$HOME" wezterm
stow -D --dir "$PWD" --target "$HOME" nvim
```

If `~/.zshrc`, `~/.config/wezterm/wezterm.lua`, or `~/.config/nvim` already exists, Stow may report a conflict. Back up the existing files before linking this configuration.

The `nvim` package contains the Neovim Lua configuration. The local `lazy-lock.json` generated by lazy.nvim is ignored by Git, so plugin revisions are not pinned by this repository.

## Run Individual Steps

If you do not want to run the full installer:

```bash
bash package/ubuntu.sh
bash package/font.sh
bash package/zsh.sh
bash package/wezterm.sh
```

## Notes

- Scripts use `set -e`, so they stop immediately on errors.
- `package/font.sh`, `package/wezterm.sh`, and `package/zsh.sh` download files from the internet.
- `package/zsh.sh` keeps an existing `.zshrc` during the Oh My Zsh install with `KEEP_ZSHRC=yes`, but `install.sh` removes that file before running Stow.
- After changing the default shell with `chsh`, log out and back in or start a new session for the change to take effect.

## Language Servers

`lua/plugins/lsp-configs.lua` installs `neovim/nvim-lspconfig` through lazy.nvim and uses the Neovim 0.11.3+ LSP API with `clangd` for C/C++ and `pylsp` for Python. The installer includes `clangd` and `python3-pylsp`. For an existing setup, install them with `sudo apt install clangd python3-pylsp` and restart Neovim.

Run `:Lazy sync` after adding this configuration. The plugin supplies server configurations; the server executables are installed separately by the package script. See the [nvim-lspconfig documentation](https://github.com/neovim/nvim-lspconfig#quickstart).

LSP provides diagnostics, completion, navigation, renaming, code actions, and formatting when supported by the server. Completion opens on server trigger characters; use `Ctrl+x Ctrl+o` to request completion manually and `Ctrl+y` to accept it. Run `:checkhealth vim.lsp` to inspect server status.

For CMake projects, generate compilation commands with `cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON`. If clangd cannot find the build directory, add `CompileFlags: { CompilationDatabase: build }` to the project's `.clangd` file. For Python virtual environments, activate the project's environment before launching Neovim.

| Key | Action |
| --- | --- |
| `gd` / `gr` | Go to definition / find references |
| `K` | Show documentation |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code actions |
| `<leader>d` | Show diagnostics |
| `[d` / `]d` | Previous / next diagnostic |
| `<leader>lf` | Format buffer |
