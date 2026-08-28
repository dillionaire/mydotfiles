# Dotfiles

Personal Zsh, Starship, and Ghostty configuration for Ubuntu and macOS.

## Included

- Zsh configuration, history behavior, aliases, and key bindings
- Oh My Zsh with autosuggestions, completions, history search, and syntax highlighting
- Starship prompt configuration
- Ghostty terminal configuration
- Optional installation of the command-line tools used by the configuration

Shell history, credentials, SSH keys, and machine secrets are intentionally not tracked.
Put one-machine-only shell settings in `~/.zshrc.local` and environment values in
`~/.zshenv.local`; both are loaded when present and ignored by Git.

## Install on a new computer

```sh
git clone https://github.com/dillionaire/mydotfiles.git ~/mydotfiles
cd ~/mydotfiles
./install.sh
exec zsh
```

On macOS, install [Homebrew](https://brew.sh) first. On Ubuntu, the installer uses
`apt` and may ask for your sudo password. To create only the configuration
symlinks without installing software:

```sh
./install.sh --links-only
```

Existing target files are renamed with a timestamp before links are created.

## Keep machines synchronized

Because the installed files are symlinks into this repository, edit them normally,
then commit and push from `~/mydotfiles`:

```sh
git add -A
git commit -m "Update shell configuration"
git push
```

On another computer:

```sh
cd ~/mydotfiles
git pull --ff-only
```

Run `./backup.sh` for a focused backup or `./uninstall.sh` to remove only the
symlinks managed by this repository.
