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
    \ 'Target file or directory.'
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


" =========== RagtagTaskPrioritize / RagtagTaskCreate Arguments ============= "

" -P / --priority NUM (capital P to avoid conflict with -p/--path).
let s:arg_priority = argonaut#arg#new()
let s:arg_priority_argid = argonaut#argid#new('-', 'P')
call argonaut#argid#set_show_in_autocomplete(s:arg_priority_argid, 0)
call argonaut#arg#add_argid(s:arg_priority, s:arg_priority_argid)
let s:arg_priority_argid = argonaut#argid#new('--', 'priority')
call argonaut#argid#set_show_in_autocomplete(s:arg_priority_argid, 1)
call argonaut#arg#add_argid(s:arg_priority, s:arg_priority_argid)
call argonaut#arg#set_description(s:arg_priority,
    \ 'Task priority (numeric).'
\ )
call argonaut#arg#set_value_required(s:arg_priority, 1)
call argonaut#arg#set_value_hint(s:arg_priority, 'NUM')

" -T / --title TITLE (capital T).
let s:arg_title = argonaut#arg#new()
let s:arg_title_argid = argonaut#argid#new('-', 'T')
call argonaut#argid#set_show_in_autocomplete(s:arg_title_argid, 0)
call argonaut#arg#add_argid(s:arg_title, s:arg_title_argid)
let s:arg_title_argid = argonaut#argid#new('--', 'title')
call argonaut#argid#set_show_in_autocomplete(s:arg_title_argid, 1)
call argonaut#arg#add_argid(s:arg_title, s:arg_title_argid)
call argonaut#arg#set_description(s:arg_title,
    \ 'Task title (required for create).'
\ )
call argonaut#arg#set_value_required(s:arg_title, 1)
call argonaut#arg#set_value_hint(s:arg_title, 'TITLE')

" -D / --description DESC (capital D).
let s:arg_description = argonaut#arg#new()
let s:arg_description_argid = argonaut#argid#new('-', 'D')
call argonaut#argid#set_show_in_autocomplete(s:arg_description_argid, 0)
call argonaut#arg#add_argid(s:arg_description, s:arg_description_argid)
let s:arg_description_argid = argonaut#argid#new('--', 'description')
call argonaut#argid#set_show_in_autocomplete(s:arg_description_argid, 1)
call argonaut#arg#add_argid(s:arg_description, s:arg_description_argid)
call argonaut#arg#set_description(s:arg_description,
    \ 'Task description.'
\ )
call argonaut#arg#set_value_required(s:arg_description, 1)
call argonaut#arg#set_value_hint(s:arg_description, 'DESC')

" -O / --owner OWNER (capital O).
let s:arg_owner = argonaut#arg#new()
let s:arg_owner_argid = argonaut#argid#new('-', 'O')
call argonaut#argid#set_show_in_autocomplete(s:arg_owner_argid, 0)
call argonaut#arg#add_argid(s:arg_owner, s:arg_owner_argid)
let s:arg_owner_argid = argonaut#argid#new('--', 'owner')
call argonaut#argid#set_show_in_autocomplete(s:arg_owner_argid, 1)
call argonaut#arg#add_argid(s:arg_owner, s:arg_owner_argid)
call argonaut#arg#set_description(s:arg_owner,
    \ 'Task owner.'
\ )
call argonaut#arg#set_value_required(s:arg_owner, 1)
call argonaut#arg#set_value_hint(s:arg_owner, 'OWNER')

" -S / --status STATUS (capital S to avoid conflict with -s/--sort).
let s:arg_status = argonaut#arg#new()
let s:arg_status_argid = argonaut#argid#new('-', 'S')
call argonaut#argid#set_show_in_autocomplete(s:arg_status_argid, 0)
call argonaut#arg#add_argid(s:arg_status, s:arg_status_argid)
let s:arg_status_argid = argonaut#argid#new('--', 'status')
call argonaut#argid#set_show_in_autocomplete(s:arg_status_argid, 1)
call argonaut#arg#add_argid(s:arg_status, s:arg_status_argid)
call argonaut#arg#set_description(s:arg_status,
    \ 'Task status (e.g., active, inactive, blocked).'
