let s:save_cpo = &cpo
set cpo&vim

if exists("g:loaded_tracker")
  finish
endif
let g:loaded_tracker = 1

function! s:dump_vim_interactions()
  echomsg "Dumping interactions to /tmp/vim_register.txt"
  let l:file_contents = readfile("/tmp/vim_register.txt", "")
  let l:file_contents += s:events
  if !empty(l:file_contents) && empty(l:file_contents[-1])
    call remove(l:file_contents, -1)
  endif
  call writefile(l:file_contents, "/tmp/vim_register.txt", "")
  let s:events = []
endfunction

function! s:collect_vim_interactions(cmd)
  let l:entry = printf("(:command :\"%s\" :file-name :\"%s\" :buffer-name \"%s\" :match \"%s\)", a:cmd, expand("<afile>"), expand("<abuffer>"), expand("<amatch>"))
  call add(s:events, l:entry)
endfunction

function! s:bind_collector_to_events()
  let s:events = []
  au BufNewFile * call <SID>collect_vim_interactions("BufNewFile")
  au BufRead * call <SID>collect_vim_interactions("BufRead")
  au BufReadPost * call <SID>collect_vim_interactions("BufReadPost")
  au FileReadPost * call <SID>collect_vim_interactions("FileReadPost")
  au FilterReadPost * call <SID>collect_vim_interactions("FilterReadPost")
  au StdinReadPost * call <SID>collect_vim_interactions("StdinReadPost")
  au BufWrite * call <SID>collect_vim_interactions("BufWrite")
  au BufWritePost * call <SID>collect_vim_interactions("BufWritePost")
  au FileWritePost * call <SID>collect_vim_interactions("FileWritePost")
  au FileAppendPost * call <SID>collect_vim_interactions("FileAppendPost")
  au FilterWritePost * call <SID>collect_vim_interactions("FilterWritePost")
  au BufAdd * call <SID>collect_vim_interactions("BufAdd")
  au BufCreate * call <SID>collect_vim_interactions("BufCreate")
  au BufDelete * call <SID>collect_vim_interactions("BufDelete")
  au BufWipeout * call <SID>collect_vim_interactions("BufWipeout")
  au BufFilePost * call <SID>collect_vim_interactions("BufFilePost")
  au BufEnter * call <SID>collect_vim_interactions("BufEnter")
  au BufLeave * call <SID>collect_vim_interactions("BufLeave")
  au BufWinEnter * call <SID>collect_vim_interactions("BufWinEnter")
  au BufWinLeave * call <SID>collect_vim_interactions("BufWinLeave")
  au BufUnload * call <SID>collect_vim_interactions("BufUnload")
  au BufHidden * call <SID>collect_vim_interactions("BufHidden")
  au BufNew * call <SID>collect_vim_interactions("BufNew")
  au SwapExists * call <SID>collect_vim_interactions("SwapExists")
  au FileType * call <SID>collect_vim_interactions("FileType")
  au Syntax * call <SID>collect_vim_interactions("Syntax")
  au EncodingChanged * call <SID>collect_vim_interactions("EncodingChanged")
  au TermChanged * call <SID>collect_vim_interactions("TermChanged")
  au VimEnter * call <SID>collect_vim_interactions("VimEnter")
  au GUIEnter * call <SID>collect_vim_interactions("GUIEnter")
  au TermResponse * call <SID>collect_vim_interactions("TermResponse")
  au VimLeave * call <SID>collect_vim_interactions("VimLeave")
  au FileChangedShell * call <SID>collect_vim_interactions("FileChangedShell")
  au FileChangedShellPost * call <SID>collect_vim_interactions("FileChangedShellPost")
  au FileChangedRO * call <SID>collect_vim_interactions("FileChangedRO")
  au ShellCmdPost * call <SID>collect_vim_interactions("ShellCmdPost")
  au ShellFilterPost * call <SID>collect_vim_interactions("ShellFilterPost")
  au FuncUndefined * call <SID>collect_vim_interactions("FuncUndefined")
  au SpellFileMissing * call <SID>collect_vim_interactions("SpellFileMissing")
  au VimResized * call <SID>collect_vim_interactions("VimResized")
  au FocusGained * call <SID>collect_vim_interactions("FocusGained")
  au FocusLost * call <SID>collect_vim_interactions("FocusLost")
  au CursorHold * call <SID>collect_vim_interactions("CursorHold")
  au CursorHold * call <SID>dump_vim_interactions()
  au CursorHoldI * call <SID>collect_vim_interactions("CursorHoldI")
  au CursorMoved * call <SID>collect_vim_interactions("CursorMoved")
  au CursorMovedI * call <SID>collect_vim_interactions("CursorMovedI")
  au WinEnter * call <SID>collect_vim_interactions("WinEnter")
  au WinLeave * call <SID>collect_vim_interactions("WinLeave")
  au TabEnter * call <SID>collect_vim_interactions("TabEnter")
  au TabLeave * call <SID>collect_vim_interactions("TabLeave")
  au CmdwinEnter * call <SID>collect_vim_interactions("CmdwinEnter")
  au CmdwinLeave * call <SID>collect_vim_interactions("CmdwinLeave")
  au InsertEnter * call <SID>collect_vim_interactions("InsertEnter")
  au InsertChange * call <SID>collect_vim_interactions("InsertChange")
  au InsertLeave * call <SID>collect_vim_interactions("InsertLeave")
  au ColorScheme * call <SID>collect_vim_interactions("ColorScheme")
  au RemoteReply * call <SID>collect_vim_interactions("RemoteReply")
  au QuickFixCmdPost * call <SID>collect_vim_interactions("QuickFixCmdPost")
  au SessionLoadPost * call <SID>collect_vim_interactions("SessionLoadPost")
endfunction

call s:bind_collector_to_events()
