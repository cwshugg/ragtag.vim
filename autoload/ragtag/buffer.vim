" Task list buffer management for ragtag.vim.
" Manages the interactive scratch buffer that displays tasks in a formatted
" table with buffer-local key mappings for inline editing.

" Buffer name constant for the ragtag task list buffer.
let s:buffer_name = 'ragtag://task-list'

" Number of header lines (header row + separator row).
let s:header_line_count = 2


" ========================= Buffer Open/Close ================================ "

" Opens or reuses the task list buffer. Creates a new scratch buffer if one
" doesn't exist, or switches to the existing one. Sets buffer options and
" filetype.
function! ragtag#buffer#open() abort
    " Check if a buffer with the ragtag name already exists.
    let l:bufnr = bufnr(s:buffer_name)
    if l:bufnr != -1 && bufexists(l:bufnr)
        " Buffer exists — find its window or switch to it.
        let l:winnr = bufwinnr(l:bufnr)
        if l:winnr > 0
            execute l:winnr . 'wincmd w'
        else
            execute 'buffer ' . l:bufnr
        endif
        return
    endif

    " Create a new scratch buffer in a bottom split so we don't clobber the
    " user's current (possibly unsaved) buffer.
    execute 'botright new'
    execute 'file ' . s:buffer_name

    " Set buffer options for a scratch buffer.
    setlocal buftype=nofile
    setlocal bufhidden=wipe
    setlocal noswapfile
    setlocal nomodifiable
    setlocal nobuflisted
    setlocal filetype=ragtag_list
endfunction


" ========================= Buffer Rendering ================================= "

" Renders task data into the task list buffer. Takes a list of task dicts
" (parsed from CLI output) and formats them as aligned table rows. Sets up
" buffer-local key mappings.
"
" a:tasks       - list of task dicts from `ragtag#utils#parse_raw_tasks()`
" a:source_path - the --path that was used (stored for refresh)
" a:cli_args    - the full CLI argument list passed to exec() (stored for
"                 refresh so --filter, --sort, and --all are preserved)
function! ragtag#buffer#render(tasks, source_path, cli_args) abort
    " Store task data, source path, and full CLI args as buffer-local vars.
    let b:ragtag_tasks = a:tasks
    let b:ragtag_source_path = a:source_path
    let b:ragtag_cli_args = a:cli_args

    " Make the buffer temporarily modifiable to write content.
    setlocal modifiable

    " Clear the buffer.
    silent! %delete _

    " Handle empty task list.
    if empty(a:tasks)
        call setline(1, 'No tasks found.')
        setlocal nomodifiable
        return
    endif

    " Define columns: [header_name, task_dict_key, min_width].
    let l:columns = [
        \ ['ID',     'id',     10],
        \ ['Title',  'title',  16],
        \ ['Owner',  'owner',   8],
        \ ['Pri',    'priority', 5],
        \ ['Status', 'status',  9],
        \ ['File',   '',       14],
    \ ]

    " Compute column widths based on the widest value in each column.
    let l:widths = []
    for l:col in l:columns
        call add(l:widths, l:col[2])
    endfor

    for l:task in a:tasks
        let l:col_idx = 0
        for l:col in l:columns
            let l:val = ''
            if l:col[1] ==# 'id'
                " Show truncated ID (first 8 characters).
                let l:val = strpart(get(l:task, 'id', ''), 0, 8)
            elseif l:col[1] !=# ''
                let l:val = get(l:task, l:col[1], '')
            else
                " File column: combine file and line.
                let l:fpath = get(l:task, 'file', '')
                let l:fline = get(l:task, 'line', '')
                if !empty(l:fpath)
                    " Use relative path if possible.
                    let l:val = fnamemodify(l:fpath, ':~:.')
                    if !empty(l:fline)
                        let l:val .= ':' . l:fline
                    endif
                endif
            endif
            let l:val_len = len(l:val)
            if l:val_len > l:widths[l:col_idx]
                let l:widths[l:col_idx] = l:val_len
            endif
            let l:col_idx += 1
        endfor
    endfor

    " Build the header line.
    let l:header_parts = []
    let l:col_idx = 0
    for l:col in l:columns
        let l:padded = l:col[0]
        while len(l:padded) < l:widths[l:col_idx]
            let l:padded .= ' '
        endwhile
        call add(l:header_parts, ' ' . l:padded . ' ')
        let l:col_idx += 1
    endfor
    let l:header = join(l:header_parts, '│')

    " Build the separator line.
    let l:sep_parts = []
    let l:col_idx = 0
    for l:col in l:columns
        let l:dash = ''
        let l:w = l:widths[l:col_idx] + 2  " +2 for padding spaces
        while len(l:dash) < l:w
            let l:dash .= '─'
        endwhile
        call add(l:sep_parts, l:dash)
        let l:col_idx += 1
    endfor
    let l:separator = join(l:sep_parts, '┼')

    " Build task rows.
    let l:lines = [l:header, l:separator]
    for l:task in a:tasks
        let l:row_parts = []
        let l:col_idx = 0
        for l:col in l:columns
            let l:val = ''
            if l:col[1] ==# 'id'
                let l:val = strpart(get(l:task, 'id', ''), 0, 8)
            elseif l:col[1] !=# ''
                let l:val = get(l:task, l:col[1], '')
            else
                let l:fpath = get(l:task, 'file', '')
                let l:fline = get(l:task, 'line', '')
                if !empty(l:fpath)
                    let l:val = fnamemodify(l:fpath, ':~:.')
                    if !empty(l:fline)
                        let l:val .= ':' . l:fline
                    endif
                endif
            endif
            " Pad to column width.
            while len(l:val) < l:widths[l:col_idx]
                let l:val .= ' '
            endwhile
            call add(l:row_parts, ' ' . l:val . ' ')
            let l:col_idx += 1
        endfor
        call add(l:lines, join(l:row_parts, '│'))
    endfor

    " Write lines into the buffer.
    call setline(1, l:lines)

    " Set buffer back to read-only.
    setlocal nomodifiable

    " Set up buffer-local key mappings.
    nnoremap <buffer> <silent> <CR> :call ragtag#buffer#jump_to_task()<CR>
    nnoremap <buffer> <silent> s :call ragtag#buffer#edit_attr('status')<CR>
    nnoremap <buffer> <silent> p :call ragtag#buffer#edit_attr('priority')<CR>
    nnoremap <buffer> <silent> o :call ragtag#buffer#edit_attr('owner')<CR>
    nnoremap <buffer> <silent> t :call ragtag#buffer#edit_attr('title')<CR>
    nnoremap <buffer> <silent> d :call ragtag#buffer#edit_attr('description')<CR>
    nnoremap <buffer> <silent> q :bwipeout<CR>
    nnoremap <buffer> <silent> r :call ragtag#buffer#refresh()<CR>