\ )
call argonaut#arg#set_value_required(s:arg_status, 1)
call argonaut#arg#set_value_hint(s:arg_status, 'STATUS')

" -E / --worktime-estimate NUM
let s:arg_worktime_estimate = argonaut#arg#new()
let s:arg_worktime_estimate_argid = argonaut#argid#new('-', 'E')
call argonaut#argid#set_show_in_autocomplete(s:arg_worktime_estimate_argid, 0)
call argonaut#arg#add_argid(s:arg_worktime_estimate, s:arg_worktime_estimate_argid)
let s:arg_worktime_estimate_argid = argonaut#argid#new('--', 'worktime-estimate')
call argonaut#argid#set_show_in_autocomplete(s:arg_worktime_estimate_argid, 1)
call argonaut#arg#add_argid(s:arg_worktime_estimate, s:arg_worktime_estimate_argid)
call argonaut#arg#set_description(s:arg_worktime_estimate,
    \ 'Estimated work time for the task.'
\ )
call argonaut#arg#set_value_required(s:arg_worktime_estimate, 1)
call argonaut#arg#set_value_hint(s:arg_worktime_estimate, 'NUM')

" -W / --worktime-spent NUM
let s:arg_worktime_spent = argonaut#arg#new()
let s:arg_worktime_spent_argid = argonaut#argid#new('-', 'W')
call argonaut#argid#set_show_in_autocomplete(s:arg_worktime_spent_argid, 0)
call argonaut#arg#add_argid(s:arg_worktime_spent, s:arg_worktime_spent_argid)
let s:arg_worktime_spent_argid = argonaut#argid#new('--', 'worktime-spent')
call argonaut#argid#set_show_in_autocomplete(s:arg_worktime_spent_argid, 1)
call argonaut#arg#add_argid(s:arg_worktime_spent, s:arg_worktime_spent_argid)
call argonaut#arg#set_description(s:arg_worktime_spent,
    \ 'Work time already spent on the task.'
\ )
call argonaut#arg#set_value_required(s:arg_worktime_spent, 1)
call argonaut#arg#set_value_hint(s:arg_worktime_spent, 'NUM')

" -U / --worktime-units UNITS
let s:arg_worktime_units = argonaut#arg#new()
let s:arg_worktime_units_argid = argonaut#argid#new('-', 'U')
call argonaut#argid#set_show_in_autocomplete(s:arg_worktime_units_argid, 0)
call argonaut#arg#add_argid(s:arg_worktime_units, s:arg_worktime_units_argid)
let s:arg_worktime_units_argid = argonaut#argid#new('--', 'worktime-units')
call argonaut#argid#set_show_in_autocomplete(s:arg_worktime_units_argid, 1)
call argonaut#arg#add_argid(s:arg_worktime_units, s:arg_worktime_units_argid)
call argonaut#arg#set_description(s:arg_worktime_units,
    \ 'Units for worktime values (e.g., hours, days).'
\ )
call argonaut#arg#set_value_required(s:arg_worktime_units, 1)
call argonaut#arg#set_value_hint(s:arg_worktime_units, 'UNITS')

" --pid PID (no short form).
let s:arg_pid = argonaut#arg#new()
let s:arg_pid_argid = argonaut#argid#new('--', 'pid')
call argonaut#argid#set_show_in_autocomplete(s:arg_pid_argid, 1)
call argonaut#arg#add_argid(s:arg_pid, s:arg_pid_argid)
call argonaut#arg#set_description(s:arg_pid,
    \ 'Parent task ID.'
\ )
call argonaut#arg#set_value_required(s:arg_pid, 1)
call argonaut#arg#set_value_hint(s:arg_pid, 'PID')


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

" Argset for :RagtagTaskSummary — includes path, sort, and help.
let s:task_summary_argset = argonaut#argset#new([
    \ s:arg_help,
    \ s:arg_path,
    \ s:arg_sort,
\ ])

" Argset for :RagtagQuery — includes path, tag, and help.
let s:query_argset = argonaut#argset#new([
    \ s:arg_help,
    \ s:arg_path,
    \ s:arg_tag,
\ ])

