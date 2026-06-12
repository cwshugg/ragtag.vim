" Syntax highlighting for the ragtag_summary filetype.
" Automatically sourced when a buffer's filetype is set to ragtag_summary.
"
" Each line in the buffer has the shape:
"   ID [owner] [priority/status] [spent/estimate units] title
"
" The three bracketed groups are distinguished by their content shape rather
" than by position:
"   - owner:        bracket content without `/` and without spaces
"   - pri/status:   bracket content containing `/` but no space
"   - worktime:     bracket content containing whitespace

if exists('b:current_syntax')
    finish
endif

" Brackets (matched only when contained within one of the bracketed groups
" defined below, so we know exactly which `[`/`]` pairs to color).
syntax match RagtagSummaryBracket /[][]/ contained

" Owner group: bracket content with no slash and no space.
syntax match RagtagSummaryOwner /\[[^][/ ]\+\]/ contains=RagtagSummaryBracket

" Priority/Status group: bracket content containing a slash but no space.
syntax match RagtagSummaryPriStatus /\[[^][ ]*\/[^][ ]*\]/ contains=RagtagSummaryBracket

" Worktime group: bracket content containing a space.
syntax match RagtagSummaryWorktime /\[[^]]*\s[^]]*\]/ contains=RagtagSummaryBracket

" Task ID: first 8 hex characters at the start of the line.
syntax match RagtagSummaryId /^[0-9a-f]\{8\}/

let b:current_syntax = 'ragtag_summary'
