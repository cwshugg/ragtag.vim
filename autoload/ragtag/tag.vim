" Tag detection and manipulation for ragtag.vim.
" Provides functions for finding @tag(...) strings in buffer text, parsing
" their attributes, and replacing them in-place.


" ========================= Tag Finding ====================================== "

" Finds the tag boundaries at or near the cursor position. Scans backward from
" the cursor to find '@tagname(' start, then forward to find the matching ')'
" (handling nested parentheses, quoted strings, and multi-line tags).
"
" Returns a dict:
"   {
"     'start_line': N,
"     'start_col': N,
"     'end_line': N,
"     'end_col': N,
"     'tag_name': 'task',
"     'raw_text': '@task(...)',
"     'id': '...'
"   }
"
" Throws an error if no tag is found at or near the cursor.
function! ragtag#tag#find_tag_at_cursor() abort
    let l:cur_line = line('.')
    let l:cur_col = col('.')

    " ---- Step 1: Scan backward to find the '@' that starts the tag. ---- "
    let l:at_line = -1
    let l:at_col = -1

    " First, search the current line from cursor backward.
    let l:line_text = getline(l:cur_line)
    let l:search_end = l:cur_col - 1
    while l:search_end >= 0
        let l:idx = strridx(l:line_text, '@', l:search_end)
        if l:idx < 0
            break
        endif
        " Check that the character after '@' is a word character (tag name).
        let l:after = strpart(l:line_text, l:idx + 1, 1)
        if l:after =~# '\w'
            let l:at_line = l:cur_line
            let l:at_col = l:idx + 1  " 1-based column
            break
        endif
        let l:search_end = l:idx - 1
    endwhile

    " If not found on current line via backward scan, also try scanning
    " forward on the current line (handles the case where the cursor is
    " positioned before the '@' character on the same line).
    if l:at_line < 0
        let l:fwd_idx = l:cur_col  " one past cursor (0-based)
        while l:fwd_idx < len(l:line_text)
            if l:line_text[l:fwd_idx] ==# '@'
                let l:after = strpart(l:line_text, l:fwd_idx + 1, 1)
                if l:after =~# '\w'
                    let l:at_line = l:cur_line
                    let l:at_col = l:fwd_idx + 1  " 1-based column
                    break
                endif
            endif
            let l:fwd_idx += 1
        endwhile
    endif

    " If still not found on current line, scan previous lines for an unclosed
    " '@tagname(' pattern (up to 20 lines back).
    if l:at_line < 0
        let l:max_back = 20
        let l:scan_line = l:cur_line - 1
        while l:scan_line >= 1 && (l:cur_line - l:scan_line) <= l:max_back
            let l:stext = getline(l:scan_line)
            " Look for '@' followed by a word character on this line.
            let l:idx = len(l:stext) - 1
            while l:idx >= 0
                if l:stext[l:idx] ==# '@'
                    let l:after = strpart(l:stext, l:idx + 1, 1)
                    if l:after =~# '\w'
                        " Found a candidate — verify it has an unclosed '('.
                        let l:candidate_line = l:scan_line
                        let l:candidate_col = l:idx + 1
                        " Check if this tag's paren is still open at cursor.
                        let l:depth = 0
                        let l:check_line = l:candidate_line
                        let l:check_text = l:stext
                        let l:check_start = l:idx
                        let l:in_quote = 0
                        let l:found_open = 0
                        while l:check_line <= l:cur_line
                            let l:ci = (l:check_line == l:candidate_line) ? l:check_start : 0
                            let l:check_text = getline(l:check_line)
                            while l:ci < len(l:check_text)
                                let l:ch = l:check_text[l:ci]
                                if l:in_quote
                                    if l:ch ==# '"' && (l:ci == 0 || l:check_text[l:ci - 1] !=# '\')
                                        let l:in_quote = 0
                                    endif
                                else
                                    if l:ch ==# '"'
                                        let l:in_quote = 1
                                    elseif l:ch ==# '('
                                        let l:depth += 1
                                        let l:found_open = 1
                                    elseif l:ch ==# ')'
                                        let l:depth -= 1
                                    endif
                                endif
                                let l:ci += 1
                            endwhile
                            let l:check_line += 1
                        endwhile
                        " If depth > 0, the paren is still open — this is our
                        " tag.
                        if l:found_open && l:depth > 0
                            let l:at_line = l:candidate_line
                            let l:at_col = l:candidate_col
                            break
                        endif
                    endif
                endif
                let l:idx -= 1
            endwhile
            if l:at_line >= 0
                break
            endif
            let l:scan_line -= 1
        endwhile
    endif

    if l:at_line < 0
        call ragtag#utils#panic('No tag found at or near the cursor position.')
    endif

    " ---- Step 2: Extract the tag name (word chars after '@'). ---- "
    let l:tag_start_text = getline(l:at_line)
    let l:name_start = l:at_col  " 0-based index of first char after '@'
    let l:name_end = l:name_start
    while l:name_end < len(l:tag_start_text) && l:tag_start_text[l:name_end] =~# '\w'
        let l:name_end += 1
    endwhile
    let l:tag_name = strpart(l:tag_start_text, l:name_start, l:name_end - l:name_start)
    if empty(l:tag_name)
        call ragtag#utils#panic('No tag found at or near the cursor position.')
    endif

    " ---- Step 3: Find the opening '(' and matching ')'. ---- "
    let l:paren_line = l:at_line
    let l:paren_col = l:name_end
    let l:paren_text = getline(l:paren_line)

    " Skip whitespace to find '('.
    while l:paren_col < len(l:paren_text) && l:paren_text[l:paren_col] =~# '\s'
        let l:paren_col += 1
    endwhile
    " If we ran off the end of the line, check the next line.
    if l:paren_col >= len(l:paren_text)
        let l:paren_line += 1
        let l:paren_text = getline(l:paren_line)
        let l:paren_col = 0
        while l:paren_col < len(l:paren_text) && l:paren_text[l:paren_col] =~# '\s'
            let l:paren_col += 1
        endwhile
    endif
    if l:paren_col >= len(l:paren_text) || l:paren_text[l:paren_col] !=# '('
        call ragtag#utils#panic('No tag found at or near the cursor position.')
    endif

    " Track parenthesis depth to find the matching ')'.
    let l:depth = 0
    let l:in_quote = 0
    let l:walk_line = l:paren_line
    let l:walk_col = l:paren_col
    let l:end_line = -1
    let l:end_col = -1
    let l:max_lines = line('$')

    while l:walk_line <= l:max_lines
        let l:wtext = getline(l:walk_line)
        while l:walk_col < len(l:wtext)
            let l:ch = l:wtext[l:walk_col]
            if l:in_quote
                if l:ch ==# '"' && (l:walk_col == 0 || l:wtext[l:walk_col - 1] !=# '\')
                    let l:in_quote = 0
                endif
            else
                if l:ch ==# '"'
                    let l:in_quote = 1
                elseif l:ch ==# '('
                    let l:depth += 1
                elseif l:ch ==# ')'
                    let l:depth -= 1
                    if l:depth == 0
                        let l:end_line = l:walk_line
                        let l:end_col = l:walk_col + 1  " 1-based, inclusive
                        break
                    endif
                endif
            endif
            let l:walk_col += 1
        endwhile
        if l:end_line >= 0
            break
        endif
        let l:walk_line += 1
        let l:walk_col = 0
    endwhile

    if l:end_line < 0
        call ragtag#utils#panic('No tag found at or near the cursor position.')
    endif

    " ---- Step 4: Collect all text from start to end. ---- "
    let l:raw_lines = []
    for l:li in range(l:at_line, l:end_line)
        let l:lt = getline(l:li)
        if l:li == l:at_line && l:li == l:end_line
            " Tag is on a single line.
            let l:raw_lines = [strpart(l:lt, l:at_col - 1, l:end_col - l:at_col + 1)]
        elseif l:li == l:at_line
            call add(l:raw_lines, strpart(l:lt, l:at_col - 1))
        elseif l:li == l:end_line
            call add(l:raw_lines, strpart(l:lt, 0, l:end_col))
        else
            call add(l:raw_lines, l:lt)
        endif
    endfor
    let l:raw_text = join(l:raw_lines, "\n")

    " ---- Step 5: Extract the 'id' attribute if present. ---- "
    let l:parsed = ragtag#tag#parse_tag_string(l:raw_text)
    let l:id = get(l:parsed.attrs, 'id', '')

    return {
        \ 'start_line': l:at_line,
        \ 'start_col': l:at_col,
        \ 'end_line': l:end_line,
        \ 'end_col': l:end_col,
        \ 'tag_name': l:tag_name,
        \ 'raw_text': l:raw_text,
        \ 'id': l:id,
    \ }
