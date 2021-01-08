
let g:loaded_termfinished = 1

if has('nvim')
	finish
endif

function s:exit_cb(winid, channel, msg) abort
	let info = filter(getwininfo(), { _,x -> x.winid == a:winid })[0]
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
	call win_execute(a:winid, printf('let &l:statusline = %s', string('%#StatusLineTermFinished#' .. s)))
endfunction

function s:TerminalWinOpen() abort
	let j = term_getjob(bufnr())
	if j != v:null
		call job_setoptions(j, { 'exit_cb' : function('s:exit_cb', [win_getid()]) })
	endif
endfunction

augroup termfinished
	autocmd!
	autocmd TerminalWinOpen * :call s:TerminalWinOpen()
augroup END