endfunction


" ========================= Task Access ====================================== "

" Returns the task dict for the line under the cursor in the task list buffer.
" Returns an empty dict if the cursor is on a header or separator line.
function! ragtag#buffer#get_task_at_cursor() abort
    if !exists('b:ragtag_tasks')
        return {}
    endif
    let l:line_nr = line('.')
    let l:task_idx = l:line_nr - s:header_line_count - 1
    if l:task_idx < 0 || l:task_idx >= len(b:ragtag_tasks)
        return {}
    endif
    return b:ragtag_tasks[l:task_idx]
endfunction


" ========================= Navigation ======================================= "

" Jumps to the source file and line of the task under the cursor. Opens the
" file in the previous window (wincmd p).
function! ragtag#buffer#jump_to_task() abort
    let l:task = ragtag#buffer#get_task_at_cursor()
    if empty(l:task)
        call ragtag#utils#print_error('No task on this line.')
        return
    endif

    let l:file = get(l:task, 'file', '')
    let l:line_nr = get(l:task, 'line', '')
    if empty(l:file)
        call ragtag#utils#print_error('No file associated with this task.')
        return
    endif

    " Switch to the previous window, then open the file.
    wincmd p
    execute 'edit ' . fnameescape(l:file)
    if !empty(l:line_nr)
        execute l:line_nr
        normal! zz
    endif
endfunction


" ========================= Attribute Editing ================================ "

