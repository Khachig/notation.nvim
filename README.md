# notation.nvim

Tap into your second brain from the comfort of your text editor.

## What is Notation?

`notation.nvim` aims to be the vessel with which you sail through your second brain. 
It is meant to be out of your way when you're working with your notes, 
but provide useful utilities to create notes, search your notes, add tags and 
search notes by tags, with more features to come.

**Note:** this plugin is primarily made for myself and to fit my own workflow. 
It still has many bugs that I'm incrementally fixing and might not fit your 
style or workflow at all. 
However, if you do somehow find this and decide to use it, feel free to add 
an issue or open a PR if you run into a bug or want to add a new feature.

## Getting Started

It is very easy to setup `notation.nvim`.

### Required Dependencies

- [Neovim (v0.7.0)](https://github.com/neovim/neovim/releases/tag/v0.7.0) or higher is required for `notation.nvim` to work.
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)

### Installation

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

You can use the plugin with the following commands:

- `NTCreateNote`
- `NTCreateJournalEntry`
- `NTListNotes`
- `NTTagNote`
- `NTSearchTags`

### Default keymaps

```
| Mapping    | Action                   |
|------------|--------------------------|
| <leader>nl | List all notes           |
| <leader>nc | Create new note          |
| <leader>nj | Create new journal entry |
| <leader>nt | Tag note                 |
| <leader>ns | Search all tags          |
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
