-- =========================
-- Editor options
-- =========================

vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true

vim.o.expandtab = true
vim.o.shiftwidth = 0
vim.o.tabstop = 4

vim.o.swapfile = false
vim.o.writebackup = false
vim.o.undofile = true

-- Leader key
vim.g.mapleader = " "

-- =========================
-- Keymaps
-- =========================

-- File
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", {
    desc = "Save file",
})

vim.keymap.set("n", "<leader>q", "<cmd>q<CR>", {
    desc = "Quit window",
})

-- Navigate between windows
vim.keymap.set("n", "<C-h>", "<C-w>h", {
    desc = "Move to left window",
})

vim.keymap.set("n", "<C-j>", "<C-w>j", {
    desc = "Move to lower window",
})

vim.keymap.set("n", "<C-k>", "<C-w>k", {
    desc = "Move to upper window",
})

vim.keymap.set("n", "<C-l>", "<C-w>l", {
    desc = "Move to right window",
})

-- Split windows
vim.keymap.set("n", "<leader>sv", "<cmd>vsplit<CR>", {
    desc = "Vertical split",
})

vim.keymap.set("n", "<leader>sh", "<cmd>split<CR>", {
    desc = "Horizontal split",
})

-- Resize windows
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<CR>", {
    desc = "Increase window height",
})

vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<CR>", {
    desc = "Decrease window height",
})

vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<CR>", {
    desc = "Decrease window width",
})

vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<CR>", {
    desc = "Increase window width",
})

-- Buffers
vim.keymap.set("n", "<leader>bn", "<cmd>bnext<CR>", {
    desc = "Next buffer",
})

vim.keymap.set("n", "<leader>bp", "<cmd>bprevious<CR>", {
    desc = "Previous buffer",
})

vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>", {
    desc = "Delete buffer",
})

-- Move selected lines
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", {
    desc = "Move selection down",
})

vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", {
    desc = "Move selection up",
})

-- Keep cursor centered while scrolling
vim.keymap.set("n", "<C-d>", "<C-d>zz", {
    desc = "Scroll down and center cursor",
})

vim.keymap.set("n", "<C-u>", "<C-u>zz", {
    desc = "Scroll up and center cursor",
})

-- Keep cursor centered while navigating search results
vim.keymap.set("n", "n", "nzzzv", {
    desc = "Next search result",
})

vim.keymap.set("n", "N", "Nzzzv", {
    desc = "Previous search result",
})

-- Paste without replacing the current register
vim.keymap.set("x", "<leader>p", '"_dP', {
    desc = "Paste without overwriting register",
})

-- Clear search highlight
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", {
    desc = "Clear search highlight",
})
