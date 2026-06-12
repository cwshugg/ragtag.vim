" Command implementations for the ragtag.vim plugin.
" Defines argonaut argument parsing, tab completion functions, and the main
" command handler functions for all user-facing ragtag commands.


" ============================= Argument Definitions ========================= "
" Following fops.vim convention: setter-based arg definitions at file scope.
" Short IDs are hidden from autocomplete; long IDs are shown.

" -h / --help (shared across all commands).
let s:arg_help = argonaut#arg#new()
let s:arg_help_argid = argonaut#argid#new('-', 'h')
call argonaut#argid#set_show_in_autocomplete(s:arg_help_argid, 0)
call argonaut#arg#add_argid(s:arg_help, s:arg_help_argid)
let s:arg_help_argid = argonaut#argid#new('--', 'help')
call argonaut#argid#set_show_in_autocomplete(s:arg_help_argid, 1)
call argonaut#arg#add_argid(s:arg_help, s:arg_help_argid)
call argonaut#arg#set_description(s:arg_help,
    \ 'Shows this help menu.'
\ )

" -p / --path (shared across all commands).
let s:arg_path = argonaut#arg#new()
let s:arg_path_argid = argonaut#argid#new('-', 'p')
call argonaut#argid#set_show_in_autocomplete(s:arg_path_argid, 0)
call argonaut#arg#add_argid(s:arg_path, s:arg_path_argid)
let s:arg_path_argid = argonaut#argid#new('--', 'path')
call argonaut#argid#set_show_in_autocomplete(s:arg_path_argid, 1)
call argonaut#arg#add_argid(s:arg_path, s:arg_path_argid)
call argonaut#arg#set_description(s:arg_path,
    \ 'File or directory to search.'
\ )
call argonaut#arg#set_value_required(s:arg_path, 1)
call argonaut#arg#set_value_hint(s:arg_path, 'PATH')


" ========================= RagtagTaskList Arguments ========================= "

" -f / --filter EXPR
let s:arg_filter = argonaut#arg#new()
let s:arg_filter_argid = argonaut#argid#new('-', 'f')
call argonaut#argid#set_show_in_autocomplete(s:arg_filter_argid, 0)
call argonaut#arg#add_argid(s:arg_filter, s:arg_filter_argid)
let s:arg_filter_argid = argonaut#argid#new('--', 'filter')
call argonaut#argid#set_show_in_autocomplete(s:arg_filter_argid, 1)
call argonaut#arg#add_argid(s:arg_filter, s:arg_filter_argid)
call argonaut#arg#set_description(s:arg_filter,
    \ 'Filter expression (e.g., status=active).'
\ )
call argonaut#arg#set_value_required(s:arg_filter, 1)
call argonaut#arg#set_value_hint(s:arg_filter, 'EXPR')

" -s / --sort FIELD
let s:arg_sort = argonaut#arg#new()
let s:arg_sort_argid = argonaut#argid#new('-', 's')
call argonaut#argid#set_show_in_autocomplete(s:arg_sort_argid, 0)
call argonaut#arg#add_argid(s:arg_sort, s:arg_sort_argid)
let s:arg_sort_argid = argonaut#argid#new('--', 'sort')
call argonaut#argid#set_show_in_autocomplete(s:arg_sort_argid, 1)
call argonaut#arg#add_argid(s:arg_sort, s:arg_sort_argid)
call argonaut#arg#set_description(s:arg_sort,
    \ 'Field to sort by (e.g., priority, status).'
\ )
call argonaut#arg#set_value_required(s:arg_sort, 1)
call argonaut#arg#set_value_hint(s:arg_sort, 'FIELD')

" -a / --all (boolean flag — include done/abandoned tasks).
let s:arg_all = argonaut#arg#new()
let s:arg_all_argid = argonaut#argid#new('-', 'a')
call argonaut#argid#set_show_in_autocomplete(s:arg_all_argid, 0)
call argonaut#arg#add_argid(s:arg_all, s:arg_all_argid)
let s:arg_all_argid = argonaut#argid#new('--', 'all')
call argonaut#argid#set_show_in_autocomplete(s:arg_all_argid, 1)
call argonaut#arg#add_argid(s:arg_all, s:arg_all_argid)
call argonaut#arg#set_description(s:arg_all,
    \ 'Include done and abandoned tasks.'