" Argset for status-change commands (complete, activate, deactivate, block,
" abandon) — all share the same structure: id, path, and help.
let s:task_status_argset = argonaut#argset#new([
    \ s:arg_help,
    \ s:arg_path,
    \ s:arg_id,
\ ])

" Argset for :RagtagTaskPrioritize — id, priority, path, and help.
let s:task_prioritize_argset = argonaut#argset#new([
    \ s:arg_help,
    \ s:arg_path,
    \ s:arg_id,
    \ s:arg_priority,
\ ])

" Argset for :RagtagTaskCreate — title (required), plus all optional fields.
let s:task_create_argset = argonaut#argset#new([
    \ s:arg_help,
    \ s:arg_path,
    \ s:arg_title,
    \ s:arg_description,
    \ s:arg_owner,
    \ s:arg_status,
    \ s:arg_priority,
    \ s:arg_worktime_estimate,
    \ s:arg_worktime_spent,
    \ s:arg_worktime_units,
    \ s:arg_pid,
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

" Tab completion function for :RagtagTaskSummary. Reuses the summary argset
" since both take only --path and --help.
function! ragtag#commands#task_summary_complete(arg, line, pos)
    return argonaut#completion#complete(a:arg, a:line, a:pos,
        \ s:task_summary_argset)
endfunction

" Tab completion function for :RagtagQuery.
function! ragtag#commands#query_complete(arg, line, pos)
    return argonaut#completion#complete(a:arg, a:line, a:pos,
        \ s:query_argset)
endfunction

" Tab completion function for :RagtagTaskComplete.
function! ragtag#commands#task_complete_complete(arg, line, pos)
    return argonaut#completion#complete(a:arg, a:line, a:pos,
        \ s:task_status_argset)
endfunction

" Tab completion function for :RagtagTaskActivate.
function! ragtag#commands#task_activate_complete(arg, line, pos)
    return argonaut#completion#complete(a:arg, a:line, a:pos,
        \ s:task_status_argset)
endfunction

" Tab completion function for :RagtagTaskDeactivate.
function! ragtag#commands#task_deactivate_complete(arg, line, pos)
    return argonaut#completion#complete(a:arg, a:line, a:pos,
        \ s:task_status_argset)
endfunction

" Tab completion function for :RagtagTaskBlock.
function! ragtag#commands#task_block_complete(arg, line, pos)
    return argonaut#completion#complete(a:arg, a:line, a:pos,
        \ s:task_status_argset)
endfunction

" Tab completion function for :RagtagTaskAbandon.
function! ragtag#commands#task_abandon_complete(arg, line, pos)
    return argonaut#completion#complete(a:arg, a:line, a:pos,
        \ s:task_status_argset)
endfunction

" Tab completion function for :RagtagTaskPrioritize.
function! ragtag#commands#task_prioritize_complete(arg, line, pos)
    return argonaut#completion#complete(a:arg, a:line, a:pos,
        \ s:task_prioritize_argset)
endfunction

" Tab completion function for :RagtagTaskCreate.
function! ragtag#commands#task_create_complete(arg, line, pos)
    return argonaut#completion#complete(a:arg, a:line, a:pos,
        \ s:task_create_argset)
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
        let l:args = ['task', 'list', '--format', 'raw', '--all', '--path', l:path]

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
        call ragtag#buffer#render(l:tasks, l:path, l:args)
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
" Displays a summary of all tags found in the current file or directory by
" invoking `ragtag summary`.
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
        let l:output = ragtag#utils#exec(['summary', '--path', l:path])

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


