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
endfunction

" Define groups on load.
call ragtag#highlight#define()