\ )


" ======================= RagtagTaskSetAttr Arguments ======================== "

" -i / --id ID
let s:arg_id = argonaut#arg#new()
let s:arg_id_argid = argonaut#argid#new('-', 'i')
call argonaut#argid#set_show_in_autocomplete(s:arg_id_argid, 0)
call argonaut#arg#add_argid(s:arg_id, s:arg_id_argid)
let s:arg_id_argid = argonaut#argid#new('--', 'id')
call argonaut#argid#set_show_in_autocomplete(s:arg_id_argid, 1)
call argonaut#arg#add_argid(s:arg_id, s:arg_id_argid)
call argonaut#arg#set_description(s:arg_id,
    \ 'Task ID (overrides cursor detection).'
\ )
call argonaut#arg#set_value_required(s:arg_id, 1)
call argonaut#arg#set_value_hint(s:arg_id, 'ID')

" -A / --attr ATTR (capital A to avoid conflict with -a/--all).
let s:arg_attr = argonaut#arg#new()
let s:arg_attr_argid = argonaut#argid#new('-', 'A')
call argonaut#argid#set_show_in_autocomplete(s:arg_attr_argid, 0)
call argonaut#arg#add_argid(s:arg_attr, s:arg_attr_argid)
let s:arg_attr_argid = argonaut#argid#new('--', 'attr')
call argonaut#argid#set_show_in_autocomplete(s:arg_attr_argid, 1)
call argonaut#arg#add_argid(s:arg_attr, s:arg_attr_argid)
call argonaut#arg#set_description(s:arg_attr,
    \ 'Attribute name (e.g., status, priority, owner).'
\ )
call argonaut#arg#set_value_required(s:arg_attr, 1)
call argonaut#arg#set_value_hint(s:arg_attr, 'ATTR')

" -v / --value VALUE
let s:arg_value = argonaut#arg#new()
let s:arg_value_argid = argonaut#argid#new('-', 'v')
call argonaut#argid#set_show_in_autocomplete(s:arg_value_argid, 0)
call argonaut#arg#add_argid(s:arg_value, s:arg_value_argid)
let s:arg_value_argid = argonaut#argid#new('--', 'value')
call argonaut#argid#set_show_in_autocomplete(s:arg_value_argid, 1)
call argonaut#arg#add_argid(s:arg_value, s:arg_value_argid)
call argonaut#arg#set_description(s:arg_value,
    \ 'New attribute value.'
\ )
call argonaut#arg#set_value_required(s:arg_value, 1)
call argonaut#arg#set_value_hint(s:arg_value, 'VALUE')


" ========================== RagtagQuery Arguments =========================== "

" -t / --tag TAG_NAME
let s:arg_tag = argonaut#arg#new()
let s:arg_tag_argid = argonaut#argid#new('-', 't')
call argonaut#argid#set_show_in_autocomplete(s:arg_tag_argid, 0)
call argonaut#arg#add_argid(s:arg_tag, s:arg_tag_argid)
let s:arg_tag_argid = argonaut#argid#new('--', 'tag')
call argonaut#argid#set_show_in_autocomplete(s:arg_tag_argid, 1)
call argonaut#arg#add_argid(s:arg_tag, s:arg_tag_argid)
call argonaut#arg#set_description(s:arg_tag,
    \ 'Tag name to search for (e.g., task, note).'
\ )
call argonaut#arg#set_value_required(s:arg_tag, 1)
call argonaut#arg#set_value_hint(s:arg_tag, 'TAG_NAME')


" ================================= Argsets ================================== "

" Argset for :RagtagTaskList — includes path, filter, sort, all, and help.
let s:task_list_argset = argonaut#argset#new([
    \ s:arg_help,
    \ s:arg_path,
    \ s:arg_filter,
    \ s:arg_sort,
    \ s:arg_all,
\ ])

" Argset for :RagtagTaskSetAttr — includes path, id, attr, value, and help.
let s:task_set_attr_argset = argonaut#argset#new([
    \ s:arg_help,
    \ s:arg_path,
    \ s:arg_id,
    \ s:arg_attr,
    \ s:arg_value,
\ ])

" Argset for :RagtagTaskGetAttr — includes path, id, attr, and help.
let s:task_get_attr_argset = argonaut#argset#new([
    \ s:arg_help,
    \ s:arg_path,
    \ s:arg_id,
    \ s:arg_attr,
