" Highlight group definitions for ragtag.vim.
" All groups use `highlight default` so users can override them in their
" vimrc or colorscheme.

" Defines all ragtag highlight groups. Called during plugin load and can be
" re-called after colorscheme changes.
function! ragtag#highlight#define() abort
    " Source buffer highlights (for RagtagQuery).
    highlight default link RagtagTagSigil Special
    highlight default link RagtagTagName Identifier
    highlight default link RagtagTagParen Delimiter
    highlight default link RagtagAttrName Type
    highlight default link RagtagAttrEquals Operator
    highlight default link RagtagAttrValue String

    " Task list buffer highlights.
    highlight default link RagtagListHeader Title
    highlight default link RagtagListSeparator NonText
    highlight default link RagtagListId Constant
    highlight default link RagtagListTitle Normal
    highlight default link RagtagListOwner Identifier
    highlight default link RagtagListFile Directory
    highlight default link RagtagListColumnSep NonText

    " Status highlights — colored by category.
    highlight default link RagtagListStatusDone DiffAdd
    highlight default link RagtagListStatusActive DiffChange
    highlight default link RagtagListStatusBlocked ErrorMsg
    highlight default link RagtagListStatusAbandoned WarningMsg
    highlight default link RagtagListStatusInactive Comment

    " Priority highlights — colored by urgency.
    highlight default link RagtagListPriority0 ErrorMsg
    highlight default link RagtagListPriority1 WarningMsg
    highlight default link RagtagListPriority2 Todo
    highlight default link RagtagListPriority3 DiffChange
    highlight default link RagtagListPriority4 DiffAdd

    " Interactive create-task buffer highlights.
    highlight default link RagtagCreateLabel Constant
    highlight default link RagtagCreateComment Comment

    " Task summary buffer highlights.
    " ID (first 8 hex chars on a line) — cyan/teal.
    hi def RagtagSummaryId ctermfg=14 guifg=#56b6c2
    " Brackets — dim gray.
    hi def RagtagSummaryBracket ctermfg=8 guifg=#5c6370
    " Owner — blue/purple.
    hi def RagtagSummaryOwner ctermfg=13 guifg=#c678dd
    " Priority/Status — yellow/orange.
    hi def RagtagSummaryPriStatus ctermfg=11 guifg=#e5c07b
    " Worktime — green.
    hi def RagtagSummaryWorktime ctermfg=10 guifg=#98c379
endfunction

" Define groups on load (also called on ColorScheme from plugin/ragtag.vim).
call ragtag#highlight#define()