" ---- RagtagTaskSummary ----------------------------------------------------- "
" Displays a summary of tasks in an interactive scratch buffer. Each task is
" rendered as a single line; pressing <CR> on a line opens the task's source
" file at the corresponding line. Press 'q' to close the summary buffer.
function! ragtag#commands#task_summary(input) abort
    let l:parser = argonaut#argparser#new(s:task_summary_argset)
    try
        call argonaut#argparser#parse(l:parser, a:input)
        if argonaut#argparser#has_arg(l:parser, '--help')
            call ragtag#utils#print('RagtagTaskSummary: Display task summary.')
            call argonaut#argparser#show_help(l:parser)
            return
        endif

        " Resolve the target path.
        let l:path = ragtag#utils#resolve_path(l:parser)

        " Determine sort mode (default: appearance).
        let l:sort = 'appearance'
        if argonaut#argparser#has_arg(l:parser, '--sort')
            let l:sort_values = argonaut#argparser#get_arg(l:parser, '--sort')
            if len(l:sort_values) > 0
                let l:sort = l:sort_values[0]
            endif
        endif

        " Fetch raw task data sorted by the chosen field.
        let l:output = ragtag#utils#exec(
            \ ['task', 'list', '--format', 'raw', '--all',
            \  '--sort', l:sort, '--path', l:path])
        let l:tasks = ragtag#utils#parse_raw_tasks(l:output)

        " Remember the source window so we can return there for jumps.
        let l:source_winid = win_getid()

        call ragtag#buffer#open_summary(l:tasks, l:source_winid)
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

        " Ensure highlight groups are defined BEFORE matchadd() calls so
        " that the highlight group names exist (otherwise matchadd() raises
        " E28: No such highlight group name).
        call ragtag#highlight#define()

        " Apply finer-grained highlight groups via matchadd() for tag
        " components in the current window. Priority -1 ensures that Vim's
        " built-in search highlighting (hlsearch) renders on top when the
        " user navigates with n/N, while the syntax colors persist once the
        " search is cleared.
        call clearmatches()
        call matchadd('RagtagTagSigil', '@\ze\w\+(', -1)
        call matchadd('RagtagTagName', '@\zs\w\+\ze(', -1)
        call matchadd('RagtagTagParen', '@\w\+\zs(\ze', -1)
        call matchadd('RagtagTagParen', '@\w\+([^)]*\zs)\ze', -1)
        call matchadd('RagtagAttrName', '(\zs\w\+\ze=\|,\s*\zs\w\+\ze=', -1)
        call matchadd('RagtagAttrEquals', '\w\zs=\ze[^=]', -1)
        call matchadd('RagtagAttrValue', '=\zs[^,)]*\ze', -1)

        " Jump to the first match so the user starts on a tag. Using
        " search() with the 'w' flag wraps from the top and triggers
        " hlsearch immediately (unlike normal! n which defers redraw).
        call cursor(1, 1)
        call search(@/, 'w')

        call ragtag#utils#print('Found ' . l:match_count . ' tag(s).')
    catch
        call ragtag#utils#print_error(v:exception)
    endtry
endfunction


" ========================= Status-Change Helper ============================= "

" Shared implementation for all status-change commands (complete, activate,
" deactivate, block, abandon). Resolves the task ID from --id or cursor
" detection, calls the appropriate CLI subcommand, and replaces the tag in the
" buffer if the ID was cursor-detected.
"
" a:input      - raw argument string from the Vim command
" a:subcommand - CLI subcommand name (e.g., 'complete', 'activate')
" a:verb       - past-tense verb for the confirmation message (e.g., 'Completed')
" a:state      - adjective/state word for the --help description (e.g., 'done')
" a:argset     - argset object to use for parsing
function! s:run_status_command(input, subcommand, verb, state, argset) abort
    let l:parser = argonaut#argparser#new(a:argset)
    try
        call argonaut#argparser#parse(l:parser, a:input)
        if argonaut#argparser#has_arg(l:parser, '--help')
            " Derive the present-tense command name from the subcommand
            " (e.g. 'complete' → 'RagtagTaskComplete').
            let l:cmd_name = 'RagtagTask' .
                \ toupper(strpart(a:subcommand, 0, 1)) .
                \ strpart(a:subcommand, 1)
            call ragtag#utils#print(l:cmd_name .
                \ ': Mark task as ' . a:state . '.')
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

        " Call the CLI to change the task status.
        let l:output = ragtag#utils#exec(['task', a:subcommand, l:id,
            \ '--no-edit', '--path', l:path])

        " If we detected the tag from the cursor, replace it in the buffer.
        if !empty(l:location)
            call ragtag#tag#replace_tag_in_buffer(l:location, l:output)
        endif

        call ragtag#utils#print(a:verb . ' task ' . strpart(l:id, 0, 8))
    catch
        call ragtag#utils#print_error(v:exception)
    endtry
