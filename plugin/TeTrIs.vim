" Name: Tetris
" A vimmer said it is impossible.
" Now, here is it!
" Version: 0.5
" Features: Colorful realtime game in pure vim6
" News: New mode, top10, better colors, improved rotation, new timing,
"	speedup, animations
" Maintainer, main author: Gergely Kontra <kgergely@mcl.hu>
" Co-autors, helpers:
"	Michael Geddes		v0.4, color, Plugin support, code optimizing
"	Peter ??? raindog		Timing help, bug reports
"	If your name is not here, but should be, drop me a mail
let s:s='---[Tetris game]---'
let s:WIDTH=10|let s:NEXTXPOS=16|let s:NEXTYPOS=2
let s:CLEAR=0|let s:CHECK=1|let s:DRAW=2
let s:shs=7|let s:cols=7

fu! s:Put(l,c,pos,m)
 let sh00=0x0f00|let sh01=0x2222|let sh02=0x0f00|let sh03=0x2222
 let sh10=0x0660|let sh11=0x0660|let sh12=0x0660|let sh13=0x0040 "cheat
 let sh20=0x0644|let sh21=0x0e20|let sh22=0x2260|let sh23=0x0470
 let sh30=0x0740|let sh31=0x0622|let sh32=0x02e0|let sh33=0x4460
 let sh40=0x4620|let sh41=0x0360|let sh42=0x4620|let sh43=0x0360
 let sh50=0x2640|let sh51=0x0630|let sh52=0x2640|let sh53=0x0630
 let sh60=0x0720|let sh61=0x2620|let sh62=0x2700|let sh63=0x2320

 let sgn0='[]'|let sgn1='MM'|let sgn2='{}'|let sgn3='XX'|let sgn4='@@'|let sgn5='<>'|let sgn6='$$'
 exe 'norm '.a:l.'G'.(a:c*2+1)."|a\<Esc>"
 let c=1|let r=1
 let s=(a:c!=s:NEXTXPOS)?(sh{b:sh}{a:pos}):(sh{b:nsh}{a:pos})
 wh r<5
  if s%2
   if a:m==s:DRAW
    exe "norm R".sgn{a:c!=s:NEXTXPOS?(b:col):(b:ncol)}."\<Esc>l"
   elsei a:m==s:CHECK
    let ch=getline('.')[col('.')-1]
    if (b:col<s:cols) && ch!='.' || (b:col==s:cols) && ch=='#'
     retu 0
    en
    norm 2l
   el
    norm 2r.l
   en
  el
   norm 2l
  en
  let c=c+1
  if c>4
   let c=1
   norm 8hj
   let r=r+1
  en
  let s=s/2
 endw
 norm ggr#
 retu 1
endf

let s:i=24|let s:r=''|wh s:i|let s:r=s:r."\<C-y>"|let s:i=s:i-1|endw

fu! s:Cnt(i)
 let m=search('^    ##[^#.]\{'.2*s:WIDTH.'}##')
 if !m|retu|en
 wh m>1
   exe 'norm' m.'GR'.s:r."\<Esc>"
   let m=m-1
 endw
 match Wall /\./
 redr
 sl 150m
 match none
 redr
 sl 150m
 exe "norm 9G".a:i."\<C-a>"
 let l=getline(9)
 let s:score=0+strpart(l,match(l,'[1-9]'))
 if s:score>=s:nxLevel
  let s:COUNTER=s:COUNTER-1
  let s:nxLevel=s:nxLevel+10
 en
 cal s:Cnt(a:i*2)
endf

fu! s:Resume()
 let s:ow=bufnr('%')
 exe bufwinnr(bufnr(s:s)).'winc w'
 res 21
 setl ma
 se gcr=a:hor1-blinkon0 ve=all
endf

fun! s:Pause()
 let &gcr=s:gcr
 let &ve=s:ve
 setl noma
 exe bufwinnr(s:ow).'winc w'
 retu 1
endf