" Prompts the user to edit an attribute of the task under the cursor. Shows
" the current value, accepts new input, calls set-attr via CLI, and replaces
" the tag in the source file buffer.
"
" a:attr - attribute name (e.g., 'status', 'priority', 'owner')
function! ragtag#buffer#edit_attr(attr) abort
    let l:task = ragtag#buffer#get_task_at_cursor()
    if empty(l:task)
        call ragtag#utils#print_error('No task on this line.')
        return
    endif

    let l:id = get(l:task, 'id', '')
    if empty(l:id)
        call ragtag#utils#print_error('Task has no ID.')
        return
    endif

    let l:current_value = get(l:task, a:attr, '')
    let l:new_value = input('Set ' . a:attr . ' [' . l:current_value . ']: ')

    " Cancel if the user pressed <Esc> or entered empty string.
    if empty(l:new_value)
        echo ''
        return
    endif

    let l:source_path = get(b:, 'ragtag_source_path', '')

    try
        " Call the CLI to set the attribute.
        let l:cli_args = ['task', 'set-attr', l:id, a:attr, l:new_value,
            \ '--no-edit', '--path', l:source_path]
        let l:output = ragtag#utils#exec(l:cli_args)

        " Attempt to update the source file buffer in-place.
        let l:source_file = get(l:task, 'file', '')
        let l:source_line = str2nr(get(l:task, 'line', '0'))
        if !empty(l:source_file) && l:source_line > 0
            call s:update_source_buffer(l:source_file, l:source_line, l:output)
        endif

        " Refresh the task list buffer.
        call ragtag#buffer#refresh()
    catch
        call ragtag#utils#print_error(v:exception)
    endtry
endfunction

" Updates the source file buffer by finding the task tag at the given line and
" replacing it with the CLI output. If the source file buffer is not loaded,
" opens it hidden to perform the replacement.
function! s:update_source_buffer(file, line_nr, new_text) abort
    let l:bufnr = bufnr(a:file)
    let l:task_list_bufnr = bufnr('%')

    if l:bufnr != -1 && bufloaded(l:bufnr)
        " Source buffer is loaded — switch to it, replace, switch back.
        execute 'buffer ' . l:bufnr
        call cursor(a:line_nr, 1)
        try
            let l:location = ragtag#tag#find_tag_at_cursor()
            call ragtag#tag#replace_tag_in_buffer(l:location, a:new_text)
        catch
            " Best effort; ignore if tag can't be found.
        endtry
        execute 'buffer ' . l:task_list_bufnr
    else
        " Source buffer is not loaded — open it hidden.
        execute 'badd ' . fnameescape(a:file)
        let l:bufnr = bufnr(a:file)
        execute 'buffer ' . l:bufnr
        call cursor(a:line_nr, 1)
        try
            let l:location = ragtag#tag#find_tag_at_cursor()
            call ragtag#tag#replace_tag_in_buffer(l:location, a:new_text)
        catch
            " Best effort; ignore if tag can't be found.
        endtry
        " Leave the buffer modified but switch back to the task list.
        execute 'buffer ' . l:task_list_bufnr
    endif
endfunction


" ========================= Refresh ========================================== "

" Refreshes the task list by re-running the CLI command with the same
" arguments used on the last render (including --filter, --sort, --all).
function! ragtag#buffer#refresh() abort
    if !exists('b:ragtag_cli_args')
        call ragtag#utils#print_error('No CLI args stored for refresh.')
        return
    endif

    let l:cli_args = b:ragtag_cli_args
    let l:source_path = get(b:, 'ragtag_source_path', '')

    try
        let l:output = ragtag#utils#exec(l:cli_args)
        let l:tasks = ragtag#utils#parse_raw_tasks(l:output)
        call ragtag#buffer#render(l:tasks, l:source_path, l:cli_args)
    catch
        call ragtag#utils#print_error(v:exception)
    endtry
endfunction

" ========================= Summary Buffer =================================== "

" Buffer name for the ragtag task summary buffer.
let s:summary_buffer_name = 'ragtag://task-summary'

" Formats a single task into a one-line summary string.
" Format: ID_SHORT [OWNER] [PRIORITY/STATUS] [SPENT/ESTIMATE UNITS] TITLE
function! s:format_summary_line(task) abort
    let l:id = strpart(get(a:task, 'id', ''), 0, 8)
    let l:owner = get(a:task, 'owner', '')
    if empty(l:owner)
        let l:owner = '-'
    endif
    let l:priority = get(a:task, 'priority', '')
    if empty(l:priority)
        let l:priority = '-'
    endif
    let l:status = get(a:task, 'status', '')
    if empty(l:status)
        let l:status = '-'
    endif
    let l:spent = get(a:task, 'worktime_spent', '')
    if empty(l:spent)
        let l:spent = '0'
    endif
    let l:estimate = get(a:task, 'worktime_estimate', '')
    if empty(l:estimate)
        let l:estimate = '-'
    endif
    let l:units = get(a:task, 'worktime_units', '')
    if empty(l:units)
        let l:units = 'hours'
    endif
    let l:title = get(a:task, 'title', '')

    return printf('%s [%s] [%s/%s] [%s/%s %s] %s',
        \ l:id, l:owner, l:priority, l:status,
        \ l:spent, l:estimate, l:units, l:title)
