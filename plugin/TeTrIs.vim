let s='---Tetris by Gergely Kontra---'
let WIDTH=10 | let COUNTER=20 | let SLEEP=30

fu! Go(l,c)
 exe 'norm '.a:l.'G'.(1+a:c*2)."|a\<Esc>"
endf

let CLEAR=0 | let CHECK=1 | let DRAW=2
let sgn='[]'
fu! Put(l,c,v,m)
 cal Go(a:l,a:c)
 let c=1|let r=1|let s=a:v|wh r<5
  if s%2
   if a:m && getline('.')[col('.')-1] !=' '|if a:m==2|echo "BUG"|en|retu 0|en
   if a:m==2
    exe "norm R".g:sgn."\<Esc>l"
   elsei a:m==1
    norm 2l
   el
    norm 2r l
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

let i=24|let r=''|wh i|let r=r."\<C-y>"|let i=i-1|endw
fu! Cnt(i)
 let m=search('^    \V##\('.g:sgn.'\)\{'.g:WIDTH.'}##')
 if !m|retu|en
 wh m>1
   exe 'norm' m.'GR'.g:r."\<Esc>"
   let m=m-1
 endw
 redr
 sleep 100m
 exe "norm 9G".a:i."\<C-a>"
 cal Cnt(a:i*2)
endf

fu! Init()
 let g:nsh=0
 let g:sh=0
 let g:pos=0
 let g:x=5
 let g:y=20
 let g:time=0
 exe 'sp '.escape(g:s,' ').'|1,$d'
 setl ve=all bh=delete bt=nowrite nf=""
 let g:gcr=&gcr
 set gcr=a:hor1-blinkon0
 exe "norm i    ##\<Esc>".(2*g:WIDTH)."a \<Esc>2a#\<Esc>Y19pGo0\<C-d>    #\<Esc>".
   \(2*g:WIDTH+4-1)."a#\<Esc>Y3pgg"
 hi Wall term=NONE cterm=NONE gui=NONE ctermfg=Green ctermbg=Green
 hi Wall gui=NONE guifg=Green guibg=Green
 syn match Wall "[#+|-]"
 hi Shape term=NONE cterm=NONE gui=NONE ctermfg=DarkGrey ctermbg=DarkGrey
 hi Shape gui=NONE guifg=DarkGrey guibg=DarkGrey
 syn match Shape "[[\]]"

 let n="\<Esc>9hji"
 let v="+--------+".n
 let f="|        |".n
 exe "norm 21\<C-w>_"
 exe "norm 1G40\<Bar>i".v.f.f.f.f.v."\<Esc>8G40\<Bar>iScrore:\<Esc>j2h6i0\<Esc>"
 redr
endf

fu! Main()
 if bufnr(g:s)==-1|cal Init()|el|wh bufname('')!=g:s|bn|endw|res|en
 let sh00=0x0f00|let sh01=0x2222|let sh02=0x00f0|let sh03=0x8888
 let sh10=0x0660|let sh11=0x0660|let sh12=0x0660|let sh13=0x0660
 let sh20=0x0644|let sh21=0x0e20|let sh22=0x2260|let sh23=0x0470
 let sh30=0x0740|let sh31=0x0622|let sh32=0x02e0|let sh33=0x4460
 let sh40=0x4620|let sh41=0x0360|let sh42=0x0462|let sh43=0x06c0
 let sh50=0x0264|let sh51=0x0630|let sh52=0x2640|let sh53=0x0c60
 let shs=6

 let NEXTXPOS=20 | let NEXTYPOS=2
 let CURRXPOS=6 | let CURRYPOS=1

 wh 1
   wh 1
     let cnt=g:COUNTER
     wh cnt
       let cnt=cnt-1
       if getchar(1)
         let c=nr2char(getchar())
         cal Put(g:y,g:x,sh{g:sh}{g:pos},g:CLEAR)
         if c=='h' && Put(g:y,g:x-1,sh{g:sh}{g:pos},g:CHECK)
           let g:x=g:x-1
         elsei c=='l' && Put(g:y,g:x+1,sh{g:sh}{g:pos},g:CHECK)
           let g:x=g:x+1
         elsei c=='j' && Put(g:y+1,g:x,sh{g:sh}{g:pos},g:CHECK)
           let g:y=g:y+1
         elsei c==' '
           wh Put(g:y+1,g:x,sh{g:sh}{g:pos},g:CHECK)
             let g:y=g:y+1
           endw
         elsei c=='i' && Put(g:y,g:x,sh{g:sh}{(g:pos+1)%4},g:CHECK)
           let g:pos=(g:pos+1)%4
         elsei c=="\<Esc>" || c=='q'
           cal End()
           retu 0
         en
         cal Put(g:y,g:x,sh{g:sh}{g:pos},g:DRAW)
         redr
         if c=='p'|retu 1|en
       en
       exe 'sl '.g:SLEEP.'m'
     endw
     cal Put(g:y,g:x,sh{g:sh}{g:pos},g:CLEAR)
     if !Put(g:y+1,g:x,sh{g:sh}{g:pos},g:CHECK)
       cal Put(g:y,g:x,sh{g:sh}{g:pos},g:DRAW)
       brea
     en
     let g:y=g:y+1
     cal Put(g:y,g:x,sh{g:sh}{g:pos},g:DRAW)
     redr
   endw
   cal Cnt(1)
   cal Put(NEXTYPOS,NEXTXPOS,sh{g:nsh}0,g:CLEAR)
   let g:sh=g:nsh
   let g:nsh=localtime()%shs
   let g:pos=0
   cal Put(NEXTYPOS,NEXTXPOS,sh{g:nsh}0,g:DRAW)
   let g:x=CURRXPOS|let g:y=CURRYPOS
   if !Put(g:y,g:x,sh{g:sh}{g:pos},g:CHECK)
     cal End()
     retu 0
   en
   cal Put(g:y,g:x,sh{g:sh}{g:pos},g:DRAW)
   redr
 endw
endf

fu! End()
 norm 22GdG
 let i=21|wh i|del|sl 40ms|let i=i-1|redr|endw|bd
 let &gcr=g:gcr
endf

nmap <Leader>te :cal Main()<CR>
