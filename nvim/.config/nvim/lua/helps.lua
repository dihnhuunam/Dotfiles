local help_text = [[
Neovim Keymaps

FILE
  <leader>w     Save file
  <leader>q     Quit current window

WINDOW NAVIGATION
  Ctrl+h        Move to left window
  Ctrl+j        Move to lower window
  Ctrl+k        Move to upper window
  Ctrl+l        Move to right window

WINDOW SPLIT
  <leader>sv    Vertical split
  <leader>sh    Horizontal split

WINDOW RESIZE
  Ctrl+Up       Increase window height
  Ctrl+Down     Decrease window height
  Ctrl+Left     Decrease window width
  Ctrl+Right    Increase window width

BUFFERS
  <leader>bn    Next buffer
  <leader>bp    Previous buffer
  <leader>bd    Delete current buffer

EDITING
  Visual J      Move selected lines down
  Visual K      Move selected lines up
  <leader>p     Paste without overwriting register

SCROLL
  Ctrl+d        Scroll down and center cursor
  Ctrl+u        Scroll up and center cursor

SEARCH
  n             Next search result
  N             Previous search result
  Esc           Clear search highlight
]]

vim.api.nvim_create_user_command("Key", function()
    local lines = vim.split(help_text, "\n")

    local buf = vim.api.nvim_create_buf(false, true)

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    vim.bo[buf].modifiable = false
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].filetype = "keyhelp"

    vim.cmd("vsplit")

    local win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(win, buf)

    vim.wo[win].number = false
    vim.wo[win].relativenumber = false
    vim.wo[win].cursorline = true

    -- Press q to close the help window
    vim.keymap.set("n", "q", "<cmd>close<CR>", {
        buffer = buf,
        silent = true,
        desc = "Close keymap help",
    })
end, {})
