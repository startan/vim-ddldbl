"{{{ File header information
"	vim:ff=unix ts=4 ss=4
"	vim60:fdm=marker
"
"	\file		ddldbl.vim
"
"	\brief		Delete Duplicate Lines and Delete Blank Lines.
"
"	\author		Tony Tan <star.stroll@gmail.com>
"	\date		2017/03/07 
"	Version:	0.1.1
"	History: {{{
"		Initial
"	Improvments:
"		Added commands :DDL and :DBL
"		DDL is 'Delete Duplicate Lines' while DBL is 'Delete Blank
"			Lines'(lines containing only whitespace)
"		Both operate on a range of lines; defaulting to the entire file.
"	Limitations:
"		Does not save cursor position
"		Opens folds if there are any; At last check this was required else
"			commands operated on each line of the fold for as many lines of
"			the fold. Inconvient, but little more imho.
" }}}
"
"}}}

if exists("plugin_ddl")
	finish
endif
let plugin_ddl = 1

let s:save_cpo = &cpo
set cpo&vim


"*****************************************************************
" Functions: {{{
if !exists("*s:FeralDeleteDuplicateLines(...)")
function s:FeralDeleteDuplicateLines() range "{{{

	let Top_Line = a:firstline
	let End_Line = a:lastline
	let flags = []
"	echo confirm(Top_Line.','.End_Line)

	silent! execute Top_Line.','.End_Line.'foldopen!'

	execute "normal! ".Top_Line.'G'
	while line('.') < End_Line
		let Cur_Line = line('.')
		if index(flags, Cur_Line) >= 0
			execute "normal! ".Cur_Line.'G'
			normal! j
			continue
		endif
		let DaLine = '^'.escape(getline('.'), '\*^$.~').'$'
		while search(DaLine, 'W') != 0
			let match_line = line('.')
			if match_line <= End_Line && index(flags, match_line) < 0
				call add(flags, match_line)
"				echo 'Deleting line('.line('.').'):'.getline('.')
			endif
		endwhile
		execute "normal! ".Cur_Line.'G'
		normal! j
	endwhile
	let sorted_flags = sort(flags, "IntComp")
	for rownum in sorted_flags
		execute "normal!".rownum.'G'
		delete
	endfor
endfunction

func IntComp(i1, i2)
	return a:i2 - a:i1
endfunc

"}}}
endif
" }}}

"*****************************************************************
" Commands: {{{
"*****************************************************************
if !exists(":DDL")
	" Delete Duplicate Lines
	command -range=% DDL		:<line1>,<line2>call <SID>FeralDeleteDuplicateLines()
endif

"[Feral:318/02@22:54] Just a hack because it is easy and logical.
if !exists(":DBL")
	" Delete Blank Lines
	command -range=% DBL		:<line1>,<line2>g/^\s*$/:delete
endif

"}}}
let &cpo = s:save_cpo
"EOF