endfunction


" ========================= Tag Parsing ====================================== "

" Parses a raw tag string into a dict of attributes.
" Input: '@task(id=abc, title="My Task", status=active)'
" Returns: {'name': 'task', 'attrs': {'id': 'abc', 'title': 'My Task', ...}}
function! ragtag#tag#parse_tag_string(text) abort
    let l:result = {'name': '', 'attrs': {}}

    " Extract tag name: everything between '@' and '('.
    let l:at_idx = stridx(a:text, '@')
    if l:at_idx < 0
        return l:result
    endif
    let l:paren_idx = stridx(a:text, '(', l:at_idx)
    if l:paren_idx < 0
        return l:result
    endif
    let l:result.name = strpart(a:text, l:at_idx + 1, l:paren_idx - l:at_idx - 1)
    let l:result.name = substitute(l:result.name, '^\s*\|\s*$', '', 'g')

    " Extract the content between the outer parentheses.
    let l:close_idx = strridx(a:text, ')')
    if l:close_idx <= l:paren_idx
        return l:result
    endif
    let l:inner = strpart(a:text, l:paren_idx + 1, l:close_idx - l:paren_idx - 1)

    " Parse key=value pairs from the inner content.
    let l:pos = 0
    let l:len = len(l:inner)
    while l:pos < l:len
        " Skip whitespace and commas.
        while l:pos < l:len && (l:inner[l:pos] =~# '[\s,\n]')
            let l:pos += 1
        endwhile
        if l:pos >= l:len
            break
        endif

        " Read attribute name (up to '=').
        let l:key_start = l:pos
        while l:pos < l:len && l:inner[l:pos] !=# '=' && l:inner[l:pos] !~# '[\s,)]'
            let l:pos += 1
        endwhile
        let l:key = strpart(l:inner, l:key_start, l:pos - l:key_start)
        let l:key = substitute(l:key, '^\s*\|\s*$', '', 'g')

        " Skip '='.
        if l:pos < l:len && l:inner[l:pos] ==# '='
            let l:pos += 1
        else
            " No value; skip this token.
            continue
        endif

        " Skip whitespace after '='.
        while l:pos < l:len && l:inner[l:pos] =~# '\s'
            let l:pos += 1
        endwhile

        " Read attribute value.
        let l:value = ''
        if l:pos < l:len && l:inner[l:pos] ==# '"'
            " Quoted value — read until closing quote.
            let l:pos += 1
            let l:val_start = l:pos
            while l:pos < l:len
                if l:inner[l:pos] ==# '"' && (l:pos == 0 || l:inner[l:pos - 1] !=# '\')
                    break
                endif
                let l:pos += 1
            endwhile
            let l:value = strpart(l:inner, l:val_start, l:pos - l:val_start)
            " Skip the closing quote.
            if l:pos < l:len
                let l:pos += 1
            endif
        else
            " Unquoted value — read until comma or closing paren.
            let l:val_start = l:pos
            while l:pos < l:len && l:inner[l:pos] !~# '[,)]'
                let l:pos += 1
            endwhile
            let l:value = strpart(l:inner, l:val_start, l:pos - l:val_start)
            let l:value = substitute(l:value, '\s*$', '', '')
        endif

        if !empty(l:key)
            let l:result.attrs[l:key] = l:value
        endif
    endwhile

    return l:result
endfunction


" ========================= Tag Replacement ================================== "

" Replaces a tag in the buffer at the given location with new text. Handles
" multi-line tags by replacing from start_line:start_col to end_line:end_col.
" Leaves the buffer modified (does not save).
"
" a:location - dict with 'start_line', 'start_col', 'end_line', 'end_col'
" a:new_text - the replacement text (may contain newlines)
function! ragtag#tag#replace_tag_in_buffer(location, new_text) abort
    let l:start_line = a:location.start_line
    let l:start_col = a:location.start_col
    let l:end_line = a:location.end_line
    let l:end_col = a:location.end_col

    " Get the text before the tag on the start line and after the tag on the
    " end line.
    let l:before = strpart(getline(l:start_line), 0, l:start_col - 1)
    let l:after = strpart(getline(l:end_line), l:end_col)

    " Strip trailing newline from the replacement text if present.
    let l:replacement = substitute(a:new_text, '\n$', '', '')

    " Split the replacement into lines.
    let l:new_lines = split(l:replacement, "\n", 1)

    " Build the final lines to insert.
    if len(l:new_lines) == 0
        let l:new_lines = ['']
    endif
    let l:new_lines[0] = l:before . l:new_lines[0]
    let l:new_lines[-1] = l:new_lines[-1] . l:after

    " Delete the original lines and replace with new content.
    " Make buffer temporarily modifiable.
    let l:save_modifiable = &l:modifiable
    setlocal modifiable

    " Delete original tag lines.
    if l:end_line > l:start_line
        execute l:start_line . ',' . l:end_line . 'delete _'
    else
        execute l:start_line . 'delete _'
    endif

    " Insert replacement lines at the correct position.
    let l:insert_at = l:start_line - 1
    call append(l:insert_at, l:new_lines)

    " Restore modifiable state.
    let &l:modifiable = l:save_modifiable
endfunction
