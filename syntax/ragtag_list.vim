" Syntax highlighting for the ragtag_list filetype.
" Automatically sourced when a buffer's filetype is set to ragtag_list.

if exists('b:current_syntax')
    finish
endif

" Column separators (│ character used between table columns).
syntax match RagtagListColumnSep /│/

" Header line (first line of the table).
syntax match RagtagListHeader /\%1l.*/

" Separator line (second line — the ───┼─── divider).
syntax match RagtagListSeparator /\%2l.*/

" Status values (matched within table cells).
syntax match RagtagListStatusDone /\<done\>/
syntax match RagtagListStatusActive /\<active\>/
syntax match RagtagListStatusBlocked /\<blocked\>/
syntax match RagtagListStatusAbandoned /\<abandoned\>/
syntax match RagtagListStatusInactive /\<new\>/
syntax match RagtagListStatusInactive /\<inactive\>/

" Priority values — use column-context matching by requiring the value to
" appear between column separators in a position consistent with the Pri
" column. Fall back to word-boundary matching for simplicity; the narrow
" column context limits false positives.
syntax match RagtagListPriority0 /│\s*\zs0\ze\s*│/
syntax match RagtagListPriority1 /│\s*\zs1\ze\s*│/
syntax match RagtagListPriority2 /│\s*\zs2\ze\s*│/
syntax match RagtagListPriority3 /│\s*\zs3\ze\s*│/
syntax match RagtagListPriority4 /│\s*\zs[4-9]\ze\s*│/

let b:current_syntax = 'ragtag_list'
