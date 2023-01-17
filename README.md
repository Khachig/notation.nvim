# notation.nvim

Tap into your second brain form the comfort of your text editor.

## What is Notation?

`notation.nvim` aims to be the vessel with which you sail through your second brain. It is meant to be out of your way when you're working with your notes, but provide useful utilities to create notes, search your notes, add tags and search notes by tags, with more features to come.

## Getting Started

It is very easy to setup `notation.nvim`.

[Neovim (v0.7.0)](https://github.com/neovim/neovim/releases/tag/v0.7.0) or higher is required for `notation.nvim` to work.

## Required Dependencies

- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)

## Installation

Using [packer.nvim](https://github.com/wbthomason/packer.nvim) with default setup.

```lua
use {
    'Khachig/notation.nvim',
    requires={
        {'nvim-lua/plenary.nvim'},
        {'nvim-telescope/telescope.nvim', branch='0.1.x'}
    },
    config=function()
        require('notation').setup()
    end
}
```

## Usage

You can use the plugin with the commands:

- `NTCreateNote`
- `NTCreateJournalEntry`
- `NTListNotes`
- `NTTagNote`
- `NTSearchTags`

### Default mappings

```
| Mapping      | Action                   |
|--------------|--------------------------|
| `<leader>nl` | List all notes           |
| `<leader>nc` | Create new note          |
| `<leader>nj` | Create new journal entry |
| `<leader>nt` | Tag note                 |
| `<leader>ns` | Search all tags          |
```

## Notation setup options

```lua
require('notation').setup({
    -- optionally set notes directory
    -- default is ~/Notes
    notes_dir = "~/Documents/mynotes",

    -- optionally disable default keymaps
    default_keymaps = false
})
```
