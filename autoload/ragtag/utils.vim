" Utility functions for ragtag.vim.
" Provides messaging helpers, shell command execution, path resolution, and
" output parsing functions used by the plugin's command implementations.


" ======================= Messaging and Error Handling ======================= "

" Prints an informational message prefixed with g:ragtag_print_prefix.
function! ragtag#utils#print(msg) abort
    echomsg ragtag#config#get('print_prefix') . a:msg
endfunction

" Prints an error message in ErrorMsg highlight, prefixed with
" g:ragtag_print_prefix.
function! ragtag#utils#print_error(msg) abort
    echohl ErrorMsg
    echomsg ragtag#config#get('print_prefix') . a:msg
    echohl None
endfunction

" Throws a raw (un-prefixed) exception. Used within try/catch flows to
" propagate errors up to the command handler, which prints the message via
" print_error() (which adds the prefix itself).
function! ragtag#utils#panic(msg) abort
    throw a:msg
endfunction


" =========================== Shell Helpers ================================== "

" Builds a ragtag CLI command string from a list of arguments.
" Prepends the configured binary path (g:ragtag_binary), shell-escapes all
" arguments, and always appends '--no-color'. If g:ragtag_config is set,
" appends '--config <path>'. Returns the full command string.
function! ragtag#utils#build_command(args) abort
    let l:cmd = shellescape(ragtag#config#get('binary'))
    for l:arg in a:args
        let l:cmd .= ' ' . shellescape(l:arg)
    endfor
    let l:cmd .= ' --no-color'
    let l:config = ragtag#config#get('config')
    if !empty(l:config)
        let l:cmd .= ' --config ' . shellescape(l:config)
    endif
    return l:cmd
endfunction

" Executes a ragtag CLI command via system(). Calls `ragtag#utils#build_command()`
" to construct the command string. Checks v:shell_error and throws on non-zero
" exit. Returns the raw stdout string on success.
function! ragtag#utils#exec(args) abort
    let l:binary = ragtag#config#get('binary')
    if !executable(l:binary)
        call ragtag#utils#panic('ragtag binary not found: "' . l:binary . '". Set g:ragtag_binary to the correct path.')
    endif
    let l:cmd = ragtag#utils#build_command(a:args)
    let l:output = system(l:cmd)
    if v:shell_error != 0
        let l:err = substitute(l:output, '\n$', '', '')
        call ragtag#utils#panic('Command failed: ' . l:err)
    endif
    return l:output
endfunction


" ============================== Path Helpers ================================ "

" Returns the resolved --path value from the argument parser. The resolution
" order is:
"   1. Explicit --path argument
"   2. g:ragtag_default_path
"   3. b:ragtag_source_path (when inside the task-list scratch buffer)
"   4. expand('%:p') — but only for ordinary file buffers (empty &buftype),
"      which excludes ragtag://, fugitive://, netrw, quickfix, etc.
"   5. getcwd() as a final fallback
function! ragtag#utils#resolve_path(parser) abort
    if argonaut#argparser#has_arg(a:parser, '--path')
        let l:values = argonaut#argparser#get_arg(a:parser, '--path')
        if len(l:values) > 0
            return l:values[0]
        endif
    endif
    let l:default = ragtag#config#get('default_path')
    if !empty(l:default)
        return l:default
    endif
    " Prefer the stored source path when inside the task-list buffer.
    if exists('b:ragtag_source_path') && !empty(b:ragtag_source_path)
        return b:ragtag_source_path
    endif
    let l:current = expand('%:p')
    if !empty(l:current) && empty(&buftype)
        return l:current
    endif
    return getcwd()
endfunction


" ============================ Output Parsing ================================ "

" Parses raw key=value output from `ragtag task list --format raw`.
" Each task is separated by a blank line. Returns a list of task dicts,
" where each dict maps attribute names to their string values.
function! ragtag#utils#parse_raw_tasks(output) abort
    let l:tasks = []
    let l:current = {}
    for l:line in split(a:output, "\n")
        if empty(l:line)
            if !empty(l:current)
                call add(l:tasks, l:current)
                let l:current = {}
            endif
            continue
        endif
        let l:eq_idx = stridx(l:line, '=')
        if l:eq_idx < 0
            continue
        endif
        let l:key = strpart(l:line, 0, l:eq_idx)
        let l:value = strpart(l:line, l:eq_idx + 1)
        let l:current[l:key] = l:value
    endfor
    if !empty(l:current)
        call add(l:tasks, l:current)
    endif
    return l:tasks
endfunction
