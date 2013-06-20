finish
let s:save_cpo = &cpo
set cpo&vim

if !has('python')
  echoerr 'Disabling tracker.vim. You need +python in your Vim'
  finish
endif

let s:pulse_username = ""

if exists("g:tracker_loaded")
  finish
endif
let g:tracker_loaded = 1

if get(g:, 'tracker_disable_set_updatetime', 0)
  set updatetime=500
endif

function! s:dump_vim_interactions()
  call s:publish_msg("/tracker/vim (" . join(s:events, " ") . ")")
  call s:publish_msg("/cwd/vim \"" . expand("%:p:h") . "\"")
  let s:events = []
endfunction

function! s:get_rfc3339()
  if exists("*strftime")
    return "#inst \"" . strftime("%FT%T%z", localtime()) . "\""
  else
    return "nil"
  endif
endfunction

function! s:collect_vim_interactions(cmd)
  let l:entry = printf(
    \ "{ :editor :vim :event {:command %s} :file-name \"%s\" :buffer-name \"%s\" :column %d, :line %d :time %s :hostname \"%s\" :username \"%s\"}",
    \ a:cmd, escape(expand("%:p"), '\\"'), escape(expand(bufname("%")), '\\"'), col("."), line("."), s:get_rfc3339(), hostname(), $USER)
  call add(s:events, l:entry)
endfunction

function! s:bind_collector_to_events()
  let s:events = []
  augroup tracker_events_aug
    autocmd!
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
    " au FuncUndefined * call <SID>collect_vim_interactions("FuncUndefined")
    au SpellFileMissing * call <SID>collect_vim_interactions("SpellFileMissing")
    au VimResized * call <SID>collect_vim_interactions("VimResized")
    au FocusGained * call <SID>collect_vim_interactions("FocusGained")
    au FocusLost * call <SID>collect_vim_interactions("FocusLost")
    au CursorHold * call <SID>collect_vim_interactions("CursorHold")
    au CursorHold * call <SID>dump_vim_interactions()
    au CursorHoldI * call <SID>collect_vim_interactions("CursorHoldI")
    au CursorHoldI * call <SID>dump_vim_interactions()
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
  augroup END
endfunction

function! s:publish_msg(msg)
  " echo "publishing msg: " . a:msg
  python <<EOF
import socket
import os.path
import vim

SOCKET_FILE = os.path.expanduser("~/.pulse/.unix-datagram.socket")

def _publish_msg(msg):
  if os.path.exists(SOCKET_FILE):
    sock = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
    sock.connect(SOCKET_FILE)
    sock.sendall(msg)
    sock.close()

try:
  _publish_msg(vim.eval("a:msg"))
except Exception, e:
  print e
EOF
endfunction

call s:bind_collector_to_events()

let &cpo = s:save_cpo
unlet s:save_cpo