fu! s:Sort()
 wh line('.')>1&&matchstr(getline(line('.')-1),'\d\+$')<s:score|move -2|endw
 g/^$/d
 11,$d _
endf
let s:top10=expand('<sfile>:p:h').'/.tetris'
" let s:top10=$HOME.'/.tetris'
" problems under windows NT with $HOME variable :(

fu! s:End()
 norm 22GdG
 let &gcr=s:gcr
 se nolz
 exe 'vs' s:top10
 if line('$')<10 || matchstr(getline('$'),'\d\+$')<s:score
  let name=strpart(inputdialog("You have made a high score!\nEnter your name"),0,30)
  let numlen=40-strlen(s:score)
  setl ve=all ma
  cal append('$',name)
  exe "norm G".numlen."|a".(s:score)."\<Esc>"
  sil! cal s:Sort()
  w
 en
 q|exe 'sv' s:top10|1|setl bh=delete|vert res 43|noh
 redr|echon 'Press a key to quit game'|cal getchar()|q
 let i=21|wh i|del|sl 40ms|let i=i-1|redr|endw|q
 let &ve=s:ve
 let &lz=s:lz
endf

fu! s:Init()
 let s:nxLevel=10
 let s:ow=bufnr('%')
 let s:score=0
 exe 'sp '.escape(s:s,' ').'|1,$d'
 let b:col=0
 let b:ncol=0
 let s:time=0
 let b:nsh=0
 let b:sh=0
 let b:pos=0
 let b:x=6
 let b:y=20
 let s:gcr=&gcr
 let s:ve=&ve
 let s:lz=&lz
 se ve=all
 setl bh=delete bt=nofile nf= gcr=a:hor1-blinkon0 lz
 exe "norm i    ##\<Esc>".s:WIDTH."a..\<Esc>2a#\<Esc>yy19pGo0\<C-d>    #\<Esc>".
   \(2*s:WIDTH+4-1)."a#\<Esc>yy3pgg"
 hi Bg term=reverse ctermfg=Black ctermbg=Black guifg=Black guibg=Black
 syn match Bg "\."
 hi Wall term=reverse ctermfg=DarkBlue ctermbg=DarkBlue guifg=DarkBlue guibg=DarkBlue
 syn match Wall "#"
 hi Shape0 ctermfg=DarkGrey ctermbg=DarkGrey guifg=DarkGrey guibg=DarkGrey
 syn match Shape0 "[[\]]"
 hi Shape1 term=reverse ctermfg=LightGreen ctermfg=LightGreen guifg=LightGreen guibg=LightGreen
 syn match Shape1 "MM"
 hi Shape2 term=reverse ctermfg=LightBlue ctermbg=LightBlue guifg=LightBlue guibg=LightBlue
 syn match Shape2 "{}"
 hi Red term=reverse ctermfg=LightRed ctermbg=LightRed guifg=LightRed guibg=LightRed
 syn match Red "XX"
 hi Shape4 term=reverse ctermfg=DarkYellow ctermbg=DarkYellow guifg=DarkYellow guibg=DarkYellow
 syn match Shape4 "@@"
 hi Shape5 term=reverse ctermfg=DarkMagenta ctermbg=DarkMagenta guifg=DarkMagenta guibg=DarkMagenta
 syn match Shape5 "<>"
 hi Shape6 term=reverse ctermfg=DarkCyan ctermbg=DarkCyan guifg=DarkCyan guibg=DarkCyan
 syn match Shape6 "$\$"

 let n="\<Esc>9hji"
 let v="##########".n
 let f="#........#".n
 exe "norm 21\<C-w>_50\<C-W>|"
 exe "norm 1G32\<Bar>i".v.f.f.f.f.v."\<Esc>8G32\<Bar>iScore:\<Esc>j2h6i0\<Esc>"
 exe "norm jj32\<Bar>iKeys:\<Esc>bjih,l: Left, Right\<Esc>2Fhjij,k: Down, Rotate\<Esc>"
 exe "norm Fjji' ': Drop\<Esc>2F'ji+,=:  Speed up"
 exe "norm 2F+jiq,q: Pause, Quit\<esc>"
 if !exists('s:CNT')
  let s:CNT=0
  echon '' | echon 'Calibrating delay loop...'
  let t0=localtime()
  let t1=t0|wh t1==t0|let t1=localtime()|endw  " wait for start of a new second
  let t0=t1|wh t1==t0|let t0=localtime()|cal s:Loop('h')|let s:CNT=s:CNT+1|endw
 en
 let s:COUNTER=s:CNT/3
 let s:DELAY=1000/s:CNT-4