endfunction

" Opens (or reuses) the task summary buffer and renders the given tasks.
" Each line corresponds to one task; pressing <CR> jumps to the task's
" source location. 'q' closes the buffer.
"
" a:tasks         - list of task dicts from `ragtag#utils#parse_raw_tasks()`
" a:source_winid  - window id to return to when jumping to a task
function! ragtag#buffer#open_summary(tasks, source_winid) abort
    " If a summary buffer already exists, wipe it so we re-render cleanly.
    let l:existing = bufnr(s:summary_buffer_name)
    if l:existing != -1 && bufexists(l:existing)
        execute 'bwipeout! ' . l:existing
    endif

    " Open a new scratch buffer in a bottom split.
    execute 'botright new'
    execute 'file ' . s:summary_buffer_name

    setlocal buftype=nofile
    setlocal bufhidden=wipe
    setlocal noswapfile
    setlocal nobuflisted

    " Render content.
    setlocal modifiable
    silent! %delete _

    if empty(a:tasks)
        call setline(1, 'No tasks found.')
        let b:ragtag_summary_tasks = []
    else
        let l:lines = []
        let l:meta = []
        for l:task in a:tasks
            call add(l:lines, s:format_summary_line(l:task))
            call add(l:meta, {
                \ 'file': get(l:task, 'file', ''),
                \ 'line': get(l:task, 'line', ''),
                \ })
        endfor
        call setline(1, l:lines)
        let b:ragtag_summary_tasks = l:meta
    endif

    setlocal nomodifiable

    " Store source window id for use by jump.
    let b:ragtag_summary_source_winid = a:source_winid

    " Filetype triggers syntax highlighting.
    setlocal filetype=ragtag_summary

    " Ensure highlight groups are defined before any matchadd() calls.
    call ragtag#highlight#define()

    " Key mappings.
    nnoremap <silent> <buffer> <CR> :call ragtag#buffer#summary_jump()<CR>
    nnoremap <silent> <buffer> q    :bwipeout<CR>
endfunction

" Jump handler for <CR> in the summary buffer. Looks up the task associated
" with the current line and opens its source file at the recorded line.
" If the file is already open in a window, switches to that window; otherwise
" returns to the source window and runs :edit there.
function! ragtag#buffer#summary_jump() abort
    if !exists('b:ragtag_summary_tasks')
        return
    endif

    let l:line_nr = line('.')
    let l:idx = l:line_nr - 1
    if l:idx < 0 || l:idx >= len(b:ragtag_summary_tasks)
        return
    endif

    let l:entry = b:ragtag_summary_tasks[l:idx]
    let l:file = get(l:entry, 'file', '')
    let l:src_line = get(l:entry, 'line', '')

    if empty(l:file)
        call ragtag#utils#print_error('No file associated with this task.')
        return
    endif

    let l:source_winid = get(b:, 'ragtag_summary_source_winid', 0)

    " Close the summary buffer first.
    bwipeout

    " If the file is already open in a window, jump there.
    let l:bufnr = bufnr(l:file)
    if l:bufnr != -1
        let l:winids = win_findbuf(l:bufnr)
        if !empty(l:winids)
            call win_gotoid(l:winids[0])
        else
            " Return to source window (if still valid) before :edit.
            if l:source_winid > 0 && win_id2win(l:source_winid) > 0
                call win_gotoid(l:source_winid)
            endif
            execute 'edit ' . fnameescape(l:file)
        endif
    else
        if l:source_winid > 0 && win_id2win(l:source_winid) > 0
            call win_gotoid(l:source_winid)
        endif
        execute 'edit ' . fnameescape(l:file)
    endif

    if !empty(l:src_line)
        execute l:src_line
        normal! zz
    endif
endfunction
