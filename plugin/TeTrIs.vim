" Name: Tetris
" Author: Gergely Kontra - Colour and Plugin by Michael Geddes
" Version: 0.4
let s:s='---Tetris by Gergely Kontra + Michael Geddes---'
let s:WIDTH=10 
let s:COUNTER=20 
let s:SLEEP=30
"let s:SPEEDMULT=100
"let s:LVLMULT=1000
let s:SPEEDMULT=1200
let s:LVLMULT=14000

fu! s:Go(l,c)
 exe 'norm '.a:l.'G'.(1+a:c*2)."|a\<Esc>"
endf
" [], ==, {}, XX, @@, <>, $$

let s:sgnre='\[]\|MM\|{}\|XX\|$$\|@@\|<>'
let s:CLEAR=0 | let s:CHECK=1 | let s:DRAW=2
let s:sgn0='[]'
let s:sgn1='MM'
let s:sgn2='{}'
let s:sgn3='XX'
let s:sgn4='@@'
let s:sgn5='<>'
let s:sgn6='$$'
let s:sh00=0x0f00|let s:sh01=0x2222|let s:sh02=0x00f0|let s:sh03=0x8888
let s:sh10=0x0660|let s:sh11=0x0660|let s:sh12=0x0660|let s:sh13=0x0660
let s:sh20=0x0644|let s:sh21=0x0e20|let s:sh22=0x2260|let s:sh23=0x0470
let s:sh30=0x0740|let s:sh31=0x0622|let s:sh32=0x02e0|let s:sh33=0x4460
let s:sh40=0x4620|let s:sh41=0x0360|let s:sh42=0x0462|let s:sh43=0x06c0
let s:sh50=0x0264|let s:sh51=0x0630|let s:sh52=0x2640|let s:sh53=0x0c60
let s:sh60=0x0720|let s:sh61=0x2620|let s:sh62=0x2700|let s:sh63=0x2320
let s:shs=7

fu! s:Put(l,c,v,m,sgn)
 cal s:Go(a:l,a:c)
 let c=1|let r=1|let s=a:v
 wh r<5
  if s%2
   if a:m && getline('.')[col('.')-1] !=' '|if a:m==2|echo "BUG"|en|retu 0|en
   if a:m==2
    exe "norm R".a:sgn."\<Esc>l"
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

let s:i=24|let s:r=''|wh s:i|let s:r=s:r."\<C-y>"|let s:i=s:i-1|endw
fu! s:Cnt(i)
 let m=search('^    \V##\('.s:sgnre.'\)\{'.s:WIDTH.'}##')
 if !m|retu|en
 wh m>1
   exe 'norm' m.'GR'.s:r."\<Esc>"
   let m=m-1
 endw
 redr
 sleep 100m
 exe "norm 9G".a:i."\<C-a>"
 cal s:Cnt(a:i*2)
endf

fu! s:Resume()
 let s:ow=bufnr('%')
 exe bufwinnr(bufnr(s:s)).'winc w'
 res 21
 set gcr=a:hor1-blinkon0
endf

fun! s:Pause()
 let &gcr=s:gcr
 exe bufwinnr(s:ow).'winc w'

endf
fu! s:Clear()
   g/^    ##[^#]/ exe "norm 7\<bar>".(s:WIDTH*2)."r@:sleep 20m\<cr>:redr\<cr>"
   sleep 200m
   g/^    ##[^#]/ exe "norm 7\<bar>".(s:WIDTH*2)."r :sleep 20m\<cr>:redr\<cr>"

   cal s:Put(b:NEXTYPOS,b:NEXTXPOS,s:sh{b:nsh}0,s:CLEAR,s:sgn{b:nsh})
   cal s:Cnt(1)
   let b:nsh=localtime()%s:shs
   let b:sh=0
   let b:pos=0
   let b:x=5
   let b:y=20
endfu

fu! s:Init()
 let s:ow=bufnr('%')
 exe 'sp '.escape(s:s,' ').'|1,$d'
 let b:nsh=0
 let b:sh=0
 let b:pos=0
 let b:x=5
 let b:y=20
 let b:time=0
 let b:lvl=0
 let b:spd=0
 setl ve=all bh=delete bt=nowrite nf=""
 let s:gcr=&gcr
 set gcr=a:hor1-blinkon0
 exe "norm i    ##\<Esc>".s:WIDTH."a  \<Esc>2a#\<Esc>yy19pGo0\<C-d>    #\<Esc>".
   \(2*s:WIDTH+4-1)."a#\<Esc>yy3pgg"
 hi Wall term=NONE cterm=NONE gui=NONE ctermfg=Green ctermbg=Green
 hi Wall gui=NONE guifg=Green guibg=Green
 syn match Wall "[#+|-]"
 hi Shape0 term=NONE cterm=NONE gui=NONE ctermfg=DarkGrey ctermbg=DarkGrey
 hi Shape0 gui=NONE guifg=DarkGrey guibg=DarkGrey
 syn match Shape0 "[[\]]"
 hi Shape1 term=NONE cterm=NONE gui=NONE ctermfg=DarkGreen ctermbg=DarkGreen guifg=DarkGreen guibg=DarkGreen
 syn match Shape1 "MM"
 hi Shape2 term=NONE cterm=NONE gui=NONE ctermfg=DarkBlue ctermbg=DarkBlue guifg=DarkBlue guibg=DarkBlue
 syn match Shape2 "{}"
 hi Shape3 term=NONE cterm=NONE gui=NONE ctermfg=DarkRed ctermbg=DarkRed guifg=DarkRed guibg=DarkRed
 syn match Shape3 "XX"
 hi Shape4 term=NONE cterm=NONE gui=NONE ctermfg=DarkYellow ctermbg=DarkYellow guifg=DarkYellow guibg=DarkYellow
 syn match Shape4 "@@"
 hi Shape5 term=NONE cterm=NONE gui=NONE ctermfg=DarkMagenta ctermbg=DarkMagenta guifg=DarkMagenta guibg=DarkMagenta
 syn match Shape5 "<>"
 hi Shape6 term=NONE cterm=NONE gui=NONE ctermfg=DarkCyan ctermbg=DarkCyan guifg=DarkCyan guibg=DarkCyan
 syn match Shape6 "$\$"


 let n="\<Esc>9hji"
 let v="+--------+".n
 let f="|        |".n
 exe "norm 21\<C-w>_"
 exe "norm 1G40\<Bar>i".v.f.f.f.f.v."\<Esc>8G40\<Bar>iScore:\<Esc>j2h6i0\<Esc>"
 exe "norm jj40\<Bar>iKeys:\<Esc>j4hiLeft, Right: h l\<Esc>j15hiDown, Rotate: j k\<esc>"
 exe "norm j16hiDrop: <space>\<Esc>"
 exe "norm j12hiPause, Quit: p q\<esc>"
 redr
