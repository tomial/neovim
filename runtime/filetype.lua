if vim.g.did_load_filetypes and vim.g.did_load_filetypes ~= 0 then
  return
end

-- For now, make this opt-in with a global variable
if vim.g.do_filetype_lua ~= 1 then
  return
end

vim.api.nvim_create_augroup('filetypedetect', { clear = false })

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  group = 'filetypedetect',
  callback = function(args)
    local ft, on_detect = vim.filetype.match({ filename = args.match, buf = args.buf })
    if not ft then
      -- Generic configuration file used as fallback
      ft = require('vim.filetype.detect').conf(args.file, args.buf)
      if ft then
        vim.api.nvim_cmd({ cmd = 'setf', args = { 'FALLBACK', ft } }, {})
      end
    else
      vim.api.nvim_buf_set_option(args.buf, 'filetype', ft)
      if on_detect then
        on_detect(args.buf)
      end
    end
  end,
})

-- These *must* be sourced after the autocommand above is created
if not vim.g.did_load_ftdetect then
  vim.cmd([[
  augroup filetypedetect
  runtime! ftdetect/*.vim
  runtime! ftdetect/*.lua
  augroup END
  ]])
end

-- Set a marker so that the ftdetect scripts are not sourced a second time by filetype.vim
vim.g.did_load_ftdetect = 1

-- If filetype.vim is disabled, set up the autocmd to use scripts.vim
if vim.g.did_load_filetypes then
  vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
    group = 'filetypedetect',
    command = "if !did_filetype() && expand('<amatch>') !~ g:ft_ignore_pat | runtime! scripts.vim | endif",
  })

  vim.api.nvim_create_autocmd('StdinReadPost', {
    group = 'filetypedetect',
    command = 'if !did_filetype() | runtime! scripts.vim | endif',
  })
end

if not vim.g.ft_ignore_pat then
  vim.g.ft_ignore_pat = '\\.\\(Z\\|gz\\|bz2\\|zip\\|tgz\\)$'
end
