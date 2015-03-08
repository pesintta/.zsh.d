## ZSH Configuration repository

This is a repository holding some decent default settings for ZSH:
 * Colored prompt(s)
 * Autocorrection
 * Completion with grouping
 * Command history completion & configuration
 * Syntax highlighting (if included)
 * Persistent history
 * History substring searches
 * Persistent dirstack
 * Version Control System support in prompt

The configuration file and the repository in general was designed with speed and simplicity in mind. It should be relatively easy to clone and test.
 
 
## Installation:
 1. Clone the repo
   * git clone git@github.com/pesintta/.zsh.d/
 2. Symlink the included .zshrc into your $HOME/.zshrc
   * ln -s .zsh.d/.zshrc ~/.zshrc
 3. start zsh and enjoy!


## Uninstallation
 1. Remove the symlink
   * unlink $HOME/.zshrc 
 2. Delete the cloned repository
   * rm -r .zsh.d