\ ])

" Argset for :RagtagSummary — includes path and help only.
let s:summary_argset = argonaut#argset#new([
    \ s:arg_help,
    \ s:arg_path,
\ ])

" Argset for :RagtagQuery — includes path, tag, and help.
let s:query_argset = argonaut#argset#new([
    \ s:arg_help,
    \ s:arg_path,
    \ s:arg_tag,
\ ])


" ============================== Tab Completion ============================== "

" Tab completion function for :RagtagTaskList.
function! ragtag#commands#task_list_complete(arg, line, pos)
    return argonaut#completion#complete(a:arg, a:line, a:pos,
        \ s:task_list_argset)
endfunction

" Tab completion function for :RagtagTaskSetAttr.
function! ragtag#commands#task_set_attr_complete(arg, line, pos)
    return argonaut#completion#complete(a:arg, a:line, a:pos,
        \ s:task_set_attr_argset)
endfunction

" Tab completion function for :RagtagTaskGetAttr.
function! ragtag#commands#task_get_attr_complete(arg, line, pos)
    return argonaut#completion#complete(a:arg, a:line, a:pos,
        \ s:task_get_attr_argset)
endfunction

" Tab completion function for :RagtagSummary.
function! ragtag#commands#summary_complete(arg, line, pos)
    return argonaut#completion#complete(a:arg, a:line, a:pos,
        \ s:summary_argset)
endfunction

" Tab completion function for :RagtagQuery.
function! ragtag#commands#query_complete(arg, line, pos)
    return argonaut#completion#complete(a:arg, a:line, a:pos,
        \ s:query_argset)
endfunction


" ========================== Command Implementations ========================= "

" ---- RagtagTaskList -------------------------------------------------------- "
" Displays an interactive task list buffer with inline attribute editing.
" Runs `ragtag task list --format raw` and renders the output in a scratch
" buffer with table formatting and key mappings.
function! ragtag#commands#task_list(input) abort
    let l:parser = argonaut#argparser#new(s:task_list_argset)
    try
        call argonaut#argparser#parse(l:parser, a:input)
        if argonaut#argparser#has_arg(l:parser, '--help')
            call ragtag#utils#print('RagtagTaskList: Display interactive task list.')
            call argonaut#argparser#show_help(l:parser)
            return
        endif

        " Resolve the target path.
        let l:path = ragtag#utils#resolve_path(l:parser)

        " Build CLI arguments.
        let l:args = ['task', 'list', '--format', 'raw', '--path', l:path]

        " Append optional filter argument.
        if argonaut#argparser#has_arg(l:parser, '--filter')
            let l:filter_values = argonaut#argparser#get_arg(l:parser, '--filter')
            if len(l:filter_values) > 0
                let l:args += ['--filter', l:filter_values[0]]
            endif
        endif

        " Append optional sort argument.
        if argonaut#argparser#has_arg(l:parser, '--sort')
            let l:sort_values = argonaut#argparser#get_arg(l:parser, '--sort')
            if len(l:sort_values) > 0
                let l:args += ['--sort', l:sort_values[0]]
            endif
        endif

        " Append --all flag if specified.
        if argonaut#argparser#has_arg(l:parser, '--all')
            let l:args += ['--all']
        endif

        " Execute the CLI command and parse the output.
        let l:output = ragtag#utils#exec(l:args)
        let l:tasks = ragtag#utils#parse_raw_tasks(l:output)

        " Open the task list buffer and render the tasks.
        call ragtag#buffer#open()
        call ragtag#buffer#render(l:tasks, l:path)
    catch
        call ragtag#utils#print_error(v:exception)
    endtry
endfunction