endfunction


" ---- RagtagTaskComplete ---------------------------------------------------- "
" Marks a task as done. The task can be identified by explicit --id or by
" placing the cursor on a @task(...) tag in the current buffer.
function! ragtag#commands#task_complete(input) abort
    call s:run_status_command(a:input, 'complete', 'Completed', 'done',
        \ s:task_status_argset)
endfunction


" ---- RagtagTaskActivate ---------------------------------------------------- "
" Sets a task's status to active. The task can be identified by explicit --id
" or by cursor detection.
function! ragtag#commands#task_activate(input) abort
    call s:run_status_command(a:input, 'activate', 'Activated', 'active',
        \ s:task_status_argset)
endfunction


" ---- RagtagTaskDeactivate -------------------------------------------------- "
" Sets a task's status to inactive. The task can be identified by explicit
" --id or by cursor detection.
function! ragtag#commands#task_deactivate(input) abort
    call s:run_status_command(a:input, 'deactivate', 'Deactivated', 'inactive',
        \ s:task_status_argset)
endfunction


" ---- RagtagTaskBlock ------------------------------------------------------- "
" Sets a task's status to blocked. The task can be identified by explicit --id
" or by cursor detection.
function! ragtag#commands#task_block(input) abort
    call s:run_status_command(a:input, 'block', 'Blocked', 'blocked',
        \ s:task_status_argset)
endfunction


" ---- RagtagTaskAbandon ----------------------------------------------------- "
" Sets a task's status to abandoned. The task can be identified by explicit
" --id or by cursor detection.
function! ragtag#commands#task_abandon(input) abort
    call s:run_status_command(a:input, 'abandon', 'Abandoned', 'abandoned',
        \ s:task_status_argset)
endfunction


" ---- RagtagTaskPrioritize -------------------------------------------------- "
" Sets a task's priority value. The task can be identified by explicit --id or
" by placing the cursor on a @task(...) tag in the current buffer.
function! ragtag#commands#task_prioritize(input) abort
    let l:parser = argonaut#argparser#new(s:task_prioritize_argset)
    try
        call argonaut#argparser#parse(l:parser, a:input)
        if argonaut#argparser#has_arg(l:parser, '--help')
            call ragtag#utils#print('RagtagTaskPrioritize: Set a task priority.')
            call argonaut#argparser#show_help(l:parser)
            return
        endif

        " Resolve the target path.
        let l:path = ragtag#utils#resolve_path(l:parser)

        " Get the priority value (required).
        if !argonaut#argparser#has_arg(l:parser, '--priority')
            call ragtag#utils#panic('--priority is required. Specify the new priority value.')
        endif
        let l:priority_values = argonaut#argparser#get_arg(l:parser, '--priority')
        let l:priority = l:priority_values[0]

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

        " Call the CLI to set the priority. Note: CLI takes priority BEFORE ID.
        let l:output = ragtag#utils#exec(['task', 'prioritize', l:priority,
            \ l:id, '--no-edit', '--path', l:path])

        " If we detected the tag from the cursor, replace it in the buffer.
        if !empty(l:location)
            call ragtag#tag#replace_tag_in_buffer(l:location, l:output)
        endif

        call ragtag#utils#print('Prioritized task ' . strpart(l:id, 0, 8) .
            \ ' (priority → ' . l:priority . ')')
    catch
        call ragtag#utils#print_error(v:exception)
    endtry
endfunction




" ---- RagtagTaskCreate ------------------------------------------------------ "

" Name of the scratch buffer used for interactive task creation.
let s:create_buffer_name = 'ragtag://create-task'

" Ordered list of field labels presented in the create-task buffer. The
" submit handler iterates this list to extract values from the buffer and to
" map each label to its CLI flag.
let s:create_fields = [
    \ ['Title',             '--title',             ''],
    \ ['Description',       '--description',       ''],
    \ ['Priority',          '--priority',          ''],
    \ ['Status',            '--status',            'new'],
    \ ['Owner',             '--owner',             'me'],
    \ ['Worktime Estimate', '--worktime-estimate', ''],
    \ ['Worktime Spent',    '--worktime-spent',    '0'],
    \ ['Worktime Units',    '--worktime-units',    'hours'],
    \ ['Parent ID',         '--pid',               ''],
\ ]

