" Syntax highlighting for the ragtag_create filetype.
" Automatically sourced when a buffer's filetype is set to ragtag_create
" (used by the interactive :RagtagTaskCreate scratch buffer).

if exists('b:current_syntax')
    finish
endif

" Comment lines — anything starting with '#'.
syntax match RagtagCreateComment /^\s*#.*$/

" Field labels — the "Label:" portion at the start of any non-comment line.
" The trailing ':' is included in the highlight; the value that follows the
" label is left as Normal so the user can clearly see where their input
" lives. Multi-word labels (e.g., "Worktime Estimate") are supported via
" \k\+\(\s\+\k\+\)*.
syntax match RagtagCreateLabel /^\k\+\(\s\+\k\+\)*:/

highlight default link RagtagCreateComment Comment
" RagtagCreateLabel is defined in autoload/ragtag/highlight.vim so users can
" override it consistently with other ragtag highlight groups.

let b:current_syntax = 'ragtag_create'