" ---- RagtagTaskSetAttr ----------------------------------------------------- "
" Sets an attribute on a task. The task can be identified by explicit --id or
" by cursor detection (finding the @task(...) tag at the cursor position).
function! ragtag#commands#task_set_attr(input) abort
    let l:parser = argonaut#argparser#new(s:task_set_attr_argset)
    try
        call argonaut#argparser#parse(l:parser, a:input)
        if argonaut#argparser#has_arg(l:parser, '--help')
            call ragtag#utils#print('RagtagTaskSetAttr: Set a task attribute.')
            call argonaut#argparser#show_help(l:parser)
            return
        endif

        " Resolve the target path.
        let l:path = ragtag#utils#resolve_path(l:parser)

        " Determine the task ID: explicit --id or cursor detection.
        let l:id = ''
        let l:location = {}
        if argonaut#argparser#has_arg(l:parser, '--id')
            let l:id_values = argonaut#argparser#get_arg(l:parser, '--id')
            if len(l:id_values) > 0
                let l:id = l:id_values[0]
            endif
        endif
        if empty(l:id)
            let l:location = ragtag#tag#find_tag_at_cursor()
            let l:id = l:location.id
            if empty(l:id)
                call ragtag#utils#panic('No task ID found at cursor. Use --id to specify explicitly.')
            endif
        endif

        " Get the attribute name (required).
        if !argonaut#argparser#has_arg(l:parser, '--attr')
            call ragtag#utils#panic('--attr is required. Specify the attribute to set.')
        endif
        let l:attr_values = argonaut#argparser#get_arg(l:parser, '--attr')
        let l:attr = l:attr_values[0]

        " Get the value (required).
        if !argonaut#argparser#has_arg(l:parser, '--value')
            call ragtag#utils#panic('--value is required. Specify the new value.')
        endif
        let l:val_values = argonaut#argparser#get_arg(l:parser, '--value')
        let l:value = l:val_values[0]

        " Call the CLI to set the attribute.
        let l:output = ragtag#utils#exec(['task', 'set-attr', l:id, l:attr,
            \ l:value, '--no-edit', '--path', l:path])

        " If we detected the tag from the cursor, replace it in the buffer.
        if !empty(l:location)
            call ragtag#tag#replace_tag_in_buffer(l:location, l:output)
        endif

        call ragtag#utils#print('Set ' . l:attr . '=' . l:value .
            \ ' on task ' . strpart(l:id, 0, 8))
    catch
        call ragtag#utils#print_error(v:exception)
    endtry
endfunction


" ---- RagtagTaskGetAttr ----------------------------------------------------- "
" Retrieves and displays a single attribute value from a task. The task can be
" identified by explicit --id or by cursor detection.
function! ragtag#commands#task_get_attr(input) abort
    let l:parser = argonaut#argparser#new(s:task_get_attr_argset)
    try
        call argonaut#argparser#parse(l:parser, a:input)
        if argonaut#argparser#has_arg(l:parser, '--help')
            call ragtag#utils#print('RagtagTaskGetAttr: Get a task attribute.')
            call argonaut#argparser#show_help(l:parser)
            return
        endif

        " Resolve the target path.
        let l:path = ragtag#utils#resolve_path(l:parser)

        " Determine the task ID: explicit --id or cursor detection.
        let l:id = ''
        if argonaut#argparser#has_arg(l:parser, '--id')
            let l:id_values = argonaut#argparser#get_arg(l:parser, '--id')
            if len(l:id_values) > 0
                let l:id = l:id_values[0]
            endif
        endif
        if empty(l:id)
            let l:location = ragtag#tag#find_tag_at_cursor()
            let l:id = l:location.id
            if empty(l:id)
                call ragtag#utils#panic('No task ID found at cursor. Use --id to specify explicitly.')
            endif
        endif

        " Get the attribute name (required).
        if !argonaut#argparser#has_arg(l:parser, '--attr')
            call ragtag#utils#panic('--attr is required. Specify the attribute to retrieve.')
        endif
        let l:attr_values = argonaut#argparser#get_arg(l:parser, '--attr')
        let l:attr = l:attr_values[0]

        " Call the CLI to get the attribute value.
        let l:output = ragtag#utils#exec(['task', 'get-attr', l:id, l:attr,
            \ '--path', l:path])

        " Echo the result (trimmed of trailing newline).
        let l:result = substitute(l:output, '\n$', '', '')
        call ragtag#utils#print(l:attr . '=' . l:result)
    catch
        call ragtag#utils#print_error(v:exception)
    endtry
endfunction