" Opens an interactive scratch buffer for creating a new task. Parses CLI
" arguments (mostly --path) to determine where the task will be created. The
" buffer is pre-populated with labelled fields; on :w/:wq the buffer is
" parsed, the CLI is invoked, and the resulting @task(...) tag is inserted
" at the original cursor position.
function! ragtag#commands#task_create(input) abort
    let l:parser = argonaut#argparser#new(s:task_create_argset)
    try
        call argonaut#argparser#parse(l:parser, a:input)
        if argonaut#argparser#has_arg(l:parser, '--help')
            call ragtag#utils#print('RagtagTaskCreate: Create a new task interactively.')
            call argonaut#argparser#show_help(l:parser)
            return
        endif

        " Resolve the target path so the CLI invocation later uses the same
        " --path the user implied with this command.
        let l:path = ragtag#utils#resolve_path(l:parser)

        " Capture the source context BEFORE opening the scratch buffer so we
        " can return to the originating window/buffer/cursor on submit.
        let l:src_winid = win_getid()
        let l:src_bufnr = bufnr('%')
        let l:src_line = line('.')
        let l:src_col = col('.')
        let l:src_indent = matchstr(getline('.'), '^\s*')

        " If a buffer with the create-task name already exists, wipe it so
        " we always start with a fresh form.
        let l:existing = bufnr(s:create_buffer_name)
        if l:existing != -1 && bufexists(l:existing)
            execute 'bwipeout! ' . l:existing
        endif

        " Open a fresh scratch buffer in a bottom split (mirrors task list
        " behavior) and assign the well-known buffer name.
        execute 'botright new'
        execute 'file ' . s:create_buffer_name

        " Buffer options: acwrite so :w fires BufWriteCmd; wipe on close so
        " :q! discards cleanly; not listed; no swapfile.
        setlocal buftype=acwrite
        setlocal bufhidden=wipe
        setlocal noswapfile
        setlocal nobuflisted
        setlocal filetype=ragtag_create

        " Stash the source context as buffer-local variables so the
        " BufWriteCmd handler can find them.
        let b:ragtag_src_winid = l:src_winid
        let b:ragtag_src_bufnr = l:src_bufnr
        let b:ragtag_src_line = l:src_line
        let b:ragtag_src_col = l:src_col
        let b:ragtag_src_indent = l:src_indent
        let b:ragtag_path = l:path

        " Build the form contents: a short comment header followed by one
        " line per field. Each field line has the form "Label: <default>".
        let l:lines = [
            \ '# New Task',
            \ '# Lines starting with # are ignored.',
            \ '# Save and close (:wq) to create the task.',
            \ '# Quit without saving (:q!) to cancel.',
            \ '',
        \ ]
        for l:field in s:create_fields
            call add(l:lines, l:field[0] . ': ' . l:field[2])
        endfor

        " Replace buffer contents with the form, then mark unmodified so an
        " immediate :q won't prompt about unsaved changes.
        call setline(1, l:lines)
        setlocal nomodified

        " Install the submit handler. BufWriteCmd is buffer-local because of
        " the <buffer> pattern.
        augroup ragtag_create_buffer
            autocmd! * <buffer>
            autocmd BufWriteCmd <buffer> call ragtag#commands#task_create_submit()
        augroup END

        " Compute and store the label lengths (including ": ") for each
        " field line so the immutability guard knows where the editable
        " region begins.
        let b:ragtag_label_lengths = {}
        let l:field_start_line = len(l:lines) - len(s:create_fields) + 1
        let l:fi = 0
        for l:field in s:create_fields
            let b:ragtag_label_lengths[l:field_start_line + l:fi] =
                \ len(l:field[0]) + 2
            let l:fi += 1
        endfor

        " Protect comment lines and label portions from editing. The
        " InsertCharPre autocmd silently discards keystrokes when the cursor
        " is inside a protected region. CursorMovedI nudges the cursor to
        " the first editable column if the user arrows into a label.
        augroup ragtag_create_protect
            autocmd! * <buffer>
            autocmd InsertCharPre <buffer> call s:create_guard_insert()
            autocmd CursorMovedI <buffer> call s:create_guard_cursor()
        augroup END

        " Block backspace from eating into labels. When the cursor is at
        " the first editable column, backspace becomes a no-op.
        inoremap <buffer><expr> <BS> <SID>create_guard_bs()
        inoremap <buffer><expr> <C-H> <SID>create_guard_bs()

        " Block dd and other normal-mode deletions on comment/blank lines.
        nnoremap <buffer> dd <Nop>
        nnoremap <buffer> cc <Nop>
        nnoremap <buffer> S <Nop>

        " Position the cursor on the Title value so the user can start
        " typing immediately. Title is the 6th line (after 4 comment lines
        " and the blank separator).
        call cursor(6, len('Title: ') + 1)
    catch
        call ragtag#utils#print_error(v:exception)
    endtry