endf
fu! s:Ctr( lvl, speed)
  let spd = s:COUNTER - (a:lvl * 5 + a:speed/10)
  return  ((spd<5)? 5: spd)
endf
fu! s:Slp( lvl, speed)
  return a:lvl<s:SLEEP?(s:SLEEP-(a:lvl) ):1
endf

fu! s:Main()
 if bufnr(s:s)==-1 || bufwinnr(bufnr(s:s))==-1
	 cal s:Init()
 el
 	cal s:Resume()
 en

 let b:NEXTXPOS=20 | let b:NEXTYPOS=2
 let b:CURRXPOS=6 | let b:CURRYPOS=1


 wh 1
   wh 1
     let cnt=s:Ctr(b:lvl, b:spd)
	 let tt=0
     wh cnt>0
       let cnt=cnt-1
       if getchar(1)
         let c=nr2char(getchar())
         cal s:Put(b:y,b:x,s:sh{b:sh}{b:pos},s:CLEAR,s:sgn{b:sh})
		 if c=~ '[hjikl]'
			 let dx=(c=='h')?-1:((c=='l')?1:0)
			 let dy=(c=='j')?1:0
			 let dpos=(c!~'[ik]')?(b:pos):((b:pos+1)%4)
			 if s:Put(b:y+dy,b:x+dx,s:sh{b:sh}{dpos},s:CHECK,s:sgn{b:sh})
				let b:x=b:x+dx
				let b:y=b:y+dy
				let b:pos=dpos
			 endif
         elsei c==' '
           wh s:Put(b:y+1,b:x,s:sh{b:sh}{b:pos},s:CHECK,s:sgn{b:sh})
             let b:y=b:y+1
           endw
		   brea
         elsei c=="\<Esc>" || c=='q'
           cal s:End()
           retu 0
         en
         cal s:Put(b:y,b:x,s:sh{b:sh}{b:pos},s:DRAW,s:sgn{b:sh})
         redr
         if c=='p'|retu s:Pause()|en
       en
	   let t= s:Slp(b:lvl, b:spd )
       exe 'sl '.t.'m'
	   let tt=tt+t+5
     endw
     cal s:Put(b:y,b:x,s:sh{b:sh}{b:pos},s:CLEAR,s:sgn{b:sh})
     if !s:Put(b:y+1,b:x,s:sh{b:sh}{b:pos},s:CHECK,s:sgn{b:sh})
       cal s:Put(b:y,b:x,s:sh{b:sh}{b:pos},s:DRAW,s:sgn{b:sh})
       brea
     en
     let b:y=b:y+1
     cal s:Put(b:y,b:x,s:sh{b:sh}{b:pos},s:DRAW,s:sgn{b:sh})
     redr
	 "let b:time=b:time+1
	 let b:time=b:time+(tt/10)
	 let b:spd = b:time / s:SPEEDMULT
	 if (b:time / s:LVLMULT) > 1
	 	let b:time=(b:time % s:LVLMULT)
		let b:lvl=b:lvl+1
     endif
"	 exe "norm 17G40\<bar>R".b:time." ".b:spd." ".b:lvl."\<esc>"
   endw
   cal s:Cnt(1)
   cal s:Put(b:NEXTYPOS,b:NEXTXPOS,s:sh{b:nsh}0,s:CLEAR,s:sgn{b:nsh})
   let b:sh=b:nsh
   let b:nsh=localtime()%s:shs
   let b:pos=0
   cal s:Put(b:NEXTYPOS,b:NEXTXPOS,s:sh{b:nsh}0,s:DRAW,s:sgn{b:nsh})
   let b:x=b:CURRXPOS|let b:y=b:CURRYPOS
   if !s:Put(b:y,b:x,s:sh{b:sh}{b:pos},s:CHECK,s:sgn{b:sh})
     cal s:End()
     retu 0
   endif
   cal s:Put(b:y,b:x,s:sh{b:sh}{b:pos},s:DRAW,s:sgn{b:sh})
   redr
 endw
endf

fu! s:End()
 norm 22GdG
 let i=21|wh i|del|sl 40ms|let i=i-1|redr|endw|bd
 let &gcr=s:gcr
endf

nmap <Leader>te :cal <SID>Main()<CR>