" ---- RagtagSummary --------------------------------------------------------- "
" Displays a summary of tags found in the current file or directory by
" invoking `ragtag task summary`.
function! ragtag#commands#summary(input) abort
    let l:parser = argonaut#argparser#new(s:summary_argset)
    try
        call argonaut#argparser#parse(l:parser, a:input)
        if argonaut#argparser#has_arg(l:parser, '--help')
            call ragtag#utils#print('RagtagSummary: Display tag summary.')
            call argonaut#argparser#show_help(l:parser)
            return
        endif

        " Resolve the target path.
        let l:path = ragtag#utils#resolve_path(l:parser)

        " Call the CLI for a summary.
        let l:output = ragtag#utils#exec(['task', 'summary', '--path', l:path])

        " Display the output.
        let l:result = substitute(l:output, '\n$', '', '')
        if empty(l:result)
            call ragtag#utils#print('No tags found.')
        else
            echo l:result
        endif
    catch
        call ragtag#utils#print_error(v:exception)
    endtry
endfunction


" ---- RagtagQuery ----------------------------------------------------------- "
" Finds tags in the current buffer and sets up Vim search highlighting for
" navigation with n/N. Optionally filters by tag name.
function! ragtag#commands#query(input) abort
    let l:parser = argonaut#argparser#new(s:query_argset)
    try
        call argonaut#argparser#parse(l:parser, a:input)
        if argonaut#argparser#has_arg(l:parser, '--help')
            call ragtag#utils#print('RagtagQuery: Find and highlight tags.')
            call argonaut#argparser#show_help(l:parser)
            return
        endif

        " Resolve the target path (default to current file for highlighting).
        let l:path = ragtag#utils#resolve_path(l:parser)

        " Determine tag name filter if provided.
        let l:tag_name = ''
        if argonaut#argparser#has_arg(l:parser, '--tag')
            let l:tag_values = argonaut#argparser#get_arg(l:parser, '--tag')
            if len(l:tag_values) > 0
                let l:tag_name = l:tag_values[0]
            endif
        endif

        " Build CLI arguments.
        let l:args = ['query']
        if !empty(l:tag_name)
            let l:args += [l:tag_name]
        endif
        let l:args += ['--path', l:path]

        " Execute the query.
        let l:output = ragtag#utils#exec(l:args)
        let l:result = substitute(l:output, '\n$', '', '')

        if empty(l:result)
            call ragtag#utils#print('No matching tags found.')
            return
        endif

        " Parse output lines to extract unique tag names found.
        let l:lines = split(l:result, "\n")
        let l:tag_names = {}
        let l:match_count = 0
        for l:line in l:lines
            let l:match_count += 1
            " Try to extract tag name from lines like: file:line: @tagname(...)
            let l:tag_match = matchstr(l:line, '@\zs\w\+\ze(')
            if !empty(l:tag_match)
                let l:tag_names[l:tag_match] = 1
            endif
        endfor

        " Build a Vim regex pattern to match the tag strings.
        if !empty(l:tag_name)
            " Specific tag: match @tagname(...).
            let @/ = '@' . l:tag_name . '([^)]*)'
        else
            " All tags: join patterns for each unique tag name found.
            let l:patterns = []
            for l:name in keys(l:tag_names)
                call add(l:patterns, '@' . l:name . '([^)]*)')
            endfor
            if !empty(l:patterns)
                let @/ = join(l:patterns, '\|')
            else
                " Fallback: match any @word(...) pattern.
                let @/ = '@\w\+([^)]*)'
            endif
        endif

        " Enable search highlighting so the user can navigate with n/N.
        set hlsearch

        " Apply finer-grained highlight groups via matchadd() for tag
        " components in the current window.
        call clearmatches()
        call matchadd('RagtagTagSigil', '@\ze\w\+(')
        call matchadd('RagtagTagName', '@\zs\w\+\ze(')
        call matchadd('RagtagTagParen', '@\w\+\zs(\ze')
        call matchadd('RagtagTagParen', '@\w\+([^)]*\zs)\ze')
        call matchadd('RagtagAttrName', '(\zs\w\+\ze=\|,\s*\zs\w\+\ze=')
        call matchadd('RagtagAttrEquals', '\w\zs=\ze[^=]')
        call matchadd('RagtagAttrValue', '=\zs[^,)]*\ze')

        " Ensure highlight groups are defined.
        call ragtag#highlight#define()

        call ragtag#utils#print('Found ' . l:match_count .
            \ ' tag(s). Use n/N to navigate.')
    catch
        call ragtag#utils#print_error(v:exception)
    endtry
endfunction