endfunction


" Returns 1 if the current line is a comment or blank header line in the
" create buffer, 0 otherwise.
function! s:is_protected_line() abort
    let l:line = getline('.')
    return l:line =~# '^\s*#' || l:line =~# '^\s*$'
endfunction


" InsertCharPre guard: prevents typing on comment/blank lines and inside
" field labels (the "Label: " prefix).
function! s:create_guard_insert() abort
    if s:is_protected_line()
        let v:char = ''
        return
    endif
    if !exists('b:ragtag_label_lengths')
        return
    endif
    let l:lnum = line('.')
    if has_key(b:ragtag_label_lengths, l:lnum)
        let l:min_col = b:ragtag_label_lengths[l:lnum] + 1
        if col('.') < l:min_col
            let v:char = ''
        endif
    endif
endfunction


" CursorMovedI guard: if the cursor lands inside a label or on a
" protected line, push it to the nearest editable column.
function! s:create_guard_cursor() abort
    if s:is_protected_line()
        " Move to the end of the line so the user can't insert here, but
        " don't fight too hard — just nudge.
        return
    endif
    if !exists('b:ragtag_label_lengths')
        return
    endif
    let l:lnum = line('.')
    if has_key(b:ragtag_label_lengths, l:lnum)
        let l:min_col = b:ragtag_label_lengths[l:lnum] + 1
        if col('.') < l:min_col
            call cursor(l:lnum, l:min_col)
        endif
    endif
endfunction


" Backspace guard for insert mode: returns an empty string (no-op) if the
" cursor is at or before the first editable column, otherwise returns a
" normal backspace character.
function! s:create_guard_bs() abort
    if s:is_protected_line()
        return ''
    endif
    if !exists('b:ragtag_label_lengths')
        return "\<BS>"
    endif
    let l:lnum = line('.')
    if has_key(b:ragtag_label_lengths, l:lnum)
        let l:min_col = b:ragtag_label_lengths[l:lnum] + 1
        if col('.') <= l:min_col
            return ''
        endif
    endif
    return "\<BS>"
endfunction


