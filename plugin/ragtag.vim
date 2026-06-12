" ragtag.vim - Interactive Vim interface for the ragtag CLI tool.
"
" Provides commands to list, query, inspect, and modify @tag(...) annotations
" (and specifically @task(...) tags) directly from within Vim.
"
" Author:       cwshugg
" Repository:   https://github.com/cwshugg/ragtag.vim

" ================================ Load Guard ================================ "
if exists('g:ragtag_initialized')
    finish
endif
let g:ragtag_initialized = 1

" ========================== Dependency Check ================================ "
" Check for argonaut.vim dependency early, before any command definitions.
" This prevents E117 errors from autoload calls if argonaut.vim is missing.
if !exists('g:argonaut_initialized')
    echohl ErrorMsg
    echomsg '[ragtag.vim] argonaut.vim is required but not installed. See :h ragtag-install'
    echohl None
    finish
endif

" ========================== Binary Check ==================================== "
" Verify that the ragtag CLI binary is available on the system.
let s:binary = get(g:, 'ragtag_binary', 'ragtag')
if !executable(s:binary)
    echohl ErrorMsg
    echomsg '[ragtag.vim] ragtag binary not found: "' . s:binary . '". Set g:ragtag_binary to the correct path.'
    echohl None
endif

" ========================== Highlight Setup ================================= "
" Install the ColorScheme autocmd at plugin-load time so highlight groups
" survive colorscheme changes even before any ragtag command has been invoked.
" The actual highlight definitions live in autoload/ragtag/highlight.vim and
" are called lazily via ragtag#highlight#define().
augroup ragtag_highlight
    autocmd!
    autocmd ColorScheme * call ragtag#highlight#define()
augroup END

" ============================== Command Definitions ========================= "

" RagtagTaskList - Displays an interactive task list buffer with inline
" attribute editing capabilities.
command!
    \ -nargs=*
    \ -complete=customlist,ragtag#commands#task_list_complete
    \ RagtagTaskList
    \ call ragtag#commands#task_list(<q-args>)

" RagtagTaskSetAttr - Sets an attribute on a task, either under the cursor or
" by explicit ID.
command!
    \ -nargs=*
    \ -complete=customlist,ragtag#commands#task_set_attr_complete
    \ RagtagTaskSetAttr
    \ call ragtag#commands#task_set_attr(<q-args>)

" RagtagTaskGetAttr - Retrieves and displays a single attribute value from a
" task.
command!
    \ -nargs=*
    \ -complete=customlist,ragtag#commands#task_get_attr_complete
    \ RagtagTaskGetAttr
    \ call ragtag#commands#task_get_attr(<q-args>)

" RagtagSummary - Displays a summary of all tags found in the current file or
" directory (invokes `ragtag summary`).
command!
    \ -nargs=*
    \ -complete=customlist,ragtag#commands#summary_complete
    \ RagtagSummary
    \ call ragtag#commands#summary(<q-args>)

" RagtagTaskSummary - Displays a summary of tasks found in the current file
" or directory (invokes `ragtag task summary`).
command!
    \ -nargs=*
    \ -complete=customlist,ragtag#commands#task_summary_complete
    \ RagtagTaskSummary
    \ call ragtag#commands#task_summary(<q-args>)

" RagtagQuery - Finds tags in the current buffer and sets up Vim search
" highlighting for navigation with n/N.
command!
    \ -nargs=*
    \ -complete=customlist,ragtag#commands#query_complete
    \ RagtagQuery
    \ call ragtag#commands#query(<q-args>)

" RagtagTaskComplete - Marks a task as done (status → complete).
command!
    \ -nargs=*
    \ -complete=customlist,ragtag#commands#task_complete_complete
    \ RagtagTaskComplete
    \ call ragtag#commands#task_complete(<q-args>)

" RagtagTaskActivate - Sets a task's status to active.
command!
    \ -nargs=*
    \ -complete=customlist,ragtag#commands#task_activate_complete
    \ RagtagTaskActivate
    \ call ragtag#commands#task_activate(<q-args>)

" RagtagTaskDeactivate - Sets a task's status to inactive.
command!
    \ -nargs=*
    \ -complete=customlist,ragtag#commands#task_deactivate_complete
    \ RagtagTaskDeactivate
    \ call ragtag#commands#task_deactivate(<q-args>)

" RagtagTaskBlock - Sets a task's status to blocked.
command!
    \ -nargs=*
    \ -complete=customlist,ragtag#commands#task_block_complete
    \ RagtagTaskBlock
    \ call ragtag#commands#task_block(<q-args>)

" RagtagTaskAbandon - Sets a task's status to abandoned.
command!
    \ -nargs=*
    \ -complete=customlist,ragtag#commands#task_abandon_complete
    \ RagtagTaskAbandon
    \ call ragtag#commands#task_abandon(<q-args>)

" RagtagTaskPrioritize - Sets a task's priority value.
command!
    \ -nargs=*
    \ -complete=customlist,ragtag#commands#task_prioritize_complete
    \ RagtagTaskPrioritize
    \ call ragtag#commands#task_prioritize(<q-args>)

" RagtagTaskTime - Sets a task's worktime_spent value.
command!
    \ -nargs=*
    \ -complete=customlist,ragtag#commands#task_time_complete
    \ RagtagTaskTime
    \ call ragtag#commands#task_time(<q-args>)

" RagtagTaskCreate - Creates a new task via CLI args and inserts the
" resulting @task(...) tag at the cursor position.
command!
    \ -nargs=*
    \ -complete=customlist,ragtag#commands#task_create_complete
    \ RagtagTaskCreate
    \ call ragtag#commands#task_create(<q-args>)