" Just checking... 
"  let CNT2=0
"  let t0=localtime()
"  let t1=t0|wh t1==t0|let t1=localtime()|endw  " wait for start of a new second
"  let t0=t1|wh t1==t0|let t0=localtime()|exe "sl ".d."m"|let CNT2=CNT2+1|endw
"  cal input('CNT='.CNT.' CNT2='.CNT2.' Counter:'.s:COUNTER)
 let s:mode=confirm('Game mode',"Traditional\nRotating")-1
endf

fu! s:Loop(c)
 let c=a:c
 cal s:Put(b:y,b:x,b:pos,s:CLEAR)
 if c=~ '[hjikl]'
  let nx=b:x+((c=='h')?-1:((c=='l')?1:0))
  let ny=b:y+((c=='j')?1:0)
  let npos=(c!~'[ik]')?(b:pos):((b:pos+1)%4)
  if s:Put(ny,nx,npos,s:CHECK)
   let b:x=nx
   let b:y=ny
   let b:pos=npos
  endif
 elsei c==' '
  wh s:Put(b:y+1,b:x,b:pos,s:CHECK)
   let b:y=b:y+1
  endw
  "brea  No break It's a feature!
 elsei c=="\<Esc>" || c=='q'
  cal s:End()
  retu 2
 elsei c=~'[+=]'
  let s:COUNTER=s:COUNTER-1
 en
 cal s:Put(b:y,b:x,b:pos,s:DRAW)
 redr
 if c=='p'|retu s:Pause()|en
 retu 0
endf

fu! s:Main()
 if bufnr(s:s)==-1 || bufwinnr(bufnr(s:s))==-1
  cal s:Init()
 el
  cal s:Resume()
 en

 let CURRXPOS=6 | let CURRYPOS=1


 wh 1
  wh 1
   let cnt=s:COUNTER
   wh cnt
    let cnt=cnt-1
    if getchar(1)
     let c=nr2char(getchar())
     let r=s:Loop(c)
     if r|retu r|en
    el
     exe 'sl '.s:DELAY.'m'
    en
   endw
   "timeout
   cal s:Put(b:y,b:x,b:pos,s:CLEAR)
   " try to move down
   if !s:Put(b:y+1,b:x,b:pos,s:CHECK)
    cal s:Put(b:y,b:x,b:pos,s:DRAW)
    brea
   en
   let b:y=b:y+1
   cal s:Put(b:y,b:x,b:pos,s:DRAW)
   redr
  endw
  cal s:Cnt(1)
  if s:mode
   exe "norm 1G7|\<C-V>19j2ld18lP"
  en
  cal s:Put(s:NEXTYPOS,s:NEXTXPOS,0,s:CLEAR)
  let b:sh=b:nsh
  let b:col=b:ncol
  let b:nsh=(8*b:sh+1+localtime())%s:shs
  let b:ncol=(8*b:col+1+localtime())%(s:cols)
  let b:pos=0
  cal s:Put(s:NEXTYPOS,s:NEXTXPOS,0,s:DRAW)
  let b:x=CURRXPOS|let b:y=CURRYPOS
  if !s:Put(b:y,b:x,b:pos,s:CHECK)
   cal s:End()
   retu 0
  en
  cal s:Put(b:y,b:x,b:pos,s:DRAW)
  redr
 endw
endf

nmap <Leader>te :cal <SID>Main()<CR>
" vi:sw=1
