" Configuration defaults for ragtag.vim.
" All g:ragtag_* variables are defined here with sensible defaults. Users can
" override any variable in their vimrc before the plugin loads.

" Path to the ragtag CLI binary.
if !exists('g:ragtag_binary')
    let g:ragtag_binary = 'ragtag'
endif

" Path to ragtag config file. Empty string means auto-detect.
if !exists('g:ragtag_config')
    let g:ragtag_config = ''
endif

" Default --path value. Empty string means use the current buffer's file.
if !exists('g:ragtag_default_path')
    let g:ragtag_default_path = ''
endif

" Message prefix for all plugin output.
if !exists('g:ragtag_print_prefix')
    let g:ragtag_print_prefix = '[ragtag.vim] '
endif

" Retrieves the value of a ragtag configuration variable by key name.
" The key is appended to the 'ragtag_' prefix to form the full variable name.
function! ragtag#config#get(key) abort
    return get(g:, 'ragtag_' . a:key, '')
endfunction
