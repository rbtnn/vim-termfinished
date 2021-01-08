
let g:loaded_termfinished = 1

if has('nvim')
	finish
endif

function s:exit_cb(channel, msg) abort
	let info = filter(getwininfo(), { _,x -> x.winid == win_getid() })[0]
	let st_row = info['winrow'] + info['height']
	let cs = []
	for st_col in range(info['wincol'], info['wincol'] + info['width'])
		let n = screenchar(st_row, st_col)
		if -1 != n
			let cs += [nr2char(n)]
		endif
	endfor
	let s = substitute(trim(join(cs, '')), '\[\(running\|normal\)\]$', '[finished]', '')
	if !hlexists('StatusLineTermFinished')
		highlight! StatusLineTermFinished ctermbg=Red guibg=#ff0000
	endif
	let &l:statusline = '%#StatusLineTermFinished#' .. s
endfunction

function s:TerminalWinOpen() abort
	if has('nvim')
	else
		if empty(get(job_info(term_getjob(bufnr())), 'exit_cb'))
			call job_setoptions(term_getjob(bufnr()), { 'exit_cb' : function('s:exit_cb') })
		endif
	endif
endfunction

augroup termfinished
	autocmd!
	if has('nvim')
		autocmd TermOpen        * :call s:TerminalWinOpen()
	else
		autocmd TerminalWinOpen * :call s:TerminalWinOpen()
	endif
augroup END