" Handles :w / :wq inside the create-task scratch buffer. Parses each
" non-comment line for a "Label: value" pair, builds the CLI command, runs
" it, closes the scratch buffer, and inserts the resulting @task(...) tag
" at the originally captured cursor position.
function! ragtag#commands#task_create_submit() abort
    try
        " Collect source context from buffer-local variables. If any are
        " missing the buffer is in an unexpected state — bail out.
        if !exists('b:ragtag_path')
            call ragtag#utils#panic('Create-task buffer is missing context.')
        endif
        let l:src_winid = b:ragtag_src_winid
        let l:src_bufnr = b:ragtag_src_bufnr
        let l:src_line = b:ragtag_src_line
        let l:src_col = b:ragtag_src_col
        let l:src_indent = b:ragtag_src_indent
        let l:path = b:ragtag_path

        " Parse the buffer line by line, ignoring blanks and comments. For
        " each field label we know about, record the user-supplied value.
        let l:values = {}
        for l:label_info in s:create_fields
            let l:values[l:label_info[0]] = ''
        endfor

        let l:line_count = line('$')
        let l:idx = 1
        while l:idx <= l:line_count
            let l:line = getline(l:idx)
            let l:idx += 1
            if l:line =~# '^\s*$' || l:line =~# '^\s*#'
                continue
            endif
            " Match "Label: value" — Label may contain spaces (e.g.
            " "Worktime Estimate"). Use a non-greedy capture before the
            " first ": ".
            let l:m = matchlist(l:line, '^\([^:]\+\):\s*\(.*\)$')
            if empty(l:m)
                continue
            endif
            let l:label = substitute(l:m[1], '^\s\+\|\s\+$', '', 'g')
            let l:value = substitute(l:m[2], '\s\+$', '', '')
            if has_key(l:values, l:label)
                let l:values[l:label] = l:value
            endif
        endwhile

        " Title is required.
        if empty(l:values['Title'])
            call ragtag#utils#panic('Title is required.')
        endif

        " Build the CLI argument list. Title always goes in; other fields
        " are included only when non-empty. Note: `ragtag task create` does
        " not accept --path; the user-supplied --path is preserved on the
        " buffer for context but not forwarded to the CLI.
        let l:args = ['task', 'create', '--format', 'oneline',
            \ '--title', l:values['Title']]
        for l:field in s:create_fields
            let l:label = l:field[0]
            let l:flag = l:field[1]
            if l:label ==# 'Title'
                continue
            endif
            let l:val = l:values[l:label]
            if !empty(l:val)
                let l:args += [l:flag, l:val]
            endif
        endfor

        " Run the CLI; capture the resulting tag string.
        let l:output = ragtag#utils#exec(l:args)
        let l:result = substitute(l:output, '\n$', '', '')

        " Extract the task ID from the CLI output for the confirmation
        " message (look for id="...").
        let l:id_match = matchstr(l:result, 'id="\zs[^"]*\ze"')
        let l:task_id = empty(l:id_match) ? '(unknown)' : l:id_match

        " Mark this scratch buffer as unmodified so the :q half of :wq
        " closes it cleanly without E37. With bufhidden=wipe the buffer is
        " automatically wiped when its window closes.
        setlocal nomodified
        let l:create_bufnr = bufnr('%')

        " DO NOT wipe the buffer here — let the :q portion of :wq close
        " the window, which triggers bufhidden=wipe. If we wipe now, :q
        " lands on the source buffer and raises E37/E162.

        " Stash context needed by the post-close handler. We use a
        " script-local dict so the BufWipeout autocmd can pick it up after
        " the buffer is gone.
        let s:create_pending = {
            \ 'result': l:result,
            \ 'task_id': l:task_id,
            \ 'src_winid': l:src_winid,
            \ 'src_bufnr': l:src_bufnr,
            \ 'src_line': l:src_line,
            \ 'src_col': l:src_col,
        \ }

        " Install a one-shot BufWipeout autocmd that fires when the create
        " buffer is actually closed (by :q or bufhidden=wipe). This is
        " where we insert the tag and print the confirmation.
        augroup ragtag_create_post
            autocmd! * <buffer>
            autocmd BufWipeout <buffer> call s:create_post_wipe()
        augroup END
    catch
        call ragtag#utils#print_error(v:exception)
    endtry
endfunction


" Post-wipe handler: called when the create buffer is actually wiped (by
" :q after BufWriteCmd marked it nomodified, or by bufhidden=wipe). Inserts
" the tag at the original cursor position and prints confirmation.
function! s:create_post_wipe() abort
    " Clean up the autogroup.
    augroup ragtag_create_post
        autocmd!
    augroup END

    if !exists('s:create_pending')
        return
    endif
    let l:ctx = s:create_pending
    unlet s:create_pending

    " Return to the source window and insert the tag.
    let l:returned = 0
    if win_id2win(l:ctx.src_winid) > 0
        call win_gotoid(l:ctx.src_winid)
        let l:returned = 1
    endif

    if l:returned && bufnr('%') == l:ctx.src_bufnr
        let l:cur_line = getline(l:ctx.src_line)
        let l:before = strpart(l:cur_line, 0, l:ctx.src_col - 1)
        let l:after = strpart(l:cur_line, l:ctx.src_col - 1)
        call setline(l:ctx.src_line, l:before . l:ctx.result . l:after)
    endif

    call ragtag#utils#print('Task ' . l:ctx.task_id . ' created successfully.')
endfunction
