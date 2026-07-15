section .text
global _start
_start:
 pushad
 mov eax,3
 mov ebx,0
 mov ecx,inputCI 
 mov edx,50000 
 int 0x80
 popad
 ;;;;syntax analyzer
  mov edx,"z"
  mov [track+0],edx 
  mov ecx,1
  mov [seqts],ecx   ;seqts for track
  mov ecx,0
  mov [newc],ecx  ;newline counter
  mov [fcs],ecx   ;totally pointless
  mov [sync],ecx ;counterfor CISYN 
 ;;;;;;semantic analyzer 
  mov eax,"z"
  mov [semtrack],eax  
  mov ecx,0
  mov [newcsm],ecx
  mov [cntn],ecx
  mov [varseq],ecx
  mov [semco],ecx
 ;codegenerator
  mov esi,cim
  mov [CIR2+20],esi
  mov [stackc],ecx 
  pushad
  mov esi,sec
  mov edi,gentext
  mov ecx,14
  cld 
  rep movsb 
  popad

;in alpha fix input issues 
;make it possible to push an input
;make adding an integer to adress of X possible 
;make instruction PTR to define a pointer 
;add registers of 64 bit 
;allow floating point if u can 
;add registers si, di and esp/sp 
;allow reserving stack 
;allow jumps in code
;allow inline nasm 

 
lexstart:
 mov ecx,0
 mov [lexc],ecx
 mov ecx,[lexco]
 jmp mainlex

mainlex:
 call lexread
 mov bh,"m"
 cmp bh,bl
 je supposemov
 mov bh,"e"
 cmp bh,bl
 je supposereg
 mov bh,"a"
 cmp bh,bl
 je supposeregx
 mov bh,"b"
 cmp bh,bl
 je supposebit
 mov bh,"c"
 cmp bh,bl
 je supposeregx
 mov bh,"d"
 cmp bh,bl
 je supposeregx
 mov bh,BYTE[fe+0] 
 cmp bh,bl 
 je supposefunc 
 mov bh,BYTE[seq2+0] 
 cmp bh,bl 
 je skeywords
 mov bh,BYTE[while2+0] 
 cmp bh,bl 
 je supposewhile
 mov bh,BYTE[ifn+0]
 cmp bh,bl 
 je ikeywords
 mov bh,BYTE[print2+0] 
 cmp bh,bl 
 je pkeywords
 mov bh,BYTE[else2+0] 
 cmp bh,bl 
 je supposeelse
 mov bh,BYTE[return2+0] 
 cmp bh,bl 
 je rkeywords 
 mov bh,[null2+0]
 cmp bh,bl
 je nullkeyw
 mov bh,[true2+0]
 cmp bh,bl
 je truekeyw
 jmp instrec

instrec: ;shifting , boolean , pps mmn 
 mov bh,"-" 
 cmp bh,bl 
 je recmin  
 mov bh,"~"
 cmp bh,bl
 je putneg 
 mov bh,"+" 
 cmp bh,bl 
 je recpls 
 mov bh,"|" 
 cmp bh,bl 
 je recorl
 mov bh,"!" 
 cmp bh,bl 
 je recnot 
 mov bh,"&" 
 cmp bh,bl 
 je recptrand 
 mov bh," "
 cmp bh,bl 
 je mainlex    
 mov bh,":"
 cmp bh,bl
 je putdots
 jmp supposeint 

supposeint:
 mov bh,0
 mov [ff],bh
 mov edx,0
 jmp supposeint2
supposeint2:
 mov bh,BYTE[ints1+edx]
 cmp bh,bl
 je recint1
 mov eax,10
 cmp edx,eax
 je supposeletter1
 inc edx
 jmp supposeint2
 
recint1: 
 call saveint 
 call lexread 
 mov edx,0 
 mov eax,10
 jmp recint2
recint2:
 mov bh,BYTE[ints1+edx]
 cmp bh,bl
 je recint1
 inc edx
 cmp edx,eax 
 jne recint2
 mov bh,"."
 cmp bh,bl
 je chkflot 
 jmp finint 

finint:
 mov bh,0
 call saveint
 mov bh,[ff]
 mov bl,"o"
 cmp bh,bl 
 je finflt 
 push ecx
 mov ecx,[intt] 
 call putx
 mov eax,0
 mov bh, 0
finint2:
 mov bl,[lex_int+eax]
 cmp bl,bh
 je finint3
 mov [CILEX+edx],bl
 add edx,1
 add eax,1  
 jmp finint2
finint3: 
 mov bl,"|"
 mov [CILEX+edx],bl
 add edx,1
 mov [lexc],edx
 pop ecx 
 mov bh,0
 mov [ff],bh
 mov bx,0
 mov [intc],bx
 dec ecx
 jmp mainlex
 
finflt:
 push ecx
 mov ecx,[flt]
 call putx
 pop ecx
 mov eax,0
 mov bh,0
finflt2:
 mov bl,[lex_int+eax]
 cmp bh,bl
 je finflt3
 mov [CILEX+edx],bl
 add edx,1
 add eax,1  
 jmp finflt2
finflt3:
 mov bl,"|"
 mov [CILEX+edx],bl
 add edx,1
 mov [lexc],edx
 mov bh,0
 mov [ff],bh
 mov bx,0
 mov [intc],bx
 sub ecx,1
 jmp mainlex

chkflot:
 push bx
 mov bl,[ff]
 mov bh,0 
 cmp bh,bl
 je putflot
 pop bx
 jmp lexerr2
putflot:
 pop bx
 mov edx,"o"
 mov [ff],edx
 jmp recint1

saveint:
 mov eax,[intc]
 mov [lex_int+eax],bh
 inc eax
 mov [intc],eax
 ret 

supposeletter1:
 mov edx,52
 mov eax,0
supposeletter:
 mov bh,[letters+eax] 
 cmp bh,bl 
 je adjusttoid2
 cmp eax,edx
 je supposebsbp
 inc eax
 jmp supposeletter
 
supposebsbp:
 mov bh,"("
 cmp bh,bl 
 je putlp
 mov bh,")"
 cmp bh,bl 
 je putrp
 mov bh,"{"
 cmp bh,bl 
 je putlb
 mov bh,"}"
 cmp bh,bl 
 je putrb
 mov bh,"["
 cmp bh,bl 
 je putsbbl
 mov bh,"]"
 cmp bh,bl 
 je putsbbr
 jmp supposetcqmdsc

supposetcqmdsc:
 mov bh,";"
 cmp bh,bl
 je terminator 
 mov bh,0xa
 cmp bh,bl
 je terminator2  
 mov bh,"#"
 cmp bh,bl
 je comment 
 mov bh,'"';qm1
 cmp bh,bl
 je recstr
 mov bh,"'";qm2
 cmp bh,bl
 je recstr2
 mov bh,","
 cmp bh,bl
 je comma
 jmp supcmpmath 
  
supcmpmath:
 mov bh,">"
 cmp bh,bl 
 je recgrt 
 mov bh,"<"
 cmp bh,bl 
 je recles  
 mov bh,"="
 cmp bh,bl 
 je recequ 
 mov bh,"*" 
 cmp bh,bl 
 je putmul
 mov bh,"/"
 cmp bh,bl 
 je putdiv 
 mov bh,"^"
 cmp bh,bl 
 je putpor 
 mov bh,"?"
 cmp bh,bl
 je finlex
 jmp lexerr

supposereg:
 push ecx
 call lexread
 mov bh,"a"
 cmp bh,bl
 je puteax
 mov bh,"b"
 cmp bh,bl
 je putebx
 mov bh,"c"
 cmp bh,bl
 je putecx
 mov bh,"d"
 cmp bh,bl
 je putedx
 mov bh,"s"
 cmp bh,bl
 je putesi 
 jmp adjusttoid
supposeregx:
 push ecx
 mov [regsx+0],bl
 call lexread
 mov [regsx+1],bl
 mov bh,"l"
 cmp bh,bl
 je putregx
 mov bh,"h"
 cmp bh,bl
 je putregx
 mov bh,"x"
 cmp bh,bl
 je putregx
 mov bh,"y"
 cmp bh,bl
 je putbyte
 mov bh,"w"
 cmp bh,bl
 je putdword
 jmp adjusttoid
 
supposebit:
 push ecx
 call lexread 
 mov bh,"i"
 cmp bh,bl
 jne gotoreg
 call lexread 
 mov bh,"t"
 cmp bh,bl 
 jne adjusttoid
 call lexread
 call noid 
 pop edx 
 jmp putbit 
 
 gotoreg:
 pop ecx
 dec ecx
 call lexread
 jmp supposeregx

supposemov:
 push ecx 
 call lexread 
 mov bh,"o"
 cmp bh,bl
 jne adjusttoid 
 call lexread
 mov bh,"v"
 cmp bh,bl
 jne adjusttoid 
 ;;;;;;;
 call lexread 
 mov bh,"b"
 cmp bh,bl 
 je supposemovb 
 mov bh,"c"
 cmp bh,bl
 je supposemovci 
 call noid 
 pop edx 
 jmp putmov 

 supposemovb:
 call lexread 
 call noid 
 pop edx
 jmp putmovb 
 
 supposemovci:
 call lexread
 mov bh,"i"
 cmp bh,bl
 jne adjusttoid 
 call lexread 
 call noid 
 pop edx 
 jmp putmovci 

;;;;;;;;;;;PUTS;;;;;;;;;;;
 putsys:
 push ecx
 mov ecx,"SYS"
 call putx
 pop ecx
 jmp mainlex
 
 putdots:
 push ecx
 mov ecx,[dots]
 call putx
 pop ecx
 jmp mainlex

 putbit:
 push ecx 
 mov ecx,[bit]
 call putx
 pop ecx
 jmp mainlex
 
 putmov:
 push ecx 
 mov ecx,[movt]
 call putx
 pop ecx
 jmp mainlex

 putmovb:
 push ecx 
 mov ecx,[movb]
 call putx
 pop ecx
 jmp mainlex 
 
 putregfunc:
 push ecx
 mov ecx,"REG"
 call putx
 pop ecx
 jmp mainlex
 
 putmovci:
 push ecx 
 mov ecx,[movci]
 call putx
 pop ecx
 jmp mainlex 
 putbyte:
 mov bh,[regsx+0]
 mov bl,"b"
 cmp bh,bl
 jne adjusttoid
 call lexread
 mov bh,"t"
 cmp bh,bl
 jne adjusttoid
 call lexread
 mov bh,"e"
 cmp bh,bl
 jne adjusttoid 
 call lexread
 call noid
 pop eax
 push ecx
 mov ecx,"BYT"
 call putx
 pop ecx
 jmp mainlex
 putword:
 mov bh,"o"
 cmp bh,bl
 jne adjusttoid
 call lexread
 mov bh,"r"
 cmp bh,bl
 jne adjusttoid
 call lexread
 mov bh,"d"
 cmp bh,bl
 jne adjusttoid
 call lexread
 call noid
 pop eax
 push ecx
 mov ecx,"WRD"
 call putx
 pop ecx
 jmp mainlex
 putdword:
 mov bh,[regsx+0]
 mov bl,"d"
 cmp bh,bl
 jne adjusttoid
 call lexread
 mov bh,"o"
 cmp bh,bl
 jne adjusttoid
 call lexread
 mov bh,"r"
 cmp bh,bl
 jne adjusttoid
 call lexread
 mov bh,"d"
 cmp bh,bl
 jne adjusttoid  
 call lexread
 call noid
 pop eax
 push ecx
 mov ecx,"DWR"
 call putx
 pop ecx
 jmp mainlex 
 
 putregx:
 call lexread
 call noid
 pop eax
 push ecx
 mov ecx,[regsx]
 call putx
 pop ecx
 jmp mainlex
 puteax:
 call lexread
 mov bh,"x"
 cmp bh,bl
 jne adjusttoid
 call lexread
 call noid
 pop eax
 push ecx
 mov ecx,[eaxl]
 call putx
 pop ecx
 jmp mainlex
 putebx:
 call lexread
 mov bh,"x"
 cmp bh,bl
 jne adjusttoid
 call lexread
 call noid
 pop eax
 push ecx
 mov ecx,[ebxl]
 call putx
 pop ecx
 jmp mainlex
 putecx:
 call lexread
 mov bh,"x"
 cmp bh,bl
 jne adjusttoid
 call lexread
 call noid
 pop eax
 push ecx
 mov ecx,[ecxl]
 call putx
 pop ecx
 jmp mainlex 
 putedx:
 call lexread
 mov bh,"i"
 cmp bh,bl
 je putedi
 mov bh,"x"
 cmp bh,bl
 jne adjusttoid
 call lexread
 call noid
 pop eax
 push ecx
 mov ecx,[edxl]
 call putx
 pop ecx
 jmp mainlex
 putedi:
 call lexread
 call noid
 pop eax
 push ecx
 mov ecx,[edil]
 call putx
 pop ecx
 jmp mainlex
 
 putesi:
 call lexread
 mov bh,"i"
 cmp bh,bl
 jne putesp 
 call lexread
 call noid
 pop eax
 push ecx
 mov ecx,[esil]
 call putx
 pop ecx
 jmp mainlex 

 putesp:
 mov bh,"p"
 cmp bh,bl
 jne adjusttoid 
 call lexread 
 call noid 
 pop edx 
 push ecx 
 mov ecx,[espt]
 call putx
 pop ecx
 jmp mainlex
 
 putmul:
 push ecx
 mov ecx,[mult]
 call putx
 pop ecx 
 jmp mainlex
 putpor:
 push ecx
 mov ecx,[port]
 call putx
 pop ecx 
 jmp mainlex
 putdiv:
 push ecx
 mov ecx,[divt]
 call putx  
 pop ecx 
 jmp mainlex

 putneg:
 push ecx
 mov ecx,[negt]
 call putx
 pop ecx
 jmp mainlex
 comma:
 push ecx
 mov ecx,[cma]
 call putx 
 pop ecx 
 jmp mainlex
 putlp:
 push ecx
 mov ecx,[lpr] 
 call putx
 pop ecx 
 jmp mainlex
 putrp:
 push ecx
 mov ecx,[rpr]
 call putx
 pop ecx 
 jmp mainlex
 putlb:
 push ecx
 mov ecx,[br1]
 call putx
 pop ecx
 jmp mainlex
 putrb:
 push ecx
 mov ecx,[br2]
 call putx
 pop ecx 
 jmp mainlex
 putsbbl:
 push ecx
 mov ecx,[sb1]
 call putx
 pop ecx 
 jmp mainlex
 putsbbr:
 push ecx
 mov ecx,[sb2]
 call putx
 pop ecx 
 jmp mainlex

 terminator:
 push ecx
 mov ecx,[term]
 call putx
 pop ecx
 jmp synin
 terminator2:
 push ecx
 mov ecx,[newt]
 call putx
 pop ecx
 mov edx,[newclx]
 add edx,1
 mov [newclx],edx
 jmp synin
 endf:
 push ecx
 mov ecx,[end]
 call putx
 pop ecx
 jmp finx
 comment:
 mov bh,0xa 
 mov bl,[inputCI+ecx]
 inc ecx
 cmp bh,bl 
 jne comment
 jmp mainlex 
 putnequ:
 push ecx
 mov ecx,[neq]
 call putx 
 pop ecx 
 jmp mainlex
 puteq2:
 push ecx
 mov ecx,[eq2]
 call putx 
 pop ecx 
 jmp mainlex
 putgequ:
 push ecx
 mov ecx,[geq]
 call putx 
 pop ecx 
 jmp mainlex
 putfunc:
 push ecx
 mov ecx,[funct]
 call putx 
 pop ecx 
 jmp mainlex

 putshlf:
 call lexread
 mov bh," "
 cmp bh,bl 
 je putshlf2  
 mov bh,"("
 cmp bh,bl
 jne adjusttoid
 putshlf2:
 pop eax
 push ecx
 mov ecx,[shlf]
 call putx
 pop ecx 
 jmp mainlex

 putshrf:
 call lexread
 mov bh," "
 cmp bh,bl 
 je putshrf2 
 mov bh,"("
 cmp bh,bl
 jne adjusttoid
 putshrf2: 
 pop eax
 push ecx
 mov ecx,[shrf]
 call putx
 pop ecx
 jmp mainlex

 putseq:
 pop eax
 push ecx
 mov ecx,[seq]
 call putx
 pop ecx 
 jmp mainlex

 putstrf:
 putstrf2: 
 pop eax
 push ecx
 mov ecx,[strf]
 call putx
 pop ecx
 jmp mainlex

 putintf:
 call lexread
 call noid
 putintf2: 
 push ecx
 mov ecx,[intf]
 call putx
 pop ecx 
 jmp mainlex

 putwhile:
 call lexread
 call noid
 pop eax
 push ecx
 mov ecx,[while]
 call putx
 pop ecx 
 jmp mainlex
 putif:
 call lexread
 call noid
 putif2: 
 pop eax
 push ecx
 mov ecx,[if]
 call putx
 pop ecx 
 jmp mainlex 
 putin:
 mov bh," "
 cmp bh,bl 
 jne adjusttoid 
 push ecx
 mov ecx,[intT]
 call putx
 pop ecx 
 jmp mainlex
 putinput:
 pop eax
 push ecx
 mov ecx,[input]
 call putx
 pop ecx 
 jmp mainlex
 putprint:
 pop eax
 push ecx
 mov ecx,[prn] 
 call putx
 pop ecx 
 jmp mainlex
 putpop:
 pop eax
 push ecx
 mov ecx,[popt]
 call putx
 pop ecx 
 jmp mainlex
 putpush:
 pop eax 
 push ecx
 mov ecx,[pusht]
 call putx
 pop ecx 
 jmp mainlex
 putelse:
 pop eax
 push ecx
 mov ecx,[else]
 call putx
 pop ecx 
 jmp mainlex
 putrolf:
 call lexread 
 mov bh," "
 cmp bh,bl 
 je putrolf2 
 mov bh,"("
 cmp bh,bl 
 jne adjusttoid 
 putrolf2: 
 pop eax
 push ecx
 mov ecx,[rolf]
 call putx
 pop ecx 
 jmp mainlex
 putrorf:
 call lexread 
 mov bh," "
 cmp bh,bl 
 je putrorf2  
 mov bh,"("
 cmp bh,bl 
 jne adjusttoid
 putrorf2: 
 pop eax
 push ecx
 mov ecx,[rorf]
 call putx
 pop ecx 
 jmp mainlex
 putret:
 push ecx
 mov ecx,[return]
 call putx
 pop ecx 
 jmp mainlex
 putlequ:
 push ecx
 mov ecx,[leq]
 call putx
 pop ecx 
 jmp mainlex
 putles:
 push ecx
 mov ecx,[lest]
 call putx
 pop ecx 
 jmp mainlex
 putmin:
 push ecx
 mov ecx,[min]
 call putx
 pop ecx 
 jmp mainlex
 putado:
 push ecx
 mov ecx,[ado]
 call putx
 pop ecx 
 jmp mainlex
 putnot:
 push ecx
 mov ecx,[nott]
 call putx
 pop ecx 
 jmp mainlex
 putptr:
 dec ecx
 push ecx
 mov ecx,[pt] 
 call putx
 pop ecx 
 jmp mainlex
 putshl:
 push ecx
 mov ecx,[shlt]
 call putx
 pop ecx
 jmp mainlex
 putmmn:
 push ecx
 mov ecx,[mmn] 
 call putx 
 pop ecx 
 jmp mainlex
 putshr:
 push ecx
 mov ecx,[shrt]
 call putx
 pop ecx 
 jmp mainlex
 putpps:
 push ecx
 mov ecx,[pps] 
 call putx
 pop ecx 
 jmp mainlex
 putor:
 push ecx
 mov ecx,[ort]
 call putx
 pop ecx 
 jmp mainlex
 putror:
 push ecx
 mov ecx,[rort] 
 call putx
 pop ecx
 jmp mainlex
 putrol:
 push ecx
 mov ecx,[rolt] 
 call putx
 pop ecx
 jmp mainlex
 putand:
 push ecx
 mov ecx,[andt]
 call putx 
 pop ecx 
 jmp mainlex
 putneq:
 push ecx
 mov ecx,[neq]
 call putx
 pop ecx 
 jmp mainlex
 putpls:
 push ecx
 mov ecx,[pls]
 call putx
 pop ecx 
 jmp mainlex
 putgrt:
 push ecx
 mov ecx,[grt]
 call putx
 pop ecx 
 jmp mainlex
 putequ:
 push ecx
 mov ecx,[equt]
 call putx
 pop ecx 
 jmp mainlex
 putnull:
 push ecx
 mov ecx,[null]
 call putx
 pop ecx
 jmp mainlex
 puttrue:
 push ecx
 mov ecx,[true]
 call putx
 pop ecx
 jmp mainlex 
 putfalse:
 push ecx
 mov ecx,[false]
 call putx
 pop ecx
 jmp mainlex  
 putx:
 mov edx,[lexc]
 mov [CILEX+edx],ecx
 add edx,3
 mov [lexc],edx
 ret 
 
;;;;;;;;;;;;RECS;;;;;;;;;
 recstr:
 push ecx
 mov ecx,[strt]
 call putx
 pop ecx
 mov bh,'"'
 jmp recstr1
 recstr1:
 call lexread 
 cmp bh,bl 
 je finstr 
 call prnbl
 jmp recstr1 
 recstr3:
 call lexread  
 cmp bh,bl 
 je finstr2 
 call prnbl
 jmp recstr3

 prnbl:
 pushad
 mov edx,[lexc]
 mov [CILEX+edx],bl
 add edx,1
 mov [lexc],edx
 popad
 ret

 recstr2:
 push ecx
 mov ecx,strt
 call putx
 pop ecx
 mov bh,"'"
 jmp recstr3

 recmin:
 call lexread 
 mov bh,"-"
 cmp bh,bl 
 je putmmn
 mov bh,">"
 cmp bh,bl 
 je putshr
 sub ecx,1
 jmp putmin ;backtrack

 recpls:
 call lexread 
 mov bh,"+"
 cmp bh,bl 
 je putpps
 dec ecx 
 jmp putpls    

 recorl:
 call lexread 
 mov bh,"|"
 cmp bh,bl 
 je putor 
 mov bh,">"
 cmp bh,bl 
 je putror
 mov bh,"<"
 cmp bh,bl 
 je putrol  
 jmp lexerr 

 recnot:
 call lexread  
 mov bh,"="
 cmp bh,bl 
 je putneq
 dec ecx
 jmp putnot 

 recptrand:
 call lexread 
 mov bh,"&"
 cmp bh,bl 
 je putand 
 mov bh,">"
 cmp bh,bl
 je putado
 jmp putptr 

 recgrt:
 call lexread 
 mov bh,"="
 cmp bh,bl 
 je putgequ
 mov bh,">"
 cmp bh,bl
 je putshr
 dec ecx  
 jmp putgrt
 recles:
 call lexread 
 mov bh,"="
 cmp bh,bl 
 je putlequ
 mov bh,"<"
 cmp bh,bl
 je putshl
 dec ecx  
 jmp putles
 
 recequ:
 call lexread 
 mov bh,"="
 cmp bh,bl 
 je puteq2
 dec ecx  
 jmp putequ
 
 recid:
 push ecx 
 mov ecx,[idt]
 call putx 
 pop ecx
 call lexread 
 jmp recid1
 recid1:
 call prnbl
 call lexread 
 mov eax,0
 jmp ifl 

 ifl:
 mov bh,BYTE[letters+eax] 
 cmp bh,bl 
 je recid1
 mov edx,52
 cmp edx,eax 
 je ifl2
 inc eax 
 jmp ifl
 ifl2: 
 mov eax,0
 jmp ifi

 ifi:
 mov bh,BYTE[ints1+eax] 
 cmp bh,bl 
 je recid1 
 mov edx,10
 cmp eax,edx
 je finid
 inc eax
 jmp ifi 

 finid:
 mov bl,"|"
 call prnbl
 sub ecx,1 
 jmp mainlex 

;;;;;;;;;;;;MAINS;;;;;;;;;;;;;
 nullkeyw:
 push ecx
 call lexread 
 mov bh,[null2+1]
 cmp bh,bl
 jne adjusttoid
 call lexread 
 mov bh,[null2+2]
 cmp bh,bl
 jne adjusttoid
 call lexread 
 mov bh,[null2+3]
 cmp bh,bl
 jne adjusttoid
 call lexread 
 call noid
 pop edx
 jmp putnull
 truekeyw:
 push ecx
 call lexread 
 mov bh,[true2+1]
 cmp bh,bl
 jne adjusttoid
 call lexread 
 mov bh,[true2+2]
 cmp bh,bl
 jne adjusttoid
 call lexread 
 mov bh,[true2+3]
 cmp bh,bl
 jne adjusttoid
 call lexread 
 call noid
 pop edx
 jmp puttrue
 falsekeyw:
 call lexread 
 mov bh,[false2+2]
 cmp bh,bl
 jne adjusttoid
 call lexread  
 mov bh,[false2+3]
 cmp bh,bl
 jne adjusttoid
 call lexread  
 mov bh,[false2+4]
 cmp bh,bl
 jne adjusttoid 
 call lexread 
 call noid
 pop edx
 jmp putfalse
 chkfalse:
 mov bh,"a"
 cmp bh,bl
 je falsekeyw
 jmp adjusttoid

 supposefunc:
 push ecx
 call lexread 
 mov bh,BYTE[fe+1] 
 cmp bh,bl
 jne chkfalse
 call lexread 
 mov bh,BYTE[fe+2]
 cmp bh,bl 
 jne adjusttoid 
 call lexread 
 mov bh,BYTE[fe+3]
 cmp bh,bl 
 jne adjusttoid 
 call lexread 
 mov bh,":"
 cmp bh,bl 
 jne adjusttoid 
 push ecx
 mov ecx,[funct]
 call putx 
 pop ecx
 pop eax
 jmp mainlex 

 supposewhile:
 push ecx
 call lexread 
 mov bh,BYTE[while2+1]
 cmp bh,bl 
 jne putword
 call lexread 
 mov bh,BYTE[while2+2]
 cmp bh,bl 
 jne adjusttoid
 call lexread 
 mov bh,BYTE[while2+3]
 cmp bh,bl 
 jne adjusttoid
 call lexread 
 mov bh,BYTE[while2+4]
 cmp bh,bl 
 jne adjusttoid
 jmp putwhile

 adjusttodid:
 pop ecx
 pop ecx
 sub ecx,1
 jmp recid 
 adjusttoid2:
 dec ecx
 jmp recid  
 skeywords:
 push ecx
 call lexread 
 mov bh,BYTE[seq2+1]
 cmp bh,bl 
 je recseq 
 mov bh,BYTE[str2+1]
 cmp bh,bl 
 je recstrf 
 mov bh,BYTE[shl2+1]
 cmp bh,bl 
 je recsh 
 cmp bl,"y"
 je recsys 
 
 recsys:
 call lexread 
 cmp bl,"s"
 jne adjusttoid
 call lexread 
 cmp bl,":"
 jne adjusttoid 
 jmp putsys
 
 recsh:
 call lexread 
 mov bh,BYTE[shl2+2]
 cmp bh,bl 
 je putshlf ;lookahead chkin put 
 mov bh,BYTE[shr2+2]
 cmp bh,bl
 je putshrf 
 jmp adjusttoid  

 recseq:
 call lexread 
 mov bh,BYTE[seq2+2]
 cmp bh,bl
 jne adjusttoid
 call lexread 
 call noid
 jmp putseq

 recstrf:
 call lexread 
 mov bh,BYTE[str2+2]
 cmp bh,bl 
 jne adjusttoid
 call lexread 
 call noid 
 jmp putstrf 

 lexread:
 mov bl,BYTE[inputCI+ecx]
 add ecx,1
 mov [lexco],ecx
 ret

 adjusttoid:
 pop ecx
 sub ecx,2
 call lexread  
 jmp recid 

 ikeywords:
 push ecx
 call lexread 
 mov bh,BYTE[ifn+1]
 cmp bh,bl 
 je putif ;chk in put 
 mov bh,BYTE[ifn+2]
 cmp bh,bl
 je chkn
 jmp adjusttoid
 
 chkn:
 call lexread 
 mov bh,BYTE[int2+2]
 cmp bh,bl 
 je putintf ;chk in put
 mov bh,BYTE[input2+2]
 cmp bh,bl
 je chkinput
 call lexread
 call noid
 pop eax
 jmp putin  ; chk in put 

 chkinput:
 call lexread 
 mov bh,BYTE[input2+3]
 cmp bh,bl 
 jne adjusttoid 
 call lexread  
 mov bh,BYTE[input2+4]
 cmp bh,bl 
 jne adjusttoid 
 call lexread  
 call noid
 jmp putinput

 pkeywords:
 push ecx 
 call lexread 
 mov bh,BYTE[print2+1]
 cmp bh,bl 
 je chkprint 
 mov bh,BYTE[pop2+1]
 cmp bh,bl 
 je chkpop
 mov bh,BYTE[push2+1]
 cmp bh,bl 
 je chkpush 
 jmp adjusttoid 

 lexerr:
 push ebx
 push ecx
 mov ecx,lexe1
 mov edx,lene1
 mov ebx,1
 mov eax,4
 int 0x80
 pop ecx
 pop ebx
 call lexread
 mov [cntn],bl
 mov ecx,CILEX
 mov edx,100
 mov eax,4
 mov ebx,1
 int 0x80   
 mov eax,1
 int 0x80 
 ret 
 lexerr2:
 mov ecx,lexe2
 mov edx,lene2
 mov ebx,1
 mov eax,4
 int 0x80 
 mov ecx,CILEX
 mov edx,100
 mov eax,4
 mov ebx,1
 int 0x80   
 mov eax,1
 int 0x80 
 ret 
 
 chkprint:
 call lexread 
 mov bh,BYTE[print2+2]
 cmp bh,bl 
 jne adjusttoid 
 call lexread 
 mov bh,BYTE[print2+3]
 cmp bh,bl 
 jne adjusttoid 
 call lexread 
 mov bh,BYTE[print2+4]
 cmp bh,bl 
 jne adjusttoid 
 call lexread 
 call noid
 jmp putprint

 chkpop:
 call lexread 
 mov bh,BYTE[pop2+2]
 cmp bh,bl  
 jne adjusttoid 
 call lexread 
 call noid
 jmp putpop

 chkpush:
 call lexread 
 mov bh,BYTE[push2+2]
 cmp bh,bl 
 jne adjusttoid 
 call lexread 
 mov bh,BYTE[push2+3]
 cmp bh,bl 
 jne adjusttoid 
 call lexread 
 call noid
 jmp putpush

 supposeelse:
 push ecx
 call lexread  
 mov bh,BYTE[else2+1] 
 cmp bh,bl 
 jne adjusttoid 
 call lexread 
 mov bh,BYTE[else2+2] 
 cmp bh,bl 
 jne adjusttoid 
 call lexread 
 mov bh,BYTE[else2+3] 
 cmp bh,bl 
 jne adjusttoid
 call lexread 
 mov bh," "
 cmp bh,bl 
 je putelse 
 mov bh,"{"
 cmp bh,bl 
 je putelse
 jmp adjusttoid

 rkeywords:
 push ecx
 call lexread  
 mov bh,BYTE[rol2+1] 
 cmp bh,bl 
 je chkro
 mov bh,BYTE[return2+1] 
 cmp bh,bl 
 je chkret
 jmp adjusttoid 

 chkro:
 call lexread 
 mov bh,BYTE[rol2+2] 
 cmp bh,bl 
 je putrolf ; chk in put (
 mov bh,BYTE[ror2+2] 
 cmp bh,bl 
 je putrorf
 jmp adjusttoid 

 chkret:
 call lexread 
 mov bh,BYTE[return2+2] 
 cmp bh,bl 
 jne chklexreg
 call lexread 
 mov bh,BYTE[return2+3] 
 cmp bh,bl  
 jne adjusttoid 
 call lexread  
 mov bh,BYTE[return2+4] 
 cmp bh,bl 
 jne adjusttoid
 call lexread 
 mov bh,BYTE[return2+5] 
 cmp bh,bl 
 jne adjusttoid
 call lexread 
 mov bh,BYTE[return2+6] 
 cmp bh,bl 
 jne adjusttoid
 mov bh," "
 cmp bh,bl 
 jne adjusttoid 
 pop eax
 jmp putret ; chk for blank sapce  

 chklexreg:
 mov bh,"g"
 cmp bh,bl 
 jne adjusttoid
 call lexread 
 call noid
 jmp putregfunc

 finstr:
 mov bl,"|"
 call prnbl
 jmp mainlex

 finstr2:
 mov bl,"|"
 call prnbl
 jmp mainlex

 finx:
 mov eax,1
 int 0x80 
 
 noid:
 mov edx,26
 mov eax,-1
 noid2:
 add eax,1
 mov bh,[ids+eax]
 cmp bh,bl 
 je adjusttodid
 cmp edx,eax 
 jne noid2
 mov edx,36
 noid3:
 add eax,1
 mov bh,[ids+eax]
 cmp bh,bl
 je adjusttodid
 cmp edx,eax
 jne noid3
 sub ecx,1
 ret


 finlex:
 mov ecx,[eof]
 call putx
 mov eax,4
 mov edx,lenlex
 mov ecx,lexmsg
 mov ebx,1
 int 0x80
 mov ecx,newline
 mov edx,1
 mov eax,4
 mov ebx,1
 int 0x80 
 mov ecx,CILEX
 mov edx,100
 mov eax,4
 mov ebx,1
 int 0x80  
 mov ecx,newline
 mov edx,1
 mov eax,4
 mov ebx,1
 int 0x80 
 jmp synin


 putinsyn:
 push ebx
 mov edx,[sync]
 mov bh,"|"
 putinsyn2:
 mov bl,[CILEX+ecx]
 mov [CISYN+edx],bl
 add ecx,1
 add edx,1
 cmp bh,bl
 jne putinsyn2
 mov [sync],edx
 pop ebx
 ret
 
 synidr:
 push ebx
 mov edx,0
 mov bh,"|" 
 synidr2:
 mov bl,[CILEX+ecx]
 mov [synids+edx],bl
 add edx,1
 add ecx,1
 cmp bh,bl
 jne synidr2
 pop ebx
 ret 
 
 idtosyn:
 push ebx
 mov edx,[sync]
 mov eax,0
 mov bh,"|"
 idtosyn2:
 mov bl,[synids+eax]
 mov [CISYN+edx],bl
 add edx,1
 add eax,1
 cmp bh,bl
 jne idtosyn2
 mov [sync],edx
 pop ebx
 ret 
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;SYNTAX ANALYZER;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

synin:
 mov ecx,0
 mov [sync],ecx ;puts counter
 jmp synstart

synstart:
 mov bl,"z"
 mov [synnf],bl
 call read
 call synreg
 call synbwd
 cmp ebx,"SYS"
 je synSYS
 mov edx,[bit]
 cmp edx,ebx
 je synbit
 mov edx,[movt]
 cmp edx,ebx
 je synmov
 mov edx,[movb]
 cmp edx,ebx
 je synmovb
 mov edx,[movci]
 cmp edx,ebx
 je synmovci 
 mov edx,[intt]
 cmp edx,ebx
 je syn_varint
 mov edx,[strt]
 cmp edx,ebx
 je syn_varstr
 mov edx,[seq]
 cmp edx,ebx
 je syn_seq
 mov edx,[idt]
 cmp edx,ebx 
 je syn_idt
 mov edx,[func]
 cmp edx,ebx 
 je syn_fdf
 mov edx,[prn]
 cmp edx,ebx 
 je syn_prn
 mov edx,[ift]
 cmp edx,ebx 
 je syn_ift
 mov edx,[while]
 cmp edx,ebx 
 je syn_wil
 mov edx,[shlf]
 cmp edx,ebx
 je sorf
 mov edx,[shrf]
 cmp edx,ebx
 je sorf
 mov edx,[rolf]
 cmp edx,ebx
 je sorf
 mov edx,[rorf]
 cmp edx,ebx
 je sorf 
 mov edx,[shlt]
 cmp edx,ebx 
 je sor
 mov edx,[shrt]
 cmp edx,ebx 
 je sor
 mov edx,[rolt]
 cmp edx,ebx 
 je sor
 mov edx,[rort]
 cmp edx,ebx 
 je sor
 mov edx,[strt2]
 cmp edx,ebx 
 je tostr
 mov edx,[intt2]
 cmp edx,ebx 
 je toint
 mov edx,[ter]
 cmp edx,ebx 
 je syn_term
 mov edx,[newt]
 cmp edx,ebx
 je synnewl
 mov edx,[ptrt]
 cmp edx,ebx
 je syn_varptr
 mov edx,[aod]
 cmp edx,ebx
 je syn_varaod 
 mov edx,[flt]
 cmp edx,ebx
 je syn_varint
 mov edx,[min]
 cmp edx,ebx
 je syn_varop1
 mov edx,[pls]
 cmp edx,ebx
 je syn_varop1
 mov edx,[negt]
 cmp edx,ebx
 je syn_varneg
 mov edx,[nott]
 cmp edx,ebx
 je syn_varnot
 mov edx,[lpr]
 cmp edx,ebx
 je syn_varlpr
 mov edx,[popt]
 cmp edx,ebx
 je syn_pop 
 mov edx,[psht]
 cmp edx,ebx
 je syn_push
 mov edx,[return]
 cmp edx,ebx
 je syn_ret 
 mov edx,[br2]
 cmp edx,ebx
 je syn_br2
 mov edx,[eof]
 cmp edx,ebx
 je finsyn
 jmp error

syn_idt:
 call synidr
 call read
 mov edx,[equt]
 cmp edx,ebx 
 je syn_idt2 
 mov edx,[lpr]
 cmp edx,ebx 
 je syn_fcl
 mov edx,[sb1]
 cmp edx,ebx 
 je syn_aru
 push ecx
 mov ecx,[idt]
 call puts
 pop ecx
 call idtosyn
 mov edx,[dect]
 cmp edx,ebx  
 je syn_variod 
 mov edx,[inct]
 cmp edx,ebx 
 je syn_variod
 mov edx,[ter]
 cmp edx,ebx
 je syn_term
 mov edx,[newt]
 cmp edx,ebx
 je synnewl 
 call cmpops
 call ops 
 call bool
 jmp error 
syn_idt2:
 call read
 mov edx,[sb1]
 cmp edx,ebx
 je syn_ard
 sub ecx,3
 push ecx
 mov ecx,[var]
 call puts
 pop ecx
 mov edx,[seqts]
 add edx,1
 mov [seqts],edx 
 mov bl,"z"
 mov [track+edx],bl
 call idtosyn
syn_idt3: 
 call read
 call synbwd
 call synreg 
 mov edx,[flt]
 cmp edx,ebx
 je syn_varint 
 mov edx,[nott]
 cmp edx,ebx 
 je syn_varcmp
 mov edx,[pls]
 cmp edx,ebx 
 je syn_varop1 
 mov edx,[min]
 cmp edx,ebx 
 je syn_varop1
 mov edx,[true]
 cmp edx,ebx 
 je syn_vartf
 mov edx,[false]
 cmp edx,ebx 
 je syn_vartf
 mov edx,[null]
 cmp edx,ebx 
 je syn_varn
 mov edx,[strt]
 cmp edx,ebx 
 je syn_varstr
 mov edx,[intt]
 cmp edx,ebx 
 je syn_varint 
 mov edx,[lpr]
 cmp edx,ebx 
 je syn_varlpr
 mov edx,[idt]
 cmp edx,ebx 
 je syn_recid 
 call synsorz
 mov edx,[strt2]
 cmp edx,ebx 
 je tostr
 mov edx,[intt2]
 cmp edx,ebx 
 je toint
 mov edx,[negt]
 cmp edx,ebx 
 je syn_varneg
 mov edx,[ptrt]
 cmp edx,ebx
 je syn_varptr 
 mov edx,[aod]
 cmp edx,ebx
 je syn_varaod  
 mov edx,[npt]
 cmp edx,ebx
 je syn_npt
 mov edx,[cma]
 cmp edx,ebx
 je chkcma 
 jmp error 

syn_varaod2:
 push ecx
 mov ecx,[aod]
 call puts
 pop ecx
 call read
 mov edx,[idt]
 cmp edx,ebx
 jne error
 call putinsyn
 call read
 call bool
 call cmpops
 jmp error 
syn_varaod:
 push ecx
 mov ecx,[aod]
 call puts
 pop ecx
 call read
 mov edx,[idt]
 cmp edx,ebx
 jne error
 call putinsyn
 mov bl,"o"
 mov bh,[synnf]
 cmp bh,bl
 je syn_varint2
 call read
 call cmpops
 call bool
 call ops
 mov edx,[rpr]
 cmp edx,ebx
 je syn_varrpr
 mov edx,[cma]
 cmp edx,ebx
 je chkcma
 mov edx,[sb2]
 cmp edx,ebx 
 je finaru
 mov edx,[ter]
 cmp edx,ebx
 je syn_term
 mov edx,[newt]
 cmp edx,ebx
 je synnewl 
 jmp error 
syn_varptr:
 push ecx
 mov ecx,[ptrt]
 call puts 
 pop ecx
 call read 
 mov edx,[idt]
 cmp edx,ebx
 jne error 
 call putinsyn
 call read 
 mov edx,[sb2]
 cmp edx,ebx
 je finaru 
 mov edx,[cma]
 cmp edx,ebx
 je chkcma 
 mov edx,[dect]
 cmp edx,ebx  
 je syn_variod 
 mov edx,[inct]
 cmp edx,ebx 
 je syn_variod
 mov edx,[rpr]
 cmp edx,ebx
 je syn_varrpr
 mov edx,[ter]
 cmp edx,ebx
 je syn_term 
 mov edx,[newt]
 cmp edx,ebx
 je synnewl 
 call ops
 call cmpops
 call bool
 jmp error 
syn_varneg:
 push ecx
 mov ecx,[negt]
 call puts
 pop ecx
 mov bl,"z"
 mov [synnf],bl 
 call read
 call synreg 
 call synbwd 
 mov edx,[intt]
 cmp edx,ebx
 je syn_varint
 mov edx,[intt2]
 cmp edx,ebx
 je toint 
 mov edx,[flt]
 cmp edx,ebx
 je syn_varint  
 mov edx,[nott]
 cmp edx,ebx 
 je syn_varnot 
 mov edx,[true]
 cmp edx,ebx
 je syn_vartf
 mov edx,[false]
 cmp edx,ebx
 je syn_vartf
 mov edx,[idt]
 cmp edx,ebx
 je syn_recid 
 mov edx,[ptrt]
 cmp edx,ebx
 je syn_varptr  
 jmp error
syn_varop1:;minpls
 push ecx
 mov ecx,[cntn]
 call puts 
 pop ecx
 mov bl,"z"
 mov [synnf],bl
 call read 
 call synreg 
 call synbwd 
 mov edx,[flt]
 cmp edx,ebx
 je syn_varint  
 mov edx,[ptrt]
 cmp edx,ebx
 je syn_varptr  
 mov edx,[nott]
 cmp edx,ebx 
 je syn_varnot 
 mov edx,[intt]
 cmp edx,ebx 
 je syn_varint 
 mov edx,[lpr]
 cmp edx,ebx 
 je syn_varlpr
 mov edx,[idt]
 cmp edx,ebx 
 je syn_recid 
 mov edx,[true]
 cmp edx,ebx
 je syn_vartf
 mov edx,[false]
 cmp edx,ebx
 je syn_vartf 
 mov edx,[intt2]
 cmp edx,ebx 
 je toint
 jmp error 
syn_varn:;null
 push ecx
 mov ecx,[cntn]
 call puts 
 pop ecx
 mov bl,"o"
 mov bh,[synnf]
 cmp bh,bl
 je syn_varint2 
 call read 
 call cmpops
 call bool
 mov edx,[ter]
 cmp edx,ebx 
 je syn_term
 mov edx,[newt]
 cmp edx,ebx
 je synnewl 
 mov edx,[sb2]
 cmp edx,ebx
 je finaru
 mov edx,[cma]
 cmp edx,ebx 
 je chkcma
 mov edx,[rpr]
 cmp edx,ebx 
 je chkrpr 
 jmp error 
syn_varn2:
 push ecx
 mov ecx,[cntn]
 call puts 
 pop ecx
 call read 
 call bool
 call cmpops
 jmp error
syn_vartf:
 push ecx
 mov ecx,[cntn]
 call puts 
 pop ecx
 call read 
 call bool
 call cmpops
 mov edx,[ter]
 cmp edx,ebx 
 je syn_term
 mov edx,[newt]
 cmp edx,ebx
 je synnewl 
 mov edx,[sb2]
 cmp edx,ebx
 je finaru
 mov edx,[cma]
 cmp edx,ebx 
 je chkcma
 mov edx,[rpr]
 cmp edx,ebx 
 je syn_varrpr
 call ops
 jmp error 
syn_varstr:;str
 push ecx
 mov ecx,[cntn]
 call puts 
 pop ecx
 call putinsyn
 mov bl,"o"
 mov bh,[synnf]
 cmp bh,bl
 je syn_varint2 
syn_varstr3:
 call read 
 call cmpops
 call bool 
 mov edx,[ter]
 cmp edx,ebx 
 je syn_term
 mov edx,[newt]
 cmp edx,ebx
 je synnewl 
 mov edx,[sb2]
 cmp edx,ebx
 je finaru
 mov edx,[cma]
 cmp edx,ebx 
 je chkcma 
 mov edx,[rpr]
 cmp edx,ebx
 je syn_varrpr
 jmp error
syn_varstr2:;str
 push ecx
 mov ecx,[cntn]
 call puts 
 pop ecx
 call putinsyn
 call read 
 call bool
 call cmpops
 jmp error
syn_varint:;int
 push ecx
 mov ecx,[cntn]
 call puts
 pop ecx
 call putinsyn
syn_varint2: 
 call read 
 call cmpops 
 call bool
 mov edx,[rpr]
 cmp edx,ebx 
 je syn_varrpr
 call ops
 mov edx,[cma]
 cmp edx,ebx 
 je chkcma 
 mov edx,[inct]
 cmp edx,ebx 
 je syn_variod 
 mov edx,[dect]
 cmp edx,ebx 
 je syn_variod 
 mov edx,[ter]
 cmp edx,ebx 
 je syn_term
 mov edx,[newt]
 cmp edx,ebx
 je synnewl 
 mov edx,[sb2]
 cmp edx,ebx
 je finaru
 jmp error 
syn_variod:
 push ecx
 mov ecx,[cntn]
 call puts
 pop ecx
 call read 
 call cmpops 
 call bool
 call ops
 mov edx,[rpr]
 cmp edx,ebx
 je syn_varrpr 
 mov edx,[ter]
 cmp edx,ebx 
 je syn_term 
 mov edx,[newt]
 cmp edx,ebx
 je synnewl 
 mov edx,[cma]
 cmp edx,ebx 
 je chkcma 
 mov edx,[sb2]
 cmp edx,ebx
 je finaru 
 jmp error 
syn_varlpr:;lpr
 mov edx,[seqts]
 add edx,1
 mov [seqts],edx
 mov ebx,"l"
 mov [track+edx],ebx
 push ecx
 mov ecx,[lpr]
 call puts
 pop ecx
 mov bl,"z"
 mov [synnf],bl
 call read
 call synreg 
 call synbwd 
 mov edx,[flt]
 cmp edx,ebx
 je syn_varint  
 mov edx,[aod]
 cmp edx,ebx
 je syn_varaod2  
 mov edx,[ptrt]
 cmp edx,ebx
 je syn_varptr  
 mov edx,[nott]
 cmp edx,ebx 
 je syn_varnot 
 mov edx,[pls]
 cmp edx,ebx 
 je syn_varop1
 mov edx,[min]
 cmp edx,ebx 
 je syn_varop1
 mov edx,[false]
 cmp edx,ebx
 je syn_vartf
 mov edx,[true]
 cmp edx,ebx
 je syn_vartf 
 mov edx,[intt]
 cmp edx,ebx 
 je syn_varint
 mov edx,[idt]
 cmp edx,ebx 
 je syn_recid 
 mov edx,[lpr]
 cmp edx,ebx
 je syn_varlpr
 mov edx,[intt2]
 cmp edx,ebx
 je toint 
 mov edx,[negt]
 cmp edx,ebx 
 je syn_varneg 
 mov edx,[strt]
 cmp edx,ebx 
 je syn_varstr2
 mov edx,[strt2]
 cmp edx,ebx
 je tostr
 mov edx,[null]
 cmp edx,ebx
 je syn_varn2
 call synsorz
 jmp error 
syn_varnot:
 mov bl,"o"
 mov [synnf],bl
 jmp syn_varcmp2
ops:
 mov edx,[pls]
 cmp edx,ebx 
 je syn_varop1
 mov edx,[min]
 cmp edx,ebx 
 je syn_varop1
 mov edx,[divt]
 cmp edx,ebx 
 je syn_varop2
 mov edx,[mult]
 cmp edx,ebx 
 je syn_varop2
 mov edx,[port]
 cmp edx,ebx 
 je syn_varop2 
 ret
cmpops:
 mov edx,[eq2]
 cmp edx,ebx 
 je syn_varcmp
 mov edx,[neq]
 cmp edx,ebx 
 je syn_varcmp
 mov edx,[geq]
 cmp edx,ebx 
 je syn_varcmp
 mov edx,[leq]
 cmp edx,ebx  
 je syn_varcmp
 mov edx,[grt]
 cmp edx,ebx 
 je syn_varcmp
 mov edx,[lest]
 cmp edx,ebx 
 je syn_varcmp
 ret
bool: 
 mov edx,[andt]
 cmp edx,ebx 
 je syn_varcmp
 mov edx,[ort]
 cmp edx,ebx 
 je syn_varcmp 
 ret

syn_varcmp:;after cmp
 mov bl,"z"
 mov [synnf],bl
syn_varcmp2: 
 push ecx
 mov ecx,[cntn]
 call puts 
 pop ecx
 call read
 call synreg 
 call synbwd 
 mov edx,[flt]
 cmp edx,ebx
 je syn_varint  
 mov edx,[aod]
 cmp edx,ebx
 je syn_varaod  
 mov edx,[ptrt]
 cmp edx,ebx
 je syn_varptr  
 mov edx,[nott]
 cmp edx,ebx 
 je syn_varnot 
 mov edx,[intt]
 cmp edx,ebx 
 je syn_varint
 mov edx,[strt]
 cmp edx,ebx 
 je syn_varstr
 mov edx,[idt]
 cmp edx,ebx 
 je syn_recid 
 mov edx,[pls]
 cmp edx,ebx 
 je syn_varop1
 mov edx,[min]
 cmp edx,ebx 
 je syn_varop1
 mov edx,[lpr]
 cmp edx,ebx 
 je syn_varlpr
 mov edx,[true]
 cmp edx,ebx 
 je syn_vartf
 mov edx,[false]
 cmp edx,ebx 
 je syn_vartf
 mov edx,[null]
 cmp edx,ebx 
 je syn_varn
 mov edx,[intt2]
 cmp edx,ebx 
 je toint
 mov edx,[strt2]
 cmp edx,ebx 
 je tostr
 call synsorz
 jmp error
syn_varrpr:;rpr
 mov edx,[seqts]
 mov eax,[track+edx]
 mov edx,"5";push
 cmp edx,eax
 je expectT 
 mov edx,"f"
 cmp edx,eax
 je syn_fclfce 
 mov edx,"t"
 cmp edx,eax
 je sttt2
 mov edx,"i"
 cmp edx,eax
 je q9f
 mov edx,"w"
 cmp edx,eax
 je qwf  
 mov edx,"p"
 cmp edx,eax
 je finprn
 mov edx,"v"
 cmp edx,eax 
 je sttv 
 mov edx,"l"
 cmp edx,eax
 jne error 
 mov edx,[seqts] 
 mov eax,0
 mov [track+edx],eax
 sub edx,1
 mov [seqts],edx
 push ecx
 mov ecx,[rpr]
 call puts
 pop ecx
 call read
 mov edx,[rpr]
 cmp edx,ebx 
 je syn_varrpr
 mov edx,[ter]
 cmp edx,ebx
 je syn_term
 mov edx,[newt]
 cmp edx,ebx
 je synnewl
 call ops
 mov edx,[sb2]
 cmp edx,ebx
 je finaru
 mov edx,[cma]
 cmp edx,ebx 
 je chkcma  
 call cmpops
 call bool 
 sub ecx,3 
 jmp adjuststt
syn_varop2:;div mul
 push ecx
 mov ecx,[cntn]
 call puts
 pop ecx
 mov bl,"z"
 mov [synnf],bl 
 call read
 call synreg 
 call synbwd 
 mov edx,[nott]
 cmp edx,ebx
 je syn_varnot 
 mov edx,[false]
 cmp edx,ebx 
 je syn_vartf
 mov edx,[true]
 cmp edx,ebx 
 je syn_vartf  
 mov edx,[flt]
 cmp edx,ebx
 je syn_varint  
 mov edx,[intt]
 cmp edx,ebx 
 je syn_varint
 mov edx,[idt]
 cmp edx,ebx 
 je syn_recid 
 mov edx,[intt2]
 cmp edx,ebx
 je toint
 mov edx,[ptrt]
 cmp edx,ebx
 je syn_varptr 
 jmp error 

syn_reg:
 push ecx
 mov ecx,[cntn]
 call puts
 pop ecx
 call read
 mov edx,[sb2]
 cmp edx,ebx
 je finaru 
 mov edx,[cma]
 cmp edx,ebx
 je chkcma  
 mov edx,[dect]
 cmp edx,ebx  
 je syn_variod 
 mov edx,[inct]
 cmp edx,ebx 
 je syn_variod
 mov edx,[ter]
 cmp edx,ebx
 je syn_term
 mov edx,[newt]
 cmp edx,ebx
 je synnewl 
 mov edx,[rpr]
 cmp edx,ebx
 je syn_varrpr 
 mov edx,[equt]
 cmp edx,ebx
 je syn_reg2
 call cmpops
 call ops 
 call bool
 jmp error 
syn_reg2:
 push ecx
 mov ecx,[equt]
 call puts
 pop ecx
 call read
 mov edx,"REG"
 cmp edx,ebx
 je syn_regfunc
 sub ecx,3
 jmp syn_idt3
synreg:
 mov edx,[eaxl]
 cmp edx,ebx
 je syn_reg
 mov edx,[ebxl]
 cmp edx,ebx
 je syn_reg
 mov edx,[ecxl]
 cmp edx,ebx
 je syn_reg
 mov edx,[edxl]
 cmp edx,ebx
 je syn_reg
 mov edx,[esil]
 cmp edx,ebx
 je syn_reg
 mov edx,[edil]
 cmp edx,ebx
 je syn_reg 
 mov edx,"alR"
 cmp edx,ebx
 je syn_reg 
 mov edx,"ahR"
 cmp edx,ebx
 je syn_reg 
 mov edx,"axR"
 cmp edx,ebx
 je syn_reg 
 mov edx,"blR"
 cmp edx,ebx
 je syn_reg 
 mov edx,"bhR"
 cmp edx,ebx
 je syn_reg 
 mov edx,"bxR"
 cmp edx,ebx
 je syn_reg 
 mov edx,"clR"
 cmp edx,ebx
 je syn_reg 
 mov edx,"chR"
 cmp edx,ebx
 je syn_reg 
 mov edx,"cxR"
 cmp edx,ebx
 je syn_reg  
 mov edx,"dlR"
 cmp edx,ebx
 je syn_reg 
 mov edx,"dhR"
 cmp edx,ebx
 je syn_reg 
 mov edx,"dxR"
 cmp edx,ebx
 je syn_reg  
 ret

syn_regfunc:
 push ecx
 mov ecx,"REG"
 call puts
 pop ecx
 call read
 mov edx,[lpr]
 cmp edx,ebx
 jne error
 mov edx,[seqts]
 mov eax,"l"
 add edx,1
 mov [track+edx],eax
 mov [seqts],edx
 jmp syn_idt3

synbwd:
 mov edx,[byt]
 cmp edx,ebx
 je syn_bwd
 mov edx,[wrd]
 cmp edx,ebx
 je syn_bwd
 mov edx,[dwr]
 cmp edx,ebx
 je syn_bwd
 mov edx,[bit]
 cmp edx,ebx
 je synbit
 ret
syn_bwd:
 push ecx
 mov ecx,[cntn]
 call puts
 pop ecx
 call read
 mov edx,[aod]
 cmp edx,ebx
 je syn_varaod
 mov edx,[lpr]
 cmp edx,ebx
 je syn_varlpr
 jmp error 

synSYS:
 push ecx
 mov ecx,"SYS"
 call puts
 pop ecx
 call read
 mov edx,[strt]
 cmp edx,ebx
 jne error 
 jmp syn_varstr
 
synsorz:
 mov edx,[rolf]
 cmp edx,ebx
 je sorf
 mov edx,[rorf]
 cmp edx,ebx
 je sorf 
 mov edx,[shlf]
 cmp edx,ebx
 je sorf
 mov edx,[shrf]
 cmp edx,ebx
 je sorf  
 mov edx,[shlt]
 cmp edx,ebx 
 je sor
 mov edx,[shrt]
 cmp edx,ebx 
 je sor
 mov edx,[rolt]
 cmp edx,ebx 
 je sor
 mov edx,[rort]
 cmp edx,ebx 
 je sor  
 ret
 
synmov:
  call read 
  mov edx,[lpr]
  cmp edx,ebx 
  jne error 
  push ecx
  mov ecx,[movt]
  call puts
  pop ecx 
  synmov2:
  ;set sequence 
  mov edx,[seqts]
  mov eax,"v"
  add edx,1
  mov [track+edx],eax
  mov [seqts],edx
  ;
  call read 
  mov edx,[ptrt]
  cmp edx,ebx
  je syn_varptr
  mov edx,[aod]
  cmp edx,ebx
  je syn_varaod 
  jmp error 
  
 synmovci:
  call read 
  mov edx,[lpr]
  cmp edx,ebx 
  jne error 
  push ecx 
  mov ecx,[movci]
  call puts
  pop ecx 
  jmp synmov2
 synmovb:
  call read 
  mov edx,[lpr]
  cmp edx,ebx 
  jne error 
  push ecx 
  mov ecx,[movb]
  call puts
  pop ecx 
  jmp synmov2
 synbit:
  call read 
  mov edx,[lpr]
  cmp edx,ebx 
  jne error 
  push ecx 
  mov ecx,[bit]
  call puts
  pop ecx 
  jmp synmov2
  
;;;;;;;POP/PUSH;;;;;
syn_pop:
 push ecx
 mov ecx,[popt]
 call puts
 pop ecx
 call read
 mov edx,[lpr]
 cmp edx,ebx
 jne error 
 call read
 mov edx,[idt]
 cmp edx,ebx
 je syn_popid
 mov edx,[eaxl]
 cmp edx,ebx
 je syn_popreg
 mov edx,[ebxl]
 cmp edx,ebx
 je syn_popreg
 mov edx,[ecxl]
 cmp edx,ebx
 je syn_popreg
 mov edx,[edxl]
 cmp edx,ebx
 je syn_popreg
 mov edx,[esil]
 cmp edx,ebx
 je syn_popreg
 mov edx,[edil]
 cmp edx,ebx
 je syn_popreg 
 mov edx,"alR"
 cmp edx,ebx
 je syn_popreg 
 mov edx,"ahR"
 cmp edx,ebx
 je syn_popreg 
 mov edx,"axR"
 cmp edx,ebx
 je syn_popreg 
 mov edx,"blR"
 cmp edx,ebx
 je syn_popreg 
 mov edx,"bhR"
 cmp edx,ebx
 je syn_popreg 
 mov edx,"bxR"
 cmp edx,ebx
 je syn_popreg 
 mov edx,"clR"
 cmp edx,ebx
 je syn_popreg 
 mov edx,"chR"
 cmp edx,ebx
 je syn_popreg 
 mov edx,"cxR"
 cmp edx,ebx
 je syn_popreg 
 mov edx,"dlR"
 cmp edx,ebx
 je syn_popreg 
 mov edx,"dhR"
 cmp edx,ebx
 je syn_popreg 
 mov edx,"dxR"
 cmp edx,ebx
 je syn_popreg 
 mov edx,[rpr]
 cmp edx,ebx
 jne error 
 jmp expectT
syn_popid:
 push ecx
 mov ecx,[idt]
 call puts
 pop ecx
 call putinsyn
 call read
 mov edx,[rpr]
 cmp edx,ebx
 jne error 
 jmp expectT
syn_popreg:
 push ecx
 mov ecx,[cntn]
 call puts
 pop ecx
 call read
 mov edx,[rpr]
 cmp edx,ebx
 jne error 
 jmp expectT 
 
syn_push:
 push ecx
 mov ecx,[psht]
 call puts
 pop ecx
 mov edx,[seqts]
 add edx,1
 mov eax,"5"
 mov [track+edx],eax
 mov [seqts],edx
 call read 
 mov edx,[lpr]
 cmp edx,ebx
 jne error
 call read
 call synreg 
 mov edx,[pls]
 cmp edx,ebx
 je syn_varop1
 mov edx,[min]
 cmp edx,ebx
 je syn_varop1
 mov edx,[null]
 cmp edx,ebx
 je syn_varn 
 mov edx,[false]
 cmp edx,ebx
 je syn_vartf
 mov edx,[true]
 cmp edx,ebx
 je syn_vartf 
 mov edx,[intt]
 cmp edx,ebx
 je syn_varint  
 mov edx,[flt]
 cmp edx,ebx
 je syn_varint   
 mov edx,[idt]
 cmp edx,ebx
 je syn_recid
 mov edx,[strt]
 cmp edx,ebx
 je syn_varstr
 mov edx,[nott]
 cmp edx,ebx
 je syn_varnot
 mov edx,[lpr]
 cmp edx,ebx
 je syn_varlpr
 mov edx,[aod]
 cmp edx,ebx
 je syn_varaod
 mov edx,[ptrt]
 cmp edx,ebx
 je syn_varptr
 jmp error 
;;;;;;;;NPT;;;;;;;;;
syn_npt:
 push ecx
 mov ecx,[npt]
 call puts
 pop ecx
 jmp expectT

;;;;;;;;SEQ;;;;;;;;;;
syn_seq:
 push ecx
 mov ecx,[seq]
 call puts
 pop ecx
 call read 
 mov edx,[lpr]
 cmp edx,ebx
 jne error 
 call read
 mov edx,[idt]
 cmp edx,ebx 
 jne error
 push ecx
 mov ecx,idt
 call puts
 pop ecx
 call read
 mov edx,[rpr]
 cmp edx,ebx
 jne error 
 call read 
 mov edx,[ter]
 cmp edx,ebx
 je syn_term
 mov edx,[newt]
 cmp edx,ebx
 je synnewl
 jmp error 
 
;;;;;;;;;FCL;;;;;;;;;; 
 syn_fcl:
 push ecx
 mov ecx,[fcl]
 call puts
 pop ecx
 ;;;;;;
 call idtosyn 
 call putseqf
 ;;;;;;;;
 jmp syn_fcl2
 q4x:
 add ecx,3;lpr ignored
 jmp syn_fcl2

 syn_fcl2:
 mov bl,"z"
 mov [synnf],bl
 call read
 call synbwd 
 call synreg 
 mov edx,[aod]
 cmp edx,ebx
 je syn_varaod
 mov edx,[flt]
 cmp edx,ebx
 je syn_fclint  
 mov edx,[nott]
 cmp edx,ebx 
 je syn_fclnot  
 mov edx,[ptrt]
 cmp edx,ebx
 je syn_varptr  
 mov edx,[intt]
 cmp edx,ebx
 je syn_fclint
 mov edx,[idt]
 cmp edx,ebx 
 je syn_recid 
 mov edx,[strt]
 cmp edx,ebx 
 je syn_fclstr
 mov edx,[lpr]
 cmp edx,ebx 
 je syn_fcllpr
 mov edx,[null]
 cmp edx,ebx 
 je syn_fcln
 mov edx,[true]
 cmp edx,ebx 
 je syn_fcltf
 mov edx,[false]
 cmp edx,ebx 
 je syn_fcltf
 mov edx,[pls]
 cmp edx,ebx 
 je syn_fclop1
 mov edx,[min]
 cmp edx,ebx 
 je syn_fclop1
 mov edx,[rpr]
 cmp edx,ebx 
 je syn_fclrpr 
 mov edx,[intt2]
 cmp edx,ebx 
 je toint
 mov edx,[strt2]
 cmp edx,ebx 
 je tostr
 mov edx,[negt]
 cmp edx,ebx 
 je syn_fclneg
 call synsorz 
 jmp error 

 putseqf:
 mov edx,[seqts]
 add edx,1
 mov al,"f"
 mov [track+edx],al
 mov [seqts],edx
 ret 

 syn_fclneg:
 push ecx
 mov ecx,[negt]
 call puts
 pop ecx
 mov bl,"z"
 mov [synnf],bl 
 call read
 call synreg 
 call synbwd 
 mov edx,[flt]
 cmp edx,ebx
 je syn_fclint   
 mov edx,[ptrt]
 cmp edx,ebx
 je syn_varptr  
 mov edx,[nott]
 cmp edx,ebx 
 je syn_fclnot  
 mov edx,[intt]
 cmp edx,ebx
 je syn_fclint
 mov edx,[intt2]
 cmp edx,ebx
 je toint 
 mov edx,[true]
 cmp edx,ebx
 je syn_fcltf
 mov edx,[false]
 cmp edx,ebx
 je syn_fcltf
 mov edx,[idt]
 cmp edx,ebx
 je syn_recid 
 jmp error
 syn_fclint:;int
 push ecx
 mov ecx,[cntn]
 call puts
 pop ecx
 call putinsyn 
 syn_fclint2:
 call read
 call ops4 
 call cmpops4
 call bool4
 mov edx,[rpr]
 cmp edx,ebx 
 je syn_fclrpr
 mov edx,[cma]
 cmp edx,ebx 
 je syn_fclcma 
 mov edx,[inct]
 cmp edx,ebx 
 je syn_fcliod 
 mov edx,[dect]
 cmp edx,ebx 
 je syn_fcliod  
 jmp error 
 syn_fcliod:
 push ecx
 mov ecx,[cntn]
 call puts
 pop ecx
 call read
 mov edx,[cma]
 cmp edx,ebx 
 je syn_fclcma
 mov edx,[rpr]
 cmp edx,ebx 
 je syn_fclrpr
 call ops4
 call bool4
 call cmpops4
 jmp error
 syn_fclstr:;str
 push ecx
 mov ecx,[strt]
 call puts
 pop ecx
 call putinsyn 
 mov bl,"o"
 mov bh,[synnf]
 cmp bh,bl
 je syn_fclint2
 call read
 call cmpops4 
 call bool4
 mov edx,[rpr]
 cmp edx,ebx 
 je syn_fclrpr 
 mov edx,[cma]
 cmp edx,ebx 
 je syn_fclcma 
 jmp error 
 syn_fclstr2:;str
 push ecx
 mov ecx,[strt]
 call puts
 pop ecx
 call putinsyn 
 call read
 call bool4
 call cmpops4
 jmp error 
 syn_fcllpr:;lpr
 push ecx
 mov ecx,[lpr]
 call puts
 pop ecx
 mov edx,[seqts]
 add edx,1
 mov eax,"l"
 mov [track+edx],eax
 mov [seqts],edx
 mov bl,"z"
 mov [synnf],bl
 call read
 call synreg 
 call synbwd 
 call synsorz 
 mov edx,[flt]
 cmp edx,ebx
 je syn_fclint   
 mov edx,[aod]
 cmp edx,ebx
 je syn_varaod2 
 mov edx,[ptrt]
 cmp edx,ebx
 je syn_varptr  
 mov edx,[nott]
 cmp edx,ebx 
 je syn_fclnot   
 mov edx,[intt]
 cmp edx,ebx 
 je syn_fclint
 mov edx,[pls]
 cmp edx,ebx 
 je syn_fclop1
 mov edx,[min]
 cmp edx,ebx 
 je syn_fclop1
 mov edx,[lpr]
 cmp edx,ebx 
 je syn_fcllpr
 mov edx,[idt]
 cmp edx,ebx 
 je syn_recid
 mov edx,[negt]
 cmp edx,ebx 
 je syn_fclneg
 mov edx,[intt2]
 cmp edx,ebx 
 je toint
 mov edx,[strt]
 cmp edx,ebx 
 je syn_fclstr2
 mov edx,[strt2]
 cmp edx,ebx
 je tostr
 mov edx,[false]
 cmp edx,ebx
 je syn_fcltf
 mov edx,[true]
 cmp edx,ebx
 je syn_fcltf
 mov edx,[null]
 cmp edx,ebx
 je syn_fcln2 
 jmp error
 syn_fcltf:;nulltf
 push ecx
 mov ecx,[cntn]
 call puts
 pop ecx
 call read
 call cmpops4 
 call bool4
 call ops4
 mov edx,[rpr]
 cmp edx,ebx 
 je syn_fclrpr 
 mov edx,[cma]
 cmp edx,ebx 
 je syn_fclcma
 jmp error 
 syn_fcln:;nulltf
 push ecx
 mov ecx,[cntn]
 call puts
 pop ecx
 mov bl,"o"
 mov bh,[synnf]
 cmp bh,bl
 je syn_fclint2 
 call read
 call cmpops4 
 call bool4
 mov edx,[rpr]
 cmp edx,ebx 
 je syn_fclrpr 
 mov edx,[cma]
 cmp edx,ebx 
 je syn_fclcma
 jmp error  
 syn_fcln2:;nulltf
 push ecx
 mov ecx,[cntn]
 call puts
 pop ecx
 call read
 call bool4
 call cmpops4
 jmp error   
 syn_fclop1:;minpls
 push ecx
 mov ecx,[cntn]
 call puts
 pop ecx
 mov bl,"z"
 mov [synnf],bl 
 call read
 call synreg 
 call synbwd 
 mov edx,[flt]
 cmp edx,ebx
 je syn_fclint   
 mov edx,[ptrt]
 cmp edx,ebx
 je syn_varptr  
 mov edx,[nott]
 cmp edx,ebx 
 je syn_fclnot  
 mov edx,[intt]
 cmp edx,ebx 
 je syn_fclint
 mov edx,[lpr]
 cmp edx,ebx 
 je syn_fcllpr
 mov edx,[idt]
 cmp edx,ebx 
 je syn_recid
 mov edx,[intt2]
 cmp edx,ebx
 je toint
 mov edx,[false]
 cmp edx,ebx 
 je syn_fcltf
 mov edx,[true]
 cmp edx,ebx 
 je syn_fcltf 
 jmp error
 syn_fclrpr:
 mov ebx,[seqts]
 mov edx,[track+ebx]
 mov eax,"f"
 cmp edx,eax
 je syn_fclfce
 mov eax,"p"
 cmp edx,eax
 je finprn
 mov eax,"z"
 cmp edx,eax
 je error
 mov eax,"l"
 cmp edx,eax 
 jne error
 push ecx
 mov ecx,[rpr]
 call puts
 pop ecx
 mov ebx,[seqts]
 mov eax,0
 mov [track+ebx],eax
 sub ebx,1
 mov [seqts],ebx
 call read
 call ops
 mov edx,[rpr]
 cmp edx,ebx 
 je syn_varrpr
 mov edx,[cma]
 cmp edx,ebx 
 je syn_fclcma 
 call cmpops
 call bool
 jmp error
 syn_fclnot:
 push ecx
 mov ecx,[nott]
 call puts
 pop ecx
 mov bl,"o"
 mov [synnf],bl
 jmp cmancmp2
 syn_fclfce:
 push ecx
 mov ecx,[fce]
 call puts
 pop ecx
 mov edx,[seqts]
 mov eax,0
 cmp edx,eax
 je syn_fclfce2
 mov bh,0
 mov [track+edx],bh
 sub edx,1
 mov [seqts],edx
 jmp adjuststt
 syn_fclfce2:
 call read
 call cmpops
 call ops
 call bool
 mov edx,[ter]
 cmp edx,ebx
 je syn_term 
 mov edx,[newt]
 cmp edx,ebx
 je synnewl 
 jmp error 

 syn_fclcma:
 push ecx
 mov ecx,[cma]
 call puts
 pop ecx
 call read
 call cmancmp
 jmp error

 ops4:
 mov edx,[pls]
 cmp edx,ebx 
 je syn_fclop1
 mov edx,[min]
 cmp edx,ebx 
 je syn_fclop1
 mov edx,[mult]
 cmp edx,ebx 
 je syn_fclop2
 mov edx,[divt]
 cmp edx,ebx
 je syn_fclop2
 mov edx,[port]
 cmp edx,ebx 
 je syn_fclop2  
 ret 
 syn_fclop2:
 push ecx
 mov ecx,[cntn]
 call puts
 pop ecx
 mov bl,"z"
 mov [synnf],bl 
 call read
 call synreg 
 call synbwd 
 mov edx,[flt]
 cmp edx,ebx
 je syn_fclint   
 mov edx,[ptrt]
 cmp edx,ebx
 je syn_varptr  
 mov edx,[idt]
 cmp edx,ebx 
 je syn_recid
 mov edx,[intt]
 cmp edx,ebx
 je syn_fclint
 mov edx,[intt2]
 cmp edx,ebx
 je toint 
 mov edx,[nott]
 cmp edx,ebx 
 je syn_fclnot   
 jmp error 
 cmpops4:
 mov edx,[eq2]
 cmp edx,ebx 
 je syn_fclcmp
 mov edx,[neq]
 cmp edx,ebx 
 je syn_fclcmp
 mov edx,[geq]
 cmp edx,ebx 
 je syn_fclcmp
 mov edx,[leq]
 cmp edx,ebx 
 je syn_fclcmp
 mov edx,[grt]
 cmp edx,ebx 
 je syn_fclcmp
 mov edx,[lest]
 cmp edx,ebx 
 je syn_fclcmp
 ret 
 syn_fclcmp:
 push ecx
 mov ecx,[cntn]
 call puts
 pop ecx
 call read
 jmp cmancmp
 jmp error
 bool4:
 mov edx,[andt]
 cmp edx,ebx
 je syn_fclcmp
 mov edx,[ort]
 cmp edx,ebx
 je syn_fclcmp
 ret
 
 cmancmp:
 mov al,"z"
 mov [synnf],al
 cmancmp2: 
 call synreg
 call synbwd 
 mov edx,[aod]
 cmp edx,ebx
 je syn_varaod
 mov edx,[flt]
 cmp edx,ebx
 je syn_fclint   
 mov edx,[ptrt]
 cmp edx,ebx
 je syn_varptr 
 mov edx,[nott]
 cmp edx,ebx 
 je syn_fclnot  
 mov edx,[pls]
 cmp edx,ebx 
 je syn_fclop1
 mov edx,[min]
 cmp edx,ebx 
 je syn_fclop1
 mov edx,[lpr]
 cmp edx,ebx 
 je syn_fcllpr
 mov edx,[intt]
 cmp edx,ebx 
 je syn_fclint
 mov edx,[strt]
 cmp edx,ebx 
 je syn_fclstr
 mov edx,[null]
 cmp edx,ebx 
 je syn_fcln
 mov edx,[true]
 cmp edx,ebx 
 je syn_fcltf
 mov edx,[false]
 cmp edx,ebx 
 je syn_fcltf
 mov edx,[idt]
 cmp edx,ebx 
 je syn_recid 
 mov edx,[intt2]
 cmp edx,ebx 
 je toint
 mov edx,[strt2]
 cmp edx,ebx
 je tostr
 mov edx,[negt]
 cmp edx,ebx 
 je syn_fclneg
 call synsorz
 ret
 
;;;;;;;;;;ARD;;;;;;;;;;;
 syn_ard:
 mov edx,[seqts]
 mov eax,"d"
 add edx,1
 mov [track+edx],eax
 mov [seqts],edx
 push ecx
 mov ecx,[ard]
 call puts
 pop ecx
 call idtosyn
 syn_ard2: 
 mov bl,"z"
 mov [synnf],bl
 call read
 call synreg 
 call synbwd 
 mov edx,[intt]
 cmp edx,ebx
 je syn_ardint
 mov edx,[flt]
 cmp edx,ebx
 je syn_ardint
 mov edx,[strt]
 cmp edx,ebx
 je syn_ardstr
 mov edx,[idt]
 cmp edx,ebx
 je syn_recid
 mov edx,[true]
 cmp edx,ebx
 je syn_ardtf 
 mov edx,[false]
 cmp edx,ebx
 je syn_ardtf
 mov edx,[null]
 cmp edx,ebx
 je syn_ardn 
 mov edx,[lpr]
 cmp edx,ebx
 je syn_ardlpr
 mov edx,[min]
 cmp edx,ebx
 je syn_ardop1
 mov edx,[pls]
 cmp edx,ebx
 je syn_ardop1
 mov edx,[negt]
 cmp edx,ebx
 je syn_ardneg
 mov edx,[nott]
 cmp edx,ebx
 je syn_ardnot
 call synsorz
 jmp error

 syn_ardneg:
 push ecx
 mov ecx,[negt]
 call puts
 pop ecx
 mov bl,"z"
 mov [synnf],bl 
 call read
 call synreg 
 call synbwd 
 mov edx,[intt]
 cmp edx,ebx
 je syn_ardint
 mov edx,[intt2]
 cmp edx,ebx
 je toint 
 mov edx,[flt]
 cmp edx,ebx
 je syn_ardint  
 mov edx,[nott]
 cmp edx,ebx 
 je syn_ardnot
 mov edx,[true]
 cmp edx,ebx
 je syn_ardtf
 mov edx,[false]
 cmp edx,ebx
 je syn_ardtf
 mov edx,[idt]
 cmp edx,ebx
 je syn_recid 
 mov edx,[ptrt]
 cmp edx,ebx
 je syn_varptr  
 jmp error
 syn_ardop1:;minpls
 push ecx
 mov ecx,[cntn]
 call puts 
 pop ecx
 mov bl,"z"
 mov [synnf],bl 
 call read 
 call synbwd 
 call synreg 
 mov edx,[flt]
 cmp edx,ebx
 je syn_ardint  
 mov edx,[ptrt]
 cmp edx,ebx
 je syn_varptr  
 mov edx,[nott]
 cmp edx,ebx 
 je syn_ardnot
 mov edx,[intt]
 cmp edx,ebx 
 je syn_ardint 
 mov edx,[lpr]
 cmp edx,ebx 
 je syn_ardlpr
 mov edx,[idt]
 cmp edx,ebx 
 je syn_recid 
 mov edx,[true]
 cmp edx,ebx
 je syn_ardtf
 mov edx,[false]
 cmp edx,ebx
 je syn_ardtf 
 mov edx,[intt2]
 cmp edx,ebx 
 je toint
 jmp error 
 syn_ardint:
 push ecx
 mov ecx,[cntn]
 call puts
 pop ecx
 call putinsyn
 syn_ardint2: 
 call read 
 call cmpops8 
 call bool8
 mov edx,[rpr]
 cmp edx,ebx 
 je syn_ardrpr
 call ops8
 mov edx,[cma]
 cmp edx,ebx 
 je syn_ardcma 
 mov edx,[inct]
 cmp edx,ebx 
 je syn_ardiod 
 mov edx,[dect]
 cmp edx,ebx 
 je syn_ardiod 
 mov edx,[sb2]
 cmp edx,ebx
 je finard
 jmp error 
 syn_ardstr:
 push ecx
 mov ecx,[cntn]
 call puts 
 pop ecx
 call putinsyn
 mov bl,"o"
 mov bh,[synnf]
 cmp bh,bl
 je syn_ardint2  
 call read 
 call cmpops8
 call bool8 
 mov edx,[sb2]
 cmp edx,ebx
 je finard
 mov edx,[cma]
 cmp edx,ebx 
 je syn_ardcma 
 mov edx,[rpr]
 cmp edx,ebx
 je syn_ardrpr
 jmp error
 syn_ardstr2:;str
 push ecx
 mov ecx,[cntn]
 call puts 
 pop ecx
 call putinsyn
 call read 
 call bool8
 call cmpops8
 jmp error 
 syn_ardrpr:
 mov ebx,[seqts]
 mov edx,[track+ebx]
 mov eax,0
 mov [track+ebx],eax
 sub ebx,1
 mov [seqts],ebx
 mov eax,"l"
 cmp edx,eax 
 jne error
 push ecx
 mov ecx,[rpr]
 call puts
 pop ecx
 call read
 call ops8
 mov edx,[rpr]
 cmp edx,ebx 
 je syn_ardrpr
 mov edx,[cma]
 cmp edx,ebx 
 je syn_ardcma 
 call cmpops8
 call bool8
 jmp error
 syn_ardtf:
 push ecx
 mov ecx,[cntn]
 call puts 
 pop ecx
 call read 
 call bool8
 call cmpops8
 mov edx,[sb2]
 cmp edx,ebx
 je finard
 mov edx,[cma]
 cmp edx,ebx 
 je syn_ardcma
 mov edx,[rpr]
 cmp edx,ebx 
 je syn_ardrpr
 call ops8
 jmp error 
 syn_ardn:;null
 push ecx
 mov ecx,[cntn]
 call puts 
 pop ecx
 mov bl,"o"
 mov bh,[synnf]
 cmp bh,bl
 je syn_ardint2  
 call read 
 call cmpops8
 call bool8
 mov edx,[sb2]
 cmp edx,ebx
 je finard
 mov edx,[cma]
 cmp edx,ebx 
 je syn_ardcma
 mov edx,[rpr]
 cmp edx,ebx 
 je syn_ardrpr 
 jmp error 
 syn_ardn2:
 push ecx
 mov ecx,[cntn]
 call puts 
 pop ecx
 call read 
 call bool8
 call cmpops8
 jmp error 
 syn_ardlpr:;lpr
 mov edx,[seqts]
 add edx,1
 mov [seqts],edx
 mov ebx,"l"
 mov [track+edx],ebx
 push ecx
 mov ecx,[lpr]
 call puts
 pop ecx
 mov bl,"z"
 mov [synnf],bl 
 call read
 call synreg 
 call synbwd 
 mov edx,[flt]
 cmp edx,ebx
 je syn_ardint  
 mov edx,[aod]
 cmp edx,ebx
 je syn_varaod2  
 mov edx,[ptrt]
 cmp edx,ebx
 je syn_varptr  
 mov edx,[nott]
 cmp edx,ebx 
 je syn_ardnot
 mov edx,[pls]
 cmp edx,ebx 
 je syn_ardop1
 mov edx,[min]
 cmp edx,ebx 
 je syn_ardop1
 mov edx,[false]
 cmp edx,ebx
 je syn_ardtf
 mov edx,[true]
 cmp edx,ebx
 je syn_ardtf 
 mov edx,[intt]
 cmp edx,ebx 
 je syn_ardint
 mov edx,[idt]
 cmp edx,ebx 
 je syn_recid 
 mov edx,[lpr]
 cmp edx,ebx
 je syn_ardlpr
 mov edx,[intt2]
 cmp edx,ebx
 je toint 
 mov edx,[negt]
 cmp edx,ebx 
 je syn_ardneg 
 mov edx,[strt]
 cmp edx,ebx 
 je syn_ardstr2
 mov edx,[strt2]
 cmp edx,ebx
 je tostr
 mov edx,[null]
 cmp edx,ebx
 je syn_ardn2
 call synsorz
 jmp error 
 syn_ardop2:
 push ecx
 mov ecx,[cntn]
 call puts
 pop ecx
 mov bl,"z"
 mov [synnf],bl 
 call read
 call synreg 
 call synbwd 
 mov edx,[false]
 cmp edx,ebx 
 je syn_ardtf
 mov edx,[true]
 cmp edx,ebx 
 je syn_ardtf  
 mov edx,[flt]
 cmp edx,ebx
 je syn_ardint  
 mov edx,[intt]
 cmp edx,ebx 
 je syn_ardint
 mov edx,[idt]
 cmp edx,ebx 
 je syn_recid 
 mov edx,[intt2]
 cmp edx,ebx
 je toint
 mov edx,[nott]
 cmp edx,ebx 
 je syn_ardnot   
 mov edx,[ptrt]
 cmp edx,ebx
 je syn_varptr 
 jmp error 
 syn_ardiod:
 push ecx
 mov ecx,[cntn]
 call puts
 pop ecx
 call read 
 call cmpops8 
 call bool8
 call ops8
 mov edx,[rpr]
 cmp edx,ebx
 je syn_ardrpr 
 mov edx,[cma]
 cmp edx,ebx 
 je syn_ardcma 
 mov edx,[sb2]
 cmp edx,ebx
 je finard
 jmp error 
 syn_ardcma:
 push ecx
 mov ecx,[cma]
 call puts
 pop ecx
 jmp syn_ard2
 syn_ardcmp:
 mov bl,"z"
 mov [synnf],bl
 syn_ardcmp2: 
 push ecx
 mov ecx,[cntn]
 call puts
 pop ecx
 call read
 call synbwd 
 call synreg 
 mov edx,[aod]
 cmp edx,ebx
 je syn_varaod
 mov edx,[flt]
 cmp edx,ebx
 je syn_ardint   
 mov edx,[ptrt]
 cmp edx,ebx
 je syn_varptr 
 mov edx,[nott]
 cmp edx,ebx 
 je syn_ardnot
 mov edx,[pls]
 cmp edx,ebx 
 je syn_ardop1
 mov edx,[min]
 cmp edx,ebx 
 je syn_ardop1
 mov edx,[lpr]
 cmp edx,ebx 
 je syn_ardlpr
 mov edx,[intt]
 cmp edx,ebx 
 je syn_ardint
 mov edx,[strt]
 cmp edx,ebx 
 je syn_ardstr
 mov edx,[null]
 cmp edx,ebx 
 je syn_ardn
 mov edx,[true]
 cmp edx,ebx 
 je syn_ardtf
 mov edx,[false]
 cmp edx,ebx 
 je syn_ardtf
 mov edx,[idt]
 cmp edx,ebx 
 je syn_recid 
 mov edx,[intt2]
 cmp edx,ebx 
 je toint
 mov edx,[strt2]
 cmp edx,ebx
 je tostr
 mov edx,[negt]
 cmp edx,ebx 
 je syn_ardneg
 call synsorz
 ret
 syn_ardnot:
 mov bl,"o"
 mov [synnf],bl
 jmp syn_ardcmp2

 finard:
 mov eax,[seqts]
 mov edx,0
 mov [track+eax],edx
 sub eax,1
 mov [seqts],eax
 push ecx
 mov ecx,[ade]
 call puts
 pop ecx
 call read
 mov edx,[ter]
 cmp edx,ebx
 jne error
 mov edx,[newt]
 cmp edx,ebx
 je synnewl 
 jmp syn_term

 ops8:
 mov edx,[pls]
 cmp edx,ebx 
 je syn_ardop1
 mov edx,[min]
 cmp edx,ebx 
 je syn_ardop1
 mov edx,[mult]
 cmp edx,ebx 
 je syn_ardop2
 mov edx,[divt]
 cmp edx,ebx 
 je syn_ardop2
 mov edx,[port]
 cmp edx,ebx 
 je syn_ardop2  
 ret 
 cmpops8:
 mov edx,[eq2]
 cmp edx,ebx
 je syn_ardcmp
 mov edx,[neq]
 cmp edx,ebx 
 je syn_ardcmp
 mov edx,[geq]
 cmp edx,ebx 
 je syn_ardcmp
 mov edx,[leq]
 cmp edx,ebx 
 je syn_ardcmp
 mov edx,[grt]
 cmp edx,ebx 
 je syn_ardcmp
 mov edx,[lest]
 cmp edx,ebx 
 je syn_ardcmp
 ret 
 bool8:
 mov edx,[andt]
 cmp edx,ebx
 je syn_ardcmp
 mov edx,[ort]
 cmp edx,ebx 
 je syn_ardcmp 
 ret
 
;;;;;;;;;;ARU;;;;;;;;;;;
 syn_aru:
 push ecx
 mov ecx,[aru] 
 call puts 
 pop ecx
 call idtosyn
 mov edx,"u"
 mov eax,[seqts]
 add eax,1
 mov [track+eax],edx
 mov [seqts],eax
 mov bl,"z"
 mov [synnf],bl
 call read
 call synreg 
 call synbwd 
 mov edx,[aod]
 cmp edx,ebx
 je syn_varaod2
 mov edx,[flt]
 cmp edx,ebx
 je syn_aruint   
 mov edx,[ptrt]
 cmp edx,ebx
 je syn_varptr  
 mov edx,[idt]
 cmp edx,ebx 
 je syn_recid 
 mov edx,[intt]
 cmp edx,ebx 
 je syn_aruint 
 mov edx,[pls]
 cmp edx,ebx 
 je syn_aruop1
 mov edx,[min]
 cmp edx,ebx 
 je syn_aruop1
 mov edx,[lpr]
 cmp edx,ebx 
 je syn_arulpr
 mov edx,[nott]
 cmp edx,ebx 
 je syn_arucmp 
 mov edx,[intt2]
 cmp edx,ebx 
 je toint
 mov edx,[negt]
 cmp edx,ebx 
 je syn_aruneg 
 mov edx,[strt]
 cmp edx,ebx 
 je syn_arustr
 mov edx,[null]
 cmp edx,ebx 
 je syn_arun2
 mov edx,[true]
 cmp edx,ebx 
 je syn_arutf
 mov edx,[false]
 cmp edx,ebx 
 je syn_arutf 
 jmp error

 syn_aruneg:
 push ecx
 mov ecx,[negt]
 call puts
 pop ecx
 mov bl,"z"
 mov [synnf],bl 
 call read
 call synbwd 
 call synreg 
 mov edx,[flt]
 cmp edx,ebx
 je syn_aruint
 mov edx,[ptrt]
 cmp edx,ebx
 je syn_varptr  
 mov edx,[intt]
 cmp edx,ebx 
 je syn_aruint
 mov edx,[intt2]
 cmp edx,ebx 
 je toint
 mov edx,[nott]
 cmp edx,ebx 
 je syn_arunot 
 mov edx,[idt]
 cmp edx,ebx 
 je syn_recid
 mov edx,[true]
 cmp edx,ebx 
 je syn_arutf
 mov edx,[false]
 cmp edx,ebx
 je syn_arutf
 jmp error 
 syn_arun:
 push ecx
 mov ecx,[cntn]
 call puts
 pop ecx
 call read
 call bool6
 call cmpops6 
 mov edx,[rpr]
 cmp edx,ebx 
 je syn_arurpr
 mov edx,[sb2]
 cmp edx,ebx 
 je finaru
 syn_arun2:
 push ecx
 mov ecx,[cntn]
 call puts
 pop ecx
 call read 
 call bool6
 mov edx,[sb2]
 cmp edx,ebx
 je finaru
 call cmpops6
 jmp error   
 syn_arutf:
 push ecx
 mov ecx,[cntn]
 call puts
 pop ecx
 call read
 call bool6
 call ops6
 call cmpops6 
 mov edx,[rpr]
 cmp edx,ebx 
 je syn_arurpr
 mov edx,[sb2]
 cmp edx,ebx 
 je finaru
 syn_arustr:
 push ecx
 mov ecx,[strt]
 call puts
 pop ecx
 call putinsyn
 mov bl,"o"
 mov bh,[synnf]
 cmp bh,bl
 je syn_aruint2
 call read 
 mov edx,[rpr]
 cmp edx,ebx
 je syn_arurpr
 mov edx,[sb2]
 cmp edx,ebx
 je finaru
 call bool6
 call cmpops6
 jmp error 
 syn_arustr2:
 push ecx
 mov ecx,[strt]
 call puts
 pop ecx
 call putinsyn
 call read 
 call bool6
 mov edx,[sb2]
 cmp edx,ebx
 je finaru
 call cmpops6
 jmp error  
 syn_aruint:;int
 push ecx
 mov ecx,[cntn]
 call puts 
 pop ecx
 call putinsyn
 syn_aruint2: 
 call read 
 call ops6
 call cmpops6
 call bool6 
 mov edx,[sb2]
 cmp edx,ebx 
 je finaru
 mov edx,[rpr]
 cmp edx,ebx
 je syn_arurpr
 mov edx,[inct]
 cmp edx,ebx 
 je syn_aruiod 
 mov edx,[dect]
 cmp edx,ebx 
 je syn_aruiod   
 jmp error
 syn_aruop1:;minpls
 push ecx
 mov ecx,[cntn]
 call puts
 pop ecx
 mov bl,"z"
 mov [synnf],bl 
 call read 
 call synbwd 
 call synreg 
 mov edx,[flt]
 cmp edx,ebx
 je syn_aruint    
 mov edx,[ptrt]
 cmp edx,ebx
 je syn_varptr  
 mov edx,[intt]
 cmp edx,ebx 
 je syn_aruint
 mov edx,[idt]
 cmp edx,ebx 
 je syn_recid
 mov edx,[nott]
 cmp edx,ebx 
 je syn_arunot 
 mov edx,[lpr]
 cmp edx,ebx 
 je syn_arulpr
 mov edx,[intt2]
 cmp edx,ebx 
 je toint
 mov edx,[true]
 cmp edx,ebx 
 je syn_arutf
 mov edx,[false]
 cmp edx,ebx
 je syn_arutf 
 jmp error 
 syn_arulpr:;lpr
 push ecx
 mov ecx,[lpr]
 call puts
 pop ecx
 mov edx,[seqts]
 add edx,1
 mov eax,"l"
 mov [track+edx],eax
 mov [seqts],edx
 mov edx,[rps]
 add edx,1
 mov [rps],edx
 mov bl,"z"
 mov [synnf],bl 
 call read 
 call synreg
 call synbwd 
 mov edx,[flt]
 cmp edx,ebx
 je syn_aruint
 mov edx,[intt2]
 cmp edx,ebx 
 je toint
 mov edx,[aod]
 cmp edx,ebx
 je syn_varaod2  
 mov edx,[ptrt]
 cmp edx,ebx
 je syn_varptr  
 mov edx,[intt]
 cmp edx,ebx 
 je syn_aruint
 mov edx,[idt]
 cmp edx,ebx 
 je syn_recid
 mov edx,[pls]
 cmp edx,ebx 
 je syn_aruop1
 mov edx,[nott]
 cmp edx,ebx 
 je syn_arunot 
 mov edx,[min]
 cmp edx,ebx 
 je syn_aruop1 
 mov edx,[lpr]
 cmp edx,ebx 
 je syn_arulpr
 mov edx,[strt]
 cmp edx,ebx 
 je syn_arustr
 mov edx,[negt]
 cmp edx,ebx 
 je syn_aruneg
 mov edx,[true]
 cmp edx,ebx 
 je syn_arutf
 mov edx,[false]
 cmp edx,ebx
 je syn_arutf 
 mov edx,[null]
 cmp edx,ebx 
 je syn_arun2
 mov edx,[strt2]
 cmp edx,ebx
 je tostr 
 call synsorz 
 jmp error
 syn_aruop2:;divmul
 push ecx
 mov ecx,[cntn]
 call puts
 pop ecx
 mov bl,"z"
 mov [synnf],bl 
 call read
 call synbwd 
 call synreg 
 mov edx,[intt]
 cmp edx,ebx 
 je syn_aruint
 mov edx,[flt]
 cmp edx,ebx
 je syn_aruint    
 mov edx,[idt]
 cmp edx,ebx 
 je syn_recid 
 mov edx,[ptrt]
 cmp edx,ebx
 je syn_varptr  
 mov edx,[intt2]
 cmp edx,ebx 
 je toint 
 mov edx,[nott]
 cmp edx,ebx 
 je syn_arunot  
 jmp error
 syn_arurpr:
 mov eax,[seqts]
 mov edx,[track+eax]
 mov eax,"l"
 cmp edx,eax
 jne error
 mov eax,[seqts]
 mov edx,0
 mov [track+eax],edx
 sub eax,1
 mov [seqts],eax
 push ecx
 mov ecx,[rpr]
 call puts
 pop ecx
 call read
 call ops6
 call cmpops6
 mov edx,[rpr]
 cmp edx,ebx
 je syn_arurpr
 mov edx,[sb2]
 cmp edx,ebx
 je finaru
 jmp error
 syn_arunot:
 mov bl,"o"
 mov [synnf],bl
 jmp syn_arucmp2

 finaru:
 mov eax,[seqts]
 mov edx,[track+eax]
 mov eax,"d"
 cmp edx,eax
 je finard
 mov eax,"u"
 cmp eax,edx
 jne error
 mov eax,[seqts]
 mov edx,0
 mov [track+eax],edx
 sub eax,1
 mov [seqts],eax
 push ecx
 mov ecx,[are]
 call puts
 pop ecx
 jmp adjuststt

 ops6:
 mov edx,[pls]
 cmp edx,ebx 
 je syn_aruop1
 mov edx,[min]
 cmp edx,ebx 
 je syn_aruop1
 mov edx,[mult]
 cmp edx,ebx 
 je syn_aruop2
 mov edx,[divt]
 cmp edx,ebx 
 je syn_aruop2
 mov edx,[port]
 cmp edx,ebx 
 je syn_aruop2  
 ret 
 cmpops6:
 mov edx,[eq2]
 cmp edx,ebx
 je syn_arucmp
 mov edx,[neq]
 cmp edx,ebx 
 je syn_arucmp
 mov edx,[geq]
 cmp edx,ebx 
 je syn_arucmp
 mov edx,[leq]
 cmp edx,ebx 
 je syn_arucmp
 mov edx,[grt]
 cmp edx,ebx 
 je syn_arucmp
 mov edx,[lest]
 cmp edx,ebx 
 je syn_arucmp
 ret 
 bool6:
 mov edx,[andt]
 cmp edx,ebx
 je syn_arucmp
 mov edx,[ort]
 cmp edx,ebx 
 je syn_arucmp 
 ret

 syn_arucmp:
 mov bl,"z"
 mov [synnf],bl
 syn_arucmp2: 
 push ecx
 mov ecx,[cntn]
 call puts
 pop ecx
 call read
 call synreg 
 call synbwd 
 mov edx,[negt]
 cmp edx,ebx
 je syn_aruneg
 mov edx,[flt]
 cmp edx,ebx
 je syn_aruint    
 mov edx,[aod]
 cmp edx,ebx
 je syn_varaod 
 mov edx,[ptrt]
 cmp edx,ebx
 je syn_varptr  
 mov edx,[pls]
 cmp edx,ebx 
 je syn_aruop1
 mov edx,[min]
 cmp edx,ebx 
 je syn_aruop1
 mov edx,[lpr]
 cmp edx,ebx 
 je syn_arulpr
 mov edx,[intt]
 cmp edx,ebx 
 je syn_aruint
 mov edx,[strt]
 cmp edx,ebx 
 je syn_arustr
 mov edx,[nott]
 cmp edx,ebx 
 je syn_arunot
 mov edx,[null]
 cmp edx,ebx 
 je syn_arun
 mov edx,[true]
 cmp edx,ebx 
 je syn_arutf
 mov edx,[false]
 cmp edx,ebx 
 je syn_arutf
 mov edx,[idt]
 cmp edx,ebx 
 je syn_recid 
 call synsorz
 jmp error 
 syn_aruiod:
 push ecx
 mov ecx,[cntn]
 call puts
 pop ecx
 call read 
 call cmpops6 
 mov edx,[rpr]
 cmp edx,ebx
 je syn_arurpr 
 call bool6
 mov edx,[sb2]
 cmp edx,ebx
 je finaru 
 call ops6
 jmp error 
 
;;;;;;;;;;;;;;PRN;;;;;;;;;;;;;;

syn_prn:;prn
 push ecx
 mov ecx,[prn]
 call puts
 pop ecx
 mov edx,[seqts]
 add edx,1
 mov eax,"p"
 mov [track+edx],eax
 mov [seqts],edx
 call read 
 mov edx,[lpr]
 cmp edx,ebx 
 jne error
 sub ecx,3
 jmp q4x
finprn:
 push ecx
 mov ecx,[fprn]
 call puts 
 pop ecx
 mov eax,0
 mov [track+edx],eax
 sub edx,1
 mov [seqts],edx
 jmp expectT

;;;;;;;;;;;;;FDF;;;;;;;;;;;;;;;
 syn_fdf:
 push ecx
 mov ecx,[fdf]
 call puts
 pop ecx
 call read
 mov edx,[idt]
 cmp edx,ebx
 jne error
 push ecx
 mov ecx,[idt]
 call puts
 pop ecx
 call putinsyn
 call read
 mov edx,[lpr] 
 cmp edx,ebx
 jne error
 jmp syn_fdf2
 syn_fdf2:
 call read
 mov edx,[idt]
 cmp edx,ebx 
 jne syn_fdfnoid
 push ecx
 mov ecx,[idt]
 call puts
 pop ecx
 call putinsyn
 call read
 mov edx,[cma]
 cmp edx,ebx
 je syn_fdfcma
 mov edx,[rpr]
 cmp edx,ebx
 je syn_fdfrpr
 jmp error
 syn_fdfcma:
 push ecx
 mov ecx,[cma]
 call puts
 pop ecx
 call read
 mov edx,[idt]
 cmp edx,ebx
 jne error
 push ecx
 mov ecx,[idt]
 call puts
 pop ecx
 call putinsyn
 jmp syn_fdfidt
 syn_fdfidt:
 call read 
 mov edx,[cma]
 cmp edx,ebx 
 je syn_fdfcma 
 mov edx,[rpr]
 cmp edx,ebx
 je syn_fdfrpr
 jmp error
 syn_fdfidt2:
 mov edx,[rpr]
 cmp edx,ebx
 je syn_fdfrpr
 mov edx,[cma]
 cmp edx,ebx
 je syn_fdfcma
 jmp error
 syn_fdfnoid:
 mov edx,[rpr]
 cmp edx,ebx
 je syn_fdfrpr
 jmp error
 syn_fdfrpr:
 mov edx,[seqts]
 mov ebx,"2"
 add edx,1
 mov [track+edx],ebx
 mov [seqts],edx 
 call read
 mov edx,[br1]
 cmp edx,ebx
 je syn_finfdf
 mov edx,[ter]
 cmp edx,ebx
 je syn_finfdf2
 mov edx,[newt]
 cmp edx,ebx
 jne error 
 mov edx,[newc]
 add edx,1
 mov [newc],edx
 syn_finfdf2:
 call read
 mov edx,[br1]
 cmp edx,ebx
 je syn_finfdf 
 sub ecx,6
 call read
 jmp syn_term
 syn_finfdf:
 mov bl,"o"
 mov [synbrf],bl
 jmp syn_term

syn_ret:
 push ecx
 mov ecx,[rett]
 call puts
 pop ecx
 mov edx,[seqts]
 mov eax,[track+edx]
 mov ebx,"2"
 cmp eax,ebx
 jne error
 mov edx,[seqts]
 mov eax,0
 mov [track+edx],eax
 sub edx,1
 mov [seqts],edx 
 call read
 call synreg
 call synbwd
 mov edx,[idt]
 cmp edx,ebx
 je syn_recid
 mov edx,[ptrt]
 cmp edx,ebx
 je syn_varptr
 mov edx,[intt]
 cmp edx,ebx
 je syn_varint
 mov edx,[flt]
 cmp edx,ebx
 je syn_varint
 mov edx,[strt]
 cmp edx,ebx
 je syn_varstr 
 mov edx,[min]
 cmp edx,ebx
 je syn_varop1
 mov edx,[pls]
 cmp edx,ebx
 je syn_varop1
 mov edx,[negt]
 cmp edx,ebx
 je syn_varneg
 mov edx,[nott]
 cmp edx,ebx
 je syn_varcmp
 mov edx,[lpr]
 cmp edx,ebx
 je syn_varlpr
 mov edx,[true]
 cmp edx,ebx
 je syn_vartf
 mov edx,[false]
 cmp edx,ebx
 je syn_vartf
 mov edx,[null]
 cmp edx,ebx
 je syn_varn 
 mov edx,[aod]
 cmp edx,ebx
 je syn_varaod
 ;call synsorz 
 jmp error
 
 syn_br2:
 mov bh,[syniwf]
 mov bl,"o"
 cmp bl,bh
 je qfwe2
 mov bl,"o"
 mov bh,[synbrf]
 cmp bh,bl
 jne error
 mov bl,"z"
 mov [synbrf],bl
 mov edx,[seqts]
 mov bl,0
 mov [track+edx],bl
 dec edx
 mov [seqts],edx  
 call read
 mov edx,[eof]
 cmp edx,ebx
 je finsyn
 mov edx,[newt]
 cmp edx,ebx
 je syn_brnew 
 mov edx,[ter]
 cmp edx,ebx
 jne error 
 push ecx
 mov ecx,[end]
 call puts
 pop ecx
 jmp syn_term
 syn_brnew:
 mov edx,[newc]
 add edx,1
 mov [newc],edx
 push ecx
 mov ecx,[end]
 call puts
 pop ecx
 jmp syn_term 
 
;;;;;;;;;;;;;;RECID;;;;;;;;;;;;;

syn_recid:
 call synidr
 call read 
 mov edx,[lpr]
 cmp edx,ebx 
 je syn_fcl
 mov edx,[sb1]
 cmp edx,ebx 
 je syn_aru
 push ecx
 mov ecx,[idt]
 call puts
 pop ecx
 call idtosyn
 sub ecx,3
 jmp adjuststt

;;;;;;;;;;;;;;IF/WHILE;;;;;;;;;;;;
 syn_ift:
 push ecx
 mov ecx,[ift]
 call puts
 pop ecx
 mov edx,[seqts]
 mov eax,"i"
 add edx,1
 mov [track+edx],eax
 mov [seqts],edx
 mov bl,"z"
 mov [synnf],bl
 call read 
 mov edx,[lpr]
 cmp edx,ebx
 jne error
 jmp syn_iow

 syn_wil:
 push ecx
 mov ecx,[while] 
 call puts
 pop ecx
 mov edx,[seqts]
 mov eax,"w"
 add edx,1
 mov [track+edx],eax
 mov [seqts],edx
 mov bl,"z"
 mov [synnf],bl
 call read 
 mov edx,[lpr]
 cmp edx,ebx
 jne error 
 jmp syn_iow

 syn_iow:
 mov bl,"z"
 mov [synnf],bl
 call read
 call synreg 
 call synbwd 
 mov edx,[nott]
 cmp edx,ebx 
 je syn_iownot
 mov edx,[flt]
 cmp edx,ebx
 je syn_iowint    
 mov edx,[aod]
 cmp edx,ebx
 je syn_varaod
 mov edx,[ptrt]
 cmp edx,ebx
 je syn_varptr  
 mov edx,[negt]
 cmp edx,ebx
 je syn_iowneg
 mov edx,[intt]
 cmp edx,ebx
 je syn_iowint
 mov edx,[strt]
 cmp edx,ebx
 je syn_iowstr
 mov edx,[negt]
 cmp edx,ebx
 je syn_iowneg
 mov edx,[pls]
 cmp edx,ebx
 je syn_iowop1
 mov edx,[min]
 cmp edx,ebx
 je syn_iowop1
 mov edx,[lpr]
 cmp edx,ebx
 je syn_iowlpr
 mov edx,[idt]
 cmp edx,ebx
 je syn_recid 
 mov edx,[null]
 cmp edx,ebx
 je syn_iown
 mov edx,[true]
 cmp edx,ebx
 je syn_iowtf
 mov edx,[false]
 cmp edx,ebx
 je syn_iowtf
 mov edx,[intt2]
 cmp edx,ebx
 je toint
 mov edx,[strt2]
 cmp edx,ebx
 je tostr
 call synsorz
 jmp error 

 syn_iowint:
 push ecx
 mov ecx,[cntn]
 call puts
 pop ecx
 call putinsyn
 syn_iowint2: 
 call read
 call ops9
 call cmpops9
 call ao9 
 mov edx,[rpr]
 cmp edx,ebx 
 je syn_iowrpr
 mov edx,[inct]
 cmp edx,ebx
 je syn_iowiod
 mov edx,[dect]
 cmp edx,ebx
 je syn_iowiod 
 jmp error 
 syn_iowneg:
 push ecx
 mov ecx,[negt]
 call puts
 pop ecx 
 mov bl,"z"
 mov [synnf],bl 
 call read
 call synreg 
 call synbwd 
 mov edx,[flt]
 cmp edx,ebx
 je syn_iowint
 mov edx,[ptrt]
 cmp edx,ebx
 je syn_varptr  
 mov edx,[intt]
 cmp edx,ebx
 je syn_iowint
 mov edx,[intt2]
 cmp edx,ebx
 je toint 
 mov edx,[nott]
 cmp edx,ebx 
 je syn_iownot
 mov edx,[true]
 cmp edx,ebx
 je syn_iowtf
 mov edx,[false]
 cmp edx,ebx
 je syn_iowtf
 mov edx,[idt]
 cmp edx,ebx
 je syn_recid 
 jmp error
 syn_iowstr:
 push ecx
 mov ecx,[strt]
 call puts
 pop ecx
 call putinsyn
 mov bl,"o"
 mov bh,[synnf]
 cmp bh,bl
 je syn_iowint2
 call read
 call cmpops9
 call ao9 
 mov edx,[rpr]
 cmp edx,ebx 
 je syn_iowrpr
 jmp error 
 syn_iowstr2:
 push ecx
 mov ecx,[strt]
 call puts
 pop ecx
 call putinsyn
 call read
 call cmpops9
 call ao9 
 jmp error
 syn_iowop1:
 push ecx
 mov ecx,[cntn]
 call puts
 pop ecx
 mov bl,"z"
 mov [synnf],bl 
 call read
 call synreg 
 call synbwd 
 mov edx,[flt]
 cmp edx,ebx
 je syn_iowint    
 mov edx,[ptrt]
 cmp edx,ebx
 je syn_varptr  
 mov edx,[intt]
 cmp edx,ebx 
 je syn_iowint
 mov edx,[lpr]
 cmp edx,ebx 
 je syn_iowlpr
 mov edx,[idt]
 cmp edx,ebx 
 je syn_recid 
 mov edx,[nott]
 cmp edx,ebx 
 je syn_iownot
 mov edx,[true]
 cmp edx,ebx
 je syn_iowtf
 mov edx,[false]
 cmp edx,ebx
 je syn_iowtf 
 mov edx,[intt2]
 cmp edx,ebx
 je toint
 jmp error 
 syn_iowop2:
 push ecx
 mov ecx,[cntn]
 call puts
 pop ecx
 mov bl,"z"
 mov [synnf],bl 
 call read 
 call synbwd 
 call synreg 
 mov edx,[flt]
 cmp edx,ebx
 je syn_iowint    
 mov edx,[ptrt]
 cmp edx,ebx
 je syn_varptr  
 mov edx,[intt]
 cmp edx,ebx 
 je syn_iowint
 mov edx,[idt]
 cmp edx,ebx 
 je syn_recid 
 mov edx,[nott]
 cmp edx,ebx 
 je syn_iownot 
 mov edx,[intt2]
 cmp edx,ebx
 je toint 
 jmp error
 syn_iowlpr:
 push ecx
 mov ecx,[lpr]
 call puts
 pop ecx
 mov bl,"z"
 mov [synnf],bl 
 mov edx,[seqts]
 mov eax,"l"
 add edx,1
 mov [track+edx],eax
 mov [seqts],edx
 call read
 call synreg 
 call synbwd 
 mov edx,[flt]
 cmp edx,ebx
 je syn_iowint    
 mov edx,[aod]
 cmp edx,ebx
 je syn_varaod2 
 mov edx,[ptrt]
 cmp edx,ebx
 je syn_varptr  
 mov edx,[nott]
 cmp edx,ebx 
 je syn_iownot
 mov edx,[negt]
 cmp edx,ebx 
 je syn_iowneg
 mov edx,[intt]
 cmp edx,ebx 
 je syn_iowint
 mov edx,[lpr]
 cmp edx,ebx 
 je syn_iowlpr 
 mov edx,[idt]
 cmp edx,ebx 
 je syn_recid 
 mov edx,[pls]
 cmp edx,ebx
 je syn_iowop1
 mov edx,[min]
 cmp edx,ebx
 je syn_iowop1
 mov edx,[strt]
 cmp edx,ebx
 je syn_iowstr2
 mov edx,[null]
 cmp edx,ebx
 je syn_iown
 mov edx,[true]
 cmp edx,ebx
 je syn_iowtf
 mov edx,[false]
 cmp edx,ebx
 je syn_iowtf 
 mov edx,[intt2]
 cmp edx,ebx
 je toint
 mov edx,[strt2]
 cmp edx,ebx
 je tostr 
 call synsorz 
 jmp error  
 syn_iown:
 push ecx
 mov ecx,[cntn]
 call puts
 pop ecx
 mov bl,"o"
 mov bh,[synnf]
 cmp bh,bl
 je syn_iowint2 
 call read
 call cmpops9
 call ao9
 mov edx,[rpr]
 cmp edx,ebx
 je syn_iowrpr
 jmp error 
 syn_iowtf:
 push ecx
 mov ecx,[cntn]
 call puts
 pop ecx
 call read
 call ops9
 call cmpops9
 call ao9
 mov edx,[rpr]
 cmp edx,ebx
 je syn_iowrpr
 mov edx,[inct]
 cmp edx,ebx
 je syn_iowiod
 mov edx,[dect]
 cmp edx,ebx
 je syn_iowiod  
 jmp error
 syn_iowrpr:
 mov eax,[seqts]
 mov edx,[track+eax]
 mov eax,"i"
 cmp edx,eax
 je q9f
 mov eax,"w"
 cmp edx,eax
 je qwf 
 mov eax,"l"
 cmp edx,eax
 jne error
 push ecx
 mov ecx,[rpr]
 call puts
 pop ecx
 mov eax,[seqts]
 mov edx,[track+eax]
 mov ebx,0
 mov [track+eax],ebx
 sub eax,1 
 mov [seqts],eax 
 call read
 call cmpops9
 call ao9
 call ops9
 mov edx,[rpr]
 cmp edx,ebx
 je syn_iowrpr
 mov edx,[pls]
 cmp edx,ebx
 je syn_iowop1
 mov edx,[min]
 cmp edx,ebx
 je syn_iowop1
 jmp error 
 syn_iowiod:
 push ecx
 mov ecx,[cntn] 
 call puts
 pop ecx
 call read 
 call ops9
 call cmpops9 
 mov edx,[rpr]
 cmp edx,ebx
 je syn_iowrpr 
 mov edx,[ter]
 cmp edx,ebx 
 je syn_term 
 mov edx,[newt]
 cmp edx,ebx
 je synnewl 

 call ao9
 jmp error 
 syn_iownot:
 mov bl,"o"
 mov [synnf],bl
 jmp aocmp2
 
 cmpops9:
 mov edx,[eq2]
 cmp edx,ebx 
 je aocmp
 mov edx,[geq]
 cmp edx,ebx 
 je aocmp
 mov edx,[leq]
 cmp edx,ebx 
 je aocmp
 mov edx,[neq]
 cmp edx,ebx 
 je aocmp
 mov edx,[grt]
 cmp edx,ebx 
 je aocmp
 mov edx,[lest]
 cmp edx,ebx 
 je aocmp
 ret 
 ao9:
 mov edx,[andt]
 cmp edx,ebx 
 je aocmp
 mov edx,[ort]
 cmp edx,ebx 
 je aocmp
 ret 
 ops9:
 mov edx,[pls]
 cmp edx,ebx
 je syn_iowop1
 mov edx,[min]
 cmp edx,ebx
 je syn_iowop1
 mov edx,[mult]
 cmp edx,ebx
 je syn_iowop2
 mov edx,[divt]
 cmp edx,ebx
 je syn_iowop2
 mov edx,[port]
 cmp edx,ebx
 je syn_iowop2
 ret
 
 aocmp:
 mov bl,"z"
 mov [synnf],bl
 aocmp2:  
 push ecx
 mov ecx,[cntn]
 call puts
 pop ecx 
 call read
 call synbwd
 mov edx,[flt]
 cmp edx,ebx
 je syn_iowint    
 mov edx,[aod]
 cmp edx,ebx
 je syn_varaod 
 mov edx,[ptrt]
 cmp edx,ebx
 je syn_varptr  
 mov edx,[negt]
 cmp edx,ebx 
 je syn_iowneg 
 mov edx,[nott]
 cmp edx,ebx 
 je syn_iownot
 mov edx,[pls]
 cmp edx,ebx
 je syn_iowop1
 mov edx,[min]
 cmp edx,ebx
 je syn_iowop1
 mov edx,[intt]
 cmp edx,ebx 
 je syn_iowint
 mov edx,[lpr]
 cmp edx,ebx 
 je syn_iowlpr
 mov edx,[idt]
 cmp edx,ebx 
 je syn_recid 
 mov edx,[null]
 cmp edx,ebx
 je syn_iown
 mov edx,[true]
 cmp edx,ebx
 je syn_iowtf
 mov edx,[false]
 cmp edx,ebx
 je syn_iowtf
 mov edx,[strt]
 cmp edx,ebx
 je syn_iowstr
 call synsorz
 call synreg  
 jmp error

 q9f:
 push ecx
 mov ecx,[endf2]
 call puts 
 pop ecx
 jmp qfwe
 qfwen:
 mov edx,[newc]
 add edx,1
 mov [newc],edx
 qfwe: 
 call read
 mov edx,[ter]
 cmp edx,ebx
 je qfwe
 mov edx,[newt]
 cmp edx,ebx
 je qfwen 
 mov edx,[br1]
 cmp edx,ebx
 jne error 
 push ecx
 mov ecx,[got]
 call puts
 pop ecx
 mov edx,[seqts]
 mov eax,0
 mov [track+edx],eax
 sub edx,1
 mov [seqts],edx
 mov bh,"o"
 mov [syniwf],bh
 jmp synstart 
 qwf:
 push ecx
 mov ecx,[endw]
 call puts 
 pop ecx
 jmp qfwe
 
 qfwe2:
 push ecx
 mov ecx,[end]
 call puts
 pop ecx
 mov bh,"z"
 mov [syniwf],bh
 jmp synstart
 
;;;;;;;;;;;;;SHF ROT;;;;;;;;;;;;;
sor:
 push ecx
 mov ecx,[cntn]
 call puts
 pop ecx
 call read
 mov edx,[intt]
 cmp edx,ebx
 jne error
 push ecx
 mov ecx,[cntn]
 call puts
 pop ecx 
 call putinsyn
 call read
 mov edx,[dots]
 cmp edx,ebx
 jne error
 jmp syn_varcmp 
  
toint:
 push ecx
 mov ecx,[intt2]
 call puts
 pop ecx
 push bx
 mov eax,"n"
 mov edx,[seqts]
 add edx,1
 mov [track+edx],eax
 mov [seqts],edx 
 call read
 mov edx,[lpr]
 cmp edx,ebx
 jne error 
 call read
 mov edx,[idt]
 cmp edx,ebx
 je syn_recid
 mov edx,[strt]
 cmp edx,ebx 
 je fint1
 mov edx,[ptrt]
 cmp edx,ebx
 je syn_varptr  
 jmp error
tostr:
 push ecx
 mov ecx,[strt2]
 call puts
 pop ecx
 mov bl,[synnf]
 mov bh,[syncf]
 push bx
 mov eax,"t"
 mov edx,[seqts]
 add edx,1
 mov [track+edx],eax
 mov [seqts],edx 
 call read
 mov edx,[lpr]
 cmp edx,ebx
 jne error 
 call read 
 mov edx,[idt]
 cmp edx,ebx
 je syn_recid
 mov edx,[intt]
 cmp edx,ebx 
 je syn_varint
 mov edx,[lpr]
 cmp edx,ebx
 je syn_varlpr 
 mov edx,[ptrt]
 cmp edx,ebx
 je syn_varptr 
 mov edx,[flt]
 cmp edx,ebx
 je syn_varint 
 jmp error
fint1:
 push ecx
 mov ecx,[cntn]
 call puts
 pop ecx
 call putinsyn
 mov edx,[seqts]
 mov eax,[track+edx]
 mov edx,"t"
 cmp edx,eax
 je fintostr
 pop bx
 call read
 mov edx,[rpr]
 cmp edx,ebx 
 jne error
 push ecx
 mov ecx,[endt]
 call puts
 pop ecx 
 mov edx,[seqts]
 mov eax,0
 mov [track+edx],eax
 sub edx,1
 mov [seqts],edx
 jmp adjuststt 
fintostr:
 push ecx
 mov ecx,[endt]
 call puts
 pop ecx 
 mov edx,[seqts]
 mov eax,0
 mov [track+edx],eax
 sub edx,1
 mov [seqts],edx
 pop bx
 mov [syncf],bh
 mov [synnf],bl
 mov ah,"o"
 cmp ah,bh
 je syn_varstr3
 cmp ah,bl
 je syn_varint2 
 call read 
 call bool
 call cmpops
 mov edx,[rpr]
 cmp edx,ebx
 je syn_varrpr
 mov edx,[sb2]
 cmp edx,ebx
 je finaru
 jmp expectT

sorf:
 push ecx
 mov ecx,[cntn]
 call puts
 pop ecx
 call read
 mov edx,[idt]
 cmp edx,ebx 
 je sorfid 
 mov edx,[intt]
 cmp edx,ebx 
 je sorf2
 mov edx,[flt]
 cmp edx,ebx
 je sorf2    
 mov edx,[strt]
 cmp edx,ebx
 je sorf2 
 mov edx,[ptrt]
 cmp edx,ebx
 je sorfptr
;regs part
 mov edx,[eaxl]
 cmp edx,ebx
 je sorfreg
 mov edx,[ebxl]
 cmp edx,ebx
 je sorfreg
 mov edx,[ecxl]
 cmp edx,ebx
 je sorfreg
 mov edx,[edxl]
 cmp edx,ebx
 je sorfreg
 mov edx,[esil]
 cmp edx,ebx
 je sorfreg
 mov edx,[edil]
 cmp edx,ebx
 je sorfreg
 mov edx,"alR"
 cmp edx,ebx
 je sorfreg
 mov edx,"ahR"
 cmp edx,ebx
 je sorfreg
 mov edx,"axR"
 cmp edx,ebx
 je sorfreg
 mov edx,"blR"
 cmp edx,ebx
 je sorfreg
 mov edx,"bhR"
 cmp edx,ebx
 je sorfreg
 mov edx,"bxR"
 cmp edx,ebx
 je sorfreg
 mov edx,"clR"
 cmp edx,ebx
 je sorfreg
 mov edx,"chR"
 cmp edx,ebx
 je sorfreg
 mov edx,"cxR"
 cmp edx,ebx
 je sorfreg
 mov edx,"dlR"
 cmp edx,ebx
 je sorfreg
 mov edx,"dhR"
 cmp edx,ebx
 je sorfreg
 mov edx,"dxR"
 cmp edx,ebx
 je sorfreg  
 jmp error
 
sorfid:
 push ecx 
 mov ecx,[idt]
 call puts 
 pop ecx
 call putinsyn
 call read
 mov edx,[cma]
 cmp edx,ebx
 je sorf3
 jmp error 
sorfreg:
 push ecx
 mov ecx,[cntn]
 call puts
 pop ecx
 call read
 mov edx,[cma]
 cmp edx,ebx
 jne error
 jmp sorf3
sorf2:
 push ecx
 mov ecx,[cntn]
 call puts
 pop ecx
 call putinsyn
 call read
 mov edx,[cma]
 cmp edx,ebx
 je sorf3
 jmp error
sorf3:
 push ecx
 mov ecx,[cma]
 call puts
 pop ecx
 call read
 mov edx,[intt]
 cmp edx,ebx
 je sorf4 
 mov edx,[idt]
 cmp edx,ebx
 je sorf5
 jmp error 
sorf4:
 push ecx
 mov ecx,[cntn]
 call puts
 pop ecx
 call putinsyn
 call read 
 mov edx,[rpr]
 cmp edx,ebx
 je finsorf
 jmp error 
sorf5:
 push ecx 
 mov ecx,[idt]
 call puts 
 pop ecx
 call putinsyn
 call read
 mov edx,[rpr]
 cmp edx,ebx
 je finsorf
 jmp error 

finsorf:
 push ecx
 mov ecx,[rpr]
 call puts
 pop ecx
 call read
 call cmpops
 sub ecx,3
 jmp expectT ;;;;;;ALL TRMS 
 
sorfptr:
 call read
 mov edx,[idt]
 cmp edx,ebx
 jne error
 push ecx
 mov ecx,[ptrt]
 call puts
 pop ecx 
 call putinsyn
 call read 
 mov edx,[cma]
 cmp edx,ebx
 jne error
 jmp sorf3
 
;;;;;;;;;;;;;ROCK BOTTOM;;;;;;;;;;;;;
 adjuststt:
 mov eax,[seqts]
 mov edx,[track+eax]
 mov eax,"f"
 cmp edx,eax
 je sttf
 mov eax,"u"
 cmp edx,eax
 je sttu
 mov eax,"z"
 cmp edx,eax
 je sttz
 mov eax,"2"
 cmp edx,eax
 je sttz 
 mov eax,"p"
 cmp edx,eax
 je sttp
 mov eax,"d"
 cmp edx,eax
 je sttd 
 mov eax,"t"
 cmp edx,eax
 je sttt
 mov eax,"n"
 cmp edx,eax
 je stty 
 mov eax,"i"
 cmp edx,eax
 je sttfw 
 mov eax,"w"
 cmp edx,eax
 je sttfw  
 mov eax,"v"
 cmp edx,eax 
 je sttv 
 jmp sttl 


 chkrpr:
 mov eax,[seqts]
 mov edx,[track+eax]
 mov eax,"f"
 cmp edx,eax 
 je syn_fclrpr
 push ecx
 mov ecx,[rpr]
 call puts 
 pop ecx
 mov eax,"l"
 cmp edx,eax
 je sttl 
 jmp error
 
 read:
 mov edx,DWORD[CILEX+ecx]
 add ecx,3
 mov [file],edx
 mov esi,file
 mov edi,cntn
 push ecx
 mov ecx,3
 cld
 rep movsb 
 pop ecx
 mov ebx,[cntn]
 mov [synco],ecx
 ret 

 
 chkcma:
 mov eax,[seqts]
 mov edx,[track+eax]
 cmp edx,"v"
 je syn_varcmp
 mov eax,"p"
 cmp edx,eax 
 je syn_varcmp
 mov eax,"f"
 cmp edx,eax 
 jne error 
 jmp syn_fclcma

 sttv:
  push ecx
  mov ecx,[end2]
  call puts 
  pop ecx
  mov edx,[seqts]
  mov eax,0
  mov [track+edx],eax
  sub edx,1
  mov [seqts],edx
  jmp expectT 
  
 sttz:
 call read
 call ops
 call cmpops
 call bool
 mov edx,[rpr]
 cmp edx,ebx 
 je syn_varrpr
 mov edx,[dect]
 cmp edx,ebx  
 je syn_variod 
 mov edx,[inct]
 cmp edx,ebx 
 je syn_variod 
 sub ecx,3
 jmp expectT ;doi 
 sttd:
 call read
 call ops8
 call cmpops8
 call bool8
 mov edx,[rpr]
 cmp edx,ebx 
 je syn_ardrpr
 mov edx,[dect]
 cmp edx,ebx  
 je syn_ardiod 
 mov edx,[inct]
 cmp edx,ebx 
 je syn_ardiod 
 mov edx,[sb2]
 cmp edx,ebx 
 je finard 
 jmp error ;doi 
 sttf:
 call read
 call ops4
 call cmpops4
 call bool4
 mov edx,[cma]
 cmp edx,ebx 
 je syn_fclcma
 mov edx,[rpr]
 cmp edx,ebx 
 je syn_fclrpr
 mov edx,[inct]
 cmp edx,ebx 
 je syn_fcliod 
 mov edx,[dect]
 cmp edx,ebx 
 je syn_fcliod   
 jmp error
 sttu:
 call read
 call ops6
 call cmpops6
 call bool6
 mov edx,[inct]
 cmp edx,ebx 
 je syn_aruiod 
 mov edx,[dect]
 cmp edx,ebx 
 je syn_aruiod    
 mov edx,[sb2]
 cmp edx,ebx 
 je finaru 
 jmp error
 
 sttp:
 call read
 call ops4
 call cmpops4
 mov edx,[inct]
 cmp edx,ebx 
 je syn_fcliod 
 mov edx,[dect]
 cmp edx,ebx 
 je syn_fcliod    
 mov edx,[rpr]
 cmp edx,ebx 
 je syn_fclrpr
 mov edx,[cma]
 cmp edx,ebx 
 je syn_fclcma
 jmp error 
 sttl:
 call read
 call ops
 call cmpops 
 mov edx,[inct]
 cmp edx,ebx 
 je syn_variod 
 mov edx,[dect]
 cmp edx,ebx 
 je syn_variod    
 mov edx,[rpr]
 cmp edx,ebx
 je syn_varrpr
 jmp error 
 sttfw:
 call read
 call ops9
 call cmpops9 
 call ao9
 mov edx,[inct]
 cmp edx,ebx 
 je syn_iowiod 
 mov edx,[dect]
 cmp edx,ebx 
 je syn_iowiod     
 mov edx,[rpr]
 cmp edx,ebx 
 je syn_iowrpr
 jmp error
 
 sttt:
 call read
 mov edx,[rpr]
 cmp edx,ebx 
 je sttt2
 call ops
 call cmpops
 call bool

 jmp error
 sttt2: 
 push ecx
 mov ecx,[endt]
 call puts
 pop ecx 
 call read
 call cmpops
 sub ecx,3
 jmp expectT
 stty:
 call read
 mov edx,[rpr]
 cmp edx,ebx 
 jne error
 push ecx
 mov ecx,[endt]
 call puts
 pop ecx 
 mov edx,[seqts]
 mov eax,0
 mov [track+edx],eax
 sub edx,1
 mov [seqts],edx 
 call read 
 call ops 
 call cmpops
 mov edx,[dect]
 cmp edx,ebx  
 je syn_variod 
 mov edx,[inct]
 cmp edx,ebx 
 je syn_variod 
 sub ecx,3
 jmp expectT 

 error:
 call semread
 call chk
 mov ecx,synerr
 mov edx,synelen
 mov eax,4
 mov ebx,1
 int 0x80
 mov ecx,CISYN
 mov edx,200
 mov eax,4
 mov ebx,1
 int 0x80 
 mov eax,1
 int 0x80 
 ret
 syn_term:
 push ecx
 mov ecx,[cntn]
 call puts
 pop ecx
 jmp semini
 synnewl:
 push ecx
 mov ecx,[cntn]
 call puts
 pop ecx
 mov edx,[newc]
 add edx,1
 mov [newc],edx
 jmp semini
 
 puts:
 mov edx,[sync]
 mov [CISYN+edx],ecx
 add edx,3
 mov [sync],edx
 ret 
 expectT:
 call read
 mov edx,[ter]
 cmp edx,ebx 
 je syn_term 
 mov edx,[newt]
 cmp edx,ebx
 je synnewl 
 jmp error  

 finsyn:
 mov ecx,[eof]
 call puts
 mov eax,4
 mov ecx,synsuc
 mov edx,synsucl
 mov ebx,1
 int 0x80
 mov ecx,CISYN
 mov edx,200
 mov eax,4
 mov ebx,1
 ;int 0x80  
 mov ecx,nl
 mov edx,1
 mov eax,4
 mov ebx,1
 int 0x80   
 jmp semini
 mov eax,1
 int 0x80 ;https://www.tutorialspoint.com/codingground.htm
 ret 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;SEMANTIC ANALYZER;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

semread: ;reads token
 mov eax,DWORD[CISYN+ecx]
 mov [file],eax
 add ecx,3
 push ecx
 mov ecx,3
 mov esi,file 
 mov edi,cntn
 cld
 rep movsb
 pop ecx
 mov ebx,[cntn]
 mov eax,0
 mov [semco],ecx
 ret 
 

semini:
 mov eax,"sem"
 mov [cntn],eax
 call chk
 mov ecx,0
 jmp semstart 

semstart:
 call clearflags
 call semread
 cmp ebx,"SYS"
 je semsys
 mov edx,[movt]
 cmp edx,ebx 
 je semmovs 
 mov edx,[movb]
 cmp edx,ebx
 je semmovs
 mov edx,[movci]
 cmp edx,ebx
 je semmovs
 mov edx,[bit]
 cmp edx,ebx
 je semmovs
 call regs
 mov edx,[seq]
 cmp edx,ebx
 je semseq
 mov edx,[prn]
 cmp edx,ebx
 je semprn
 mov edx,[popt]
 cmp edx,ebx
 je sempop
 mov edx,[psh]
 cmp edx,ebx
 je sempush
 mov edx,[strt2]
 cmp edx,ebx
 je semtostr
 mov edx,[true]
 cmp edx,ebx
 je zint2
 mov edx,[false]
 cmp edx,ebx
 je zint2
 mov edx,[ptrt]
 cmp edx,ebx
 je semptr
 mov edx,[null]
 cmp edx,ebx
 je znull 
 mov edx,[if]
 cmp edx,ebx
 je semiow 
 mov edx,[while]
 cmp edx,ebx
 je semiow  
 mov edx,[fce]
 cmp edx,ebx
 je endfcl
 mov edx,[idt]
 cmp edx,ebx 
 je zidt 
 mov edx,[intt]
 cmp edx,ebx 
 je zint
 mov edx,[flt]
 cmp edx,ebx 
 je zint  
 mov edx,[strt]
 cmp edx,ebx 
 je zstrt
 mov edx,[fdf]
 cmp edx,ebx 
 je semfdf
 mov edx,[fcl]
 cmp edx,ebx 
 je semfcl
 mov edx,[aru]
 cmp edx,ebx 
 je semaru
 mov edx,[ard]
 cmp edx,ebx 
 je semard
 mov edx,[var]
 cmp edx,ebx 
 je semvar
 mov edx,[lpr]
 cmp edx,ebx
 je zlpr
 mov edx,[rett]
 cmp edx,ebx
 je fdfret
 mov edx,[aod]
 cmp edx,ebx
 je zaod
 mov edx,[intt2]
 cmp edx,ebx
 je semtoint
 call sorfs
 call sors
 call z_ops
 mov edx,"eof"
 cmp edx,ebx
 je eoff
 mov edx,[end]
 cmp edx,ebx
 je semstart
 mov edx,[ter]
 cmp edx,ebx
 je succ
 mov edx,[newt]
 cmp edx,ebx
 je semnewl
 mov edx,[npt]
 cmp edx,ebx 
 je semstart
 jmp error2 
 
 semsys:
 call tonothing 
 jmp semstart
 
;;;;;;;GENERAL;;;;;;;;
 sempush:
  call semread
  call regs 
  mov edx,[aod]
  cmp edx,ebx
  je zaod
  mov edx,[lpr]
  cmp edx,ebx
  je zlpr
  mov edx,[idt]
  cmp edx,ebx
  je zidt
  mov edx,[ptrt]
  cmp edx,ebx
  je semptr
  mov edx,[true]
  cmp edx,ebx
  je zint2
  mov edx,[false]
  cmp edx,ebx
  je zint2
  mov edx,[null]
  cmp edx,ebx
  je znull 
  call z_ops
  mov edx,[strt]
  cmp edx,ebx
  je zstrt
  mov edx,[fcl]
  cmp edx,ebx
  je semfcl
  mov edx,[aru]
  cmp edx,ebx
  je semaru
  mov edx,[intt]
  cmp edx,ebx
  je zint
  mov edx,[flt]
  cmp edx,ebx 
  je zint  
  endpush:
  add ecx,3
  jmp semstart
  
 sempop:
  call semread
  mov edx,[idt]
  cmp edx,ebx
  je sempop2 
  mov edx,[trm]
  cmp edx,ebx
  je succ
  add ecx,3 
  jmp succ 
  sempop2:
  mov edx,0
  call readid2
  call getidtype 
  add ecx,3
  call semread
  mov edx,[trm]
  cmp edx,ebx
  je succ
 
 semseq:
  add ecx,3
  mov edx,0
  call readid2
  mov edx,0
  mov eax,0
  call chkaru 
  semseqend:
  add ecx,3
  jmp semstart
 
 semprn:
  mov edx,[semseqts]
  mov eax,"p"
  add edx,1
  mov [semtrack+edx],eax
  mov [semseqts],edx
  jmp fclsem2
  semfinprn:
  mov edx,[semseqts]
  mov eax,0
  mov [semtrack+edx],eax 
  sub edx,1
  mov [semseqts],edx
  call semread
  jmp succ

 semmovs:
  mov edx,[semseqts]
  mov eax,"m"
  add edx,1
  mov [semtrack+edx],eax
  mov [semseqts],edx
  jmp semstart
  semfinmov:
  mov edx,[semseqts]
  mov bl,0
  mov [semtrack+edx],bl 
  sub edx,1
  mov [semseqts],edx
  jmp semstart 

 semiow:
  call semread
  call sors 
  call sorfs
  call regs 
  mov edx,[strt2]
  cmp edx,ebx
  je semtostr
  mov edx,[intt2]
  cmp edx,ebx
  je semtoint
  mov edx,[idt]
  cmp edx,ebx 
  je zidt
  mov edx,[ptrt]
  cmp edx,ebx
  je semptr 
  mov edx,[true]
  cmp edx,ebx
  je zint2
  mov edx,[false]
  cmp edx,ebx
  je zint2 
  mov edx,[intt]
  cmp edx,ebx 
  je zint 
  mov edx,[fcl]
  cmp edx,ebx 
  je semfcl
  mov edx,[aru]
  cmp edx,ebx 
  je semaru 
  mov edx,[lpr]
  cmp edx,ebx
  je zlpr
  mov edx,[null]
  cmp edx,ebx
  je znull
  mov edx,[strt]
  cmp edx,ebx 
  je zstrt
  mov edx,[ptrt]
  cmp edx,ebx
  je semptr
  call z_ops
  sem_endiow:
  add ecx,3 ;) 
  jmp semstart
 
 zaod:
  mov edx,0
  mov eax,0 ;might need to be deleted
  call readid2
  call getidtype
  jmp zint2
 zidt:
  call clearflags
  mov edx,0
  call readid2 
  call getidtype
  mov bl,[sf]
  mov bh,"o"
  cmp bh,bl
  je zstrt2
  mov bl,[nf2]
  cmp bh,bl
  je znull 
  jmp zint2
 zidt2:
  mov edx,0
  call readid2
  call getidtype
  jmp zint2
 zterm:
  call semread 
  mov edx,[trm]
  cmp edx,ebx
  je succ
  mov edx,[newt]
  cmp edx,ebx
  je semnewl 
  call trms
  mov edx,[rpr]
  cmp edx,ebx
  je zrpr
  mov edx,[endp]
  cmp edx,ebx
  je endpush
  mov edx,[endw]
  cmp edx,ebx
  je sem_endiow
  mov edx,[endt]
  cmp edx,ebx
  je semfintostr
  mov edx,[endf2]
  cmp edx,ebx
  je sem_endiow
  call z_ops
  jmp z_0 
 zint:
  call tonothing
 zint2:
  call clearflags
  call semread
  call z_ops
  call trms 
  mov edx,[endp]
  cmp edx,ebx
  je endpush 
  mov edx,[inct]
  cmp edx,ebx
  je zterm
  mov edx,[endt]
  cmp edx,ebx
  je semfintostr
  mov edx,[dect] 
  cmp edx,ebx
  je zterm 
  mov edx,[endw]
  cmp edx,ebx
  je sem_endiow
  mov edx,[endf2]
  cmp edx,ebx
  je sem_endiow
  mov edx,[rpr]
  cmp edx,ebx
  je zrpr
  mov edx,[trm]
  cmp edx,ebx
  je succ
  jmp z_0 ;cmp for sure
 znull:
  jmp zstrt2
 zstrt:
  call tonothing
 zstrt2:
  call clearflags
  call semread
  call strerrors
  mov edx,[trm]
  cmp edx,ebx 
  je succ
  call trms
  mov edx,[endp]
  cmp edx,ebx
  je endpush 
  mov edx,[endt]
  cmp edx,ebx
  je semfintostr
  mov edx,[endw]
  cmp edx,ebx
  je sem_endiow
  mov edx,[endf2]
  cmp edx,ebx
  je sem_endiow 
  mov edx,[rpr]
  cmp edx,ebx
  je zchkrpr
  jmp z_0
 zrpr:
  call semread
  mov edx,[trm]
  cmp edx,ebx
  je succxreg 
  call z_ops
  call trms 
  mov edx,[endp]
  cmp edx,ebx
  je endpush 
  mov edx,[endt]
  cmp edx,ebx
  je semfintostr
  mov edx,[rpr]
  cmp edx,ebx
  je zrpr
  mov edx,[endw]
  cmp edx,ebx
  je sem_endiow
  mov edx,[endf2]
  cmp edx,ebx
  je sem_endiow 
  jmp z_0 
 zlpr:
  mov bl,"z"
  mov [zcf],bl
  mov [znf],bl
  call semread
  call regs 
  call sorfs
  call sors
  call z_ops
  mov edx,[strt2]
  cmp edx,ebx
  je semtostr 
  mov edx,[true]
  cmp edx,ebx
  je zint2
  mov edx,[false]
  cmp edx,ebx
  je zint2
  mov edx,[lpr]
  cmp edx,ebx 
  je zlpr 
  mov edx ,[intt]
  cmp edx,ebx
  je zint 
  mov edx,[flt]
  cmp edx,ebx 
  je zint  
  mov edx,[intt2]
  cmp edx,ebx 
  je semtoint  
  mov edx,[idt]
  cmp edx,ebx
  je zidt
  mov edx,[fcl]
  cmp edx,ebx
  je semfcl
  mov edx,[null]
  cmp edx,ebx
  je zstrlpr2
  mov edx,[strt]
  cmp edx,ebx
  je zstrlpr
  mov edx,[aod]
  cmp edx,ebx
  je zstrlpr3
  mov edx,[ptrt]
  cmp edx,ebx
  je semptr 
 zop:
  mov bl,"z"
  mov [znf],bl
  call semread
  call regs 
  mov edx,[intt]
  cmp edx,ebx 
  je zint
  mov edx,[ptrt]
  cmp edx,ebx
  je semptr2 
  mov edx,[flt]
  cmp edx,ebx 
  je zint   
  mov edx,[true]
  cmp edx,ebx
  je zint2
  mov edx,[false]
  cmp edx,ebx
  je zint2 
  mov edx,[idt]
  cmp edx,ebx
  je zintidt
  mov edx,[fcl]
  cmp edx,ebx
  je zfclint 
  mov edx,[aru]
  cmp edx,ebx 
  je semaru 
  mov edx,[lpr]
  cmp edx,ebx
  je zlpr
  mov edx,[nott]
  cmp edx,ebx
  je zop2
  mov edx,[intt2]
  cmp edx,ebx
  je semtoint
 zop2:
  mov bl,"o"
  mov [znf],bl
  call semread
  call regs 
  call z_ops
  mov edx,[idt]
  cmp edx,ebx
  je zidt2
  mov edx,[intt]
  cmp edx,ebx
  je zint 
  mov edx,[flt]
  cmp edx,ebx 
  je zint   
  mov edx,[ptrt]
  cmp edx,ebx
  je semptr
  mov edx,[intt2]
  cmp edx,ebx
  je semtoint
  mov edx,[strt2]
  cmp edx,ebx
  je semtostr
  mov edx,[null]
  cmp edx,ebx
  je zint2
  mov edx,[true]
  cmp edx,ebx
  je zint2
  mov edx,[false]
  cmp edx,ebx
  je zint2 
  mov edx,[strt]
  cmp edx,ebx
  je zint
  mov edx,[fcl]
  cmp edx,ebx
  je semfcl
  mov edx,[aru]
  cmp edx,ebx
  je semaru
  mov edx,[lpr] 
  cmp edx,ebx 
  je zlpr 
  mov edx,[aod]
  cmp edx,ebx
  je zaod
 
 zintidt:
  mov edx,0
  call readid2
  call getidtype 
  mov bl,[iff]
  mov bh,"o"
  cmp bh,bl
  jne seme1
  jmp zint2
 zfclint:
  mov edx,[semseqts]
  add edx,1
  mov eax,"f"
  mov [semtrack+edx],eax
  mov [semseqts],edx
  mov edx,0
  call readid2 ;read id of func 
  mov edx,0
  mov eax,0
  call chkfcl
  mov bl,[rtype]
  mov bh,"i"
  cmp bh,bl 
  jne seme1
  jmp fclsem2
 zstrlpr:
  call tonothing ;str
 zstrlpr2:
  call clearflags
  call semread
  call strerrors 
  mov edx,[rpr]
  cmp edx,ebx
  je seme3 
  jmp z_0;null
 zstrlpr3:
  mov edx,0
  call readid2
  call getidtype
  jmp zstrlpr2;aod
 
 z_0:
  mov bl,"z"
  mov [znf],bl
  mov bl,"o"
  mov [zcf],bl
  call semread
  call regs 
  call sors 
  mov edx,[ptrt]
  cmp edx,ebx
  je semptr 
  mov edx,[strt2]
  cmp edx,ebx
  je semtostr 
  mov edx,[null]
  cmp edx,ebx
  je znull 
  mov edx,[fcl]
  cmp edx,ebx 
  je semfcl
  mov edx,[aru]
  cmp edx,ebx 
  je semaru
  mov edx,[idt]
  cmp edx,ebx 
  je zidt
  mov edx,[intt]
  cmp edx,ebx 
  je zint
  mov edx,[flt]
  cmp edx,ebx 
  je zint  
  mov edx,[true]
  cmp edx,ebx
  je zint2
  mov edx,[false]
  cmp edx,ebx
  je zint2
  mov edx,[null]
  cmp edx,ebx
  je znull
  mov edx,[intt2]
  cmp edx,ebx
  je semtoint
  mov edx,[lpr]
  cmp edx,ebx
  je zlpr
  call z_ops
  mov edx,[strt]
  cmp edx,ebx 
  je zstrt
  call sorfs 

 z_ops:
  mov edx,[nott]
  cmp edx,ebx
  je zop2
  mov edx,[negt]
  cmp edx,ebx
  je zop
  mov edx,[pls]
  cmp edx,ebx 
  je zop 
  mov edx,[min]
  cmp edx,ebx 
  je zop 
  mov edx,[mult]
  cmp edx,ebx 
  je zop 
  mov edx,[divt]
  cmp edx,ebx 
  je zop 
  ret  
 
 trms:
  mov edx,[trm]
  cmp edx,ebx
  je succ
  mov edx,[newt]
  cmp edx,ebx
  je semnewl 
  mov edx,[fce] 
  cmp edx,ebx 
  je endfcl
  mov edx,[are]
  cmp edx,ebx
  je semfinaru
  mov edx,[ade]
  cmp edx,ebx
  je semfinard  
  mov edx,[fprn]
  cmp edx,ebx
  je semfinprn
  mov edx,[cma]
  cmp edx,ebx
  je chkcma2 
  mov edx,[end2]
  cmp edx,ebx
  je semend2
  ret
 chkcma2:
  mov edx,[semseqts]
  mov al,[semtrack+edx]
  mov ah,"f"
  cmp al,ah
  je addpar
  mov ah,"p"
  cmp al,ah
  je addpar
  mov ah,"m"
  cmp al,ah
  je z_0 
  jmp ardef1
 semend2:
  mov edx,[semseqts]
  mov al,[semtrack+edx]
  mov ah,"m"
  cmp al,ah
  je semfinmov
  jmp semstts2
 sors:
  mov edx,[shrt]
  cmp edx,ebx
  je semsor
  mov edx,[rort] 
  cmp edx,ebx
  je semsor
  mov edx,[rolt] 
  cmp edx,ebx
  je semsor
  mov edx,[shlt] 
  cmp edx,ebx
  je semsor 
  ret
 sorfs:
  mov edx,[shrf]
  cmp edx,ebx
  je semsorf
  mov edx,[rorf] 
   cmp edx,ebx
  je semsorf
  mov edx,[rolf] 
  cmp edx,ebx
  je semsorf
  mov edx,[shlf] 
  cmp edx,ebx
  je semsorf 
  ret  
 
 
 zchkrpr:
  mov bl,[zcf]
  mov bh,"o"
  cmp bh,bl
  je zrpr
  jmp seme3
  
 semsor:
  call semread ;int
  call tonothing 
  call semread ;dots
  jmp z_0 
 
 ;;;;;;;;SEMSORF;;;;
  semsorf:
   mov bl,"o"
   mov [sorff],bl
   call semread
   mov edx,[idt]
   cmp edx,ebx
   je sorfid
   mov edx,[intt]
   cmp edx,ebx
   je semsorf2x
   mov edx,[flt]
   cmp edx,ebx
   je semsorf2x 
   mov edx,[strt]
   cmp edx,ebx
   je semsorf2
   mov edx,[ptrt]
   cmp edx,ebx
   je semsorfp  
  ;regs
   mov edx,"alR"
   cmp edx,ebx
   je semsorfint
   mov edx,"ahR"
   cmp edx,ebx
   je semsorfint
   mov edx,"axR"
   cmp edx,ebx
   je semsorfint
   mov edx,"EAX"
   cmp edx,ebx
   je semsorfint
   mov edx,"blR"
   cmp edx,ebx
   je semsorfint
   mov edx,"bhR"
   cmp edx,ebx
   je semsorfint
   mov edx,"bxR"
   cmp edx,ebx
   je semsorfint
   mov edx,"EBX"
   cmp edx,ebx
   je semsorfint
   mov edx,"clR"
   cmp edx,ebx
   je semsorfint
   mov edx,"chR"
   cmp edx,ebx
   je semsorfint
   mov edx,"cxR"
   cmp edx,ebx
   je semsorfint
   mov edx,"ECX"
   cmp edx,ebx
   je semsorfint
   mov edx,"dlR"
   cmp edx,ebx
   je semsorfint
   mov edx,"dhR"
   cmp edx,ebx
   je semsorfint
   mov edx,"dxR"
   cmp edx,ebx
   je semsorfint
   mov edx,"EDX"
   cmp edx,ebx
   je semsorfint
   mov edx,"ESI"
   cmp edx,ebx
   je semsorfint
   mov edx,"EDI"
   cmp edx,ebx
   je semsorfint
  ;;;;STR
  semsorf2:
   call tonothing
  semsorf2str: 
   add ecx,3
   call clearflags
   call semread
   mov edx,[intt]
   cmp edx,ebx
   je semfinsorf2
   mov edx,[idt]
   cmp edx,ebx
   je sorfintid
  sorfintid:
   mov edx,0
   call readid2
   call getidtype
   mov bh,"o"
   mov bl,[sf]
   cmp bh,bl
   je error
   mov bl,[nf2]
   cmp bh,bl
   je error
   call clearflags
   jmp semfinsorf 
  semfinsorf2:
   call tonothing 
  semfinsorf:
   add ecx,3 ;rpr
   jmp semstts2
    ;call semread
   ;call trms
   ;sub ecx,3
   ;jmp semstts2
  semsorfid:
   mov edx,0
   call readid2
   call getidtype
   mov bh,"o"
   mov bl,[sf]
   cmp bh,bl
   je semsorf2str
   mov bh,"o"
   mov bl,[nf2]
   cmp bh,bl
   je semsorf2str
   call clearflags
   jmp semsorfint

  ;;;;INT
  semsorf2x:
   call tonothing
  semsorfint:
   add ecx,3 ;cma 
   call semread
   mov edx,[intt]
   cmp edx,ebx
   je semfinsorf2x
   mov edx,[idt]
   cmp edx,ebx
   je sorfintid2
  semfinsorf2x:
   call tonothing
  semfinsorf3: 
   add ecx,3 ;rpr
   jmp semstts
  sorfintid2:
   mov edx,0
   call readid2
   call getidtype
   mov bh,"o"
   mov bl,[sf]
   cmp bh,bl
   je error
   mov bl,[nf2]
   cmp bh,bl
   je error
   call clearflags
   jmp semfinsorf3 
  
  semsorfp:
   mov edx,0
   call readid2
   call getptrt
   mov bl,"o"
   mov bh,[iff]
   cmp bh,bl
   je semsorfint
   mov bh,[nf2]
   cmp bh,bl
   je error2
   mov bh,[sf]
   cmp bh,bl
   je semsorf2str 
 

 semtoint:
  mov bl,"z"
  mov [xf],bl
  call semread
  mov edx,[strt]
  cmp edx,ebx
  je fintoint 
  mov edx,[idt]
  cmp edx,ebx
  je tointid 
 fintoint:
  call tonothing
  add ecx,3
  jmp semstts
 tointid:
  mov edx,0
  call readid2
  call getidtype
  mov bl,"o"
  mov bh,[iff]
  cmp bh,bl
  je seme10
  mov bh,[nf2]
  cmp bh,bl 
  je seme10
  mov bl,"o"
  mov [chgf],bl
  mov bl,"i"
  mov [ntype],bl
  call getidtype
  call clearflags
  add ecx,3
  jmp semstts 

 semtostr:
   call semread
   call regs 
   mov edx,[intt]
   cmp edx,ebx
    je zint
   mov edx,[lpr]
   cmp edx,ebx
   je zlpr
   mov edx,[idt]
   cmp edx,ebx
   je tostrid
   mov edx,[ptrt]
   cmp edx,ebx
   je semptr2
 semfintostr:
  mov bl,"o"
  mov bh,[vnf]
  cmp bh,bl
  je semstts
  mov bh,[znf]
  cmp bh,bl
  je semstts
  mov bh,[fnf]
  cmp bh,bl
  je semstts
  mov edx,[semseqts]
  mov bl,[semtrack+edx]
  mov bh,"f"
  cmp bh,bl 
  je tof2 
  mov bh,"v"
  cmp bh,bl
  je varstrx
  mov bh,"z"
  cmp bh,bl
  je toz2 
  mov bh,"d"
  cmp bh,bl 
  je tod2 
  mov bh,"u"
  cmp bh,bl
  je tou2
 tostrid:
  mov edx,0
  call readid2
  call getidtype
  mov bl,"o"
  mov bh,[nf2]
  cmp bh,bl
  je seme9
  mov bh,[sf]
  cmp bh,bl
  je seme9
  call semread
  sub ecx,3
  mov edx,[endt]
  cmp edx,ebx
  jne zint2
  add ecx,3
  jmp semfintostr 
 

 semptr:
  mov edx,0
  call readid2
  call getptrt
  mov bl,"o"
  mov bh,[iff]
  cmp bh,bl
  je semstts
  mov bh,[nf2]
  cmp bh,bl
  je semstts2
  mov bh,[sf]
  cmp bh,bl
  je semstts2
  semptr2:
  mov edx,0
  call readid2
  call getptrt
  mov bl,"o"
  mov bh,[iff]
  cmp bh,bl
  jne error2 
  jmp semstts

 semregfunc:
  mov bl,"o"
  mov [regfunc],bl
  jmp semstart
 succxreg:
  mov bl,[regfunc]
  cmp bl,"z"
  je succ
  mov bl,"z"
  mov [regfunc],bl
  sub ecx,3
  mov [semco2],ecx
  jmp addvar

 regs:
  mov edx,[byt]
  cmp edx,ebx
  je zbwd
  mov edx,[wrd]
   cmp edx,ebx
  je zbwd
  mov edx,[dwr]
  cmp edx,ebx
  je zbwd 
  mov eax,alfs
  mov edx,"alR"
  cmp edx,ebx
  je regz
  add eax,2
  mov edx,"ahR"
  cmp edx,ebx
  je regz
  add eax,2
  mov edx,"axR"
  cmp edx,ebx
  je regz
  add eax,2
  mov edx,"EAX"
  cmp edx,ebx
  je regz
  add eax,2
  mov edx,"blR"
  cmp edx,ebx
  je regz
  add eax,2
  mov edx,"bhR"
  cmp edx,ebx
  je regz
  add eax,2
  mov edx,"bxR"
  cmp edx,ebx
  je regz
  add eax,2
  mov edx,"EBX"
  cmp edx,ebx
  je regz
  add eax,2 
  mov edx,"clR"
  cmp edx,ebx
  je regz
  add eax,2
  mov edx,"chR"
  cmp edx,ebx
  je regz
  add eax,2
  mov edx,"cxR"
  cmp edx,ebx
  je regz
  add eax,2
  mov edx,"ECX"
  cmp edx,ebx
  je regz
  add eax,2
  mov edx,"dlR"
  cmp edx,ebx
  je regz
  add eax,2
  mov edx,"dhR"
  cmp edx,ebx
  je regz
  add eax,2
  mov edx,"dxR"
  cmp edx,ebx
  je regz
  add eax,2
  mov edx,"EDX"
  cmp edx,ebx
  je regz
  add eax,2
  mov edx,"ESI"
  cmp edx,ebx
  je regz
  add eax,2
  mov edx,"EDI"
  cmp edx,ebx
  je regz
  ret  

 zbwd:
  call semread
  mov edx,[aod]
  cmp edx,ebx 
  je zaod
  mov edx,[lpr]
  cmp edx,ebx
  je zlpr
 regz:
  push eax
  call semread
  pop eax
  mov edx,[equt]
  cmp edx,ebx
  je defreg
  sub ecx,3
  mov dl,[eax]
  mov dh,"i"
  cmp dl,dh
  je zint2
  mov dh,"v"
  cmp dl,dh
  je regz2
  mov dh,"s"
  cmp dl,dh
  je zstrt2
  jmp zint2
 regz2:
  add eax,1
  mov dl,[eax]
  mov dh,"i"
  cmp dl,dh
  je zint2
  mov dh,"v"
  cmp dl,dh
  je regz2
  mov dh,"s"
  cmp dl,dh
  je zstrt2
  jmp zint2 
 defreg:
  mov dh,[eax]
  mov dl,"v"
  mov [eax],dl
  add eax,1
  mov [eax],dh
  mov edx,[semseqts]
  add edx,1 
  mov al,"v"
  mov [semtrack+edx],al
  mov [semseqts],edx 
  mov edx,0 
  mov [semco2],ecx
  jmp semvar2

 ;;;;;;;;;;DEFREGS;;;;;;;;;;;;
  ;checks if a register is being given a value
  chkregsv:
  mov ebx,alfs
  mov dl,[ebx]
  cmp dl,"v"
  je assignreg1
  mov ebx,ahfs
  mov dl,[ebx]
  cmp dl,"v"
  je assignreg1
  mov ebx,axfs
  mov dl,[ebx]
  cmp dl,"v"
  je assignreg2
  mov ebx,eaxfs
  mov dl,[ebx]
  cmp dl,"v"
  je assignreg3
  mov ebx,blfs
  mov dl,[ebx]
  cmp dl,"v"
  je assignreg1
  mov ebx,bhfs
  mov dl,[ebx]
  cmp dl,"v"
  je assignreg1
  mov ebx,bxfs
  mov dl,[ebx]
  cmp dl,"v"
  je assignreg2
  mov ebx,ebxfs
  mov dl,[ebx]
  cmp dl,"v"
  je assignreg3
  mov ebx,clfs
  mov dl,[ebx]
  cmp dl,"v"
  je assignreg1
  mov ebx,chfs
  mov dl,[ebx]
  cmp dl,"v"
  je assignreg1
  mov ebx,cxfs
  mov dl,[ebx]
  cmp dl,"v"
  je assignreg2
  mov ebx,ecxfs
  mov dl,[ebx]
  cmp dl,"v"
  je assignreg3
  mov ebx,dlfs
  mov dl,[ebx]
  cmp dl,"v"
  je assignreg1
  mov ebx,dhfs
  mov dl,[ebx]
  cmp dl,"v"
  je assignreg1
  mov ebx,dxfs
  mov dl,[ebx]
  cmp dl,"v"
  je assignreg2
  mov ebx,edxfs
  mov dl,[ebx]
  cmp dl,"v"
  je assignreg3
  mov ebx,esifs
  mov dl,[ebx]
  cmp dl,"v"
  je assignreg
  mov ebx,edifs
  mov dl,[ebx]
  cmp dl,"v"
  je assignreg
  jmp addvar2a
  
  assignreg1:
  mov dl,[pf]
  cmp dl,"o"
  je assignaod1 
  mov dl,[sf]
  cmp dl,"o"
  je assignstr1
  mov dl,"i"
  mov [ebx],dl
  add ebx,3
  mov [ebx],dl
  add ebx,2
  mov [ebx],dl
  jmp endvar
  assignaod1:
  mov dl,"a"
  mov [ebx],dl
  add ebx,3
  mov [ebx],dl
  add ebx,2
  mov [ebx],dl 
  jmp endvar
  assignstr1:
  mov dl,"s"
  mov [ebx],dl
  add ebx,3
  mov [ebx],dl
  add ebx,2
  mov [ebx],dl 
  jmp endvar

  assignreg2:
  mov dl,[pf]
  cmp dl,"o"
  je assignaod2
  mov dl,[sf]
  cmp dl,"o"
  je assignstr2
  mov dl,"i"
  mov [ebx],dl
  add ebx,2
  mov [ebx],dl
  sub ebx,4;5
  mov [ebx],dl
  sub ebx,2
  mov [ebx],dl
  jmp endvar
  assignaod2:
  mov dl,"a"
  mov [ebx],dl
  add ebx,2
  mov [ebx],dl
  sub ebx,5
  mov [ebx],dl
  sub ebx,2
  mov [ebx],dl
  jmp endvar
  assignstr2:
  mov dl,"s"
  mov [ebx],dl
  add ebx,2
  mov [ebx],dl
  sub ebx,5
  mov [ebx],dl
  sub ebx,2
  mov [ebx],dl
  jmp endvar
 
  assignreg3:
  mov dl,[pf]
  cmp dl,"o"
  je assignaod3
  mov dl,[sf]
  cmp dl,"o"
  je assignstr3
  mov dl,"i"
  mov [ebx],dl
  sub ebx,2
  mov [ebx],dl
  sub ebx,2;5
  mov [ebx],dl
  sub ebx,2
  mov [ebx],dl
  jmp endvar
  assignaod3:
  mov dl,"a"
  mov [ebx],dl
  sub ebx,2
  mov [ebx],dl
  sub ebx,2;5
  mov [ebx],dl
  sub ebx,2
  mov [ebx], dl
  jmp endvar 
  assignstr3:
  mov dl,"s"
  mov [ebx],dl
  sub ebx,2
  mov [ebx],dl
  sub ebx,2;5
  mov [ebx],dl
  sub ebx,2
  mov [ebx],dl
  jmp endvar
   
  assignreg:
  mov dl,[pf]
  cmp dl,"o"
  je assignaod 
  mov dl,[sf]
  cmp dl,"o"
  je assignstr
  mov dl,"i"
  mov [ebx],dl
  ret 
  assignaod:
  mov dl,"a" 
  mov [ebx],dl
  ret  
  assignstr:
  mov dl,"s"
  mov [ebx],dl
  ret 
   
;;;;;;;;;;;;;;;;;VAR;;;;;;;;;;;;;;;;
 semvar:
  mov edx,[semseqts]
  add edx,1
  mov al,"v"
  mov [semtrack+edx],al
  mov [semseqts],edx 
  mov edx,0
  call readvar
  mov [semco2],ecx  
  mov eax,0
  mov edx,0
  call chkvar
 semvar2:
  call semread
  call varregs
  mov edx,"REG"
  cmp edx,ebx 
  je semregfunc
  mov edx,[ptrt]
  cmp edx,ebx
  je varptr
  mov edx,[aru]
  cmp edx,ebx
  je varint
  mov edx,[fcl]
  cmp edx,ebx
  je semfcl
  mov edx,[aod]
  cmp edx,ebx
  je varaod
  mov edx,[intt]
  cmp edx,ebx
  je varint
  mov edx,[strt2]
  cmp edx,ebx
  je semtostr
  mov edx,[fcl]
  cmp edx,ebx
  je semfcl
  mov edx,[lpr]
  cmp edx,ebx
  je varlpr 
  mov edx,[flt]
  cmp edx,ebx
  je varint
  mov edx,[pls]
  cmp edx,ebx
  je varop
  mov edx,[min]
  cmp edx,ebx
  je varop 
  mov edx,[negt]
  cmp edx,ebx
  je varop
  mov edx,[nott]
  cmp edx,ebx
  je varop2
  mov edx,[intt2]
  cmp edx,ebx 
  je var2nt 
  mov edx,[true]
  cmp edx,ebx
  je varint 
  mov edx,[false]
  cmp edx,ebx
  je varint 
  mov edx,[strt]
  cmp edx,ebx
  je varstr 
  mov edx,[idt]
  cmp edx,ebx 
  je varid2
  mov edx,[npt]
  cmp edx,ebx
  je var_input
  mov edx,[null]
  cmp edx,ebx
  je varnull
  mov edx,[rolf]
  cmp edx,ebx
  je varsorf
  mov edx,[shrf]
  cmp edx,ebx
  je varsorf
  mov edx,[shlf]
  cmp edx,ebx
  je varsorf
  mov edx,[rorf]
  cmp edx,ebx
  je varsorf 
  mov edx,[shrt]
  cmp edx,ebx 
  je semvarsor
  mov edx,[rort] 
  cmp edx,ebx 
  je semvarsor
  mov edx,[rolt] 
  cmp edx,ebx
  je semvarsor
  mov edx,[shlt] 
  cmp edx,ebx
  je semvarsor
  mov edx,[bit]
  cmp edx,ebx 
  je semvarbit
  mov edx,[byt]
  cmp edx,ebx
  je semvar2
  mov edx,[wrd]
  cmp edx,ebx
  je semvar2
  mov edx,[dwr]
  cmp edx,ebx
  je semvar2
  jmp error2 

 varsorf:
  mov bl,"o"
  mov [vfi],bl
  jmp semsorf
 semvarsor:
  call semread ;int
  call tonothing; 
  call semread;dots 
  call semread 
  mov edx,[aod]
  cmp edx,ebx
  je varaod
  mov edx,[intt]
  cmp edx,ebx
  je varint
  mov edx,[strt2]
  cmp edx,ebx
  je semtostr
  mov edx,[fcl]
  cmp edx,ebx
  je semfcl
  mov edx,[lpr]
  cmp edx,ebx
  je varlpr 
  mov edx,[flt]
  cmp edx,ebx
  je varint
  mov edx,[pls]
  cmp edx,ebx
  je varop
  mov edx,[min]
  cmp edx,ebx
  je varop 
  mov edx,[negt]
  cmp edx,ebx
  je varop
  mov edx,[nott]
  cmp edx,ebx
  je varop2
  mov edx,[intt2]
  cmp edx,ebx 
  je var2nt 
  mov edx,[true]
  cmp edx,ebx
  je varint 
  mov edx,[false]
  cmp edx,ebx
  je varint 
  mov edx,[strt]
  cmp edx,ebx
  je varstr 
  mov edx,[idt]
  cmp edx,ebx 
  je varid2
  mov edx,[npt]
  cmp edx,ebx
  je var_input
  jmp error2

 varptr:
  mov edx,0
  call readid2
  call getptrt
  mov bh,"o"
  mov [aruf],bh
  mov bl,[iff]
  cmp bh,bl
  je varint
  mov bl,"z"
  mov [aruf],bl
  mov bl,[sf]
  cmp bh,bl
  je varstrx
  mov bl,[nf2]
  cmp bh,bl
  je varnull
  jmp error2
 
 semvarbit:
  mov bl,"o"
  mov [iff],bl
  call addvar 

 ;Define a pointer 
 varaod:
  mov edx,0
  call readid2
  call getidtype
  mov bl,[iff]
  cmp bl,"o"
  je varaodi 
  mov bl,[sf]
  cmp bl,"o"
  je varaods
  jmp varaodn
 varaodx: 
  call semread
  mov edx,[trm]
  cmp edx,ebx
  je varaod2
  mov bl,"o"
  mov [vcf],bl
  jmp varint
 varaod2:
  mov bl,"o"
  mov [pf],bl
  call defptr

 varaodi:
  mov bl,"i"
  mov [pfi],bl
  jmp varaodx
 varaods:
  mov bl,"s"
  mov [pfi],bl
  jmp varaodx
 varaodn:
  mov bl,"n"
  mov [pfi],bl
  jmp varaodx 
 
 varid2:
  mov edx,0
  mov [stackc],ecx
  call readid2 
  call getidtype 
  mov bl,"o"
  mov bh,[sf]
  cmp bh,bl 
  je var_idstr
  mov bh,[nf2]
  cmp bh,"o"
  je varnull 
  mov [idfsem],bl
  jmp varint 

 varint:
  mov bl,"o"
  mov [iff],bl
  mov bl,"z"
  mov [sf],bl
  mov [nf2],bl 
  jmp addvar

 var2nt:
  mov bl,"o"
  mov [xf],bl 
  jmp varint

 varlpr:
  mov bl,"o"
  mov [lf],bl 
  jmp varint 

 varop:
  mov bl,"o"
  mov [of],bl
  jmp varint  
 varop2:
  mov bl,"o"
  mov [vnf],bl
  jmp varint

 varstr:
  call tonothing
 varstrx: 
  call semread 
  mov edx,[trm]
  cmp edx,ebx 
  je varstr2
  mov bl,"o"
  mov [vcf],bl
  jmp varint 
 varstr2:
  mov bl,"z"
  mov [iff],bl
  mov [nf2],bl
  mov bl,"o"
  mov [sf],bl
  jmp addvar 

 var_input:
  mov bl,"z"
  mov [iff],bl
  mov [nf2],bl 
  mov bl,"o"
  mov [sf],bl
  jmp addvar 
 
 varnull: 
  call semread
  mov edx,[trm]
  cmp edx,ebx
  je varnull2 
  sub ecx,3
  jmp varint
 varnull2:
  mov bl,"o"
  mov [nf2],bl 
  call addvar 

 var_idstr:
  call semread
  mov edx,[trm]
  cmp edx,ebx 
  je varstr3
  call strerrors
  mov bl,"o"
  mov [vcf],bl
  jmp varint
 varstr3:
  mov bl,"o"
  mov [sf],bl 
  mov bl,"z"
  mov [iff],bl
  mov [nf2],bl
  call addvar 

 
 addvar:
  mov bl,"o"
  mov bh,[fdfi]
  cmp bh,bl
  je addvarfdf
  mov [vf],bl
  jmp chkregsv
  addvar2a:
  mov eax,[varseq]
  mov bh,"|"
  mov edx,0
 addvar2:
  mov bl,BYTE[varid+edx]
  mov [vars+eax],bl 
  add eax,1
  add edx,1 
  cmp bh,bl 
  je finaddvar
  jmp addvar2 
 finaddvar:
  mov [varseq],eax
  mov eax,[varseq]
  mov bl,"o"
  mov bh,[iff]
  cmp bh,bl 
  je varisint 
  mov bh,[nf2]
  cmp bh,bl
  je varisnull
  mov dx,"s;"
  mov [vars+eax],dx
  add eax,2 
  mov [varseq],eax
  jmp endvar
 varisint:
  mov dx,"i;"
  mov [vars+eax],dx
  add eax,2 
  mov [varseq],eax
  jmp endvar2
 varisnull:
  mov edx,"n;"
  mov [vars+eax],edx
  add eax,2 
  mov [varseq],eax
  jmp endvar2

 addvarfdf:
  mov eax,0
  mov edx,[ftempc]
  addvarfdf2:
  mov bl,[varid+eax]
  mov [ftemp+edx],bl
  cmp bl,"|"
  je addvarfdf3
  add eax,1
  add edx,1 
  jmp addvarfdf2
  addvarfdf3:
  add edx,1
  mov [ftempc],edx
  jmp finaddvar

 defptr:
  call chkregsv
  mov eax,[ptrseq]
  mov bh,"|"
  mov edx,0
  defptr2:
  mov bl,BYTE[varid+edx]
  mov [ptrvar+eax],bl 
  mov [ptrseq],eax
  add eax,1
  add edx,1 
  cmp bh,bl 
  je endptrdef
  jmp defptr2 
  endptrdef:
  mov bl,[pfi]
  mov bh,"i"
  cmp bh,bl
  je ptrint 
  mov bl,[pfi]
  mov bh,"s"
  cmp bh,bl
  je ptrstr
  mov bl,[pfi]
  mov bh,"n"
  cmp bh,bl
  je ptrnull
  mov bx,"i;"
  call addptr3 
  ptrint:
  mov bx,"i;"
  call addptr3
  ptrstr:
  mov bx,"s;"
  call addptr3 
  ptrnull:
  mov bx,"n;" 
  call addptr3 
 addptr3: 
  mov [ptrvar+eax],bx
  add eax,1 
  mov [ptrseq],eax
  jmp endvar 

 endvar:
  mov bh,[vf]
  cmp bh,"o" 
  jne varint
 endvar2: 
  mov edx,[semseqts]
  mov bl,0
  mov [semtrack+edx],bl 
  sub edx,1
  mov [semseqts],edx
  mov bl,"z"
  mov [vf],bl
  mov [vcf],bl
  mov [iff],bl
  mov [sf],bl
  mov [vnf],bl
  mov [vfi],bl
  mov [nf2],bl
  mov [lf],bl 
  mov [pf],bl 
  mov [xf],bl
  mov [semfb],bl
  mov ecx,[semco2]
  jmp semstart


 readvar:
  mov bl,BYTE[CISYN+ecx]
  mov bh,"|"
  cmp bh,bl
  jne readvar2
  mov [varid+edx],bl 
  add ecx,1
  ret 
  readvar2:
  mov [varid+edx],bl 
  add edx,1
  add ecx,1
  jmp readvar 

 chkvar: ;eax,0  
  mov bl,BYTE[vars+eax]
  mov bh,BYTE[varid+edx]
  cmp bh,bl 
  jne chkvar2
  add edx,1
  add eax,1
  mov bh,"|"
  cmp bh,bl 
  je seme5
  jmp chkvar 
  chkvar2: 
  mov bh,0
  add eax,1
  mov bl,BYTE[vars+eax]
  cmp bh,bl
  je semvar2 
  mov edx,0
  chkvar3:
  mov bh,";"
  mov bl,BYTE[vars+eax]
  cmp bh,bl 
  je chkvar
  mov bh,0
  cmp bh,bl
  je semvar2
  add eax,1
  jmp chkvar3
 
 ;if x=func() and func return int
 int_chkvflag:
  mov bl,[vf]
  mov bh,"o"
  cmp bh,bl 
  je tov 
  jmp varint
 ;if it returns string
 str_chkvflag:
  mov bl,[vf]
  mov bh,"o"
  cmp bh,bl 
  je chknf
  jmp varstrx
  
 ;check for NOT flag (if not instruction is used)
 chknf:
  mov bl,[vnf]
  mov bh,"o"
  cmp bh,bl
  je tov
  jmp varstr2

 chkvf2: 
  mov bl,[vf]
  mov bh,"o"
  cmp bh,bl
  je endvar
  sub ecx,3
  jmp varint
 
varregs:
 mov eax,alfs
 mov edx,"alR"
 cmp edx,ebx
 je regvar
 add eax,2
 mov edx,"ahR"
 cmp edx,ebx
 je regvar
 add eax,2
 mov edx,"axR"
 cmp edx,ebx
 je regvar
 add eax,2
 mov edx,"EAX"
 cmp edx,ebx
 je regvar
 add eax,2
 mov edx,"blR"
 cmp edx,ebx
 je regvar
 add eax,2
 mov edx,"bhR"
 cmp edx,ebx
 je regvar
 add eax,2
 mov edx,"bxR"
 cmp edx,ebx
 je regvar
 add eax,2
 mov edx,"EBX"
 cmp edx,ebx
 je regvar
 add eax,2
 mov edx,"clR"
 cmp edx,ebx
 je regvar
 add eax,2
 mov edx,"chR"
 cmp edx,ebx
 je regvar
 add eax,2
 mov edx,"cxR"
 cmp edx,ebx
 je regvar
 add eax,2
 mov edx,"ECX"
 cmp edx,ebx
 je regvar
 add eax,2
 mov edx,"dlR"
 cmp edx,ebx
 je regvar
 add eax,2
 mov edx,"dhR"
 cmp edx,ebx
 je regvar
 add eax,2
 mov edx,"dxR"
 cmp edx,ebx
 je regvar
 add eax,2
 mov edx,"EDX"
 cmp edx,ebx
 je regvar
 add eax,2
 mov edx,"ESI"
 cmp edx,ebx
 je regvar
 add eax,2
 mov edx,"EDI"
 cmp edx,ebx
 je regvar
 ret
regvar:
 mov dl,"o"
 mov [regf],dl
 mov dl,[eax]
 cmp dl,"i"
 je varint
 cmp dl,"a"
 je varaodx
 cmp dl,"s"
 je varstrx
 add eax,1
 jmp regvar

setgvarseq:
 mov edx,0
 mov eax,[gvseqc]
 setgvarseq2:
 mov bl,byte[varid+edx]
 mov [gidseq+eax],bl
 cmp bl,"|"
 je setgvarseq3
 add edx,1
 add eax,1
 setgvarseq3:
 add eax,1
 mov edx,[stackc]
 mov [gidseq+eax],edx
 add edx,8 
 mov [stackc],edx
 add eax,4
 mov bl,";"
 mov [gidseq+eax],bl
 add eax,1
 mov [gvseqc],eax
 ret
 
;;;;;;;;;;;;;;;;ARD;;;;;;;;;;;;;
 semard: ;when read ard
  mov edx,[semseqts]
  mov eax,"d"
  add edx,1
  mov [semtrack+edx],eax
  mov [semseqts],edx
  mov edx,0 
  call readid2
  mov edx,0 
  mov eax,0
  call ardchk
 semard2:
  mov edx,0
  mov eax,[ardc]
  mov bh,"|"
  call putard 
 ardef1:
  call semread
  call chk
  call sors 
  call regs 
  mov edx,[intt] 
  cmp edx,ebx
  je zint 
  mov edx,[flt] 
  cmp edx,ebx
  je zint 
  mov edx,[strt]
  cmp edx,ebx
  je zstrt 
  mov edx,[true]
  cmp edx,ebx
  je zint2
  mov edx,[false]
  cmp edx,ebx
  je zint2
  call z_ops
  mov edx,[idt]
  cmp edx,ebx
  je zidt 
  mov edx,[lpr]
  cmp edx,ebx
  je zlpr 
  mov edx,[fcl]
  cmp edx,ebx
  je semfcl
  mov edx,[null]
  cmp edx,ebx
  je zstrt2
  mov edx,[aru]
  cmp edx,ebx
  je semaru
  mov edx,[ptrt]
  cmp edx,ebx
  je semptr
  call sorfs
  jmp error2

 semfinard:
  mov edx,[semseqts]
  mov eax,0
  mov [semtrack+edx],eax
  sub edx,1
  mov [semseqts],edx
  ;add ecx,3 ;trm
  jmp semstart

 ardchk:
  mov bl,BYTE[defard+eax]
  mov bh,BYTE[idv+edx]
  cmp bh,bl
  jne ardchk2 
  add edx,1
  add eax,1
  mov bh,"|"
  cmp bh,bl 
  je seme13 
  jmp ardchk
  ardchk2:
  mov bh,0
  add eax,1
  mov bl,BYTE[defard+eax]
  cmp bh,bl
  je semard2 
  mov edx,0
  ardchk3:
  mov bh,"|"
  mov bl,BYTE[defard+eax]
  cmp bh,bl 
  je ardchk
  mov bh,0
  cmp bh,bl
  je semard2
  add eax,1
  jmp ardchk3

 putard:
  mov bl,[idv+edx]
  mov [defard+eax],bl
  cmp bh,bl
  jne putard2
  add eax,1
  mov [ardc],eax
  jmp ardef1
  putard2:
  add eax,1 
  add edx,1 
  jmp putard
 
;;;;;;;;;;;;;;;FCL;;;;;;;;;;;;;;
 semfcl:
  mov dl,[fcf]
  cmp dl,"o"
  je fcltofcl
 semfcl2:
  mov dl,"o"
  mov [fcf],dl ;used in case a func was called inside a func call k(f())
  mov edx,0
  mov [parcount],edx ;parcount of the func call
  mov edx,[semseqts]
  add edx,1
  mov eax,"f"
  mov [semtrack+edx],eax
  mov [semseqts],edx
  mov edx,0
  call readid2 ;read id of func 
  mov edx,0
  mov eax,0
  call chkfcl ;check if the function exists
  call semread 
  mov edx,[fce] ;if it has no arguments
  cmp edx,ebx
  je endfcl0
  sub ecx,3
 fclsem2:
  call semread
  call regs 
  mov edx,[intt] 
  cmp edx,ebx
  je zint 
  mov edx,[flt] 
  cmp edx,ebx
  je zint 
  mov edx,[strt]
  cmp edx,ebx
  je zstrt 
  mov edx,[true]
  cmp edx,ebx
  je zint2
  mov edx,[false]
  cmp edx,ebx
  je zint2
  call z_ops
  mov edx,[idt]
  cmp edx,ebx
  je zidt 
  mov edx,[lpr]
  cmp edx,ebx
  je zlpr 
  mov edx,[fcl]
  cmp edx,ebx
  je semfcl
  mov edx,[null]
  cmp edx,ebx
  je zstrt2
  mov edx,[aru]
  cmp edx,ebx
  je semaru
  mov edx,[ptrt]
  cmp edx,ebx
  je semptr
  call sors
  call sorfs
  mov edx,[intt2]
  cmp edx,ebx
  je semtoint
  mov edx,[strt2]
  cmp edx,ebx
  je semtostr 
  mov edx,[ptrt]
  cmp edx,ebx
  je semptr   
  mov edx,[fce]
  cmp edx,ebx
  je endfcl 
  mov edx,[cma]
  cmp edx,ebx
  je addpar
  jmp error2
 
 ;if u call a function inside a function call k(f()) 
 ;it pushes parcount, parcount2,fdfcount and rtype
 ;using stack2 and its counter (semstack)
 fcltofcl:
  mov dl,"o"
  mov [fcfc],dl
  mov eax,[semstack]
  mov edx,[rtype]  
  mov [stack2+eax],edx
  add eax,4
  mov edx,[parcount2]  
  mov [stack2+eax],edx
  add eax,4 
  mov edx,[parcount]  
  mov [stack2+eax],edx
  add eax,4 
  mov edx,[fdfcount]  
  mov [stack2+eax],edx
  add eax,4  
  mov [semstack],eax
  mov edx,0
  mov [parcount],edx
  mov [parcount2],edx
  jmp semfcl2

 fcltofcl2:;end
  mov bh,[rtype] ;get the return type of the function f (from our example k(f())  )
  mov eax,[semstack]
  sub eax,4
  mov edx,[stack2+eax]
  mov [fdfcount],edx 
  sub eax,4 
  mov edx,[stack2+eax]
  mov [parcount],edx 
  sub eax,4
  mov edx,[stack2+eax]
  mov [parcount2],edx 
  sub eax,4
  mov edx,[stack2+eax]
  mov [rtype],edx  
  mov [semstack],eax
  ;pop the parcount, parcount2, fdfcount and rtype of the func k (from example k(f())  )
  mov bl,"s"
  cmp bh,bl
  je tof2 ;if function f returns a string
  jmp tof ; if function f returns an int

 ;if the called function is used with math k(1+f()) 
 fcltofcl3:
  mov dl,"o"
  mov [fcfc],dl
  mov eax,[semstack]
  mov edx,[rtype]  
  mov [stack2+eax],edx
  add eax,4
  mov edx,[parcount2]  
  mov [stack2+eax],edx
  add eax,4 
  mov edx,[parcount]  
  mov [stack2+eax],edx
  add eax,4 
  mov edx,[fdfcount]  
  mov [stack2+eax],edx
  add eax,4  
  mov [semstack],eax
  mov edx,0
  mov [parcount],edx
  mov [parcount2],edx
  jmp zfclint

 ;add 1 to the arguments counter
 addpar:
  mov eax,[parcount]
  add eax,1
  mov [parcount],eax
  jmp fclsem2 

 ;when it reads FCE 
 endfcl0:
  mov edx,[parcount]
  sub edx,1
  mov [parcount],edx
 endfcl:
  mov edx,DWORD[parcount]
  add edx,1
  mov eax,DWORD[parcount2]
  cmp edx,eax
  jne chkfdfdf4
 endfcl3:
  mov eax,[fdfcount2]
  mov [fdfcount],eax
  mov dl,"z"
  mov [fcf],dl
  mov edx,[semseqts]
  mov bl,0
  mov [semtrack+edx],bl 
  sub edx,1
  mov [semseqts],edx
  mov bh,[rf]
  mov bl,"o"
  cmp bh,bl
  je fcltoret
  mov bl,"f"
  mov bh,[semtrack+edx]
  cmp bh,bl
  je fcltofcl2
  mov bl,"z"
  cmp bh,bl
  je fcltoz
  mov bl,"v"
  cmp bh,bl
  je fcltov
  mov bl,"d"
  cmp bh,bl
  je fcltod
  mov bl,"u"
  cmp bh,bl
  je fcltou 
  jmp semstts 

 fcltoz:
  mov bh,[rtype]
  mov bl,"i"
  cmp bh,bl 
  je toz
  mov bl,"s"
  cmp bh,bl
  je toz2
  jmp toz 
 fcltov:
  mov bl,[rtype]
  mov bh,"i"
  cmp bh,bl
  je int_chkvflag
  mov bh,"s"
  cmp bh,bl
  je str_chkvflag
  jmp int_chkvflag
 fcltod:
  mov bl,[rtype]
  mov bh,"i"
  cmp bh,bl
  je tod
  mov bh,"s"
  cmp bh,bl
  je tod2
  jmp tod
 fcltou:
  mov bl,[rtype]
  mov bh,"i"
  cmp bh,bl
  je tou
  mov bh,"s"
  cmp bh,bl
  je tou2
  jmp tou
 fcltoret:
  mov bh,[rtype]
  mov bl,"i"
  cmp bh,bl 
  je retint4
  mov bl,"s"
  cmp bh,bl
  je retchkstr2
  jmp retint4 
  

 chkfcl:
  mov bl,BYTE[funcs+eax]
  mov bh,BYTE[idv+edx]
  cmp bh,bl
  jne chkfcl2 
  add edx,1
  add eax,1
  mov bh,"|"
  cmp bh,bl 
  je getfclpar
  jmp chkfcl
 chkfcl2:
  mov edx,0
  mov bh,";"
  mov bl,BYTE[funcs+eax]
  cmp bh,bl 
  je chkfcl3
  cmp bl,0
  je chkfcl3
  add eax,1
  jmp chkfcl2
 chkfcl3:
  add eax,1
  mov bl,BYTE[funcs+eax] 
  mov bh,0
  cmp bh,bl
  je chkfdfdf 
  jmp chkfcl

 ;get the number of arguments for the function 
 getfclpar:
  mov edx,[funcs+eax] ;pars
  mov [parcount2],edx
  add eax,4 
  mov bl,[funcs+eax]
  mov [rtype],bl 
  ret
 
;;;;;;;;;;;;;;;;ARU;;;;;;;;;;;;;;;;
 semaru:
  mov edx,[semseqts]
  add edx,1
  mov eax,"u"
  mov [semtrack+edx],eax
  mov [semseqts],edx
  mov edx,0
  call readid2
  mov edx,0
  mov eax,0
  call chkaru
 arusem2:
  call semread
  call regs
  mov edx,[intt]
  cmp edx,ebx 
  je zint 
  mov edx,[flt]
  cmp edx,ebx
  je zint
  mov edx,[strt]
  cmp edx,ebx 
  je zstrt 
  mov edx,[idt]
  cmp edx,ebx 
  je zidt
  call z_ops
  mov edx,[are]
  cmp edx,ebx 
  je finaru 
  mov edx,[lpr]
  cmp edx,ebx
  je zlpr
  mov edx,[null]
  cmp edx,ebx
  je zstrt2
  mov edx,[true]
  cmp edx,ebx
  je zint2
  mov edx,[false]
  cmp edx,ebx
  je zint2
  mov edx,[fcl]
  cmp edx,ebx
  je semfcl
  mov edx,[aod]
  cmp edx,ebx
  je zaod
  mov edx,[aru]
  cmp edx,ebx
  je semaru 
  mov edx,[seqend]
  cmp edx,ebx
  je semseqend
  mov edx,[ptrt]
  cmp edx,ebx 
  je semptr    
  jmp error2  
 
 chkaue:
  mov bh,"o"
  mov bl,[zcf]
  cmp bh,bl
  je semfinaru 
  jmp error2
 chkaue2:
  mov bh,"o"
  mov bl,[zcf]
  cmp bh,bl
  je zrpr
  jmp error2  
  
 semfinaru:
  mov edx,[semseqts]
  mov eax,0
  mov [semtrack+edx],eax
  sub edx,1
  mov [semseqts],edx
  mov bh,[rf]
  cmp bh,"o"
  je retint4
  jmp semstts 

 chkaru:
  mov bl,BYTE[defard+eax]
  mov bh,BYTE[idv+edx]
  cmp bh,bl
  jne chkaru2 
  add edx,1
  add eax,1
  mov bh,"|"
  cmp bh,bl 
  je arusem2
  jmp chkaru
  chkaru2:
  mov bh,0
  add eax,1
  mov bl,BYTE[defard+eax]
  cmp bh,bl
  je chkarfdf
  mov edx,0
  chkaru3:
  mov bh,"|"
  mov bl,BYTE[defard+eax]
  cmp bh,bl 
  je chkaru
  mov bh,0
  cmp bh,bl
  je chkarfdf
  add eax,1
  jmp chkaru3 
 
;;;;;;;;;;;;;;;;FDF;;;;;;;;;;;;;VARx212|INT2334|PLS
 semfdf:
 mov eax,0
 mov [ftempc],eax
 mov bl,"o"
 mov [fdff],bl
 add ecx,3
 mov edx,0
 call readid2
 mov edx,0
 mov eax,0
 call chkfdf 
 fdfsem2: 
 call semread
 mov edx,[idt]
 cmp edx,ebx 
 je argok
 mov edx,[cma]
 cmp edx,ebx
 je fdfsem2
 mov edx,[got];started func 
 cmp edx,ebx
 je finfdf
 mov edx,[ter]
 cmp edx,ebx
 je finfdf
 mov edx,[newt]
 cmp edx,ebx
 je finfdfnl 
 jmp error2 

 argok:
 mov edx,0
 mov eax,0
 call readid ;read the id
 call saveftemp ;put it in ftemp (temporary argument holder)
 mov edx,[argc]
 add edx,1
 mov [argc],edx
 mov bl,"o"
 mov [fdfi],bl
 jmp fdfsem2

 finfdfnl:
 mov edx,[newc]
 add edx,1
 mov [newc],edx
 finfdf: 
 mov edx,[fncsc]
 mov bh,0
 mov eax,0
 putfid:;mov idv to funcs
 mov bl,BYTE[idv+eax]
 cmp bl,bh
 je putfid2
 mov [funcs+edx],bl 
 add edx,1
 add eax,1
 jmp putfid
 putfid2:;add argc to funcs
 mov [fncsc],edx
 mov eax,[fncsc]
 mov edx,[argc]
 mov [funcs+eax],edx
 putfid3: ;chk where is end of agrc
 add eax,4
 mov [fncsc],eax
 jmp succ

 chkfdf:
 mov bl,BYTE[funcs+eax]
 mov bh,BYTE[idv+edx]
 cmp bh,bl
 jne chkfdf2 
 add edx,1
 add eax,1
 mov bh,"|"
 cmp bh,bl 
 je seme8 
 jmp chkfdf
 chkfdf2:
 mov bh,0
 add eax,1
 mov bl,BYTE[funcs+eax]
 cmp bh,bl
 je fdfsem2 
 mov edx,0
 chkfdf3:
 mov bh,"|"
 mov bl,BYTE[funcs+eax]
 cmp bh,bl 
 je chkfdf
 mov bh,0
 cmp bh,bl
 je fdfsem2
 add eax,1
 jmp chkfdf3 

 fdfret:
 mov bl,"o"
 mov [rf],bl
 ;mov [eofdf],bl
 call semread
 mov edx,[aru]
 cmp edx,ebx
 je semaru
 mov edx,[intt]
 cmp edx,ebx
 je retint 
 mov edx,[strt]
 cmp edx,ebx
 je retchkstr
 mov edx,[true]
 cmp edx,ebx
 je retint
 mov edx,[false]
 cmp edx,ebx
 je retint 
 mov edx,[null]
 cmp edx,ebx
 je retchknull 
 mov edx,[idt]
 cmp edx,ebx
 je retchkid
 mov edx,[aru]
 cmp edx,ebx
 je retaru
 mov edx,[lpr]
 cmp edx,ebx
 je retlpr
 mov edx,[min]
 cmp edx,ebx
 je retint2
 mov edx,[pls]
 cmp edx,ebx
 je retint2
 mov edx,[negt]
 cmp edx,ebx
 je retint2
 mov edx,[nott]
 cmp edx,ebx
 je retint3
 mov edx,[fcl]
 cmp edx,ebx
 je semfcl
 mov edx,[ptrt]
 cmp edx,ebx
 je retptr   
 mov edx,[aod]
 cmp edx,ebx
 je retaod
 ;regs
 mov edx,[byt]
 cmp edx,ebx
 je fdfret
 mov edx,[wrd]
 cmp edx,ebx
 je fdfret
 mov edx,[dwr]
 cmp edx,ebx
 je fdfret 
 mov eax,alfs
 mov edx,"alR"
 cmp edx,ebx
 je retregz
 add eax,2
 mov edx,"ahR"
 cmp edx,ebx
 je retregz
 add eax,2
 mov edx,"axR"
 cmp edx,ebx
 je retregz
 add eax,2
 mov edx,"EAX"
 cmp edx,ebx
 je retregz
 add eax,2
 mov edx,"blR"
 cmp edx,ebx
 je retregz
 add eax,2
 mov edx,"bhR"
 cmp edx,ebx
 je retregz
 add eax,2
 mov edx,"bxR"
 cmp edx,ebx
 je retregz
 add eax,2
 mov edx,"EBX"
 cmp edx,ebx
 je retregz
 add eax,2
 mov edx,"clR"
 cmp edx,ebx
 je retregz
 add eax,2
 mov edx,"chR"
 cmp edx,ebx
 je retregz
 add eax,2
 mov edx,"cxR"
 cmp edx,ebx
 je retregz
 add eax,2
 mov edx,"ECX"
 cmp edx,ebx
 je retregz
 add eax,2
 mov edx,"dlR"
 cmp edx,ebx
 je retregz
 add eax,2
 mov edx,"dhR"
 cmp edx,ebx
 je retregz
 add eax,2
 mov edx,"dxR"
 cmp edx,ebx
 je retregz
 add eax,2
 mov edx,"EDX"
 cmp edx,ebx
 je retregz
 add eax,2
 mov edx,"ESI"
 cmp edx,ebx
 je retregz
 add eax,2
 mov edx,"EDI"
 cmp edx,ebx
 je retregz

 retregz:
 mov dl,[eax]
 mov dh,"i"
 cmp dh,dl
 je retint4
 mov dh,"s"
 cmp dh,dl
 je retchkstr2
 mov dh,"a"
 cmp dh,dl
 je retint4

 
 retchkstr:
 call tonothing
 retchkstr2: 
 call semread
 mov edx,[trm]
 cmp edx,ebx
 je retstr 
 jmp retintx
 retchknull:
 call semread
 mov edx,[trm]
 cmp edx,ebx
 je retnull 
 jmp retintx
 retchkid:
 mov edx,0
 call readid2
 call getidtype
 mov bl,"o"
 mov bh,[sf]
 cmp bh,bl 
 je retchkstr2
 mov bh,[nf2]
 cmp bh,bl
 je retchknull
 jmp retint4 
 retaod:
 mov edx,0
 call readid2
 call getidtype
 jmp retint4

 retptr:
 mov edx,0
 call readid2
 call getptrt
 mov bl,"o"
 mov bh,[iff]
 cmp bh,bl
 je retint4
 mov bh,[nf2]
 cmp bh,bl
 je retchknull
 mov bh,[sf]
 cmp bh,bl
 je retchkstr2

 retaru:
 mov eax,"i;"
 call putrtype
 jmp semaru 
 retlpr:
 mov eax,"i;"
 call putrtype
 jmp zlpr  
 retstr:
 mov eax,"s;"
 call putrtype
 jmp succ 
 retintx:
 mov eax,"i;"
 call putrtype
 sub ecx,3
 jmp zstrt2
 retint:
 mov eax,"i;"
 call putrtype 
 jmp zint
 retint2:
 mov eax,"i;"
 call putrtype
 jmp zop
 retint3:
 mov eax,"i;"
 call putrtype
 jmp zop2 
 retint4:
 mov eax,"i;"
 call putrtype
 jmp zint2
 retnull:
 mov eax,"n;"
 call putrtype
 jmp succ
 putrtype:
 mov edx,[fncsc]
 mov [funcs+edx],eax
 add edx,2
 ;mov bl,0xa
 ;mov [funcs+edx],bl
 mov [fncsc],edx
 mov bl,"z"
 mov [rf],bl
 mov [fdff],bl
 mov [fdfi],bl
 ret

 chkfdfdf:
  mov dl,[fdff]
  cmp dl,"o"
  jne seme7
  mov edx,0
  mov eax,[fdfcount]
 chkfdfdf2:
  mov bl,[idv+edx]
  mov [fdfundef+eax],bl
  cmp bl,"|"
  je chkfdfdf3
  add eax,1
  add edx,1
  jmp chkfdfdf2
 chkfdfdf3: 
  add eax,1
  mov bl,"f"
  mov [fdfundef+eax],bl
  add eax,6 
  mov [fdfcount],eax
  jmp fclsem2

 chkfdfdf4:
  mov dl,[fdff]
  cmp dl,"o"
  jne seme6
  mov dl,"o"
  mov dh,[fcfc]
  cmp dh,dl
  je chkfdfdfx
 chkfdfdfz:
  mov edx,[parcount]
  mov eax,[fdfcount]
  sub eax,5
  mov [fdfundef+eax],edx
  add eax,5
  mov [fdfcount],eax
  jmp endfcl3
 chkfdfdfx:
  mov edx,[fdfcount]
  mov [fdfcount2],edx
  mov dl,"z"
  mov [fcfc],dl
  jmp chkfdfdfz 
 
 chkidfdf:
  mov dl,[fdff]
  cmp dl,"o"
  jne seme4
  mov edx,0
  mov eax,[fdfcount3]
 chkidfdf2:
  mov bl,[idv+edx]
  mov [fdfundef2+eax],bl
  cmp bl,"|"
  je chkidfdf3
  add eax,1
  add edx,1
  jmp chkidfdf2
 chkidfdf3: 
  add eax,1
  mov bl,"i"
  mov [fdfundef2+eax],bl
  add eax,1 
  mov bl,";"
  mov [fdfundef2+eax],bl
  add eax,1  
  mov [fdfcount3],eax
  jmp zint2

 chkarfdf:
  mov dl,[fdff]
  cmp dl,"o"
  jne seme12
  mov edx,0
  mov eax,[fdfcount3]
 chkarfdf2:
  mov bl,[idv+edx]
  mov [fdfundef2+eax],bl
  cmp bl,"|"
  je chkarfdf3
  add eax,1
  add edx,1
  jmp chkarfdf2
 chkarfdf3:
  add eax,1
  mov bl,"a"
  mov [fdfundef2+eax],bl
  add eax,1 
  mov bl,";"
  mov [fdfundef2+eax],bl
  add eax,1  
  mov [fdfcount3],eax
  jmp arusem2
 
 saveftemp:
  mov eax,0
  mov edx,[ftempc]
  saveftemp2:
  mov bl,[idv2+eax]
  mov [ftemp+edx],bl
  cmp bl,"|"
  je saveftemp3
  add eax,1
  add edx,1 
  jmp saveftemp2
  saveftemp3:
  add edx,1
  mov [ftempc],edx
  ret
 
 ;;checks if a variable is in ftemp 
 fdfspecial:
  mov eax,0
  mov edx,0
  fdfspecial2:
  mov bl,[idv+edx]
  mov bh,[ftemp+eax]
  cmp bh,bl
  jne fdfspecial3
  add edx,1
  add eax,1
  cmp bl,"|"
  je fdfspecial4
  jmp fdfspecial2
  fdfspecial3:
  mov bl,[ftemp+eax]
  add eax,1
  cmp bl,"|"
  jne fdfspecial3
  mov edx,0
  add eax,1
  mov bl,[ftemp+eax]
  cmp bl,0
  je togetidtype 
  sub eax,1
  jmp fdfspecial2
  fdfspecial4:
  mov bl,"z"
  mov [iff],bl
  mov [sf],bl
  mov [nf2],bl
  ret
  togetidtype:
   mov edx,0
   mov eax,0  
   jmp getidtype2
   
;;;;;;;;;;;;ROCK BOTTOM;;;;;;;;;;;;
 semstts2:
 mov edx,[semseqts]
 mov bl,[semtrack+edx]
 mov bh,"f"
 cmp bh,bl 
 je tof2 
 mov bh,"v"
 cmp bh,bl
 je tov2 
 mov bh,"z"
 cmp bh,bl
 je toz2 
 mov bh,"d"
 cmp bh,bl 
 je tod2 
 mov bh,"u"
 cmp bh,bl
 je tou2
 mov bh,"p"
 cmp bh,bl
 je top2


 semstts:
 mov edx,[semseqts]
 mov bl,[semtrack+edx]
 mov bh,"f"
 cmp bh,bl 
 je tof 
 mov bh,"v"
 cmp bh,bl
 je tov 
 mov bh,"z"
 cmp bh,bl
 je toz 
 mov bh,"d"
 cmp bh,bl 
 je tod 
 mov bh,"u"
 cmp bh,bl
 je tou
 mov bh,"p"
 cmp bh,bl
 je top

 tod:
 call semread
 call z_ops
 mov edx,[ade]
 cmp edx,ebx
 je semfinard
 mov edx,[cma]
 cmp edx,ebx
 je ardef1
 jmp z_0
 tod2:
 call semread
 mov edx,[rpr]
 cmp edx,ebx
 je chkzcf
 mov edx,[ade]
 cmp edx,ebx
 je semfinard
 call strerrors
 jmp z_0  
 top:
 call semread 
 call trms 
 call z_ops
 jmp z_0
 top2:
 call semread
 call strerrors
 call trms
 jmp z_0
 tou:
 call semread
 call z_ops
 mov edx,[are]
 cmp edx,ebx
 je semfinaru
 jmp z_0 
 tou2:
 call semread
 mov edx,[rpr]
 cmp edx,ebx
 je chkaue2
 mov edx,[ade]
 cmp edx,ebx
 je chkaue
 call strerrors
 jmp z_0 
 tof:
 call semread
 mov edx,[cma]
 cmp edx,ebx 
 je addpar 
 mov edx,[fce]
 cmp edx,ebx
 je endfcl
 mov edx,[rpr]
 cmp edx,ebx
 je zrpr
 call z_ops
 jmp z_0
 tof2:
 call semread
 mov edx,[rpr]
 cmp edx,ebx
 je chkfcf
 mov edx,[fce]
 cmp edx,ebx
 je endfcl
 call strerrors
 jmp z_0 
 tov:
 jmp toz
 tov2:
 jmp toz2
 toz:
 call semread
 mov edx,[rpr]
 cmp edx,ebx 
 je zrpr
 mov edx,[endp]
 cmp edx,ebx
 je endpush 
 mov edx,[endt]
 cmp edx,ebx
 je semfintostr
 mov edx,[trm]
 cmp edx,ebx
 je succ 
 mov edx,[inct]
 cmp edx,ebx
 je zterm 
 mov edx,[dect]
 cmp edx,ebx
 je zterm
 mov edx,[endw]
 cmp edx,ebx
 je sem_endiow
 mov edx,[endf2]
 cmp edx,ebx
 je sem_endiow
 call z_ops
 jmp z_0
 toz2:
 call semread
 call strerrors
 mov edx,[trm]
 cmp edx,ebx
 je succ
 mov edx,[endp]
 cmp edx,ebx
 je endpush 
 mov edx,[endt]
 cmp edx,ebx
 je semfintostr
 mov edx,[rpr]
 cmp edx,ebx
 je chkzcf
 mov edx,[endw]
 cmp edx,ebx
 je sem_endiow
 mov edx,[endf2]
 cmp edx,ebx
 je sem_endiow 
 jmp z_0
 

 chkfcf:
 mov bl,[fcf]
 mov bh,"o"
 cmp bh,bl
 jne seme3
 jmp zrpr
 chkzcf:
 mov bl,[zcf]
 mov bh,"o"
 cmp bh,bl
 jne seme3
 jmp zrpr

 strerrors:
 mov edx,[inct]
 cmp edx,ebx
 je seme2 
 mov edx,[dect]
 cmp edx,ebx
 je seme2
 mov edx,[min]
 cmp edx,ebx
 je seme1
 mov edx,[mult]
 cmp edx,ebx
 je seme1
 mov edx,[divt]
 cmp edx,ebx
 je seme1
 mov edx,[pls]
 cmp edx,ebx
 je seme1
 ret

 chkint:
 mov bl,BYTE[idv+eax] 
 ; mov bh,BYTE[intvar+edx]
 cmp bh,bl 
 jne tonothing2
 mov bh,"|"
 cmp bh,bl 
 jne chkint2 
 ret 
 chkint2:
 add eax,1
 add edx,1 
 jmp chkint 
 
 tonothing2:
 mov eax,0
 mov bh,"|"
 tonothing2x:
 ;mov bl,BYTE[intvar+edx]
 cmp bh,bl 
 je chkint 
 add edx,1 
 jmp tonothing2x


 error2:
 mov eax,4
 mov ebx,1
 mov edx,3
 mov ecx,cntn
 int 0x80
 mov eax,1
 int 0x80 
 chk:
 pushad
 mov ecx,cntn
 mov edx,4
 mov ebx,1
 mov eax,4
 int 0x80
 popad
 ret
   
 readid2:
 mov bl,byte[CISYN+ecx]
 mov bh,"|"
 cmp bh,bl 
 jne readid2x
 mov [idv+edx],bl 
 add ecx,1
 ret 
 ;idts arus fcls 
 readid2x:
 mov [idv+edx],bl 
 add edx,1
 add ecx,1
 jmp readid2

 readid:
 mov bl,BYTE[CISYN+ecx]
 mov bh,"|"
 cmp bh,bl
 jne readidx
 mov [idv2+edx],bl 
 add ecx,1
 ret 
 ;vars ards fdfs 
 readidx:
 mov [idv2+edx],bl 
 add edx,1
 add ecx,1
 jmp readid
 
 tonothing:
 add ecx,1
 mov bh,"|"
 mov bl,BYTE[CISYN+ecx];int0|
 cmp bh,bl 
 jne tonothing 
 add ecx,1
 ret  
 
 getidtype:
 mov bl,[fdfi]
 cmp bl,"o"
 je fdfspecial
 mov edx,0
 mov eax,0  
 getidtype2:
 mov bl,BYTE[idv+edx]
 mov bh,BYTE[vars+eax]
 cmp bh,bl 
 jne getidtype3
 mov bh,"|"
 cmp bh,bl 
 je finidt 
 add eax,1
 add edx,1 
 jmp getidtype2  
 getidtype3:
 mov bl,";"
 mov bh,BYTE[vars+eax]
 cmp bh,bl 
 je getidtype3x 
 mov bl,0
 cmp bh,bl 
 je chkidfdf 
 add eax,1 
 jmp getidtype3
 getidtype3x:
 add eax,1
 mov edx,0 
 jmp getidtype2 
 finidt:
 inc eax
 mov bl,[vars+eax]
 mov bh,"i"
 cmp bl,bh 
 je typeint 
 mov bh,"n"
 cmp bl,bh 
 je typenull 
 mov bh,"s"
 cmp bl,bh 
 je typestr 
 mov bl,"o"
 mov [pf],bl
 ret 
 typeint:
 mov bh,"o"
 mov [iff],bh
 ret 
 typenull:
 mov bh,"o"
 mov [nf2],bh
 ret
 typestr:
 mov bh,"o"
 mov [sf],bh
 ret

 getptrt:
 mov edx,0
 mov eax,0  
 getptrt2:
 mov bl,BYTE[idv+edx]
 mov bh,BYTE[ptrvar+eax]
 cmp bh,bl 
 jne getptrt3
 mov bh,"|"
 cmp bh,bl 
 je finptr 
 add eax,1
 add edx,1 
 jmp getptrt2
 getptrt3:
 mov bh,";"
 mov bl,BYTE[ptrvar+eax]
 cmp bh,bl 
 je getptrt3x
 add eax,1 
 jmp getptrt3
 getptrt3x:
 add eax,1
 mov bh,0 
 mov bl,BYTE[ptrvar+eax]
 cmp bh,bl 
 je seme11
 sub eax,1
 mov edx,0 
 jmp getptrt2
 finptr:
 add eax,1
 mov bl,"i"
 mov bh,[ptrvar+eax]
 cmp bh,bl 
 je pisint
 mov bl,"n"
 cmp bh,bl
 je pisnull
 jmp pisstr
 pisint:
 mov bh,"o"
 mov [iff],bh
 ret 
 pisnull:
 mov bh,"o"
 mov [nf2],bh
 ret
 pisstr: 
 mov bh,"o"
 mov [sf],bh
 ret 

 clearflags:
 mov bh,"z"
 mov [sf],bh
 mov [iff],bh
 mov [nf2],bh
 ret

 succ:
 ;mov dl,"o"
 ;mov dh,[eofdf]
 ;cmp dh,dl
 ;jne cgen
 ;mov dl,"z"
 ;mov [eofdf],dl
 ;mov [fdff],dl
 ;call chk
 jmp cgen
 
 semnewl:
 mov edx,[newc]
 add edx,1
 mov [newc],edx
 jmp succ
 
 eoff:
 mov edx,suklen
 mov ecx,suk 
 mov eax,4
 mov ebx,1
 int 0x80
 jmp cgen
 mov eax,1
 int 0x80 
 
 seme1:
 mov ecx,semerr1 
 mov edx,lense1
 mov eax,4
 mov ebx,1
 int 0x80
 mov eax,1
 int 0x80
 seme2:
 mov ecx,semerr2 
 mov edx,lense2
 mov eax,4
 mov ebx,1
 int 0x80
 mov eax,1
 int 0x80
 seme3:
 mov ecx,semerr3 
 mov edx,lense3
 mov eax,4
 mov ebx,1
 int 0x80
 mov eax,1
 int 0x80
 seme4:
 mov ecx,semerr4 
 mov edx,lense4
 mov eax,4
 mov ebx,1
 int 0x80
 mov ecx,idv
 mov edx,20
 mov eax,4
 mov ebx,1
 int 0x80
 mov eax,1
 int 0x80
 seme5:
 mov ecx,semerr5
 mov edx,lense5
 mov eax,4
 mov ebx,1
 int 0x80
 mov eax,1
 int 0x80
 seme6:
 mov ecx,semerr6 
 mov edx,lense6
 mov eax,4
 mov ebx,1
 int 0x80
 mov ecx,idv
 mov eax,4
 mov ebx,1
 mov edx,20
 int 0x80 
 mov eax,1
 int 0x80 
 seme7:
 mov ecx,semerr7 
 mov edx,lense7
 mov eax,4
 mov ebx,1
 int 0x80
 mov ecx,funcs
 mov eax,4
 mov ebx,1
 mov edx,20
 int 0x80
 mov eax,1
 int 0x80
 seme8:
 mov ecx,semerr8
 mov edx,lense8
 mov eax,4
 mov ebx,1
 int 0x80
 mov eax,1
 int 0x80
 seme9:
 mov ecx,semerr9 
 mov edx,lense9
 mov eax,4
 mov ebx,1
 int 0x80
 mov eax,1
 int 0x80
 seme10:
 mov ecx,semerr10 
 mov edx,lense10
 mov eax,4
 mov ebx,1
 int 0x80
 mov eax,1
 int 0x80 
 seme11:
 mov ecx,semerr11 
 mov edx,lense11
 mov eax,4
 mov ebx,1
 int 0x80
 mov eax,1
 int 0x80  
 seme12:
 mov ecx,semerr12 
 mov edx,lense12
 mov eax,4
 mov ebx,1
 int 0x80
 mov eax,1
 int 0x80  
 seme13:
 mov ecx,semerr13 
 mov edx,lense13
 mov eax,4
 mov ebx,1
 int 0x80
 mov eax,1
 int 0x80   


cgenread: ;reads token 
 push esi
 mov eax,DWORD[CISYN+ecx]
 mov [file],eax
 add ecx,3 
 push ecx
 mov ecx,3
 mov esi,file 
 mov edi,cntn
 cld
 rep movsb
 pop ecx
 mov ebx,[cntn]
 mov eax,0
 pop esi
 ret 

cgen:
 pushad
 mov ecx,CISYN
 mov edx,30
 mov eax,4
 mov ebx,1
 int 0x80 
 popad
 mov eax,"cgn"
 mov [cntn],eax
 call chk
 mov ecx,0
 mov [idc],ecx
 mov [idc2],ecx
 mov [intc],ecx
 mov [trmgenc],ecx
 mov [regfunc],cl

_codegenerator:
 call cgenread
 ;regs
  mov eax,alf
  mov edx,"alR"
  cmp edx,ebx
  je _genreg
  add eax,2
  mov edx,"ahR"
  cmp edx,ebx
  je _genreg
  add eax,2
  mov edx,"axR"
  cmp edx,ebx
  je _genreg
  add eax,2
  mov edx,"EAX"
  cmp edx,ebx
  je _genreg
  add eax,2
  mov edx,"blR"
  cmp edx,ebx
  je _genreg
  add eax,2
  mov edx,"bhR"
  cmp edx,ebx
  je _genreg
  add eax,2
  mov edx,"bxR"
  cmp edx,ebx
  je _genreg
  add eax,2
  mov edx,"EBX"
  cmp edx,ebx
  je _genreg
  add eax,2
  mov edx,"clR"
  cmp edx,ebx
  je _genreg 
  add eax,2
  mov edx,"chR"
  cmp edx,ebx
  je _genreg
  add eax,2
  mov edx,"cxR"
  cmp edx,ebx
  je _genreg
  add eax,2
  mov edx,"ECX"
  cmp edx,ebx
  je _genreg
  add eax,2
  mov edx,"dlR"
  cmp edx,ebx
  je _genreg
  add eax,2
  mov edx,"dhR"
  cmp edx,ebx
  je _genreg
  add eax,2
  mov edx,"dxR"
  cmp edx,ebx
  je _genreg
  add eax,2
  mov edx,"EDX"
  cmp edx,ebx
  je _genreg
  add eax,2
  mov edx,"ESI"
  cmp edx,ebx
  je _genreg
  add eax,2
  mov edx,"EDI"
  cmp edx,ebx
  je _genreg
  mov edx,"SYS"
 cmp ebx,edx
 je gensyscall
 mov edx,"DOT"
 cmp edx,ebx
 je _cgenbitsdot
 mov edx,[movci]
 cmp edx,ebx 
 je _genmovci
 mov edx,[movt]
 cmp edx,ebx
 je _genmov
 mov edx,[movb]
 cmp edx,ebx
 je _genmovb
 mov edx,[negt]
 cmp edx,ebx
 je _genneg
 mov edx,[byt]
 cmp edx,ebx
 je _genb
 mov edx,[wrd]
 cmp edx,ebx
 je _genw
 mov edx,[dwrd]
 cmp edx,ebx
 je _gend
 mov edx,[bit]
 cmp edx,ebx
 je _genmbit
 mov edx,[aod]
 cmp edx,ebx
 je _genaod
 mov edx,[lpr]
 cmp edx,ebx
 je _genlpr
 mov edx,[rpr]
 cmp edx,ebx
 je _genlpr2
 mov edx,[intt2]
 cmp edx,ebx
 je _gen2nt
 mov edx,[strt2]
 cmp edx,ebx
 je _gen2tr 
 mov edx,[ptrt]
 cmp edx,ebx
 je _genptr
 mov edx,[end2]
 cmp edx,ebx
 je _genend
 mov edx,[fprint]
 cmp edx,ebx
 je _genprint2
 mov edx,[fdf]
 cmp edx,ebx
 je genfdf
 mov edx,[var]
 cmp edx,ebx
 je _genvar 
 mov edx,[fcl]
 cmp edx,ebx 
 je genfcl
 mov edx,[npt]
 cmp edx,ebx
 je gentonpt
 mov edx,[fce]
 cmp edx,ebx
 je genfce2
 mov edx,[rett]
 cmp edx,ebx
 je genret
 mov edx,[cma]
 cmp edx,ebx
 je _gencma
 mov edx,[rolt]
 cmp edx,ebx
 je _genrolt
 mov edx,[rort]
 cmp edx,ebx
 je _genrort
 mov edx,[shlt]
 cmp edx,ebx
 je _genshlt
 mov edx,[shrt]
 cmp edx,ebx
 je _genshrt 
 mov edx,[rolf]
 cmp edx,ebx
 je _genrolf  
 mov edx,[rorf]
 cmp edx,ebx
 je _genrorf  
 mov edx,[shlf]
 cmp edx,ebx
 je _genshlf  
 mov edx,[shrf]
 cmp edx,ebx
 je _genshrf   
 mov edx,[ard]
 cmp edx,ebx
 je _genard
 mov edx,[ade]
 cmp edx,ebx
 je _genfinard
 mov edx,[aru]
 cmp edx,ebx
 je _genaru
 mov edx,[print]
 cmp edx,ebx
 je _genprint
 mov edx,[strt]
 cmp edx,ebx
 je _genstr
 mov edx,[if]
 cmp edx,ebx
 je genif 
 mov edx,[endf2]
 cmp edx,ebx
 je _genfinif
 mov edx,[while]
 cmp edx,ebx
 je genwil 
 mov edx,[endw]
 cmp edx,ebx
 je _genfinwil
 mov edx,[end]
 cmp edx,ebx
 je genbr2
 mov edx,[nott]
 cmp edx,ebx
 je _gennot
 mov edx,[andt]
 cmp edx,ebx
 je _genand
 mov edx,[ort]
 cmp edx,ebx
 je _genor
 mov edx,[else]
 cmp edx,ebx
 je genelse
 mov edx,[neq]
 cmp edx,ebx
 je _genneq
 mov edx,[eq2]
 cmp edx,ebx
 je _geneq2
 mov edx,[grt]
 cmp edx,ebx
 je _gengrt
 mov edx,[lest]
 cmp edx,ebx
 je _genles
 mov edx,[geq]
 cmp edx,ebx
 je _gengeq
 mov edx,[leq]
 cmp edx,ebx
 je _genleq 
 mov edx,[are]
 cmp edx,ebx
 je _genfinaru
 mov edx,[intt]
 cmp edx,ebx
 je _genint 
 mov edx,[flt]
 cmp edx,ebx
 je genflt  
 mov edx,[true]
 cmp edx,ebx
 je _gentrue
 mov edx,[false]
 cmp edx,ebx
 je _genfalse
 mov edx,[nullt]
 cmp edx,ebx
 je _gennull
 mov edx,[idt]
 cmp edx,ebx
 je _genidt  
 mov edx,[term]
 cmp edx,ebx
 je _genterm
 mov edx,[eof]
 cmp edx,ebx
 je cgenfin
 mov edx,[pls]
 cmp edx,ebx
 je _exppls
 mov edx,[min]
 cmp edx,ebx
 je _expmin
 mov edx,[mult]
 cmp edx,ebx
 je _expmul
 mov edx,[divt]
 cmp edx,ebx
 je _expdiv 
 mov edx,[port]
 cmp edx,ebx
 je _exppor
 mov edx,[br1]
 cmp edx,ebx
 je _codegenerator
 jmp error2

gensyscall:
 push ecx 
 mov ecx,"XXX"
 mov [cntn],ecx
 call chk
 mov ecx,"mov "
 mov edx,4
 call prnx
 mov ecx,"eax,"
 call prnx 
 mov al,[eaxf]
 cmp al,"a"
 je genadrs1
 mov eax,[CIR]
 call itos
 call prncij2
 call prnnull
 gensys2:
 mov ecx,"mov "
 mov edx,4
 call prnx
 mov ecx,"ebx,"
 call prnx 
 mov al,[ebxf]
 cmp al,"a"
 je genadrs2
 mov eax,[CIR+4]
 call itos
 call prncij2
 call prnnull 
 gensys3:
 mov ecx,"mov "
 mov edx,4
 call prnx
 mov ecx,"ecx,"
 call prnx 
 mov al,[ecxf]
 cmp al,"a"
 je genadrs3
 mov eax,[CIR+8]
 call itos
 call prncij2
 call prnnull 
 gensys4: 
 mov ecx,"mov "
 mov edx,4
 call prnx
 mov ecx,"edx,"
 call prnx 
 mov al,[edxf]
 cmp al,"a"
 je genadrs4
 mov eax,[CIR+12]
 call itos
 call prncij2
 call prnnull  
 gensys5:
 mov ecx,"int "
 mov edx,4
 call prnx 
 pop ecx 
 add ecx,3 ;str
 mov edx,1
 gensys5x:
 mov bl,[CISYN+ecx]
 cmp bl,"|"
 je fingensys
 push ecx
 mov cl,bl
 call prnx
 pop ecx 
 inc ecx
 jmp gensys5x
 fingensys:
 inc ecx 
 call prnnull
 jmp _codegenerator
 
 genadrs1:
  mov eax,[CIR+0] ;eax
  mov [CIR2+0],eax
  call genadrsx 
  mov ecx,"_CID"
  mov edx,4
  call prnx
  mov ecx,"_"
  mov edx,1
  call prnx 
  mov eax,[intc2]
  dec eax
  call itos
  call prncij2
  call prnnull
  jmp gensys2
 genadrs2:
  mov eax,[CIR+4] ;ebx
  mov [CIR2+0],eax
  call genadrsx 
  mov ecx,"_CID"
  mov edx,4
  call prnx
  mov ecx,"_"
  mov edx,1
  call prnx 
  mov eax,[intc2]
  dec eax
  call itos
  call prncij2
  call prnnull
  jmp gensys3
 genadrs3:
  mov eax,[CIR+8] ;ecx
  mov [CIR2+0],eax 
  call genadrsx 
  mov ecx,"_CID"
  mov edx,4
  call prnx
  mov ecx,"_"
  mov edx,1
  call prnx 
  mov eax,[intc2]
  dec eax
  call itos
  call prncij2
  call prnnull
  jmp gensys4
 genadrs4:
  mov eax,[CIR+12] ;edx
  mov [CIR2+0],eax 
  call genadrsx 
  mov ecx,"_CID"
  mov edx,4
  call prnx
  mov ecx,"_"
  mov edx,1
  call prnx 
  mov eax,[intc2]
  dec eax
  call itos
  call prncij2
  call prnnull
  jmp gensys5 
 
 
 genadrsx:
  mov ecx,"_CID"
  mov edx,4
  call prnx2
  mov ecx,"_"
  mov edx,1
  call prnx2 
  mov eax,[intc2]
  call itos
  call prncij2x
  mov eax,[intc2]
  add eax,1
  mov [intc2],eax
  mov ecx," db "
  mov edx,4
  call prnx2
  mov eax,[CIR2+0]
  mov cl,[eax]
  cmp cl,"+"
  je genadrsint
  cmp cl,"-"
  je genadrsint 
  mov edx,1
  mov ecx,'"'
  call prnx2
  mov ecx,0
  genadrsloop:
  mov cl,[eax]
  cmp cl,0xa 
  je finadrsloop
  call prnx2
  inc eax
  jmp genadrsloop
  finadrsloop:
  mov ecx,'",'
  mov edx,2
  call prnx2
  mov edx,1
  mov ecx,"0"
  call prnx2 
  mov ecx,0xa
  call prnx2
  ret 
  genadrsint:
  mov ecx,0
  mov edx,1
  genadrsloop2:
  mov cl,[eax]
  cmp cl,0xa 
  je finadrsloop2
  add cl,30h   
  call prnx2
  mov cl,"," 
  call prnx2
  inc eax
  jmp genadrsloop2
  finadrsloop2:
  mov ecx,"0"
  call prnx2 
  mov ecx,0xa
  call prnx2
  ret 
 
;mkj. 
 _genmovci:
 mov edx,[genseqts]
 mov bl,"m"
 inc edx 
 mov [genseq+edx],bl 
 mov [genseqts],edx 
 jmp _codegenerator
 _genmovci2:
 mov eax,[CIR2+0]
 mov edx,[CIR2+4]
 push eax
 push edx
 jmp _codegenerator
 _genfinmovci:
 mov eax,[CIR2+0]
 mov edx,[CIR2+4]
 pop ebx; edx
 pop ebx; aod 
 push ecx
 mov ecx,edx
 _genfinmovci2:
 mov dl,[eax]
 mov [ebx],dl
 inc ebx
 inc eax
 loop _genfinmovci2
 pop ecx 
 mov edx,[genseqts]
 mov bl,0
 mov [genseq+edx],bl
 dec edx
 mov [genseqts],edx
 jmp _codegenerator

 _genmov:
 mov edx,[genseqts]
 mov bl,"k"
 inc edx 
 mov [genseq+edx],bl 
 mov [genseqts],edx 
 jmp _codegenerator
 _genmov2:
 mov eax,[CIR2+0]
 mov edx,[CIR2+4]
 push eax
 push edx
 jmp _codegenerator 
 _genfinmov:
 mov eax,[CIR2+0]
 mov edx,[CIR2+4]
 mov esi,[CIR2+20]
 push ecx
 call _CIMEM2REG_
 mov [CIR2+20],esi
 pop ecx
 pop ebx ;edx
 pop ebx; aod 
 mov [ebx],eax 
 mov edx,[genseqts]
 mov bl,0
 mov [genseq+edx],bl
 dec edx
 mov [genseqts],edx
 jmp _codegenerator 
 
 ;j
 
 ;j
 
 _genmovb:
 mov edx,[genseqts]
 mov bl,"j"
 inc edx 
 mov [genseq+edx],bl 
 mov [genseqts],edx 
 jmp _codegenerator
 _genmovb2:
 mov eax,[CIR2+0]
 mov edx,[CIR2+4]
 push eax
 push edx
 jmp _codegenerator 
 _genfinmovb:
 mov eax,[CIR2+0]
 mov bl,[eax+1];true false
 pop edx
 pop eax ;bit num 
 push ecx
 push ebx
 call _CIMEM2REG_
 pop ebx 
 pop ecx
 mov [_CIPSV_],eax
 mov [_CIPSV_+4],bl 
 pop edx
 pop eax
 push ecx
 push eax
 mov edx,0
 mov ecx,[_CIPSV_] 
 _CIMOVB_:
 cmp ecx,7
 jle _CIMOVB2_
 sub ecx,7 
 add edx,1
 jmp _CIMOVB_
 _CIMOVB2_:
 mov [_CIPSV_],ecx
 
 mov [_CIPSV_+5],edx
 ;inc edx
 mov bh,[eax+edx];got the byte 
 ;convert to binary 
 mov edx,0 
 clc
 mov esi,[CIR2+20]
 _CIMOVB3_:
 cmp edx,9 
 je _CIMOVB5_
 shl bh,1 
 jc _CIMOVB4_
 ;it is zero 
 mov bl,0
 mov [esi],bl 
 inc esi 
 inc edx 
 jmp _CIMOVB3_
 _CIMOVB4_:
 mov bl,1
 mov [esi],bl 
 inc esi 
 inc edx
 jmp _CIMOVB3_ 
 _CIMOVB5_:
 sub esi,9
 mov edx,[_CIPSV_]
 mov bl,[_CIPSV_+4]
 ;add bl,30h
 mov [esi+edx],bl  
 pushad
 mov ecx,esi
 mov edx,8
 mov eax,4
 mov ebx,1
 ;int 0x80
 popad
 mov bl,0
 _CIB2N_:
 mov bl,[esi]
 cmp bl,1 
 je _CIBTN1_ 
 _CIB2N_2:
 inc esi
 mov bl,[esi]
 cmp bl,1 
 je _CIBTN2_ 
 _CIB2N_4:
 inc esi
 mov bl,[esi]
 cmp bl,1 
 je _CIBTN4_ 
 _CIB2N_8:
 inc esi
 mov bl,[esi]
 cmp bl,1 
 je _CIBTN8_ 
 _CIB2N_16:
 inc esi
 mov bl,[esi]
 cmp bl,1 
 je _CIBTN16_ 
 _CIB2N_32:
 inc esi
 mov bl,[esi]
 cmp bl,1 
 je _CIBTN32_ 
 _CIB2N_64:
 inc esi
 mov bl,[esi]
 cmp bl,1 
 je _CIBTN64_ 
 _CIB2N_128:
 inc esi
 mov bl,[esi]
 cmp bl,1 
 je _CIBTN128_ 
 _CIB2Nx_:
 pop eax
 mov edx,[_CIPSV_+5]
 mov [eax+edx],bl 
 pop ecx
 mov edx,[genseqts]
 mov bl,0
 mov [genseq+edx],bl
 dec edx
 mov [genseqts],edx
 jmp _codegenerator  

 ;x=3;movb(&>x,14,true);y=str(x);print(y);?
 _CIBTN1_:
 add bl,1 
 jmp _CIB2N_2
 _CIBTN2_:
 add bl,2
 jmp _CIB2N_4
 _CIBTN4_:
 add bl,4
 jmp _CIB2N_8 
 _CIBTN8_:
 add bl,8 
 jmp _CIB2N_16
 _CIBTN16_:
 add bl,16
 jmp _CIB2N_32
 _CIBTN32_:
 add bl,32
 jmp _CIB2N_64 
 _CIBTN64_:
 add bl,64
 jmp _CIB2N_128
 _CIBTN128_:
 add bl,128
 jmp _CIB2Nx_

 _genmbit:
 mov edx,[genseqts]
 mov bl,"."
 inc edx 
 mov [genseq+edx],bl 
 mov [genseqts],edx 
 jmp _codegenerator
 _genmbit2:
 mov eax,[CIR2+0]
 mov edx,[CIR2+4]
 push eax
 push edx
 jmp _codegenerator
 _genfinmbit:
 pop ebx 
 pop ebx ;aod 
 mov bl,[ebx]
 push ebx 
 mov eax,[CIR2+0]
 mov edx,[CIR2+4]
 call _CIMEM2REG_
 pop ebx 
 push ecx
 mov ecx,eax
 _genfinmbit2:
 shl bl,1
 loop _genfinmbit2
 shl bl,1
 jc _genfinmbit3
 mov esi,[CIR2+20]
 mov bl,"+"
 mov bh,1
 mov [esi],bx
 add esi,2
 mov bl,0xa
 mov [esi],bl
 inc esi 
 mov [CIR2+20],esi 
 sub esi,2
 mov edx,1
 mov [CIR2+0],esi
 mov [CIR2+4],edx
 pop ecx 
 mov edx,[genseqts]
 mov bl,0
 mov [genseq+edx],bl
 dec edx
 mov [genseqts],edx
 jmp _codegenerator  
 _genfinmbit3:
 mov esi,[CIR2+20]
 mov bl,"+"
 mov bh,0
 mov [esi],bx
 add esi,2
 mov bl,0xa
 mov [esi],bl
 inc esi
 mov [CIR2+20],esi 
 sub esi,2
 mov edx,1
 mov [CIR2+0],esi
 mov [CIR2+4],edx
 pop ecx 
 mov edx,[genseqts]
 mov bl,0
 mov [genseq+edx],bl
 dec edx
 mov [genseqts],edx
 jmp _codegenerator  
 
 
_genreg:
 push ebx
 push eax
 call cgenread
 mov edx,[equt]
 cmp edx,ebx
 je regdef 
 pop eax
 pop ebx
 _genregsx:
 push ecx
 call _regmathx
 mov bl,[ecx+1]
 cmp bl,"o"
 jne _genregsx2  ;if wasnt used with "reg()", jump ;;;jne or je? find out
 pop ecx
 cmp eax,0 
 je _genregff ;if the value was 0
 mov edx,10 
 cmp eax,2147483647
 jge _gencnvrtreg
 dec edx ;9
 cmp eax,100000000
 jge _gencnvrtreg
 dec edx ;8
 cmp eax,10000000
 jge _gencnvrtreg 
 dec edx ;7
 cmp eax,1000000
 jge _gencnvrtreg
 dec edx ;6
 cmp eax,100000
 jge _gencnvrtreg
 dec edx ;5
 cmp eax,10000
 jge _gencnvrtreg
 dec edx ;4
 cmp eax,1000
 jge _gencnvrtreg
 dec edx ;3
 cmp eax,100
 jge _gencnvrtreg
 dec edx ;2
 cmp eax,10
 jge _gencnvrtreg 
 dec edx ;1
 cmp eax,9
 jle _gencnvrtreg 
 _gencnvrtreg:
 push ecx
 mov esi,[CIR2+20]
 call _CIREG2MEM_ ;paramter in eax ,R2Nneg is added new 
 mov [CIR2+0],eax
 mov [CIR2+4],edx
 mov [CIR2+20],esi
 pop ecx 
 sub ecx,3 
 jmp _codegenerator 
_genregff:
 mov bl,"+"
 mov bh,0
 push esi
 mov [esi],bx
 add esi,2
 pop eax 
 mov edx,1
 mov [CIR2+0],eax
 mov [CIR2+4],edx
 sub ecx,3
 jmp _codegenerator
_genregsx2:
 pop ecx 
 mov esi,[CIR2+20]
 mov [esi],eax
 add esi,4
 mov [CIR2+20],esi
 sub esi,4
 mov [CIR2+0],esi
 mov edx,4
 mov [CIR2+4],edx
 sub ecx,3
 jmp _codegenerator 
 
 
 ;;;x=123;eax=reg(x);a=eax;z=str(a);print(z);?

_genprint:
 mov edx,[genseqts]
 mov bl,"p"
 add edx,1
 mov [genseq+edx],bl
 mov [genseqts],edx
 jmp _codegenerator
 _genprint2:
 mov edx,[genseqts]
 mov bl,0
 mov [genseq+edx],bl
 mov [genseqts],edx
 push ecx
 mov eax,[CIR2+0]
 mov edx,[CIR2+4]
 call _CIPRN_
 pop ecx
 jmp _codegenerator
 _genprint3:
 push ecx
 mov eax,[CIR2+0]
 mov edx,[CIR2+4] 
 call _CIPRN_
 pop ecx
 jmp _codegenerator
 
_genend:
 mov edx,[genseqts]
 mov bl,"i"
 mov bh,[genseq+edx]
 cmp bh,bl
 je _gen2nt2
 mov bl,"s"
 cmp bh,bl
 je _gen2tr2
 mov bl,"m"
 cmp bh,bl
 je _genfinmovci
 mov bl,"k"
 cmp bh,bl
 je _genfinmov
 cmp bl,"j"
 cmp bh,bl
 je _genfinmovb 
 mov bl,"."
 cmp bh,bl
 je _genfinmbit
 
_gen2nt:
 mov edx,[genseqts]
 mov bl,"i"
 add edx,1
 mov [genseq+edx],bl
 mov [genseqts],edx
 jmp _codegenerator
 _gen2nt2:
 mov edx,[genseqts]
 mov bl,0
 mov [genseq+edx],bl
 dec edx
 mov [genseqts],edx
 push ecx
 mov eax,[CIR2+0]
 mov edx,[CIR2+4] 
 mov esi,[CIR2+20]
 call _CI2NT_
 mov [CIR2+20],esi
 mov [CIR2+0],eax
 mov [CIR2+4],edx
 pop ecx
 call _bwdxmath 
 jmp _codegenerator
 
_gen2tr:
 mov edx,[genseqts]
 mov bl,"s"
 add edx,1
 mov [genseq+edx],bl
 mov [genseqts],edx
 jmp _codegenerator
 _gen2tr2:
 mov edx,[genseqts]
 mov bl,0
 mov [genseq+edx],bl
 dec edx
 mov [genseqts],edx
 push ecx
 mov eax,[CIR2+0]
 mov edx,[CIR2+4]
 mov esi,[CIR2+20]
 call _CI2TR_
 mov [CIR2+20],esi
 mov [CIR2+0],eax
 mov [CIR2+4],edx
 pop ecx
 jmp _codegenerator
 
_genaod:
  mov edx,0
  call readid
  mov edx,0
  mov eax,0
  call chknptvar
  cmp eax,1 
  je gentonpt
  mov eax,0
  mov edx,0
  call _getidseq
 mov edx,eax
 mov eax,[stack+edx]
 mov edx,4
 mov [CIR2+0],eax
 mov [CIR2+4],edx
 call _bwdxmath  
 jmp _codegenerator
_genptr:
 mov edx,0
 call readid
 mov eax,0
 mov edx,0
 call _getidseq
 mov edx,eax
 mov eax,[stack+edx]
 push ecx
 call _CIPTR_
 pop ecx
 mov [CIR2+0],eax
 mov [CIR2+4],edx 
 call _bwdxmath 
 jmp _codegenerator
 
_genlpr:
 mov edx,[genseqts]
 mov bl,"("
 add edx,1
 mov [genseq+edx],bl
 mov [genseqts],edx
 jmp _codegenerator
_genlpr2:
  mov ebx,[genseqts]
  mov bl,[genseq+ebx]
  mov bh,"1"
  cmp bh,bl
  je _genfinbytes
  mov bh,"2"
  cmp bh,bl
  je _genfinbytes
  mov bh,"3"
  cmp bh,bl
  je _genfinbytes
  mov bh,"4"
  cmp bh,bl
  je _genfinbytes
  mov bl,[regfunc]
  cmp bl,"o"
  je _codegenerator
  push edx
  mov edx,[genseqts]
  mov bl,0
  mov [genseq+edx],bl
  sub edx,1
  mov [genseqts],edx
  mov bl,[genseq+edx]
  pop edx
  mov bh,"b"
  cmp bh,bl
  je _genb4
  mov bh,"w"
  cmp bh,bl
  je _genw4
  mov bh,"d"
  cmp bh,bl
  je _gend4    
  add ecx,3
  call _bwdxmath 
  jmp _codegenerator

_bwdxmath:
  mov ebx,[genseqts]
  mov bl,[genseq+ebx]
  mov bh,"+"
  cmp bh,bl
  je _bwdtopls
  mov bh,"-"
  cmp bh,bl
  je _bwdtomin
  mov bh,"*"
  cmp bh,bl
  je _bwdtomul
  mov bh,"/"
  cmp bh,bl
  je _bwdtodiv
  mov bh,"^"
  cmp bh,bl
  je _bwdtopor
  ret 
 
gentonpt:
  ;mov ecx,[trmgenc]
  mov ecx,0 
  mov edx,[genseqtr]
  mov [genseqts],edx
  jmp codegenerator
  
;;;;;;;;BWD;;;;;;;bwd 
 _genb:
  call cgenread 
  mov edx,[lpr]
  cmp edx,ebx
  je _genb2
  ;its aod
  mov edx,0
  call readid
  mov edx,0
  mov eax,0
  call getidseq
  mov edx,eax
  mov eax,[stack+edx] 
  mov edx,4
  mov [CIR2+0],eax
  mov [CIR2+4],edx
  call cgenread
  mov edx,[pls]
  cmp edx,ebx
  je _genb3
  mov edx,[min]
  cmp edx,ebx
  je _genb3 
  mov edx,[mult]
  cmp edx,ebx
  je _genb3 
  mov edx,[divt]
  cmp edx,ebx
  je _genb3 
  mov edx,[port]
  cmp edx,ebx
  je _genb3
   sub ecx,3
  push ecx
  mov eax,[CIR2+0]
  mov edx,[CIR2+4]
  mov esi,[CIR2+20]
  call _CIBYT_
  mov [CIR2+20],esi
  mov [CIR2+0],eax
  mov [CIR2+4] ,edx
  pop ecx
  call _bwdxmath
  ;more 
  jmp _codegenerator
 _genb3:
  ;save aod
  mov edx,[genseqts]
  mov bl,"b"
  add edx,1
  mov [genseq+edx],bl
  mov [genseqts],edx   
  mov bl,"o"
  mov [aodf],bl
  sub ecx,3
  jmp _codegenerator
 _genb2:
  mov edx,[genseqts]
  mov bl,"b"
  add edx,1
  mov [genseq+edx],bl
  mov [genseqts],edx   
  jmp _genlpr
 _genb4:
  push ecx
  mov eax,[CIR2+0]
  mov edx,[CIR2+4]
  mov esi,[CIR2+20]
  call _CIBYT_
  mov [CIR2+20],esi
  mov [CIR2+0],eax
  mov [CIR2+4],edx
  pop ecx
  mov edx,[genseqts]
  mov bl,0
  mov [genseq+edx],bl
  sub edx,1
  mov [genseqts],edx
  call _bwdxmath
  jmp _codegenerator
 
 _genw:
  call cgenread 
  mov edx,[lpr]
  cmp edx,ebx
  je _genw2
  ;its aod
  mov edx,0
  call readid
  mov edx,0
  mov eax,0
  call getidseq
  mov edx,eax
  mov eax,[stack+edx] 
  mov edx,4
  mov [CIR2+0],eax
  mov [CIR2+4],edx
  call cgenread
  mov edx,[pls]
  cmp edx,ebx
  je _genw3
  mov edx,[min]
  cmp edx,ebx
  je _genw3
  mov edx,[mult]
  cmp edx,ebx
  je _genw3 
  mov edx,[divt]
  cmp edx,ebx
  je _genw3 
  mov edx,[port]
  cmp edx,ebx
  je _genw3 
  sub ecx,3
  push ecx
  mov eax,[CIR2+0]
  mov edx,[CIR2+4]
  mov esi,[CIR2+20]
  call _CIWRD_
  mov [CIR2+20],esi
  mov [CIR2+0],eax
  mov [CIR2+4],edx
  pop ecx
  call _bwdxmath
  jmp _codegenerator
 _genw3:
  mov edx,[genseqts]
  mov bl,"w"
  add edx,1
  mov [genseq+edx],bl
  mov [genseqts],edx   
  mov bl,"o"
  mov [aodf],bl
  sub ecx,3
  jmp _codegenerator
 _genw2:
  mov edx,[genseqts]
  mov bl,"w"
  add edx,1
  mov [genseq+edx],bl
  mov [genseqts],edx   
  jmp _genlpr
 _genw4:
  push ecx
  mov eax,[CIR2+0]
  mov edx,[CIR2+4]
  mov esi,[CIR2+20]
  call _CIWRD_
  mov [CIR2+20],esi
  mov [CIR2+0],eax
  mov [CIR2+4],edx
  pop ecx
  mov edx,[genseqts]
  mov bl,0
  mov [genseq+edx],bl
  sub edx,1
  mov [genseqts],edx
  call _bwdxmath 
  jmp _codegenerator
  
 _gend:
  call cgenread 
  mov edx,[lpr]
  cmp edx,ebx
  je _gend2
  ;its aod
  mov edx,0
  call readid
  mov edx,0
  mov eax,0
  call getidseq
  mov edx,eax
  mov eax,[stack+edx] 
  mov edx,4
  mov [CIR2+0],eax
  mov [CIR2+4],edx
  call cgenread
  mov edx,[pls]
  cmp edx,ebx
  je _gend3
  mov edx,[min]
  cmp edx,ebx
  je _gend3
  mov edx,[mult]
  cmp edx,ebx
  je _gend3 
  mov edx,[divt]
  cmp edx,ebx
  je _gend3 
  mov edx,[port]
  cmp edx,ebx
  je _gend3 
  sub ecx,3  
  push ecx
  mov eax,[CIR2+0]
  mov edx,[CIR2+4]
  mov esi,[CIR2+20]
  call _CIDWR_
  mov [CIR2+20],esi
  mov [CIR2+0],eax
  mov [CIR2+4],edx
  pop ecx
  call _bwdxmath
  jmp _codegenerator
 _gend3:
  mov edx,[genseqts]
  mov bl,"d"
  add edx,1
  mov [genseq+edx],bl
  mov [genseqts],edx   
  mov bl,"o"
  mov [aodf],bl
  sub ecx,3
  jmp _codegenerator
 _gend2:
  mov edx,[genseqts]
  mov bl,"d"
  add edx,1
  mov [genseq+edx],bl
  mov [genseqts],edx   
  jmp _genlpr
 _gend4:
  push ecx
  mov eax,[CIR2+0]
  mov edx,[CIR2+4]
  mov esi,[CIR2+20]
  call _CIDWR_
  mov [CIR2+20],esi
  mov [CIR2+0],eax
  mov [CIR2+4],edx
  pop ecx
  mov edx,[genseqts]
  mov bl,0
  mov [genseq+edx],bl
  sub edx,1
  mov [genseqts],edx
  call _bwdxmath 
  jmp _codegenerator
  
 _bwdtopls:
  call _restore
  jmp _dopls2
 _bwdtomin:
  call _restore
  jmp _domin2
 _bwdtomul:
  call _restore
  jmp _domul2
 _bwdtodiv:
  call _restore
  jmp _dodiv
 _bwdtopor:
  call _restore
  jmp _dopor
 
 _doaodmath:
  mov edx,[stackc]
  mov ebx,[stack+edx]
  sub edx,4
  mov [stackc],edx
  call _CIMEM2REG_
  add ebx,eax
  mov edx,[genseqts]
  mov bl,[genseq+edx]
  mov bh,"b"
  cmp bh,bl
  je _genb4
  mov bh,"w"
  cmp bh,bl
  je _genw4
  mov bh,"d"
  cmp bh,bl
  je _gend4 
  jmp _codegenerator 

;;;;;;;;;TFN;;;;;;;;
 _gentrue:
 mov eax,esi
 mov edx,1
 mov bl,"+"
 mov bh,1
 mov [esi],bx
  mov [CIR2+0],esi
  mov [CIR2+4] ,edx  
 add esi,2
 add ecx,3
 mov edx,[genseqts]
 mov bl,byte[genseq+edx]
 mov bh,"n"
 cmp bh,bl
 je _genfinnot 
 sub ecx,3
 mov bh,"~"
 cmp bh,bl
 je _fingenneg
 call _bwdxmath
 jmp _codegenerator
 _genfalse:
 mov eax,esi
 mov edx,1
 mov bl,"+"
 mov bh,0
 mov [esi],bx
  mov [CIR2+0],esi
  mov [CIR2+4] ,edx  
 add esi,2
 add ecx,3
 mov edx,[genseqts]
 mov bl,byte[genseq+edx]
 mov bh,"n"
 cmp bh,bl
 je _genfinnot 
 sub ecx,3
 mov bh,"~"
 cmp bh,bl
 je _fingenneg
 call _bwdxmath
 jmp _codegenerator 
 _gennull:
 mov eax,esi
 mov edx,0
 mov bl,0xa
 mov [esi],bl
  mov [CIR2+0],esi
  mov [CIR2+4] ,edx  
 add esi,1
 jmp _codegenerator
 
_genneg:
 mov edx,[genseqts]
 mov bl,"~"
 add edx,1
 mov [genseq+edx],bl
 mov [genseqts],edx
 jmp _codegenerator
_fingenneg:
 mov edx,[genseqts]
 mov bl,0
 mov [genseq+edx],bl 
 sub edx,1
 mov [genseqts],edx
 push ecx
  mov eax,[CIR2+0]
  mov edx,[CIR2+4] ;,edx 
  mov esi,[CIR2+20]
  call _CINEG_
  mov [CIR2+20],esi
  mov [CIR2+0],eax
  mov [CIR2+4] ,edx 
  pop ecx
  call _chkpres
  jmp _codegenerator  
 
;;;;;;;;;STR;;;;;;;
_genstr:
 mov edx,0
 mov [strc],edx
 call readstr
_movstr:
 push ecx
 mov ecx,[strc]
 mov edx,0
 mov esi,[CIR2+20]
 push esi
_movstr2:
 mov bl,[strv+edx]
 mov [esi],bl
 inc esi 
 add edx,1
 loop _movstr2
 mov bl,0xa
 mov [esi],bl
 inc esi 
 pop eax ;eax=esi past
 ;edx is ready
 mov edx,[strc]
 mov ecx,0
 mov [strc],ecx
 pop ecx 
_fingenstr: 
  mov [CIR2+0],eax
  mov [CIR2+4],edx 
  mov [CIR2+20],esi
  jmp _codegenerator 
 
;;;;;;;;BYTES;;;;;;1234 
 _genrolf:
  mov bl,"1"
  jmp _genbytes;r
 _genrorf:
  mov bl,"2"
  jmp _genbytes ;q
 _genshlf:
  mov bl,"3"
  jmp _genbytes;p
 _genshrf:
  mov bl,"4"
  jmp _genbytes;n

 _genbytes:
  mov edx,[genseqts]
  add edx,1
  mov [genseq+edx],bl
  mov [genseqts],edx
  jmp _codegenerator
 _genbytes2:
  call _savee
  jmp _codegenerator
  
 _genfinbytes:
  call _restore
  mov edx,[genseqts]
  mov bl,[genseq+edx]
  mov bh,0
  mov [genseq+edx],bh
  sub edx,1
  mov [genseqts],edx  
  mov bh,"1"
  cmp bh,bl
  je _genfinrolf
  mov bh,"2"
  cmp bh,bl
  je _genfinrorf
  mov bh,"3"
  cmp bh,bl
  je _genfinshlf
  mov bh,"4"
  cmp bh,bl
  je _genfinshrf
 
 _genfinrolf:
  push ecx
  mov eax,[CIR2+0]
  mov edx,[CIR2+4] 
  mov ebx,[CIR2+8]
  mov ecx,[CIR2+12]  
  mov esi,[CIR2+20]  
  call _CIROLf_
  mov [CIR2+0],eax
  mov [CIR2+4],edx
  mov [CIR2+20],esi
  pop ecx
  jmp _codegenerator
 _genfinrorf:
  push ecx
  mov eax,[CIR2+0]
  mov edx,[CIR2+4] 
  mov ebx,[CIR2+8]
  mov ecx,[CIR2+12]  
  mov esi,[CIR2+20]  
  call _CIRORf_
  mov [CIR2+0],eax
  mov [CIR2+4],edx
  mov [CIR2+20],esi
  pop ecx
  jmp _codegenerator
 _genfinshlf:
  push ecx
  mov eax,[CIR2+0]
  mov edx,[CIR2+4] 
  mov ebx,[CIR2+8]
  mov ecx,[CIR2+12]  
  mov esi,[CIR2+20]  
  call _CISHLf_
  mov [CIR2+0],eax
  mov [CIR2+4],edx
  mov [CIR2+20],esi
  pop ecx
  jmp _codegenerator
 _genfinshrf:
  push ecx
  mov eax,[CIR2+0]
  mov edx,[CIR2+4] 
  mov ebx,[CIR2+8]
  mov ecx,[CIR2+12]  
  mov esi,[CIR2+20]  
  call _CISHRf_
  mov [CIR2+0],eax
  mov [CIR2+4],edx
  mov [CIR2+20],esi
  pop ecx
  jmp _codegenerator

;;;;;;;;;BITS;;;;;;5678 
 _genrolt:
  mov bl,"5"
  jmp _genbits;z
 _genrort:
  mov bl,"6"
  jmp _genbits ;y
 _genshlt:
  mov bl,"7"
  jmp _genbits ;v
 _genshrt:
  mov bl,"8"
  jmp _genbits;s

 _genbits:
  mov edx,[genseqts]
  add edx,1
  mov [genseq+edx],bl
  mov [genseqts],edx
  add ecx,3 ; int
  mov edx,0
  call _readint 
  ;here we mov ebx,int
  push ecx
  mov bl,"+"
  mov [esi],bl
  inc esi 
  call _prnint; moves int to esi 
  pop ecx 
  mov ebx,[stackc]
  mov [stack+ebx],eax
  add ebx,4
  mov [stack+ebx],edx
  add ebx,4
  mov [stackc],ebx
  add ecx,3 ;dot
  jmp _codegenerator
 _genfinbits:
  mov edx,[genseqts]
  mov bl,0
  mov [genseq+edx],bl
  sub edx,1
  mov [genseqts],edx
  ;sub ecx,3
  jmp _codegenerator

 _genfinrolt:
  call _popbitsb 
  push ecx
  mov eax,[CIR2+0]
  mov edx,[CIR2+4] 
  mov ebx,[CIR2+8]
  mov ecx,[CIR2+12]  
  mov esi,[CIR2+20]  
  call _CIROL_
  mov [CIR2+0],eax
  mov [CIR2+4],edx
  mov [CIR2+20],esi
  pop ecx
  jmp _genfinbits
 _genfinrort:
  call _popbitsb 
  push ecx
  mov eax,[CIR2+0]
  mov edx,[CIR2+4] 
  mov ebx,[CIR2+8]
  mov ecx,[CIR2+12]  
  mov esi,[CIR2+20]  
  call _CIROR_
  mov [CIR2+0],eax
  mov [CIR2+4],edx
  mov [CIR2+20],esi
  pop ecx
  jmp _genfinbits
 _genfinshlt:
  call _popbitsb 
  push ecx
  mov eax,[CIR2+0]
  mov edx,[CIR2+4] 
  mov ebx,[CIR2+8]
  mov ecx,[CIR2+12]  
  mov esi,[CIR2+20]  
  call _CISHL_
  mov [CIR2+0],eax
  mov [CIR2+4],edx
  mov [CIR2+20],esi
  pop ecx
  jmp _genfinbits
 _genfinshrt:
  call _popbitsb
  push ecx
  mov eax,[CIR2+0]
  mov edx,[CIR2+4] 
  mov ebx,[CIR2+8]
  mov ecx,[CIR2+12]
  mov esi,[CIR2+20] 
  call _CISHR_
  mov [CIR2+0],eax
  mov [CIR2+4],edx
  mov [CIR2+20],esi
  pop ecx
  jmp _genfinbits

 _chkforbits:
  mov edx,[genseqts]
  mov bl,[genseq+edx]
  mov bh,"5"
  cmp bh,bl
  je _genfinrolt
  mov bh,"6"
  cmp bh,bl
  je _genfinrort
  mov bh,"7"
  cmp bh,bl
  je _genfinshlt
  mov bh,"8"
  cmp bh,bl
  je _genfinshrt
  ret
 _cgenbitsdot:
  mov ebx,[stackc]
  mov [stack+ebx],eax
  add ebx,4
  mov [stack+ebx],edx
  add ebx,4 
  mov [stackc],ebx
  jmp _codegenerator
 _popbitsb:
  mov ebx,[stackc]
  sub ebx,4
  mov edx,[stack+ebx]
  sub ebx,4
  mov eax,[stack+ebx]
  mov [stackc],ebx
  mov [CIR2+8],eax
  mov [CIR2+12],edx
  ret
  
;;;;;;;;;CMP;;;;;;;;axytog 
 _genneq: ;3
  call _chkpres
  mov edx,[genseqts]
  mov bl,"a"
  add edx,1 
  mov [genseq+edx],bl
  mov [genseqts],edx  
  jmp _gencmp
 _geneq2: ;4
  call _chkpres
  mov edx,[genseqts]
  mov bl,"x"
  add edx,1
  mov [genseq+edx],bl
  mov [genseqts],edx  
  jmp _gencmp 
 _gengrt: ;5
  call _chkpres
  mov edx,[genseqts]
  mov bl,"y"
  add edx,1
  mov [genseq+edx],bl
  mov [genseqts],edx  
  jmp _gencmp 
 _genles: ;6
  call _chkpres
  mov edx,[genseqts]
  mov bl,"t"
  add edx,1
  mov [genseq+edx],bl
  mov [genseqts],edx  
  jmp _gencmp 
 _gengeq: ;7
  call _chkpres
  mov edx,[genseqts]
  mov bl,"o"
  add edx,1
  mov [genseq+edx],bl
  mov [genseqts],edx  
  jmp _gencmp 
 _genleq: ;8
  call _chkpres
  mov edx,[genseqts]
  mov bl,"g"
  add edx,1
  mov [genseq+edx],bl
  mov [genseqts],edx
  jmp _gencmp 

 _gencmp:
  call _savee
  jmp _codegenerator


 _fingenneq:;jne
  call _restore
  push ecx
  mov eax,[CIR2+0]
  mov edx,[CIR2+4] ;,edx
  mov ebx,[CIR2+8]
  mov ecx,[CIR2+12]
  mov esi,[CIR2+20]
  call _CINEQ_
  mov [CIR2+20],esi
  mov [CIR2+0],eax
  mov [CIR2+4],edx
  pop ecx
  mov bl,0
  mov edx,[genseqts] 
  mov [genseq+edx],bl
  dec edx
  mov [genseqts],edx    
  jmp _codegenerator
 _fingeneq2:;je
  call _restore
  push ecx
  mov eax,[CIR2+0]
  mov edx,[CIR2+4] ;,edx
  mov ebx,[CIR2+8]
  mov ecx,[CIR2+12]
  mov esi,[CIR2+20]
  call _CIEQ2_
  mov [CIR2+20],esi
  mov [CIR2+0],eax
  mov [CIR2+4],edx
  pop ecx
  mov bl,0
  mov edx,[genseqts] 
  mov [genseq+edx],bl
  dec edx
  mov [genseqts],edx    
  jmp _codegenerator
 _fingengrt:;jg
  call _restore
  push ecx
  mov eax,[CIR2+0]
  mov edx,[CIR2+4] ;,edx
  mov ebx,[CIR2+8]
  mov ecx,[CIR2+12]
  mov esi,[CIR2+20]
  call _CIGRT_
  mov [CIR2+20],esi
  mov [CIR2+0],eax
  mov [CIR2+4],edx
  pop ecx
  mov bl,0
  mov edx,[genseqts] 
  mov [genseq+edx],bl
  dec edx
  mov [genseqts],edx    
  jmp _codegenerator
 _fingenles:;jl
  call _restore
  push ecx
  mov eax,[CIR2+0]
  mov edx,[CIR2+4] ;,edx
  mov ebx,[CIR2+8]
  mov ecx,[CIR2+12]
  mov esi,[CIR2+20]
  call _CILES_
  mov [CIR2+20],esi
  mov [CIR2+0],eax
  mov [CIR2+4],edx
  pop ecx
  mov bl,0
  mov edx,[genseqts] 
  mov [genseq+edx],bl
  dec edx
  mov [genseqts],edx    
  jmp _codegenerator
 _fingengeq:;geq
  call _restore
  push ecx
  mov eax,[CIR2+0]
  mov edx,[CIR2+4] ;,edx
  mov ebx,[CIR2+8]
  mov ecx,[CIR2+12]
  mov esi,[CIR2+20]
  call _CIGEQ_
  mov [CIR2+20],esi
  mov [CIR2+0],eax
  mov [CIR2+4],edx
  pop ecx
  mov bl,0
  mov edx,[genseqts] 
  mov [genseq+edx],bl
  dec edx
  mov [genseqts],edx    
  jmp _codegenerator
 _fingenleq:;leq
  call _restore
  push ecx
  mov eax,[CIR2+0]
  mov edx,[CIR2+4] ;,edx
  mov ebx,[CIR2+8]
  mov ecx,[CIR2+12]
  mov esi,[CIR2+20]
  call _CILEQ_
  mov [CIR2+20],esi
  mov [CIR2+0],eax
  mov [CIR2+4],edx
  pop ecx
  mov bl,0
  mov edx,[genseqts] 
  mov [genseq+edx],bl
  dec edx
  mov [genseqts],edx    
  jmp _codegenerator
 
 _chkpreexp:
  mov edx,[genseqts]
  mov bl,[genseq+edx]
  mov bh,"n"
  cmp bh,bl
  je _genfinnot 
  sub ecx,3
  call _chktoexp
  add ecx,3
  ret
 
 _chktocmp:
  mov edx,[genseqts]
  mov bl,[genseq+edx]
  mov bh,"a"
  cmp bh,bl
  je _fingenneq
  mov bh,"x"
  cmp bh,bl
  je _fingeneq2
  mov bh,"y"
  cmp bh,bl
  je _fingengrt
  mov bh,"t"
  cmp bh,bl
  je _fingenles
  mov bh,"o"
  cmp bh,bl
  je _fingengeq
  mov bh,"g"
  cmp bh,bl
  je _fingenleq
  ret 
 
;;;;;;;;;CMA;;;;;;;;
 _gencma:
  call _chkpres
  mov edx,[genseqts]
  mov bl,[genseq+edx]
  mov bh,")"
  cmp bh,bl
  je genfclpar
  mov bh,"["
  cmp bh,bl 
  je _genaddel
  mov bh,"p"
  cmp bh,bl 
  je _genprint3
  mov bh,"1"
  cmp bh,bl
  je _genbytes2
  mov bh,"2"
  cmp bh,bl
  je _genbytes2
  mov bh,"3"
  cmp bh,bl
  je _genbytes2
  mov bh,"4"
  cmp bh,bl
  je _genbytes2
  mov bh,"m"
  cmp bh,bl
  je _genmovci2
  mov bh,"k"
  cmp bh,bl
  je _genmov2
  mov bh,"j"
  cmp bh,bl
  je _genmovb2
  mov bh,"."
  cmp bh,bl
  je _genmbit2
  call _chktocmp
  
;;;;;;;;;VAR;;;;;;;;
 _genvar:
  mov edx,[varsc]
  mov [varsc2],edx
  mov edx,0
  call readid
  call setvarseq
  mov ebx,eax
  mov [_varstack],eax
  mov eax,[genseqts]
  mov bl,"v"
  add eax,1 
  mov [genseq+eax],bl
  mov [genseqts],eax
  jmp _codegenerator
 _fingenvar:
  mov edx,[genseqts]
  mov bl,0
  mov [genseq+edx],bl
  sub edx,1
  mov [genseqts],edx
  mov ebx,[_varstack]
  mov eax,[CIR2+0]
  mov edx,[CIR2+4]
  mov [stack+ebx],eax
  add ebx,4
  mov [stack+ebx],edx
  add ebx,4
  mov [stackc],ebx
  mov [trmgenc],ecx
  sub ecx,3 ;so it reads trm 
  jmp _codegenerator

 _setvarseq:
  mov edx,[varsc]
  mov eax,0
  _setvarseq2:
  mov bl,[idv2+eax] 
  mov [genvars+edx],bl
  inc eax
  inc edx
  cmp bl,"|"
  jne _setvarseq2
  mov eax,[stackc]
  mov [genvars+edx],eax
  add edx,4
  mov bl,";"
  mov [genvars+edx],bl 
  inc edx
  mov [varsc],edx
  mov eax,[stackc]
  ret
 
 _movvar:
  mov bl,[idv2+eax]
  mov [genvars+edx],bl
  add edx,1
  add eax,1
  cmp bl,bh
  jne _movvar
  mov [varsc],edx
  ret

;;;;;;;;INT;;;;;;;;;
_genint:
 mov edx,0
 call _readint
 mov [intc],edx
 _genint2: 
 push ecx
 mov ecx,[intc]
 mov edx,0
 mov esi,[CIR2+20]
 push esi
 _genint3:
 push ecx
 mov cl,[intv+edx]
 mov [esi],cl
 inc esi 
 pop ecx
 add edx,1
 loop _genint3
 mov bl,0xa
 mov [esi],bl
 inc esi 
 mov [CIR2+20],esi
 pop eax ;eax=esi past
 ;edx is ready 
 dec edx
  mov [CIR2+0],eax
  mov [CIR2+4],edx
 pop ecx 
 add ecx,3
 mov edx,[genseqts]
 mov bl,byte[genseq+edx]
 mov bh,"n"
 cmp bh,bl
 je _genfinnot 
 sub ecx,3
 mov bh,"~"
 cmp bh,bl
 je _fingenneg
 call _bwdxmath
 mov eax,[stackc]
 push eax
 call cgenread
 mov edx,[pls]
 cmp edx,ebx
 je _exppls
 mov edx,[min]
 cmp edx,ebx
 je _expmin
 mov edx,[mult]
 cmp edx,ebx
 je _expmul
 mov edx,[divt]
 cmp edx,ebx
 je _expdiv
 mov edx,[port]
 cmp edx,ebx
 je _exppor
 pop eax
 sub ecx,3
 jmp _codegenerator

;;;;;;;;NOT;;;;;;;;;
 _gennot:
  mov edx,[genseqts]
  mov bl,"n"
  add edx,1
  mov [genseq+edx],bl
  mov [genseqts],edx
  jmp _codegenerator
 _genfinnot:
  mov edx,[genseqts]
  mov bl,0
  mov [genseq+edx],bl
  sub edx,1
  mov [genseqts],edx
  mov eax,[CIR2+0]
  mov edx,[CIR2+4]
  mov esi,[CIR2+20]
  call _CINOT_
  mov [CIR2+0],eax
  mov [CIR2+4],edx
  mov [CIR2+20],esi
  sub ecx,3
  call _chkpres
  jmp _codegenerator

;;;;;;;;AND;;;;;;;;;
 _genand:
  call _chkpres
  mov edx,[genseqts]
  mov bl,"&"
  add edx,1
  mov [genseq+edx],bl
  mov [genseqts],edx
  call _savee
  jmp _codegenerator
 _genfinand:
  mov edx,[genseqts]
  mov bl,0
  mov [genseq+edx],bl
  sub edx,1
  mov [genseqts],edx 
  call _restore
  push ecx
  mov eax,[CIR2+0]
  mov edx,[CIR2+4]
  mov ebx,[CIR2+8]
  mov ecx,[CIR2+12] 
  mov esi,[CIR2+20]
  call _CIAND_
  mov [CIR2+0],eax
  mov [CIR2+4],edx
  mov [CIR2+20],esi
  pop ecx
  jmp _codegenerator

;;;;;;;;OR;;;;;;;;;
 _genor:
  call _chkpres
  mov edx,[genseqts]
  mov bl,"|"
  add edx,1
  mov [genseq+edx],bl
  mov [genseqts],edx 
  call _savee
  jmp _codegenerator
 _genfinor:
  mov edx,[genseqts]
  mov bl,0
  mov [genseq+edx],bl
  sub edx,1
  mov [genseqts],edx 
  call _restore
  push ecx
  mov eax,[CIR2+0]
  mov edx,[CIR2+4]
  mov ebx,[CIR2+8]
  mov ecx,[CIR2+12] 
  mov esi,[CIR2+20]
  call _CIOR_
  mov [CIR2+0],eax
  mov [CIR2+4],edx
  mov [CIR2+20],esi
  pop ecx
  jmp _codegenerator 

;;;;;;;;IDT;;;;;;;;;x=1;func:y(u);return u;;? 
 _genidt:
  mov edx,0
  call readid
  mov bl,[fdfif]
  cmp bl,"o"
  je _genfdfidt
  _genidtx:
  mov edx,0
  mov eax,0
  call chknptvar 
  cmp eax,1 
  je gentonpt
  mov eax,0
  mov edx,0
  call _getidseq
 _genidt2:
  mov ebx,eax
  mov eax,[stack+ebx]
  add ebx,4 
  mov edx,[stack+ebx]
  mov [CIR2+0],eax
  mov [CIR2+4],edx
  add ecx,3
  mov edx,[genseqts]
  mov bl,byte[genseq+edx]
  mov bh,"n"
  cmp bh,bl
  je _genfinnot 
  sub ecx,3
  mov bh,"~"
  cmp bh,bl
  je _fingenneg
  call _bwdxmath
  mov eax,[stackc]
  push eax
  call cgenread
  mov edx,[pls]
  cmp edx,ebx
  je _exppls
  mov edx,[min]
  cmp edx,ebx
  je _expmin
  mov edx,[mult]
  cmp edx,ebx
  je _expmul
  mov edx,[divt]
  cmp edx,ebx
  je _expdiv
  mov edx,[port]
  cmp edx,ebx
  je _exppor
  pop eax 
  sub ecx,3 
  jmp _codegenerator  
   
 chknptvar:
  mov bl,[idv2+eax]
  mov bh,[gennvar+edx]
  cmp bh,bl 
  jne chknptvar2
  cmp bl,"|" ;if yes 
  je chknptvar3
  inc eax
  inc edx
  jmp chknptvar
  chknptvar3:
  mov eax,1
  ret
  chknptvar2:
  mov bl,[gennvar+edx]
  cmp bl,";"
  je chknptvar4
  cmp bl,0
  je chknptvar4
  inc edx 
  jmp chknptvar2
  chknptvar4:
  mov eax,0 
  inc edx 
  mov bl,[gennvar+edx]
  cmp bl,0 
  jne chknptvar 
  ;if ended 
  mov eax,0
  ret 
 
 _getidseq:
  mov bl,[idv2+eax]
  mov bh,[genvars+edx]
  cmp bh,bl
  jne _getidseq2
  add edx,1
  add eax,1
  mov bh,"|"
  cmp bh,bl
  jne _getidseq
  mov eax,[genvars+edx]
  ret 
  _getidseq2:
  mov bh,";"
  mov bl,[genvars+edx]  
  add edx,1  
  cmp bh,bl
  jne _getidseq2
  mov eax,0
  jmp _getidseq   

 _genfdfidt:
   mov edx,[fdfco]
   mov eax,0
   call _getfdfseq
   jmp genidt2 ;BECAUSE func arg is like input 
 
 _getfdfseq:
   mov bl,[idv2+eax]
   mov bh,[genfuncs+edx]
   cmp bh,bl
   jne _getfdfseq2
   add edx,1
   add eax,1
   mov bh,"|"
   cmp bh,bl
   jne _getfdfseq
   mov eax,[genfuncs+edx]
   ret 
   _getfdfseq2:
   mov bh,":"
   mov bl,[genfuncs+edx]  
   add edx,1  
   cmp bh,bl
   je _getfdfseq3
   cmp bl,";"
   je _genidtx
   jmp _genidtx
   _getfdfseq3:
   mov eax,0
   jmp _getfdfseq

;;;;;;;;TRM;;;;;;;;;;
 _genterm:
  call _chkpres
  mov edx,[genseqts]
  mov bl,byte[genseq+edx]
  mov bh,"v"
  cmp bh,bl
  je _fingenvar
  mov bh,"r"
  cmp bh,bl
  je _fingenret
   mov bl,[regf]
  mov bh,"o"
  cmp bh,bl
  je regdef2 
  mov [trmgenc],ecx
  mov edx,[genseqts]
  mov [genseqtr],edx
  jmp lexstart

_fingenret:
 mov eax,[CIR2+0]
 mov edx,[CIR2+4]
 call _movcisp
 jmp fingenret
;;;;;;;;;ARD;;;;;;;;; 
 _genard:
  mov edx,[genseqts]
  add edx,1
  mov bl,"[" 
  mov [genseq+edx],bl
  mov [genseqts],edx
  mov edx,0
  call readid2
  mov eax,0
  call _setar
  jmp _codegenerator
 _genfinard:
  call _chkpres
  call _addel
  mov edx,[genseqts]
  mov bl,0
  mov [genseq],bl
  sub edx,1
  mov [genseqts],edx
  jmp _codegenerator
 _genaddel:
  call _addel
  jmp _codegenerator

 _addel:
  mov eax,[CIR2+0]
  mov edx,[CIR2+4]
  mov ebx,[stackc]
  mov [stack+ebx],eax
  add ebx,4
  mov [stack+ebx],edx
  add ebx,4
  mov [stackc],ebx
  ret

 _setar:
  mov edx,[ardcg]
  _setar2:
  mov bl,[idv+eax]
  mov [genards+edx],bl
  inc eax
  inc edx
  cmp bl,"|"
  jne _setar2
  mov eax,[stackc]
  add eax,4
  ;mov [stackc],eax
  sub eax,4
  mov [genards+edx],eax
  add edx,4
  mov bl,";"
  mov [genards+edx],bl 
  inc edx
  mov [ardcg],edx
  ret

;;;;;;;;;ARU;;;;;;;;
 _genaru:
  mov edx,[genseqts]
  add edx,1
  mov bl,"]" 
  mov [genseq+edx],bl
  mov [genseqts],edx
  mov edx,0
  call readid2
  mov edx,0
  mov eax,0
  call _findar
  mov eax,[genards+edx]
  mov [arugens],eax
  jmp _codegenerator
 _genfinaru:
  call _chkpres
  mov ebx,[arugens]
  push ecx
  push ebx
  mov eax,[CIR2+0]
  mov edx,[CIR2+4]
  ;inc eax ;skip sign
  call _CIN2Rb_  ;;;;avoid string check so far
  ;x=["6","7","kk","hglg"];print(x[1]);?
  mov ebx,8
  mul ebx
  add eax,4
  pop ebx
  add eax,ebx
  mov ebx,eax
  mov edx,[stack+ebx]
  sub ebx,4
  mov eax,[stack+ebx]
  mov [CIR2+0],eax
  mov [CIR2+4],edx
  ;
  pop ecx
  mov edx,[genseqts]
  mov bl,0
  mov [genseq],bl
  sub edx, 1
  mov [genseqts],edx 
  mov eax,[stackc]
  push eax
  call cgenread
  mov edx,[pls]
  cmp edx,ebx
  je _exppls
  mov edx,[min]
  cmp edx,ebx
  je _expmin
  mov edx,[mult]
  cmp edx,ebx
  je _expmul
  mov edx,[divt]
  cmp edx,ebx
  je _expdiv
  mov edx,[port]
  cmp edx,ebx
  je _exppor
  pop eax
  sub ecx,3 
  jmp _codegenerator 

 _findar:
  mov bl,[idv+eax]
  mov bh,[genards+edx]
  cmp bh,bl
  jne _findar2
  add edx,1
  add eax,1
  mov bh,"|"
  cmp bh,bl
  jne _findar
  ret 
 _findar2:
  mov bh,";"
  mov bl,[genards+edx]
  add edx,1 
  cmp bh,bl
  jne _findar2
  mov eax,0
  jmp _findar

;;;;;;;;;EXP;;;;;;;;;
 _dwbmath:
  mov edx,[byt]
  cmp edx,ebx
  je _xtobwd1
  mov edx,[wrd]
  cmp edx,ebx
  je _xtobwd2
  mov edx,[dwrd]
  cmp edx,ebx
  je _xtobwd3
  mov edx,[intt2]
  cmp edx,ebx
  je _exptoint2
  mov edx,[flt]
  cmp edx,ebx
  je _exptoflt
  mov edx,[ptrt]
  cmp edx,ebx
  je _exptoptr
  mov edx,[true]
  cmp edx,ebx
  je _exptotfn
  mov edx,[false]
  cmp edx,ebx
  je _exptotfn 
  ret
  
 _xtobwd1:
  call _savee
  jmp _genb
 _xtobwd2:
  call _savee
  jmp _genw
 _xtobwd3:
  call _savee
  jmp _gend
 
 _regexp:
  push ebx
  mov eax,alf
  mov edx,"alR"
  cmp edx,ebx
  je _exptoreg
  add eax,2
  mov edx,"ahR"
  cmp edx,ebx
  je _exptoreg
  add eax,2
  mov edx,"axR"
  cmp edx,ebx
  je _exptoreg
  add eax,2
  mov edx,"EAX"
  cmp edx,ebx
  je _exptoreg
  add eax,2
  mov edx,"blR"
  cmp edx,ebx
  je _exptoreg
  add eax,2
  mov edx,"bhR"
  cmp edx,ebx
  je _exptoreg
  add eax,2
  mov edx,"bxR"
  cmp edx,ebx
  je _exptoreg
  add eax,2
  mov edx,"EBX"
  cmp edx,ebx
  je _exptoreg
  add eax,2
  mov edx,"clR"
  cmp edx,ebx
  je _exptoreg
  add eax,2
  mov edx,"chR"
  cmp edx,ebx
  je _exptoreg
  add eax,2
  mov edx,"cxR"
  cmp edx,ebx
  je _exptoreg
  add eax,2
  mov edx,"ECX"
  cmp edx,ebx
  je _exptoreg
  add eax,2
  mov edx,"dlR"
  cmp edx,ebx
  je _exptoreg
  add eax,2
  mov edx,"dhR"
  cmp edx,ebx
  je _exptoreg
  add eax,2
  mov edx,"dxR"
  cmp edx,ebx
  je _exptoreg
  add eax,2
  mov edx,"EDX"
  cmp edx,ebx
  je _exptoreg
  add eax,2
  mov edx,"ESI"
  cmp edx,ebx
  je _exptoreg
  add eax,2
  mov edx,"EDI"
  cmp edx,ebx
  je _exptoreg
  pop ebx
  ret
 _restore:
  mov eax,[CIR2+0]
  mov edx,[CIR2+4]
  mov [CIR2+8],eax 
  mov [CIR2+12],edx
  ;;xhcg em 
  push ecx 
  mov ecx,[stackc]
  sub ecx,4
  mov edx,[stack+ecx]
  sub ecx,4
  mov eax,[stack+ecx]
  mov [stackc],ecx 
  pop ecx
  mov [CIR2+0],eax
  mov [CIR2+4],edx
  ret
 _savee:
  push ecx
  mov eax,[CIR2+0]
  mov edx,[CIR2+4] 
  mov ecx,[stackc]
  mov [stack+ecx],eax 
  add ecx,4
  mov [stack+ecx],edx 
  add ecx,4
  mov [stackc],ecx
  pop ecx 
  ret
 _savee2:
  push ecx
  mov eax,[CIR2+0]
  mov edx,[CIR2+4] 
  mov ecx,[stackc]
  mov [stack+ecx],eax 
  add ecx,4
  mov [stack+ecx],edx 
  add ecx,4
  mov [stackc],ecx
  pop ecx 
  mov eax,[CIR2+8]
  mov edx,[CIR2+12] 
  mov [CIR2+0],eax
  mov [CIR2+4],edx 
  ret
 _chkops:
  mov edx,[genseqts]
  mov bl,[genseq+edx]
  mov bh,"+"
  cmp bh,bl
  je _topls
  mov bh,"-"
  cmp bh,bl
  je _tomin
  mov bh,"*"
  cmp bh,bl
  je _tomul
  mov bh,"/"
  cmp bh,bl
  je _todiv
  mov bh,"^"
  cmp bh,bl
  je _topor
  pop eax
  mov [stackc],eax
  mov bl,"o"
  mov bh,[aodf]
  cmp bh,bl
  je _doaodmath
  add ecx,3
  mov bl,[genseq+edx]
  cmp bl,"("
  je _genlpr2
  sub ecx,3
  jmp _codegenerator
 
 _topls:
  call _restore
  jmp _dopls2
 _tomin:
  call _restore
  jmp _domin2
 _tomul:
  ;get eax back 
  call _restore
  jmp _domul2
 _todiv:
  call _restore
  jmp _dodiv
 _topor:
  call _restore
  jmp _dopor
 
 _exptoout:
  push ecx
  mov eax,[CIR2+0]
  mov edx,[CIR2+4]
  mov ecx,[stackc]
  mov [stack+ecx],eax 
  add ecx,4
  mov [stack+ecx],edx
  add ecx,4
  mov [stackc],ecx 
  pop ecx
  ret
 
 _exptofcl:  
  call _exptoout
  jmp genfcl
 _exptoaru:
  call _exptoout
  jmp _genaru
 _exptoid:
  call _exptoout
  jmp _genidt
 _exptonot:
  call _exptoout
  jmp _gennot
 _exptoreg:
  push ebx
  call _exptoout
  pop ebx
  add ecx,3
  jmp _genregsx
 _exptolpr:
  call _savee
  jmp _genlpr
 _exptoaod:
  call _savee
  jmp _genaod
 _exptoint2:
  call _savee
  jmp _gen2nt
 _exptoflt:
  call _savee
  ;jmp genflt
 _exptoptr:
  call _savee
  jmp _genptr
 _exptotfn:
  call _savee
  sub ecx,3
  jmp _codegenerator
  
 ;;;;!PLS!;;;;
 _exppls:
  mov edx,[genseqts]
  mov bl,byte[genseq+edx]
  mov bh,"n"
  cmp bh,bl
  je _exptonot 
  mov eax,[genseqts]
  mov bl,"+"
  add eax,1
  mov [genseq+eax],bl
  mov [genseqts],eax
 _exppls2: 
  call cgenread
  call _dwbmath
  mov edx,[lpr]
  cmp edx,ebx
  je _exptolpr
  mov edx,[aod]
  cmp edx,ebx
  je _exptoaod
  mov edx,[fcl]
  cmp edx,ebx
  je _exptofcl
  mov edx,[aru]
  cmp edx,ebx
  je _exptoaru
  mov edx,[idt]
  cmp edx,ebx
  je _exptoid
  mov edx,[nott]
  cmp edx,ebx
  je _exptonot 
  call _regexp
  mov edx,0
  call _readint 
  ;here we mov ebx,int
  push ecx
  mov bl,"+"
  mov [esi],bl
  inc esi 
  call _prnint; moves int to esi 
  mov [CIR2+8],eax
  mov [CIR2+12],edx  
  pop ecx
 _exppls3: 
  call cgenread
  mov edx,[pls]
  cmp edx,ebx
  je _plstopls
  mov edx,[min]
  cmp edx,ebx
  je _plstomin
  mov edx,[mult]
  cmp edx,ebx
  je _plstomul
  mov edx,[divt]
  cmp edx,ebx
  je _plstodiv
  mov edx,[port]
  cmp edx,ebx
  je _plstopor
  jmp _dopls

 _plstopls:
  call _movbadd
  jmp _exppls
 _plstomin:
  call _movbadd
  jmp _expmin
 _plstomul:
  call _savee2
  jmp _expmul
 _plstodiv:
  call _savee2
  jmp _expdiv
 _plstopor:
  call _savee2
  jmp _exppor
 
 _dopls:
  sub ecx,3
  call _movbadd
  jmp _chkops
 _dopls2:
  call _movbadd
  jmp _chkops
 
 _movbadd:
  push ecx
  mov eax,[CIR2+0]
  mov edx,[CIR2+4] 
  mov ebx,[CIR2+8]
  mov ecx,[CIR2+12]
  mov esi,[CIR2+20]
  call _CIADD_
  mov [CIR2+20],esi
  mov [CIR2+0],eax
  mov [CIR2+4],edx
  pop ecx
  mov edx,[genseqts]
  mov bl,0
  mov [genseq+edx],bl
  sub edx,1
  mov [genseqts],edx 
  ret

 _outtopls:
  call _restore
  jmp _exppls3
 ;;min;;
 _expmin:
  mov edx,[genseqts]
  mov bl,byte[genseq+edx]
  mov bh,"n"
  cmp bh,bl
  je _exptonot 
  mov eax,[genseqts]
  mov bl,"-"
  add eax,1
  mov [genseq+eax],bl
  mov [genseqts],eax 
  call cgenread
  call _dwbmath  
  mov edx,[lpr]
  cmp edx,ebx
  je _exptolpr
  mov edx,[aod]
  cmp edx,ebx
  je _exptoaod 
  mov edx,[fcl]
  cmp edx,ebx
  je _exptofcl
  mov edx,[aru]
  cmp edx,ebx
  je _exptoaru 
  mov edx,[idt]
  cmp edx,ebx
  je _exptoid
  mov edx,[nott]
  cmp edx,ebx
  je _exptonot  
  call _regexp 
  mov edx,0
  call _readint
  push ecx
  mov bl,"+"
  mov [esi],bl
  inc esi  
  call _prnint; moves int to esi 
  mov [CIR2+8],eax
  mov [CIR2+12],edx  
  pop ecx
 _expmin2: 
  call cgenread
  mov edx,[pls]
  cmp edx,ebx
  je _mintopls
  mov edx,[min]
  cmp edx,ebx
  je _mintomin
  mov edx,[mult]
  cmp edx,ebx
  je _mintomul
  mov edx,[divt]
  cmp edx,ebx
  je _mintodiv
  mov edx,[port]
  cmp edx,ebx
  je _mintopor
  jmp _domin

 _CIA2M_:
  push eax
  mov al,"-"
  mov ah,[ebx]
  mov [ebx],al
  mov [CIR2+17],ah 
  pop eax
  ret
 _CIM2A_:
  push eax
  mov ebx,[CIR2+8]
  mov al,[CIR2+17]
  mov [ebx],al
  pop eax
  ret


 _mintopls:
  call _savee2
  jmp _exppls
 _mintomin:
  push ecx
  mov ebx,[CIR2+8]
  mov ecx,[CIR2+12]  
  call _CIA2M_ ;make the integer signed 
  mov [CIR2+8],ebx
  mov [CIR2+12],ecx
  pop ecx
  call _movbadd2
  call _CIM2A_
  jmp _expmin
 _mintomul:
  call _savee2
  jmp _expmul
 _mintodiv:
  call _savee2
  jmp _expdiv
 _mintopor:
  call _savee2
  jmp _exppor
  
 _domin:
  sub ecx,3
 _domin2:
  push ecx
  mov ebx,[CIR2+8]
  mov ecx,[CIR2+12]  
  call _CIA2M_ ;make the integer signed 
  mov [CIR2+8],ebx
  mov [CIR2+12],ecx
  pop ecx
  call _movbadd2
  call _CIM2A_  
  
  jmp _chkops

 _movbadd2:
  push ecx
  mov eax,[CIR2+0]
  mov edx,[CIR2+4] 
  mov ebx,[CIR2+8]
  mov ecx,[CIR2+12]
  mov esi,[CIR2+20]
  call _CIADD_
  mov [CIR2+20],esi
  mov [CIR2+0],eax
  mov [CIR2+4],edx
  pop ecx
  mov edx,[genseqts]
  mov bl,0
  mov [genseq+edx],bl
  sub edx,1
  mov [genseqts],edx 
  ret


 ;;mul;;
 _expmul:
  mov edx,[genseqts]
  mov bl,byte[genseq+edx]
  mov bh,"n"
  cmp bh,bl
  je _exptonot 
  mov eax,[genseqts]
  mov bl,"*"
  add eax,1
  mov [genseq+eax],bl
  mov [genseqts],eax
  call cgenread
  call _dwbmath
  mov edx,[lpr]
  cmp edx,ebx
  je _exptolpr
  mov edx,[aod]
  cmp edx,ebx
  je _exptoaod 
  mov edx,[fcl]
  cmp edx,ebx
  je _exptofcl 
  mov edx,[aru]
  cmp edx,ebx
  je _exptoaru 
  mov edx,[idt]
  cmp edx,ebx
  je _exptoid
  mov edx,[nott]
  cmp edx,ebx
  je _exptonot  
  mov edx,0
  call _readint 
  push ecx
  call _prnint; moves int to esi 
  mov [CIR2+8],eax
  mov [CIR2+12],edx  
  ;edi is returned by prnint 
  pop ecx
 _expmul2: 
  call cgenread
  mov edx,[pls]
  cmp edx,ebx
  je _multopls
  mov edx,[min]
  cmp edx,ebx
  je _multomin
  mov edx,[mult]
  cmp edx,ebx
  je _multomul
  mov edx,[divt]
  cmp edx,ebx
  je _multodiv
  mov edx,[port]
  cmp edx,ebx
  je _multopor
  jmp _domul 
 
 _multopls:
  call _movbmul
  jmp _exppls 
 _multomin: 
  call _movbmul
  jmp _expmin
 _multomul:
  call _movbmul
  jmp _expmul 
 _multodiv:
  call _savee2
  jmp _expdiv
 _multopor:
  call _savee2
  jmp _exppor
  
 _domul:
  sub ecx,3
 _domul2:
  call _movbmul
  jmp _chkops

 lmao:
  pushad
  mov bl,[esi-1]
  add bl,30h
  mov [cntn],bl
  mov eax,cntn
  mov edx,1
  call _CIPRN_
  popad
  ret 
  
 _movbmul:
  push ecx
  mov eax,[CIR2+0]
  mov edx,[CIR2+4]
  mov ebx,[CIR2+8]
  mov ecx,[CIR2+12]
  mov esi,[CIR2+20]
  call _CIMUL_
  mov [CIR2+20],esi
  mov [CIR2+0],eax
  mov [CIR2+4],edx 
  pop ecx
  mov edx,[genseqts]
  mov bl,0
  mov [genseq+edx],bl
  sub edx,1
  mov [genseqts],edx  
  ret

 _outtomul:
  call _restore
  jmp _expmul2

 ;;div;;
 _expdiv:
  mov edx,[genseqts]
  mov bl,byte[genseq+edx]
  mov bh,"n"
  cmp bh,bl
  je _exptonot 
  mov eax,[genseqts]
  mov bl,"/"
  add eax,1
  mov [genseq+eax],bl
  mov [genseqts],eax
  call cgenread 
  call _dwbmath
  mov edx,[lpr]
  cmp edx,ebx
  je _exptolpr
  mov edx,[aod]
  cmp edx,ebx
  je _exptoaod  
  mov edx,[fcl]
  cmp edx,ebx
  je _exptofcl
  mov edx,[aru]
  cmp edx,ebx
  je _exptoaru 
  mov edx,[idt]
  cmp edx,ebx
  je _exptoid 
  mov edx,[nott]
  cmp edx,ebx
  je _exptonot  
  mov edx,0
  call _readint
  push ecx
  call _prnint; moves int to esi 
  mov [CIR2+8],eax
  mov [CIR2+12],edx
  ;edi is returned by prnint 
  pop ecx
 _expdiv2: 
  call cgenread 
  mov edx,[pls]
  cmp edx,ebx
  je _divtopls
  mov edx,[min]
  cmp edx,ebx
  je _divtomin
  mov edx,[mult]
  cmp edx,ebx
  je _divtomul
  mov edx,[divt]
  cmp edx,ebx
  je _divtodiv
  mov edx,[port]
  cmp edx,ebx
  je _divtopor 
  call _movbdiv
  sub ecx,3
  jmp _chkops 

 _dodiv:
  call _movbdiv
  jmp _chkops
 _divtopls:
  call _movbdiv
  jmp _exppls
 _divtomin:
  call _movbdiv
  jmp _expmin
 _divtomul:
  call _movbdiv
  jmp _expmul
 _divtodiv:
  call _movbdiv
  jmp _expdiv 
 _divtopor:
  call _savee2
  jmp _exppor  
 
 _movbdiv:
  push ecx
  mov eax,[CIR2+0]
  mov edx,[CIR2+4] 
  mov ebx,[CIR2+8]
  mov ecx,[CIR2+12]  
  mov esi,[CIR2+20]
  call _CIDIV_
  mov [CIR2+20],esi
  mov [CIR2+0],eax
  mov [CIR2+4],edx  
  pop ecx
  mov edx,[genseqts]
  mov bl,0
  mov [genseq+edx],bl
  sub edx,1
  mov [genseqts],edx 
  ret
 _outtodiv:
  call _restore
  jmp _expdiv2
  
 ;;por;;
 _exppor:
  mov edx,[genseqts]
  mov bl,byte[genseq+edx]
  mov bh,"n"
  cmp bh,bl
  je _exptonot 
  mov eax,[genseqts]
  mov bl,"^"
  add eax,1
  mov [genseq+eax],bl
  mov [genseqts],eax
  call cgenread 
  call _dwbmath 
  mov edx,[lpr]
  cmp edx,ebx
  je _exptolpr
  mov edx,[aod]
  cmp edx,ebx
  je _exptoaod
  mov edx,[fcl]
  cmp edx,ebx
  je _exptofcl
  mov edx,[aru]
  cmp edx,ebx
  je _exptoaru 
  mov edx,[idt]
  cmp edx,ebx
  je _exptoid 
  mov edx,[nott]
  cmp edx,ebx
  je _exptonot  
  mov edx,0
  call _readint
  push ecx
  call _prnint; moves int to esi 
  mov [CIR2+8],eax
  mov [CIR2+12],edx   
  pop ecx
 _exppor2: 
  call cgenread 
  mov edx,[pls]
  cmp edx,ebx
  je _portopls
  mov edx,[min]
  cmp edx,ebx
  je _portomin
  mov edx,[mult]
  cmp edx,ebx
  je _portomul
  mov edx,[divt]
  cmp edx,ebx
  je _portodiv
  mov edx,[port]
  cmp edx,ebx
  je _portopor
  call _movbpor
  sub ecx,3
  jmp _chkops 

 _portopls:
  call _movbpor
  jmp _exppls
 _portomin:
  call _movbpor
  jmp _expmin
 _portomul:
  call _movbpor
  jmp _expmul
 _portodiv:
  call _movbpor
  jmp _expdiv 
 _portopor:
  call _movbpor
  jmp _exppor
 
 _movbpor:
  push ecx
  mov eax,[CIR2+0]
  mov edx,[CIR2+4] 
  mov ebx,[CIR2+8]
  mov ecx,[CIR2+12]  
  mov esi,[CIR2+20]
  call _CIPOR_
  mov [CIR2+20],esi
  mov [CIR2+0],eax
  mov [CIR2+4],edx  
  pop ecx
  mov edx,[genseqts]
  mov bl,0
  mov [genseq+edx],bl
  sub edx,1
  mov [genseqts],edx 
  ret
 _outtopor:
  call _restore
  jmp _exppor2  
 
 _dopor:
  call _movbpor
  jmp _chkops


;;;;;;;;;ROCK BOTTOM;;;;;;;;
 _chkpres:
  mov edx,[genseqts]
  mov bl,byte[genseq+edx]
  mov bh,"n"
  cmp bh,bl
  je _genfinnot 
  mov bh,"~"
  cmp bh,bl
  je _fingenneg 
  sub ecx,3
  mov bh,"&"
  cmp bh,bl
  je _genfinand
  mov bh,"|"
  cmp bh,bl
  je _genfinor  
  call _chktocmp 
  call _chktoexp
  call _chkforbits
  add ecx,3
  ret
 _chktoexp:
  mov edx,[genseqts]
  mov bl,[genseq+edx]
  mov bh,"+"
  cmp bh,bl
  je _topls
  mov bh,"-"
  cmp bh,bl
  je _tomin
  mov bh,"*"
  cmp bh,bl
  je _tomul
  mov bh,"/"
  cmp bh,bl
  je _todiv
  mov bh,"^"
  cmp bh,bl
  je _topor
  ret
 
 _regmathx:
  mov ecx,alf
  mov edx,"alR"
  cmp edx,ebx
  je _genal
  add ecx,2
  mov edx,"ahR"
  cmp edx,ebx
  je _genah
  add ecx,2  
  mov edx,"axR"
  cmp edx,ebx
  je _genax
  add ecx,2  
  mov edx,"EAX"
  cmp edx,ebx
  je _geneax
  add ecx,2  
  mov edx,"blR"
  cmp edx,ebx
  je _genbl
  add ecx,2  
  mov edx,"bhR"
  cmp edx,ebx
  je _genbh
    add ecx,2
  mov edx,"bxR"
  cmp edx,ebx
  je _genbx
    add ecx,2
  mov edx,"EBX"
  cmp edx,ebx
  je _genebx
   add ecx,2 
  mov edx,"clR"
  cmp edx,ebx
  je _gencl 
   add ecx,2 
  mov edx,"chR"
  cmp edx,ebx
  je _gench
   add ecx,2 
  mov edx,"cxR"
  cmp edx,ebx
  je _gencx
   add ecx,2 
  mov edx,"ECX"
  cmp edx,ebx
  je _genecx
   add ecx,2 
  mov edx,"dlR"
  cmp edx,ebx
  je _gendl
   add ecx,2 
  mov edx,"dhR"
  cmp edx,ebx
  je _gendh
  add ecx,2  
  mov edx,"dxR"
  cmp edx,ebx
  je _gendx
  add ecx,2  
  mov edx,"EDX"
  cmp edx,ebx
  je _genedx
  add ecx,2  
  mov edx,"ESI"
  cmp edx,ebx
  je _genesi
  add ecx,2  
  mov edx,"EDI"
  cmp edx,ebx
  je _genedi
 
 _genal:
  movzx eax,byte[CIR+3]
  ret 
 _genah:
  movzx eax,byte[CIR+2]
  ret 
 _genax:
  movzx eax,word[CIR+2]
  ret   
 _geneax:
  mov eax,dword[CIR+0]
  ret 
 _genbl:
  movzx eax,byte[CIR+7]
  ret 
 _genbh:
  movzx eax,byte[CIR+6]
  ret 
 _genbx:
  movzx eax,word[CIR+6]
  ret 
 _genebx:
  mov eax,dword[CIR+4]
  ret 
 _gencl:
  movzx eax,byte[CIR+11]
  ret 
 _gench:
  movzx eax,byte[CIR+10]
  ret 
 _gencx:
  movzx eax,word[CIR+10]
  ret 
 _genecx:
  mov eax,dword[CIR+8]
  ret  
 _gendl:
  movzx eax,byte[CIR+15]
  ret 
 _gendh:
  movzx eax,byte[CIR+14]
  ret 
 _gendx:
  movzx eax,word[CIR+14]
  ret    
 _genedx:
  mov eax,dword[CIR+12]
  ret 
 _genesi:
  mov eax,dword[CIR+16]
  ret   
 _genedi:
  mov eax,dword[CIR+20]
  ret 
 
 
 _prnint: 
 mov ecx,[intc]
 mov eax,intv
 mov esi,[CIR2+20]
 push esi
 _prnint2:
 mov bl,[eax]
 mov [esi],bl
 inc esi
 inc eax
 loop _prnint2
 mov edx,[intc]
 mov bl,0xa
 mov [esi],bl
 pop esi
 mov eax,esi
 add esi,edx 
 inc esi
 dec edx
 mov [CIR2+20],esi
 ret 
 
  _CIPTR_:
  mov ebx,eax ;ado from eax to ebx 
  mov edx,-1
  _CIPTR2_:
  add edx,1
  mov cl,[ebx+edx]
  cmp cl,0xa 
  jne _CIPTR2_ 
  mov cl,[ebx+0]
  cmp cl,"+"
  je _CIPTRic_
  cmp cl,"-"
  je _CIPTRic_
  _CIPTRs_:
  add edx,1 
  ret 
  _CIPTRic_:
  mov cl,[ebx+1]
  cmp cl,10 
  jge _CIPTRs_
  dec edx 
  ret 
  
  
  
 
  _CIPRN_:
  mov ecx,eax 
  mov ebx,1
  mov eax,4
  int 0x80 
  ret 
 
  _CIBYT_:
  mov al,byte[eax+0]
  mov [esi],al
  mov eax,esi
  add esi,1
  mov dl,0xa
  mov [esi],dl
  inc esi  
  mov edx,1
  ret 
  
  _CIWRD_:
  movzx eax,Word[eax+0]
  mov [esi],ax
  mov eax,esi
  add esi,2
  mov dl,0xa
  mov [esi],dl
  inc esi
  mov edx,2
  ret   
  
   _CIDWR_:
  mov eax,dword[eax+0]
  mov [esi],eax
  mov eax,esi
  add esi,4
  mov dl,0xa
  mov [esi],dl
  inc esi
  mov edx,4
  ret 
  
  _CINEG_:
  mov bl,[eax]
  cmp bl,"+"
  je _CINEG1_
  mov bl,"+"
  mov [eax],bl
  ret 
  _CINEG1_:
  mov bl,"-"
  mov [eax],bl
  ret 
  
 _CINEQ_:
  cmp edx,ecx 
  jne _CINEQ3_
  dec eax 
  dec ebx
  inc ecx
  _CINEQ2_:
  inc eax
  inc ebx
  mov dl,[eax]
  mov dh,[ebx]
  cmp dl,dh
  jne _CINEQ3_
  loop _CINEQ2_
  push esi 
  mov bl,"+"
  mov [esi],bl
  mov bh,0
  mov [esi+1],bh
  mov bl,0xa 
  mov [esi+2],bl
  mov edx,1
  add esi,3
  pop eax
  ret
  _CINEQ3_:
  push esi 
  mov bl,"+"
  mov [esi],bl
  mov bh,1
  mov [esi+1],bh
  mov bl,0xa 
  mov [esi+2],bl
  mov edx,1
  add esi,3
  pop eax
  ret 
 _CIEQ2_:
  cmp edx,ecx 
  jne _CIEQ23_ ;false
  dec eax 
  dec ebx
  inc ecx
  _CIEQ22_:
  inc eax
  inc ebx
  mov dl,[eax]
  mov dh,[ebx]
  cmp dl,dh
  jne _CIEQ23_ ;false
  loop _CIEQ22_
  push esi 
  mov bl,"+"
  mov [esi],bl
  mov bh,1
  mov [esi+1],bh
  mov bl,0xa 
  mov [esi+2],bl
  mov edx,1
  add esi,3
  pop eax
  ret
  _CIEQ23_:
  push esi 
  mov bl,"+"
  mov [esi],bl
  mov bh,0
  mov [esi+1],bh
  mov bl,0xa 
  mov [esi+2],bl
  mov edx,1
  add esi,3
  pop eax
  ret  
 _CIGRT_:
  cmp edx,ecx 
  jl _CIGRT3_ ;false
  cmp edx,ecx
  jg _CIGRT1_
  dec eax
  dec ebx 
  inc ecx 
  _CIGRT2_:
  inc eax
  inc ebx
  mov dl,[eax]
  mov dh,[ebx]
  cmp dl,dh
  jl _CIGRT3_ ;false
  cmp dl,dh
  jg _CIGRT1_
  loop _CIGRT2_
  ;false if always equal 
  _CIGRT3_:
  push esi 
  mov bl,"+"
  mov [esi],bl
  mov bh,0
  mov [esi+1],bh
  mov bl,0xa 
  mov [esi+2],bl
  mov edx,1
  add esi,3
  pop eax
  ret
  _CIGRT1_:
  push esi 
  mov bl,"+"
  mov [esi],bl
  mov bh,1
  mov [esi+1],bh
  mov bl,0xa 
  mov [esi+2],bl
  mov edx,1
  add esi,3
  pop eax
  ret  
 _CILES_:
  cmp edx,ecx 
  jl _CILES1_ ;true
  cmp edx,ecx
  jg _CILES3_ ;false
  dec eax
  dec ebx 
  inc ecx 
  _CILES2_:
  inc eax
  inc ebx
  mov dl,[eax]
  mov dh,[ebx]
  cmp dl,dh
  jl _CILES1_ 
  cmp dl,dh
  jg _CILES3_;false
  loop _CILES2_
  ;false if always equal 
  _CILES3_:
  push esi 
  mov bl,"+"
  mov [esi],bl
  mov bh,0
  mov [esi+1],bh
  mov bl,0xa 
  mov [esi+2],bl
  mov edx,1
  add esi,3
  pop eax
  ret
  _CILES1_:
  push esi 
  mov bl,"+"
  mov [esi],bl
  mov bh,1
  mov [esi+1],bh
  mov bl,0xa 
  mov [esi+2],bl
  mov edx,1
  add esi,3
  pop eax
  ret    
 _CIGEQ_:
  cmp edx,ecx 
  jg _CIGEQ1_ ;true
  cmp edx,ecx
  jl _CIGEQ3_ ;false
  dec eax 
  dec ebx
  inc ecx
  _CIGEQ2_:
  inc eax
  inc ebx
  mov dl,[eax]
  mov dh,[ebx]
  cmp dl,dh
  jl _CIGEQ3_ ;false
  cmp dl,dh 
  jg _CIGEQ1_
  loop _CIGEQ2_
  _CIGEQ1_:
  push esi 
  mov bl,"+"
  mov [esi],bl
  mov bh,1
  mov [esi+1],bh
  mov bl,0xa 
  mov [esi+2],bl
  mov edx,1
  add esi,3
  pop eax
  ret
  _CIGEQ3_:
  push esi 
  mov bl,"+"
  mov [esi],bl
  mov bh,0
  mov [esi+1],bh
  mov bl,0xa 
  mov [esi+2],bl
  mov edx,1
  add esi,3
  pop eax
  ret  
 _CILEQ_:
  cmp edx,ecx 
  jl _CILEQ1_ ;true
  cmp edx,ecx
  jg _CILEQ3_ ;false
  dec eax 
  dec ebx
  inc ecx
  _CILEQ2_:
  inc eax
  inc ebx
  mov dl,[eax]
  mov dh,[ebx]
  cmp dl,dh
  jg _CILEQ3_ ;false
  cmp dl,dh 
  jl _CILEQ1_
  loop _CILEQ2_
  _CILEQ1_:
  push esi 
  mov bl,"+"
  mov [esi],bl
  mov bh,1
  mov [esi+1],bh
  mov bl,0xa 
  mov [esi+2],bl
  mov edx,1
  add esi,3
  pop eax
  ret
  _CILEQ3_:
  push esi 
  mov bl,"+"
  mov [esi],bl
  mov bh,0
  mov [esi+1],bh
  mov bl,0xa 
  mov [esi+2],bl
  mov edx,1
  add esi,3
  pop eax
  ret  
  
  
 _readint:
 mov [intc],edx
 mov bl,"+"
 mov [intv],bl
 inc edx
 _readintx:
 mov bl,[CISYN+ecx]
 cmp bl,"|"
 je _readint2
 sub bl,30h
 mov [intv+edx],bl
 inc edx
 inc ecx
 jmp _readintx
 _readint2:
 mov [intc],edx
 inc ecx
 ret

;;;;;;;;;;;;library '
 _CINOT_:
 push ecx 
 cmp edx,1
 jg _CIPUTF_
 mov cl,[eax+1]
 cmp cl,0xa
 je _CIPUTT_
 cmp cl,0
 je _CIPUTT_
 jmp _CIPUTF_
 
 _CIAND_:
 push ecx
 cmp edx,1
 jg _CIAND2_
 cmp ecx,1
 jg _CIAND3_
 mov cl,[eax+1]
 cmp cl,0xa
 je _CIPUTF_ ;if eax= null
 cmp cl,0
 je _CIPUTF_ ;if eax=0 (false)
 jmp _CIAND2_
 _CIAND2_:  ;eax is true
 mov cl,[ebx+1]
 cmp cl,0xa
 je _CIPUTF_ ;if ebx=null
 mov cl,[ebx+1]
 cmp cl,0
 je _CIPUTF_ ;if ebx=0 (false)
 jmp _CIPUTT_ ;if ebx==true 
 _CIAND3_:
 mov cl,[eax+1]
 cmp cl,0xa
 je _CIPUTF_
 mov cl,[eax+1]
 cmp cl,0
 je _CIPUTF_
 jmp _CIPUTT_
 
 _CIOR_:
 push ecx 
 cmp edx,1
 jg _CIPUTT_
 cmp ecx,1 
 jg _CIPUTT_
 mov cl,[eax+1]
 cmp cl,0xa
 je _CIOR2_
 cmp cl,0
 je _CIOR2_
 jmp _CIPUTT_
 _CIOR2_:
 mov cl,[ebx+1]
 cmp cl,0xa
 je _CIPUTF_
 mov cl,[ebx+1]
 cmp cl,0
 je _CIPUTF_
 jmp _CIPUTT_

 _CIPUTT_:
 mov cl,1
 mov ch,"+"
 call _CIPUTx_
 pop ecx
 ret
 _CIPUTx_:
 mov eax,esi
 mov [esi],ch
 inc esi
 mov [esi],cl
 inc esi 
 mov edx,1 
 ret 
 _CIPUTF_:
 mov cl,0
 mov ch,"+"
 call _CIPUTx_
 pop ecx
 ret
 



 ;;;;_CIADD_;;;;;
 _CIADD_:
 ;locate space;
 ;call chkx
 ;call chk3
 add esi,ecx
 add esi,edx
 add esi,edx
 add esi,ecx
 add esi,5
 push edx
 mov dl,[eax]
 cmp dl,"-"
 je _CISUBx_
 mov dl,[ebx]
 cmp dl,"-"
 je _CISUB_
 _CIADDsx_:
 mov dl,0xa 
 mov [esi],dl
 dec esi  
 pop edx
 cmp edx,ecx
 jge _CIADD2_
 xchg eax,ebx
 xchg edx,ecx
 jmp _CIADD2_
 _CIADD2_:;edx bigger
 push esi
 push eax
 push ecx
 push edx
 add eax,edx
 add ebx,ecx
 _CIADD3_:
 mov dl,[eax]
 mov dh,[ebx]
 add dl,dh;11
 cmp dl,9
 jg _CIADD4_;0
 mov dh,[esi];
 add dl,dh;
 cmp dl,10
 je _CIADD4a_ 
 cmp dl,9
 jg _CIADD4_ ;
 mov [esi],dl
 _CIADDx_:
 dec esi 
 dec eax
 dec ebx
 dec ecx
 cmp ecx,0
 jne _CIADD3_
 jmp _CIADD5a_
 _CIADD4_:
 ;sub dl,10
 mov dh,[esi]
 add dl,dh
 cmp dl,10
 je _CIADD4a_
 sub dl,10
 mov [esi],dl
 dec esi
 mov dh,[esi]
 add dh,1
 mov [esi],dh
 inc esi
 jmp _CIADDx_
 _CIADD4a_:
 mov dl,0
 mov [esi],dl
 dec esi
 mov dh,[esi]
 add dh,1
 mov [esi],dh
 inc esi
 jmp _CIADDx_
 _CIADD5a_:
 ;done;
 pop edx
 pop ecx
 pop eax
 sub edx,ecx
 cmp edx,0
 je _CIADD5b_
 add eax,edx
 mov ebx,edx
 _CIADD5_:
 mov dl,[eax]
 mov dh,[esi]
 add dl,dh
 mov [esi],dl
 dec esi
 dec eax
 dec ebx 
 cmp ebx,0
 jne _CIADD5_
 inc esi
 mov dl,[esi]
 dec esi
 cmp dl,"-"
 je _CIADD5c_
 cmp dl,"+"
 je _CIADD5c_
 mov dl,[eax]
 mov [esi],dl
 _CIADD5c_:
 mov eax,esi
 ;inc eax
 pop esi
 call _FIXZES_ 
 call _CILEN_
 ret
 _CIADD5b_:
 dec esi
 mov dl,[eax]
 mov [esi],dl
 jmp _CIADD5c_
 ;LEN gives 3 instead of 2 for edx in first attempt which causes error later 
 
 _CILEN_:
 push eax
 mov edx,-1
 _CILEN2_:
 add edx,1
 add eax,1
 mov cl,[eax]
 cmp cl,0xa
 jne _CILEN2_
 pop eax 
 ret

 _CISUBx_:
 mov dl,[ebx]
 cmp dl,"-"
 je _CIADDsx_
 _CISUB_:
 mov dl,[eax]
 mov dh,[ebx]
 mov [_CIPSV_+0],dl
 mov [_CIPSV_+1],dh
 mov dl,0xa 
 mov [esi],dl
 ;call chk3  
 dec esi  
 pop edx
 push ecx
 mov ecx,edx
 push esi
 add eax,edx
 push edx
 _CIMOVEE_:
 mov dl,[eax]
 mov [esi],dl
 dec eax
 dec esi
 loop _CIMOVEE_
 mov eax,esi
 pop edx
 pop esi
 pop ecx 
 push eax
 push ebx
 push ecx
 push edx
 ;sub eax,edx
 inc ebx
 inc eax
 cmp ecx,edx
 je _CISUBC_ ;just to know if the thing is only zero 
 ;, if not equal it just acts normally
 ;cause if in fin t shall do a cmp for lengths
 cmp ecx,edx
 jle _CISUB2x_
 _CISUB2_:
 pop edx
 pop ecx
 pop ebx
 pop eax
 xchg eax,ebx
 xchg edx,ecx 
 add ebx,ecx
 add eax,edx
 push edx
 mov dl,[_CIPSV_+1]
 mov [_CIPSV_+0],dl
 pop edx
 jmp _CISUB3_
 _CISUB2x_:
 pop edx
 pop ecx
 pop ebx
 pop eax 
 add ebx,ecx 
 add eax,edx
 ;sign is determind in fin
 _CISUB3_:
 push edx
 mov dl,[eax]
 mov dh,[ebx]
 cmp dl,dh 
 jl _CISUB4_
 sub dl,dh
 ;mov dh,[esi]
 ;add dl,dh
 mov [esi],dl
 pop edx
 _CISUB3b_: 
 ;call chk4
 dec eax
 dec ebx
 dec esi
 dec edx
 dec ecx
 cmp edx,0
 je _CISUBF2x_
 cmp ecx,0
 je _CISUBF_
 jmp _CISUB3_
 _CISUB4_:
 pop edx
 push edx  
 push eax
 _CISUB5a_:
 dec eax
 mov dl,[eax]
 cmp dl,0
 je _CISUB5b_
 cmp dl,"+"
 je _CISUB6b_
 cmp dl,"-"
 je _CISUB6b_ 
 jmp _CISUB6_
 _CISUB5b_:
 mov dl,9
 mov [eax],dl
 ;cmp edx,ecx
 ;je _CISUB6a_
 jmp _CISUB5a_
 _CISUB6_:
 mov dl,[eax]
 sub dl,1
 mov [eax],dl
 pop eax
 mov dl,[eax]
 mov dh,[ebx]
 add dl,10 
 sub dl,dh 
 mov [esi],dl 
 pop edx
 jmp _CISUB3b_
 _CISUB6b_:
 _CISUB6a_:
 pop eax
 mov dl,"-"
 mov [_CIPSV_+0],dl
 pop edx 
 push edx
 mov dl,[eax]
 mov dh,[ebx]
 ;add dl,dh
 sub dh,dl
 mov dl,dh
 mov dh,[esi]
 ;call chk 
 add dl,dh
 mov [esi],dl
 pop edx
 jmp _CISUB3b_
 _CISUBC_:
 mov dl,[eax]
 mov dh,[ebx]
 inc eax
 inc ebx
 cmp dl,dh
 jl _CISUB2_
 cmp dl,dh 
 jg _CISUB2x_
 loop _CISUBC_
 jmp _CISUB2x_
 ;its zero 
 _CISUBF_:
 mov ecx,edx
 _CISUBF2_: 
 mov dl,[eax]
 mov [esi],dl
 dec eax
 dec esi
 loop _CISUBF2_
 _CISUBF2x_:
 mov eax,esi 
 mov dl,[_CIPSV_+0]
 mov [eax],dl 
 call _FIXZES_
 ;call _chkzero_
 call _CILEN_
 ;call chkx
 ;call chk3 
 ret
 
  _CIPORdiv_:
 mov dl,"+"
 mov [_CIPSV3_],dl
 mov dl,1
 mov [_CIPSV3_+1],dl
 mov dl,0xa
 mov [_CIPSV3_+2],dl
 mov ebx,eax
 mov ecx,edx
 mov eax,_CIPSV3_
 mov edx,1 
 call _CIDIV_
 ret 
 _CIPOR_:
 push ecx 
 mov cl,[eax]
 mov [_CIPSV3_],cl
 mov cl,[ebx]
 mov [_CIPSV3_+1],cl
 pop ecx 
 mov [_CIPSV_+4],ebx
 mov [_CIPSV_+8],ecx
 mov ebx,eax 
 mov ecx,edx 
 _CIPOR2_:
 push eax 
 push edx
 call _CIMUL_
 ;mov dl,[eax+1]
 ;mov esi,eax
 ;mov ecx,edx
 push eax
 push edx
 mov ebx,_CIPSV2_
 mov ecx,1 
 mov eax,[_CIPSV_+4]
 mov edx,[_CIPSV_+8] 
 call _CIADD_
 ;;;;;;;
 push edx
 mov dl,[eax+1]
 cmp dl,1
 je _CIPORF_
 pop edx 
 ;;;;;;;
 mov [_CIPSV_+4],eax
 mov [_CIPSV_+8],edx 
 pop ecx;mul
 pop ebx;mul
 pop edx;normal
 pop eax;normal
 jmp _CIPOR2_
 _CIPORF_:
 pop edx
 pop edx
 pop eax
 pop ebx
 pop ebx 
 call _CILEN_
 mov cl,[_CIPSV3_]
 mov [eax],cl 
 mov cl,[_CIPSV3_+1]
 cmp cl,"-"
 je _CIPORdiv_
 ret 

 _CIMUL_:;locating memory
 ;esi,ecx,edx,eax,ebx,esi
 add esi,edx
 add esi,ecx
 add esi,edx
 add esi,10
 push edx
 mov dl,0xa
 mov [esi],dl
 pop edx
 dec esi
 push esi
 add eax,edx
 add ebx,ecx
 cmp ecx,edx
 jg _CIMUL2_
 push ecx
 mov cl,0
 push edx
 jmp _CIMUL3_
 _CIMUL2_:;chk whos bigger
 xchg eax,ebx
 xchg edx,ecx
 push ecx 
 mov cl,0
 push edx
 _CIMUL3_:;multiply
 push eax
 push ebx
 mov al,[eax]
 mov ah,0
 mov bl,[ebx]
 mov bh,0
 mul bl
 jmp _CIMUL4_
 _CIMUL3a_:
 pop ebx
 pop eax
 dec edx
 dec esi
 dec eax
 cmp edx,0
 je _CIMUL3b_
 jmp _CIMUL3_
 _CIMUL3b_:
 mov ch,[esi]
 add cl,ch
 mov [esi],cl
 pop edx
 pop ecx
 dec ecx
 dec esi
 cmp ecx,0
 je _CIMULF_
 pop esi
 add eax,edx
 dec ebx
 dec esi
 push esi
 push ecx
 push edx
 mov cl,0
 jmp _CIMUL3_
 _CIMUL4_:;chk result of mul
 mov ah,cl
 add al,ah
 mov ah,8
 mov bl,80 
 cmp al,80
 jge _CIMUL4a_ 
 sub ah,1
 mov bl,70
 cmp al,70
 jge _CIMUL4a_ 
 sub ah,1
 mov bl,60 
 cmp al,60
 jge _CIMUL4a_ 
 sub ah,1
 mov bl,50 
 cmp al,50
 jge _CIMUL4a_ 
 sub ah,1
 mov bl,40 
 cmp al,40
 je _CIMUL4a_ 
 sub ah,1
 mov bl,30 
 cmp al,30
 jge _CIMUL4a_ 
 sub ah,1
 mov bl,20 
 cmp al,20
 jge _CIMUL4a_ 
 sub ah,1
 mov bl,10 
 cmp al,10
 jge _CIMUL4a_
 sub ah,1
 mov cl,ah
 push esi 
 mov ah,[esi]
 add al,ah
 cmp al,10
 jge _CIMULA_
 mov [esi],al 
 pop esi
 jmp _CIMUL3a_
 _CIMUL4a_:
 mov cl,ah
 sub al,bl
 push esi
 _CIMUL4b_:
 mov ah,[esi]
 add al,ah
 cmp al,10
 jge _CIMULA_
 mov [esi],al 
 pop esi
 jmp _CIMUL3a_
 _CIMULA_:
 sub al,10
 mov [esi],al
 dec esi
 mov al,[esi]
 add al,1
 cmp al,10
 jge _CIMULA_
 mov [esi],al
 pop esi
 jmp _CIMUL3a_
 _CIMULF_:
 add esi,1
 dec ebx
 mov cl,[ebx]
 cmp cl,"-"
 je _CIMULS_
 mov ch,[eax+0]
 cmp ch,"-"
 je _CIMULS2_
 _CIMULFx_:
 mov ch,"+"
 dec esi
 mov [esi],ch
 _CIMULF0_:
 pop eax
 mov eax,esi
 call _FIXZES_
 call _CILEN_
 add esi,edx
 call _CIMULLC_
 ;mov [CIR2+0],eax
 ;mov [CIR2+4],edx
 ret ; :)
 _CIMULS_:
 mov cl,[eax+0]
 cmp cl,"-"
 je _CIMULFx_
 dec esi
 mov ch,"-"
 mov [esi],ch 
 jmp _CIMULF0_
 _CIMULS2_:
 mov ch,"+"
 dec esi
 mov [esi],ch
 jmp _CIMULF0_

 

 _CIMULLC_:
 push edx
 push esi
 ;dec esi ; because cilen returns lenth+1 
 _CIMULLC2_:
 mov dl,[esi]
 ;CMPS
  cmp dl,10
  je _CIMULLC3_ 
  cmp dl,11
  je _CIMULLC31_  
  cmp dl,12
  je _CIMULLC32_  
  cmp dl,13
  je _CIMULLC33_  
  cmp dl,14
  je _CIMULLC34_   
 cmp dl,"-"
 je _CIMULLCf_
 cmp dl,"+"
 je _CIMULLCf_ 
 dec esi
 jmp _CIMULLC2_
 ;_CIMULLC3_'s 
  _CIMULLC3_:
  mov dl,0
  mov [esi],dl 
  jmp  _CIMULLC3b_
  _CIMULLC31_:
  mov dl,1
  mov [esi],dl 
  jmp  _CIMULLC3b_
  _CIMULLC32_:
  mov dl,2
  mov [esi],dl 
  jmp  _CIMULLC3b_
  _CIMULLC33_:
  mov dl,3
  mov [esi],dl 
  jmp  _CIMULLC3b_
  _CIMULLC34_:
  mov dl,4
  mov [esi],dl 
  jmp  _CIMULLC3b_ 
 _CIMULLC3b_:
 dec esi 
 mov dl,[esi]
 cmp dl,"-"
 je _CIMULLC4_
 cmp dl,"+"
 je _CIMULLC4_
 add dl,1
 cmp dl,10 
 je _CIMULLC3_
 mov [esi],dl
 dec esi 
 jmp _CIMULLC2_
 _CIMULLC4_:
 mov dh,dl 
 mov dl,1
 mov [esi],dl 
 dec esi 
 mov [esi],dh 
 jmp _CIMULLC2_
 _CIMULLCf_:
 mov eax,esi
 pop esi
 pop edx
 call _CILEN_
 ret 

 
  _FIXZES_:
  push edx
  mov dh,[eax] ;sign 
  _FIXZES2_:
  inc eax
  mov dl,[eax]
  cmp dl,0 
  je _FIXZES4_
  jmp _FIXZES3_
  _FIXZES4_:
  mov [eax],dh
  jmp _FIXZES2_
  _FIXZES3_:
  cmp dl,0xa 
  je _FIXZES5_
  pop edx 
  dec eax 
  ret
  _FIXZES5_:
  dec eax
  mov dl,0
  mov [eax],dl
  dec eax
  mov [eax],dh
  pop edx
  ret
  
 _chkzero_:
  push edx 
  mov dl,[eax+1] 
  cmp dl,0xa
  je _chkzero2_
  pop edx
  ret 
  _chkzero2_:
  mov dl,0 
  mov [eax+1],dl
  mov dl,0xa
  mov [eax+2],dl
  pop edx
  ret

 _CIDIVSign_:
 mov cl,[ebx]
 cmp cl,"-"
 je _CIDIVpls_
 mov cl,"-"
 mov [esi],cl
 inc esi
 pop ecx
 jmp _CIDIVstart_
 _CIDIVpls_:
 mov cl,"+"
 mov [esi],cl
 inc esi 
 pop ecx
 jmp _CIDIVstart_
 _CIDIV_:
 push ecx 
 mov cl,[eax]
 cmp cl,"-"
 je _CIDIVSign_ 
 mov cl,[ebx]
 cmp cl,"-"
 jne _CIDIVpls_
 mov [esi],cl
 inc esi
 pop ecx
 _CIDIVstart_:
 mov [_CIDIVS_2],esi
 add esi,ecx 
 add esi,ecx
 add esi,edx
 add esi,5
 cmp edx,ecx
 jg _CIDIVe_
 cmp edx,ecx 
 je _CIDIVcom_
 jmp _CIDIVfix_
 FIXDIV10:
 push ecx 
 mov cl,[eax+1]
 mov ch,[ebx+1]
 cmp cl,ch 
 je FIXDIV10f 
 cmp cl,ch
 jg FIXDIV10f
 add edx,1
 pop ecx
 ret 
 FIXDIV10f:
 pop ecx 
 ret 
 _CIDIVe_:
 push ecx
 push ecx 
 push esi
 inc ecx
 _CIDIV1_:
 mov dl,[eax]
 mov [esi],dl
 inc esi
 inc eax 
 loop _CIDIV1_ 
 mov [_CIDIVS_+4],eax
 mov [_CIDIVS_+12],esi 
 pop eax
 mov [_CIDIVS_+8],esi 
 _CIDIV1a_:
 mov cl,"-"
 mov [ebx],cl
 pop ecx 
 pop edx 
 call FIXDIV10 
 push ebx
 push ecx
 _CIDIV2_:
 mov esi,[_CIDIVS_+8] 
 call _CIADD_
 mov [_CIDIVS_+8],esi  
 mov ecx,[_CIDIVS_+0]
 add ecx,1
 mov [_CIDIVS_+0],ecx
 pop ecx
 pop ebx
 push eax
 push ebx
 push edx
 _CIDIV2a_:
 inc eax
 inc ebx
 mov dl,[eax];res o sub
 mov dh,[ebx];divisor
 cmp dl,dh
 jg _CIDIV2cg_
 cmp dl,dh
 je _CIDIV2ce_
 pop edx
 push edx
 cmp edx,ecx 
 jg _CIDIV2s_
 pop edx
 pop ebx
 pop eax
 _CIDIV3_:
 call _CIDIVcm_
 jmp _CIDIVrem_
 _CIDIV3a_:
 push edx
 mov dl,[eax+1]
 cmp dl,0 
 je _CIDIVFin_
 pop edx 
 jmp _CIDIVL_ 
 
 ;if dividend ended, chk res o sub 

 _CIDIV2cg_:
 pop edx
 push edx
 cmp edx,ecx
 jge _CIDIV2s_
 pop edx;res o sub
 pop ebx 
 pop eax
 jmp _CIDIV3_
 _CIDIV2ce_:
 cmp dl,0xa
 je _CIDIV2s_
 pop edx 
 push edx 
 cmp edx,ecx
 jg _CIDIV2s_ 
 cmp edx,ecx
 je _CIDIV2a_
 pop edx
 pop ebx
 pop eax
 jmp _CIDIV3_
 _CIDIV2s_:
 pop edx
 pop ebx
 pop eax
 push ebx
 push ecx
 ;mov esi,[_CIDIVS_+12]
 jmp _CIDIV2_  

 _CIDIVFin_:
 pop edx
 mov eax,[_CIDIVS_2]
 call _CILEND_
 mov eax,esi
 Call _CIDIVCZ_
 mov eax,esi
 add esi,edx 
 add esi,2
 ret

 _CIDIV1x_:
 push ebx
 push ecx
 jmp _CIDIV2_
 _CIDIVcm_:
 push edx
 push ebx
 push eax
 mov esi,[_CIDIVS_2]
 mov eax,[_CIDIVS_] ;counted
 cmp eax,10
 jge _CIDIVcm3_
 mov ebx,10
 _CIDIVcm2_:
 xor edx,edx
 div ebx 
 mov [esi],dl ;result
 inc esi 
 cmp eax,0 
 jne _CIDIVcm2_
 mov [_CIDIVS_],eax
 mov [_CIDIVS_2],esi
 pop eax
 pop ebx
 pop edx
 ret
 _CIDIVcm3_:
 mov dl,1
 mov [esi],dl
 inc esi 
 mov dl,0
 mov [esi],dl
 inc esi 
 mov [_CIDIVS_],eax
 mov [_CIDIVS_2],esi
 pop eax
 pop ebx
 pop edx
 ret 
 
 ;move counted number to result by divison on 10 -_- 

 _CIDIVrem_:;mov rest o dividend to remainder 
 push eax 
 push ebx
 push ecx
 mov cl,[_CIDIVS_+17]
 cmp cl,"o"
 je _CIDIVremf_ 
 pop ecx
 jmp _CIDIVzs_
 _CIDIVrem1_:
 mov esi,[_CIDIVS_+4]
 dec esi
 add eax,edx  
 _CIDIVrem2_:
 push ecx
 inc eax 
 inc esi
 mov cl,[esi]
 cmp cl,0xa
 je _CIDIVremx_
 mov [eax],cl 
 inc edx 
 _CIDIVrem2b_:
 pop ecx 
 ;compare 
 cmp edx,ecx 
 jl _CIDIVrem2_
 cmp edx,ecx
 je _CIDIVrem3_
 _CIDIVrem2a_:
 inc esi
 mov [_CIDIVS_+4],esi
 mov [_CIDIVS_+12],eax
 mov esi,eax
 pop ebx
 pop eax
 jmp _CIDIV1x_
 _CIDIVremx_:
 mov cl,"o"
 mov [_CIDIVS_+17],cl 
 mov [_CIDIVS_+12],esi
 pop ecx
 pop ebx
 pop eax
 jmp _CIDIV3a_
 _CIDIVrem3_:
 push eax
 push ebx 
 push edx
 sub eax,edx
 sub ebx,ecx
 inc ebx
 _CIDIVrem3a_:
 inc eax
 inc ebx
 mov dl,[eax]
 mov dh,[ebx]
 cmp dl,dh 
 je _CIDIVrem3b_
 cmp dl,dh
 jl _CIDIVrem4_
 pop edx
 pop ebx
 pop eax
 jmp _CIDIVrem2a_
 _CIDIVrem3b_:
 cmp dl,0xa 
 jne _CIDIVrem4_ 
 pop edx
 pop ebx
 pop eax
 pop ebx
 pop eax
 jmp _CIDIV1a_
 _CIDIVrem4_:
 pop edx
 pop ebx
 pop eax
 jmp _CIDIVrem2_
 _CIDIVremf_:
 pop ecx 
 pop ebx
 pop eax
 jmp _CIDIV3a_ 

 _CIDIVL_:
 push edx
 mov dl,[_CIDIVS_+18]
 cmp dl,"o"
 je _CIDIVL3_
 push esi
 mov dl,"."
 mov esi,[_CIDIVS_2]
 mov [esi],dl
 inc esi 
 mov [_CIDIVS_2],esi
 pop esi 
 mov dl,"o"
 mov [_CIDIVS_+18],dl
 mov dl,[_CIDIVS_+19]
 sub dl,1
 mov [_CIDIVS_+19],dl 
 jmp _CIDIVL3_
 _CIDIVL2_:
 pop edx
 push edx
 mov dl,0
 mov esi,[_CIDIVS_2] ;result
 mov [esi],dl
 inc esi 
 mov [_CIDIVS_2],esi
 _CIDIVL3_:
 mov dl,[_CIDIVS_+19]
 add dl,1
 mov [_CIDIVS_+19],dl
 cmp dl,8 
 je _CIDIVFin_ 
 pop edx
 push eax
 push ecx 
 mov cl,0
 mov ch,0xa
 add eax,edx 
 inc eax
 mov [eax],cl
 inc eax 
 mov [eax],ch
 pop ecx
 pop eax 
 inc edx 
 ;;; comparison here 
 push eax
 push ebx
 push edx
 _CIDIVL3a_:
 inc eax
 inc ebx
 mov dl,[eax];res o sub
 mov dh,[ebx];divisor
 cmp dl,dh
 jg _CIDIVLcg_
 cmp dl,dh
 je _CIDIVLce_
 pop edx
 push edx
 cmp edx,ecx 
 jg _CIDIVLs_ ;valid
 _CIDIVLs2_:
 mov dl,[_CIDIVS_+19]
 sub dl,1
 mov [_CIDIVS_+19],dl 
 pop edx
 pop ebx
 pop eax
 push edx
 jmp _CIDIVL2_
 _CIDIVLcg_:
 pop edx
 push edx
 cmp edx,ecx
 jge _CIDIVLs_ ;valid
 jmp _CIDIVLs2_; not valid, add more
 _CIDIVLce_:
 cmp dl,0xa
 jne _CIDIVL3a_
 pop edx
 push edx 
 cmp edx,ecx 
 jge _CIDIVLs_
 jmp _CIDIVL3a_
 _CIDIVLs_:
 pop edx
 pop ebx
 pop eax
 jmp _CIDIV1x_

 ;tell me what im doin here, if im not bein real mmm.

 _CILEND_:
 mov esi,[_CIDIVS_2]
 mov dl,0xa
 mov [esi],dl 
 mov edx,0
 dec esi
 _CILEND2_:
 mov cl,[esi]
 cmp cl,"-"
 je _CILEND3_
 cmp cl,"+"
 je _CILEND3_
 dec esi
 inc edx
 jmp _CILEND2_
 _CILEND3_:
 ret

 _CIDIVCZ_: 
 ;clear zeroes
 push eax
 inc eax
 mov ecx,[_CIDIVS_+8]
 cmp edx,ecx
 jg _CIDIVZC2_
 pop eax
 ret 
 _CIDIVZC2_:
 mov bl,[eax]
 cmp bl,0
 je _CIDIVZC3_ 
 ;cmp bl,0xa 
 ;je CIDIVZC4
 inc eax
 jmp _CIDIVZC2_
 _CIDIVZC3_:
 push eax
 push ecx 
 mov ecx,eax
 ;dec ecx
 _CIDIVZC3a_:
 inc eax
 mov bl,[eax]
 mov [ecx],bl
 inc ecx
 cmp bl,0xa 
 jne _CIDIVZC3a_
 pop eax
 pop ecx
 dec edx
 cmp edx,ecx 
 jg _CIDIVZC2_
 pop eax
 ret 
 _CIDIVzs_:
 push edx
 mov dl,[eax+1]
 cmp dl,0
 jne _CIDIVzsx_
 push eax 
 mov eax,[_CIDIVS_+4]
 mov dl,[eax]
 cmp dl,0
 jne _CIDIVzsx2_
 inc eax
 _CIDIVzs2_:
 mov dl,[eax]
 cmp dl,0 
 je _CIDIVzs3_
 cmp dl,0xa 
 je _CIDIVzs4_
 ;;;;;;;;;;;;;;;;;;
 mov dl,0
 push esi
 mov esi,[_CIDIVS_2]
 mov [esi],dl
 inc esi 
 inc esi
 mov [_CIDIVS_2],esi
 pop esi 
 ;might need to be deleted
 mov [_CIDIVS_+4],eax
 pop eax 
 pop edx
 dec edx
 jmp _CIDIVrem1_
 _CIDIVzs3_:
 push esi
 mov esi,[_CIDIVS_2]
 mov [esi],dl
 inc esi 
 mov [_CIDIVS_2],esi
 pop esi
 inc eax
 jmp _CIDIVzs2_
 _CIDIVzs4_:
 mov [_CIDIVS_+4],eax
 pop edx 
 pop eax 
 push ecx
 mov cl,"o"
 mov [_CIDIVS_+17],cl 
 pop ecx
 pop ebx 
 pop eax
 jmp _CIDIV3a_
 _CIDIVzsx_:
 pop edx
 jmp _CIDIVrem1_
 _CIDIVzsx2_:
 pop eax
 pop edx
 dec edx
 jmp _CIDIVrem1_

 _CIDIVfix_:
 push ecx 
 mov cl,"o"
 mov [_CIDIVS_+17],cl 
 push esi
 mov esi,[_CIDIVS_2]
 mov cl,0
 mov [esi],cl
 inc esi 
 mov [_CIDIVS_2],esi
 pop esi 
 pop ecx 
 push ecx
 push edx
 mov ecx,edx
 push esi
 inc ecx 
 _CIDIVfix1_:
 mov dl,[eax]
 mov [esi],dl
 inc esi
 inc eax 
 loop _CIDIVfix1_ 
 mov [_CIDIVS_+4],eax
 mov [_CIDIVS_+12],esi 
 pop eax
 mov [_CIDIVS_+8],esi 
 pop edx 
 pop ecx 
 jmp _CIDIVL_
 _CIDIVcom_:
 push edx
 push eax
 push ebx 
 _CIDIVcom1_:
 inc eax
 inc ebx
 mov dl,[eax]
 mov dh,[ebx]
 cmp dl,dh
 jl _CIDIV2fix_
 cmp dl,dh 
 jg _CIDIV2e_
 cmp dl,0xa 
 jne _CIDIVcom1_
 pop ebx 
 pop eax 
 pop edx 
 jmp _CIDIVe_ ; equal all 
 _CIDIV2fix_:
 pop ebx 
 pop eax 
 pop edx 
 jmp _CIDIVfix_
 _CIDIV2e_:
 pop ebx 
 pop eax 
 pop edx 
 jmp _CIDIVe_
 
 
 _CISHL_:
 call _BITBYTEF_
 call _CIMEM2REG_  
 _CISHL2_:
 shl eax,1
 loop _CISHL2_
 call _CIREG2MEM_ 
 mov eax,esi 
 ret 
 
 _CISHR_:
 call _BITBYTEF_
 call _CIMEM2REG_
 _CISHR2_:
 shr eax,1
 loop _CISHR2_
 call _CIREG2MEM_ 
 mov eax,esi 
 ret 

 _CIROL_:
 call _BITBYTEF_
 call _CIMEM2REG_  
 _CIROL2_:
 rol eax,1
 loop _CIROL2_
 call _CIREG2MEM_ 
 mov eax,esi 
 ret  
 
 _CIROR_:
 call _BITBYTEF_
 call _CIMEM2REG_  
 _CIROR2_:
 ror eax,1
 loop _CIROR2_
 call _CIREG2MEM_ 
 mov eax,esi 
 ret 
 
 ;convert to register
 _CIMEM2REG_:
 mov bl,[eax]
 cmp bl,"-"
 je _CIN2Rb_
 cmp bl,"+"
 je _CIN2Rb_ 
 jmp _CIN2Rstr_  
 _CIN2Rb_:
 push esi
 push ecx ;meh
 push eax  ;source
 push edx ;length
 mov bl,0
 mov [_CIPSV_+5],bl 
 mov bl,[eax]
 cmp bl,"-"
 jne _CIN2Rs_
 mov [_CIPSV_+5],bl 
 _CIN2Rs_:
 mov [_CIPSV_],eax 
 mov ebx,eax
 mov eax,1 
 push eax
 mov eax,ebx
 mov esi,0 ;target 
 xor ebx,ebx
 _CIN2R2_:
 mov eax,[_CIPSV_]
 mov bl,[eax+edx]
 dec edx 
 pop eax 
 push edx
 push eax
 xor edx,edx
 mul ebx 
 add esi,eax
 pop eax
 mov ebx,10 
 xor edx,edx 
 mul ebx ;eax*ebx 
 pop edx 
 push eax 
 cmp edx,0
 jne _CIN2R2_
 pop eax
 _CIN2R3_:
 pop edx  
 pop eax
 pop ecx 
 mov eax,esi 
 pop esi
 mov bl,[_CIPSV_+5]
 cmp bl,"-"
 je _CIN2R4_ 
 ;add eax,30h 
 ;ov []
 ret 
 _CIN2R4_:
 neg eax 
 ret 
 _CIN2Rstr_:
 cmp edx,0 
 je _CIN2Rstrs_
 cmp edx,1
 jge _CIN2Rstrchk_
 push esi
 push ecx 
 mov ecx,0
 mov [esi],ecx
 mov ecx,edx
 cmp ecx,4
 jg _CIN2Rstrs2_ 
 _CIN2Rstrs_:
 mov bl,[eax]
 mov [esi],bl
 inc esi 
 inc eax 
 cmp bl,0xa
 jne _CIN2Rstrs_
 dec esi
 sub esi,edx 
 mov bl,"o"
 mov [_CIPSV_+5],bl ;str
 mov eax,[esi]
 pop ecx
 pop esi
 ret 
 _CIN2Rstrs2_:
 mov ecx,4
 jmp _CIN2Rstrs_
 _CIN2Rstrchk_:
 push esi
 push ecx
 mov bl,[eax+1]
 cmp bl,10
 jge _CIN2Rstrs_
 pop ecx
 pop esi
 jmp _CIN2Rb_
 
 ;convert to normal
 _CIREG2MEM_:  ;REQUIRES EDX LENGTH OF REGISTER VALUES 
 mov bl,[_CIPSV_+5]
 cmp bl,"o"
 je _CIR2Ns_
 push edx 
 push ecx 
 inc esi ;sign 
 cmp eax,0 
 jl _CIR2Nneg_
 mov bl,"+"
 mov [_CIPSV_+5],bl
 add esi,edx
 mov ebx,10 
 _CIR2N2_:
 xor edx,edx
 div ebx 
 mov [esi],dl
 dec esi
 cmp eax,0 
 jne _CIR2N2_
 pop ecx
 pop edx 
 mov bl,[_CIPSV_+5]
 mov [esi],bl
 mov eax,esi
 ;done 
 ret 
 _CIR2Nneg_:
 neg eax 
 mov bl,"-"
 mov [_CIPSV_+5],bl 
 add esi,edx
 mov ebx,10
 jmp _CIR2N2_
 _CIR2Ns_:
 mov bl,[eax+0]
 mov [esi],bl
 inc esi 
 mov bl,[eax+1]
 mov [esi],bl
 inc esi 
 mov bl,[eax+2]
 mov [esi],bl
 inc esi 
 mov bl,[eax+3]
 mov [esi],bl
 sub esi,3
 mov eax,esi
 mov edx,4
 add esi,4 
 mov bl,0
 mov [_CIPSV_+5],bl
 ret 
 
 
 _BITBYTEF_: ;converts second integer to register
 push edx
 push eax
 mov eax,ebx
 mov edx,ecx
 call _CIMEM2REG_ 
 mov ecx,eax
 pop eax
 pop edx
 ret
 

 ;do not move with negative numbers in bits or bytes!  
 ;;;;;;;;;;;;BYTES;;;;;;;;;;; 
 _CISHLf_:
 call _BITBYTEF_ 
 call _CIMOVEx_ 
 push edx 
 push ebx 
 mov bl,0
 inc eax
 mov [eax+edx],bl
 dec eax
 inc edx
 _CISHLf2_:
 inc eax ;byte discarded 
 mov [eax+edx],bl 
 loop _CISHLf2_
 mov bl,0xa 
 mov [eax+edx],bl
 pop ebx 
 pop edx 
 ret  
 _CISHRf_:
 add esi,ecx
 call _BITBYTEF_  
 call _CIMOVEx_
 push edx 
 push ebx
 mov bl,0
 inc eax
 mov [eax+edx],bl
 dec eax
 _CISHRf2_:
 mov [eax],bl
 dec eax
 loop _CISHRf2_
 pop ebx 
 pop edx 
 push ebx
 mov bl,0xa
 inc eax
 mov [eax+edx],bl
 dec eax
 pop ebx
 ret 
 
 
 _CIROLf_: 
 call _BITBYTEF_ 
 call _CIMOVEx_
 push edx
 push ebx
 _CIROLf2_:
 mov bl,[eax]
 inc eax
 mov [eax+edx],bl
 loop _CIROLf2_
 pop ebx 
 pop edx 
 push ebx
 mov bl,0xa
 inc eax 
 mov [eax+edx],bl
 dec eax
 pop ebx
 ret  
 _CIRORf_:
 add esi,edx
 call _BITBYTEF_ 
 call _CIMOVEx_
 push edx
 push ebx
 _CIRORf2_:
 mov bl,[eax+edx]
 dec eax 
 mov [eax],bl
 loop _CIRORf2_
 pop ebx 
 pop edx 
 push ebx
 mov bl,0xa
 inc eax
 mov [eax+edx],bl
 dec eax
 pop ebx
 ret  

 _CIMOVEx_:
 push edx
 push esi 
 _CIMOVEx2_:
 mov dl,[eax]
 mov [esi],dl
 inc eax 
 inc esi 
 cmp dl,0xa 
 jne _CIMOVEx2_
 pop eax
 pop edx
 ret 
 

 _CI2NT_:
 push edx
 push esi
 mov ecx,edx
 _CIINT2_:
 mov dl,[eax+ecx]
 sub dl,30h
 mov [esi+ecx],dl
 loop _CIINT2_
 mov dl,[eax+ecx]
 sub dl,30h
 mov [esi+ecx],dl 
 pop eax;eax==esi before
 pop edx
 inc edx
 add esi,edx
 mov bl,0xa
 mov [esi],bl 
 inc esi
 sub edx,2
 ret
 
 _CI2TR_:
 push edx
 push esi
 mov ecx,edx
 _CI2TR2_:
 mov dl,[eax+ecx]
 add dl,30h
 mov [esi+ecx],dl
 loop _CI2TR2_
 mov dl,[eax+ecx]
 add dl,30h
 mov [esi+ecx],dl 
 pop eax;eax==esi before
 pop edx
 inc edx
 add esi,edx
 mov bl,0xa
 mov [esi],bl 
 inc esi
 ret
  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;make another "save" for moving from exp to exp that exchanges ebx and eax 


codegenerator:
 call cgenread
 ;regs
  mov eax,alf
  mov edx,"alR"
  cmp edx,ebx
  je genreg
  add eax,2
  mov edx,"ahR"
  cmp edx,ebx
  je genreg
  add eax,2
  mov edx,"axR"
  cmp edx,ebx
  je genreg
  add eax,2
  mov edx,"EAX"
  cmp edx,ebx
  je genreg
  add eax,2
  mov edx,"blR"
  cmp edx,ebx
  je genreg
  add eax,2
  mov edx,"bhR"
  cmp edx,ebx
  je genreg
  add eax,2
  mov edx,"bxR"
  cmp edx,ebx
  je genreg
  add eax,2
  mov edx,"EBX"
  cmp edx,ebx
  je genreg
  add eax,2
  mov edx,"clR"
  cmp edx,ebx
  je genreg 
  add eax,2
  mov edx,"chR"
  cmp edx,ebx
  je genreg
  add eax,2
  mov edx,"cxR"
  cmp edx,ebx
  je genreg
  add eax,2
  mov edx,"ECX"
  cmp edx,ebx
  je genreg
  add eax,2
  mov edx,"dlR"
  cmp edx,ebx
  je genreg
  add eax,2
  mov edx,"dhR"
  cmp edx,ebx
  je genreg
  add eax,2
  mov edx,"dxR"
  cmp edx,ebx
  je genreg
  add eax,2
  mov edx,"EDX"
  cmp edx,ebx
  je genreg
  add eax,2
  mov edx,"ESI"
  cmp edx,ebx
  je genreg
  add eax,2
  mov edx,"EDI"
  cmp edx,ebx
  je genreg
 mov edx,[psht]
 cmp edx,ebx
 je cgenpush
 mov edx,[popt]
 cmp edx,ebx 
 je cgenpop
 mov edx,"DOT"
 cmp edx,ebx
 je cgenbitsdot
 mov edx,[negt]
 cmp edx,ebx
 je genneg
 mov edx,[byt]
 cmp edx,ebx
 je genb
 mov edx,[wrd]
 cmp edx,ebx
 je genw
 mov edx,[dwrd]
 cmp edx,ebx
 je gend
 mov edx,[aod]
 cmp edx,ebx
 je genaod
 mov edx,[lpr]
 cmp edx,ebx
 je genlpr
 mov edx,[rpr]
 cmp edx,ebx
 je genlpr2
 mov edx,[intt2]
 cmp edx,ebx
 je gen2nt
 mov edx,[strt2]
 cmp edx,ebx
 je gen2tr 
 mov edx,[ptrt]
 cmp edx,ebx
 je genptr
 mov edx,[end2]
 cmp edx,ebx
 je genend2
 mov edx,[fprint]
 cmp edx,ebx
 je genprint2
 mov edx,[fdf]
 cmp edx,ebx
 je genfdf
 mov edx,[var]
 cmp edx,ebx
 je genvar 
 mov edx,[fcl]
 cmp edx,ebx 
 je genfcl
 mov edx,[fce]
 cmp edx,ebx
 je genfce2
 mov edx,[rett]
 cmp edx,ebx
 je genret
 mov edx,[cma]
 cmp edx,ebx
 je gencma
 mov edx,[rolt]
 cmp edx,ebx
 je genrolt
 mov edx,[rort]
 cmp edx,ebx
 je genrort
 mov edx,[shlt]
 cmp edx,ebx
 je genshlt
 mov edx,[shrt]
 cmp edx,ebx
 je genshrt 
 mov edx,[rolf]
 cmp edx,ebx
 je genrolf  
 mov edx,[rorf]
 cmp edx,ebx
 je genrorf  
 mov edx,[shlf]
 cmp edx,ebx
 je genshlf  
 mov edx,[shrf]
 cmp edx,ebx
 je genshrf   
 mov edx,[ard]
 cmp edx,ebx
 je genard
 mov edx,[are]
 cmp edx,ebx
 je genfinard
 mov edx,[aru]
 cmp edx,ebx
 je genaru
 mov edx,[print]
 cmp edx,ebx
 je genprint
 mov edx,[strt]
 cmp edx,ebx
 je genstr
 mov edx,[if]
 cmp edx,ebx
 je genif 
 mov edx,[endf2]
 cmp edx,ebx
 je genfinif
 mov edx,[while]
 cmp edx,ebx
 je genwil 
 mov edx,[endw]
 cmp edx,ebx
 je genfinwil
 mov edx,[end]
 cmp edx,ebx
 je genbr2
 mov edx,[nott]
 cmp edx,ebx
 je gennot
 mov edx,[andt]
 cmp edx,ebx
 je genand
 mov edx,[ort]
 cmp edx,ebx
 je genor
 mov edx,[else]
 cmp edx,ebx
 je genelse
 mov edx,[neq]
 cmp edx,ebx
 je genneq
 mov edx,[eq2]
 cmp edx,ebx
 je geneq2
 mov edx,[grt]
 cmp edx,ebx
 je gengrt
 mov edx,[lest]
 cmp edx,ebx
 je genles
 mov edx,[geq]
 cmp edx,ebx
 je gengeq
 mov edx,[leq]
 cmp edx,ebx
 je genleq 
 mov edx,[ade]
 cmp edx,ebx
 je genfinaru
 mov edx,[intt]
 cmp edx,ebx
 je genint 
 mov edx,[flt]
 cmp edx,ebx
 je genflt  
 mov edx,[true]
 cmp edx,ebx
 je gentrue
 mov edx,[false]
 cmp edx,ebx
 je genfalse
 mov edx,[nullt]
 cmp edx,ebx
 je gennull
 mov edx,[idt]
 cmp edx,ebx
 je genidt  
 mov edx,[term]
 cmp edx,ebx
 je genterm
 mov edx,[eof]
 cmp edx,ebx
 je cgenfin
 mov edx,[pls]
 cmp edx,ebx
 je exppls
 mov edx,[min]
 cmp edx,ebx
 je expmin
 mov edx,[mult]
 cmp edx,ebx
 je expmul
 mov edx,[divt]
 cmp edx,ebx
 je expdiv 
 mov edx,[port]
 cmp edx,ebx
 je exppor
 mov edx,[npt]
 cmp edx,ebx
 je cgennpt 
 mov edx,[br1]
 cmp edx,ebx
 je codegenerator
 jmp error

;regfunc converts given value to fit a register
genregfunc:
 mov bl,"o"
 mov eax,[CIR2+24]
 mov [eax+1],bl 
 mov [regfunc],bl
 jmp _codegenerator

;dont use input in regdef
genreg:
 push ebx
 push eax
 call cgenread
 mov edx,[equt]
 cmp edx,ebx
 je regdef 
 pop eax
 pop ebx
 genregsx:
 call regmathx 
 push ecx
 mov ecx,"call"
 mov edx,4
 call prnx
 mov ecx," _CI"
 call prnx
 mov ecx,"REG2"
 call prnx
 mov ecx,"MEM_"
 call prnx
 call prnnull
 pop ecx 
 sub ecx,3 
 jmp codegenerator 
regdef:
 pop eax ;adress of the register flag
 pop ebx ;register
 mov bl,"o"
 mov [regf],bl ;flag of regdef
 mov bl,"v"
 mov [eax+0],bl ;flag of the register
 mov [CIR2+24],eax
 call cgenread
 mov edx,[aod]
 cmp edx,ebx
 je regdefa
 mov edx,"REG"
 cmp edx,ebx
 je genregfunc
 sub ecx,3
 jmp _codegenerator
 regdefa:
 mov bl,"o"
 mov [regfaod],bl
 sub ecx,3
 jmp _codegenerator
regdef2:
 sub ecx,3 ;to read trm
 mov bl,"a"
 mov [regf],bl 
 mov bl,[regfaod]
 cmp bl,"o"
 je regdef2a
 mov bl,[regfunc]
 cmp bl,"o"
 jne regdef2a
 push ecx
 mov esi,[CIR2+20]
 mov eax,[CIR2+0]
 mov edx,[CIR2+4]
 call _CIMEM2REG_
 mov [CIR2+20],esi
 mov [CIR2+0],eax
 pop ecx  
 mov bl,"z"
 mov [regf],bl
regdef2a: 
 push ecx
 call recreg
 pop ecx
 mov bl,"z"
 mov [regf],bl
 mov [regfaod],bl 
 mov [regfunc],bl
 jmp _codegenerator


genprint:
 mov edx,[genseqts]
 mov bl,"p"
 add edx,1
 mov [genseq+edx],bl
 mov [genseqts],edx
 jmp codegenerator
genprint2:
 mov edx,[genseqts]
 mov bl,0
 mov [genseq+edx],bl
 mov [genseqts],edx
 push ecx
 mov ecx,"call"
 mov edx,4
 call prnx
 mov ecx," _CI"
 call prnx
 mov ecx,"PRN_"
 call prnx
 call prnnull
 pop ecx
 jmp codegenerator
 genprint3:
 push ecx
 mov ecx,"call"
 mov edx,4
 call prnx
 mov ecx," _CI"
 call prnx
 mov ecx,"PRN_"
 call prnx
 call prnnull
 pop ecx
 jmp codegenerator ;move target to runtime through data
 
cgenpush:
 mov edx,[genseqts]
 mov bl,"?"
 add edx,1
 mov [genseq+edx],bl
 mov [genseqts],edx
 jmp codegenerator
cgenpush2:
 mov edx,[genseqts]
 mov bl,0
 mov [genseq+edx],bl
 mov [genseqts],edx
 push ecx
 mov ecx,"call"
 mov edx,4
 call prnx
 mov ecx," _CI"
 call prnx
 mov ecx,"PSH_"
 call prnx
 call prnnull
 pop ecx
 jmp codegenerator
cgenpop:
 mov edx,[genseqts]
 mov bl,"$"
 add edx,1
 mov [genseq+edx],bl
 mov [genseqts],edx
 jmp codegenerator
cgenpop2:
 mov edx,[genseqts]
 mov bl,0
 mov [genseq+edx],bl
 mov [genseqts],edx
 push ecx
 mov ecx,"call"
 mov edx,4
 call prnx
 mov ecx," _CI"
 call prnx
 mov ecx,"POP_"
 call prnx
 call prnnull
 pop ecx
 jmp codegenerator
 
genend2:
 mov edx,[genseqts]
 mov bl,"i"
 mov bh,[genseq+edx]
 cmp bh,bl
 je gen2nt2
 mov bl,"s"
 cmp bh,bl
 je gen2tr2
 
gen2nt:
 mov edx,[genseqts]
 mov bl,"i"
 add edx,1
 mov [genseq+edx],bl
 mov [genseqts],edx
 jmp codegenerator
gen2nt2:
 mov edx,[genseqts]
 mov bl,0
 mov [genseq+edx],bl
 dec edx
 mov [genseqts],edx
 push ecx
 mov ecx,"call"
 mov edx,4
 call prnx
 mov ecx," _CI"
 call prnx
 mov ecx,"2NT_"
 call prnx
 call prnnull
 pop ecx
 call bwdxmath 
 jmp codegenerator
 
gen2tr:
 mov edx,[genseqts]
 mov bl,"s"
 add edx,1
 mov [genseq+edx],bl
 mov [genseqts],edx
 jmp codegenerator
gen2tr2:
 mov edx,[genseqts]
 mov bl,0
 mov [genseq+edx],bl
 dec edx
 mov [genseqts],edx
 push ecx
 mov ecx,"call"
 mov edx,4
 call prnx
 mov ecx," _CI"
 call prnx
 mov ecx,"2TR_"
 call prnx
 call prnnull
 pop ecx
 jmp codegenerator

genaod:
 mov edx,0
 call readid
 mov eax,0
 mov edx,0
 call getidseq
 push ecx
 push eax ;location in stack (stack+eax)
 mov ecx,"mov "
 mov edx,4
 call prnx
 call prneax
 mov ecx,"[esp"
 call prnx
 mov ecx,"+"
 mov edx,1
 call prnx
 pop eax
 call itos
 call prncij2
 mov ecx,"]"
 mov edx,1
 call prnx
 call prnnull ;mov eax,[esp+number] now eax has the address of it
 mov ecx,"mov "
 mov edx,4
 call prnx
 call prnedx
 mov ecx,"4"
 mov edx,1
 call prnx
 call prnnull
 pop ecx
 call bwdxmath  
 jmp codegenerator
genptr:
 mov edx,0
 call readid
 mov eax,0
 mov edx,0
 call getidseq
 push ecx
 push eax
 mov ecx,"mov "
 mov edx,4
 call prnx
 call prneax
 mov ecx,"[esp"
 call prnx
 mov ecx,"+"
 mov edx,1
 call prnx
 pop eax
 call itos
 call prncij2
 mov ecx,"]"
 mov edx,1
 call prnx
 call prnnull
 ; mov eax,[stack+number]
 mov ecx,"call"
 mov edx,4
 call prnx
 mov ecx," _CI"
 call prnx
 mov ecx,"PTR_"
 call prnx
 call prnnull
 pop ecx ;_CIPTR_ will return value in that address 
 call bwdxmath 
 jmp codegenerator
 
genlpr:
 mov edx,[genseqts]
 mov bl,"("
 add edx,1
 mov [genseq+edx],bl
 mov [genseqts],edx
 jmp codegenerator
genlpr2:
  mov edx,[genseqts]
  mov bl,[genseq+edx]
  mov bh,"1"
  cmp bh,bl
  je genfinbytes
  mov bh,"2"
  cmp bh,bl
  je genfinbytes
  mov bh,"3"
  cmp bh,bl
  je genfinbytes
  mov bh,"4"
  cmp bh,bl
  je genfinbytes
  mov bl,[regfunc]
  cmp bl,"o"
  je regdef2
  mov edx,[genseqts]
  mov bl,0
  mov [genseq+edx],bl
  sub edx,1
  mov [genseqts],edx
  mov bl,[genseq+edx]
  mov bh,"b"
  cmp bh,bl
  je genb4
  mov bh,"w"
  cmp bh,bl
  je genw4
  mov bh,"d"
  cmp bh,bl
  je gend4    
  add ecx,3
  call bwdxmath 
  jmp codegenerator

bwdxmath:
  mov edx,[genseqts]
  mov bl,[genseq+edx]
  mov bh,"+"
  cmp bh,bl
  je bwdtopls
  mov bh,"-"
  cmp bh,bl
  je bwdtomin
  mov bh,"*"
  cmp bh,bl
  je bwdtomul
  mov bh,"/"
  cmp bh,bl
  je bwdtodiv
  mov bh,"^"
  cmp bh,bl
  je bwdtopor
  ret

;;;;;;;;BWD;;;;;;;
 genb:
  call cgenread 
  mov edx,[lpr]
  cmp edx,ebx
  je genb2
  ;its aod
  mov edx,0
  call readid
  mov eax,0
  mov edx,0
  call getidseq
  push ecx
  push eax
  mov ecx,"mov "
  mov edx,4
  call prnx
  call prneax
  mov ecx,"[esp"
  call prnx
  mov ecx,"+"
  mov edx,1
  call prnx
  pop eax
  call itos
  call prncij2
  mov ecx,"]"
  mov edx,1
  call prnx
  call prnnull
  mov ecx,"mov "
  mov edx,4
  call prnx 
  mov ecx,"edx,"
  call prnx
  mov ecx,"4"
  mov edx,1
  call prnx 
  call prnnull
  pop ecx
  ;mov eax,[stack+number], mov edx,4 ;aod 
  call cgenread
  mov edx,[pls]
  cmp edx,ebx
  je genb3
  mov edx,[min]
  cmp edx,ebx
  je genb3
  mov edx,[mult]
  cmp edx,ebx
  je genb3 
  mov edx,[divt]
  cmp edx,ebx
  je genb3 
  mov edx,[port]
  cmp edx,ebx
  je genb3 
  push ecx
  mov ecx,"call"
  mov edx,4
  call prnx 
  mov ecx," _CI"
  call prnx
  mov ecx,"BYT_"
  call prnx
  call prnnull 
  pop ecx
  sub ecx,3
  call bwdxmath
  ;more 
  jmp codegenerator
 genb3:
  ;save aod
  mov edx,[genseqts]
  mov bl,"b"
  add edx,1
  mov [genseq+edx],bl
  mov [genseqts],edx   
  mov bl,"o"
  mov [aodf],bl
  sub ecx,3
  jmp codegenerator
 genb2:
  mov edx,[genseqts]
  mov bl,"b"
  add edx,1
  mov [genseq+edx],bl
  mov [genseqts],edx   
  jmp genlpr
 genb4:
  push ecx
  mov ecx,"call"
  mov edx,4
  call prnx
  mov ecx," _CI"
  call prnx
  mov ecx,"BYT_"
  call prnx
  call prnnull 
  pop ecx
  mov edx,[genseqts]
  mov bl,0
  mov [genseq+edx],bl
  sub edx,1
  mov [genseqts],edx
  call bwdxmath
  jmp codegenerator
 
 genw:
  call cgenread 
  mov edx,[lpr]
  cmp edx,ebx
  je genw2
  ;its aod
  mov edx,0
  call readid
  mov edx,0
  mov eax,0
  call getidseq
  push ecx
  push eax
  mov ecx,"mov "
  mov edx,4
  call prnx
  call prneax
  mov ecx,"[esp"
  call prnx
  mov ecx,"+"
  mov edx,1
  call prnx
  pop eax
  call itos
  call prncij2
  mov ecx,"]"
  mov edx,1
  call prnx
  call prnnull
  mov ecx,"edx,"
  call prnx
  mov ecx,"4"
  mov edx,1
  call prnx 
  call prnnull  
  pop ecx
  call cgenread
  mov edx,[pls]
  cmp edx,ebx
  je genw3
  mov edx,[min]
  cmp edx,ebx
  je genw3
  mov edx,[mult]
  cmp edx,ebx
  je genw3 
  mov edx,[divt]
  cmp edx,ebx
  je genw3 
  mov edx,[port]
  cmp edx,ebx
  je genw3 
  push ecx
  mov ecx,"call"
  mov edx,4
  call prnx
  mov ecx," _CI"
  call prnx
  mov ecx,"WRD_"
  call prnx
  call prnnull 
  pop ecx
  sub ecx,3
  call bwdxmath
  jmp codegenerator
 genw3:
  mov edx,[genseqts]
  mov bl,"w"
  add edx,1
  mov [genseq+edx],bl
  mov [genseqts],edx   
  mov bl,"o"
  mov [aodf],bl
  sub ecx,3
  jmp codegenerator
 genw2:
  mov edx,[genseqts]
  mov bl,"w"
  add edx,1
  mov [genseq+edx],bl
  mov [genseqts],edx   
  jmp genlpr
 genw4:
  push ecx
  mov ecx,"call"
  mov edx,4
  call prnx
  mov ecx," _CI"
  call prnx
  mov ecx,"WRD_"
  call prnx
  call prnnull 
  pop ecx
  mov edx,[genseqts]
  mov bl,0
  mov [genseq+edx],bl
  sub edx,1
  mov [genseqts],edx
  call bwdxmath 
  jmp codegenerator
  
 gend:
  call cgenread 
  mov edx,[lpr]
  cmp edx,ebx
  je genb2
  ;its aod
  mov edx,0
  call readid
  mov edx,0
  mov eax,0
  call getidseq
  push ecx
  push eax
  mov ecx,"mov "
  mov edx,4
  call prnx
  call prneax
  mov ecx,"[esp"
  call prnx
  mov ecx,"+"
  mov edx,1
  call prnx
  pop eax
  call itos
  call prncij2
  mov ecx,"]"
  mov edx,1
  call prnx
  call prnnull
  mov ecx,"mov "
  mov edx,4
  call prnx 
  mov ecx,"edx,"
  call prnx 
  mov ecx,"4"
  mov edx,1
  call prnx
  pop ecx
  call cgenread
  mov edx,[pls]
  cmp edx,ebx
  je gend3
  mov edx,[min]
  cmp edx,ebx
  je gend3
  mov edx,[mult]
  cmp edx,ebx
  je gend3 
  mov edx,[divt]
  cmp edx,ebx
  je gend3 
  mov edx,[port]
  cmp edx,ebx
  je gend3 
  push ecx
  mov ecx,"call"
  mov edx,4 
  call prnx
  mov ecx," _CI"
  call prnx
  mov ecx,"BYT_"
  call prnx
  call prnnull 
  pop ecx
  sub ecx,3
  call bwdxmath
  jmp codegenerator
 gend3:
  mov edx,[genseqts]
  mov bl,"d"
  add edx,1
  mov [genseq+edx],bl
  mov [genseqts],edx   
  mov bl,"o"
  mov [aodf],bl
  sub ecx,3
  jmp codegenerator
 gend2:
  mov edx,[genseqts]
  mov bl,"d"
  add edx,1
  mov [genseq+edx],bl
  mov [genseqts],edx   
  jmp genlpr
 gend4:
  push ecx
  mov ecx,"call"
  mov edx,4
  call prnx
  mov ecx," _CI"
  call prnx
  mov ecx,"DWR_"
  call prnx
  call prnnull 
  pop ecx
  mov edx,[genseqts]
  mov bl,0
  mov [genseq+edx],bl
  sub edx,1
  mov [genseqts],edx
  call bwdxmath 
  jmp codegenerator
  
 bwdtopls:
  call restore
  jmp dopls2
 bwdtomin:
  call restore
  jmp domin2
 bwdtomul:
  call restore
  jmp domul2
 bwdtodiv:
  call restore
  jmp dodiv
 bwdtopor:
  call restore
  jmp dopor
 
 doaodmath:
  push ecx
  mov ecx,"mov "
  mov edx,4
  call prnx
  call prnebx
  mov ecx,"[esp"
  call prnx
  mov ecx,"+"
  mov edx,1
  call prnx
  mov eax,[stackc]
  sub eax,4
  mov [stackc],eax
  add eax,4
  call itos
  call prncij2
  mov ecx,"]"
  mov edx,1
  call prnx
  call prnnull
  mov ecx,"push"
  mov edx,4
  call prnx 
  mov ecx," ebx"
  call prnx 
  call prnnull
  mov ecx,"call"
  mov edx,4
  call prnx
  mov ecx," _CI"
  call prnx
  mov ecx,"MEM2"
  call prnx
  mov ecx,"REG_"
  call prnx
  call prnnull
  mov ecx,"pop"
  mov edx,3
  call prnx
  mov edx,4
  mov ecx," ebx"
  call prnx 
  call prnnull  
  mov ecx,"add "
  mov edx,4
  call prnx
  call prnebx
  mov edx,3
  call prneax
  call prnnull
  pop ecx
  mov edx,[genseqts]
  mov bl,[genseq+edx]
  mov bh,"b"
  cmp bh,bl
  je genb4
  mov bh,"w"
  cmp bh,bl
  je genw4
  mov bh,"d"
  cmp bh,bl
  je gend4 
  jmp codegenerator
  
cgennpt:
  push ecx 
  mov ecx,"call"
  mov edx,4
  call prnx
  mov ecx," _CI"
  call prnx 
  mov ecx,"NPT_"
  call prnx 
  call prnnull
  pop ecx
  jmp codegenerator

;;;;;;;;;TFN;;;;;;;;
 gentrue:
  push ecx
  mov ecx,"mov "
  mov edx,4
  call prnx
  call prneax
  mov ecx,"esi"
  dec edx
  call prnx
  call prnnull
  mov ecx,"mov "
  mov edx,4
  call prnx
  call prnedx
  mov ecx,"1"
  mov edx,1
  call prnx
  call prnnull
  mov ecx,"mov "
  mov edx,4
  call prnx
  mov ecx,"bl,+"
  call prnx 
  call prnnull
  mov ecx,"mov "
  mov edx,4
  call prnx
  mov ecx,"bh,1"
  call prnx 
  call prnnull 
  mov ecx,"mov "
  mov edx,4
  call prnx
  mov ecx,"esi,"
  call prnx 
  mov ecx,"bx"
  mov edx,2
  call prnx
  call prnnull
  mov ecx,"add "
  mov edx,4
  call prnx 
  mov ecx,"esi,"
  call prnx 
  mov edx,1
  mov ecx,"2"
  call prnx 
  call prnnull 
  pop ecx
  add ecx,3
  mov edx,[genseqts]
  mov bl,byte[genseq+edx]
  mov bh,"n"
  cmp bh,bl
  je genfinnot 
  sub ecx,3
  mov bh,"~"
  cmp bh,bl
  je fingenneg
  call bwdxmath
  jmp codegenerator
 genfalse:
  push ecx
  mov ecx,"mov "
  mov edx,4
  call prnx
  call prneax
  mov ecx,"esi"
  dec edx
  call prnx
  call prnnull
  mov ecx,"mov "
  mov edx,4
  call prnx
  call prnedx
  mov ecx,"1"
  mov edx,1
  call prnx
  call prnnull
  mov ecx,"mov "
  mov edx,4
  call prnx
  mov ecx,"bl,+"
  call prnx 
  call prnnull
  mov ecx,"mov "
  mov edx,4
  call prnx
  mov ecx,"bh,0"
  call prnx 
  call prnnull 
  mov ecx,"mov "
  mov edx,4
  call prnx
  mov ecx,"esi,"
  call prnx 
  mov ecx,"bx"
  mov edx,2
  call prnx
  call prnnull
  mov ecx,"add "
  mov edx,4
  call prnx 
  mov ecx,"esi,"
  call prnx 
  mov edx,1
  mov ecx,"2"
  call prnx 
  call prnnull 
  pop ecx
  add ecx,3
  mov edx,[genseqts]
  mov bl,byte[genseq+edx]
  mov bh,"n"
   cmp bh,bl
  je genfinnot 
  sub ecx,3
  mov bh,"~"
  cmp bh,bl
  je fingenneg
  call bwdxmath
  jmp codegenerator 
 gennull:
  push ecx
  mov ecx,"mov "
  mov edx,4
   call prnx
  call prneax
  mov ecx,"esi"
  dec edx
  call prnx
  call prnnull
  mov ecx,"mov "
  mov edx,4
  call prnx
  call prnedx
  mov ecx,"0"
  mov edx,1
  call prnx
  call prnnull
  mov ecx,"mov "
  mov edx,4
  call prnx
  mov ecx,"bl,0"
  call prnx 
  mov ecx,"xa"
  mov edx,2
  call prnx 
  call prnnull
  mov ecx,"mov "
  mov edx,4
  call prnx
  mov ecx,"esi,"
  call prnx 
  mov ecx,"bl"
  mov edx,2
  call prnx
  call prnnull
  mov ecx,"add "
  mov edx,4
  call prnx 
  mov ecx,"esi,"
  call prnx 
  mov edx,1
  mov ecx,"1"
  call prnx 
  call prnnull
  pop ecx
  jmp codegenerator
 
genneg:
 mov edx,[genseqts]
 mov bl,"~"
 add edx,1
 mov [genseq+edx],bl
 mov [genseqts],edx
 jmp codegenerator
fingenneg: 
 mov edx,[genseqts]
 mov bl,0
 mov [genseq+edx],bl
 sub edx,1
 mov [genseqts],edx 
 push ecx
 mov ecx,"call"
 mov edx,4
 call prnx
 mov ecx," _CI"
 call prnx
 mov ecx,"NEG_"
 call prnx
 call prnnull
 pop ecx
 ;;;wasnt in _fingenneg sub ecx,3
 call chkpres
 jmp codegenerator

;;;;;;;;ELSE;;;;;;;;
 genelse:
 mov edx,[genseqts]
 mov bl,"e"
 add edx,1
 mov [genseq+edx],bl
 mov [genseqts],edx
 push ecx
 mov ecx,cielsej
 mov edx,8
 mov eax,4
 mov ebx,1
 int 0x80
 mov eax,[cielsejc]
 call itos
 call prncij2
 mov edx,1
 mov ecx,":"
 call prnx
 call prnnull
 mov ecx,"cmp "
 mov edx,4
 call prnx
 call prneax
 mov ecx,"1"
 mov edx,1
 call prnx
 call prnnull
 mov ecx,"jge "
 mov edx,4
 call prnx
 mov ecx,cifinelsej 
 mov edx,11
 mov eax,4
 mov ebx,1
 int 0x80 
 mov eax,[cielsejc]
 call itos
 call prncij2
 call prnnull
 pop ecx 
 jmp codegenerator
 genfinelse:
 mov edx,[genseqts]
 mov bl,0
 mov [genseq+edx],bl
 sub edx,1
 mov [genseqts],edx  
 push ecx
 mov ecx,cifinelsej 
 mov edx,11
 mov eax,4
 mov ebx,1
 int 0x80 
 mov eax,[cielsejc]
 call itos
 call prncij2
 mov edx,1
 mov ecx,":"
 call prnx 
 call prnnull
 pop ecx
 jmp codegenerator
 
;;;;;;;;;IF;;;;;;;;;
 genif:
 mov edx,[genseqts]
 mov bl,"f"
 add edx,1
 mov [genseq+edx],bl
 mov [genseqts],edx
 jmp _codegenerator
 _genfinif:
 call _chkpres
 mov eax,[CIR2+0]
 mov edx,[CIR2+4]
 call _movcisp
 push ecx
 mov ecx,"mov "
 mov edx,4
 call prnx
 call prneax
 mov ecx,"[eax"
 call prnx 
 mov ecx,"+1]"
 mov edx,3
 call prnx 
 call prnnull
 pop ecx
 jmp genfinif2
 genfinif:
 call chkpres
 genfinif2: 
 push ecx
 mov ecx,"mov "
 mov edx,4
 call prnx
 mov ecx,"[esp"
 call prnx
 mov ecx,"+"
 mov edx,1
 call prnx
 mov eax,[stackc]
 add eax,4
 mov [stackc],eax
 sub eax,4
 call itos
 call prncij2
 mov ecx,"],"
 mov edx,2
 call prnx
 mov edx,3
 call prneax
 call prnnull
 mov ecx,"cmp "
 mov edx,4
 call prnx
 call prneax
 mov ecx,"1"
 mov edx,1
 call prnx
 call prnnull
 mov ecx,"jge "
 mov edx,4
 call prnx
 mov ecx,ciifj 
 mov edx,6
 mov eax,4
 mov ebx,1
 int 0x80 
 mov eax,[ciifjc]
 call itos
 call prncij2
 call prnnull
 mov ecx,"jmp "
 mov edx,4
 call prnx
 mov ecx,cifinifj
 mov edx,9
 mov eax,4
 mov ebx,1
 int 0x80
 mov eax,[ciifjc]
 call itos
 call prncij2
 call prnnull 
 mov ecx,ciifj 
 mov edx,6
 mov eax,4
 mov ebx,1
 int 0x80 
 mov eax,[ciifjc]
 call itos
 call prncij2
 mov ecx,":"
 mov edx,1
 call prnx
 call prnnull
 pop ecx
 jmp _codegenerator
 genendif:
 push ecx
 mov ecx,cifinifj
 mov edx,9
 mov eax,4
 mov ebx,1
 int 0x80
 mov eax,[ciifjc]
 call itos
 call prncij2
 mov ecx,":"
 mov edx,1
 call prnx
 call prnnull  
 mov eax,[ciifjc]
 add eax,1
 mov [ciifjc],eax
 pop ecx
 mov edx,[genseqts]
 mov bl,0
 mov [genseq+edx],bl
 sub edx,1
 mov [genseqts],edx  
 jmp _codegenerator

;;;;;;;;;WIL;;;;;;;;
 genwil:
 mov edx,[genseqts]
 mov bl,"l"
 add edx,1
 mov [genseq+edx],bl
 mov [genseqts],edx
 push ecx
 mov ecx,ciwilj
 mov edx,7
 mov eax,4
 mov ebx,1
 int 0x80
 mov eax,[ciwiljc]
 call itos
 call prncij2
 mov ecx,":"
 mov edx,1
 call prnx 
 call prnnull
 pop ecx
 jmp _codegenerator
 _genfinwil:
 call _chkpres
 mov eax,[CIR2+0]
 mov edx,[CIR2+4]
 call _movcisp
 push ecx
 mov ecx,"mov "
 mov edx,4
 call prnx
 call prneax
 mov ecx,"[eax"
 call prnx 
 mov ecx,"+1]"
 mov edx,3
 call prnx 
 call prnnull
 pop ecx
 jmp genfinwil2 
 genfinwil:
 call chkpres
 genfinwil2:
 push ecx
 mov edx,4 
 mov ecx,"cmp "
 call prnx
 call prneax
 mov ecx,"1"
 mov edx,1
 call prnx
 call prnnull
 mov ecx,"jge "
 mov edx,4
 call prnx
 mov ecx,ciwilj2 
 mov edx,8
 mov eax,4
 mov ebx,1
 int 0x80 
 mov eax,[ciwiljc]
 call itos
 call prncij2
 call prnnull
 mov ecx,"jmp "
 mov edx,4
 call prnx
 mov ecx,cifinwilj
 mov edx,10
 mov eax,4
 mov ebx,1
 int 0x80
 mov eax,[ciwiljc]
 call itos
 call prncij2
 call prnnull 
 mov ecx,ciwilj2 
 mov edx,8
 mov eax,4
 mov ebx,1
 int 0x80 
 mov eax,[ciwiljc]
 call itos
 call prncij2
 mov ecx,":"
 mov edx,1
 call prnx
 call prnnull
 pop ecx
 jmp _codegenerator
 genendwil:
 push ecx
 mov ecx,"jmp "
 mov edx,4
 call prnx
 mov ecx,ciwilj
 mov edx,7
 mov eax,4
 mov ebx,1
 int 0x80
 mov eax,[ciwiljc]
 call itos
 call prncij2
 call prnnull
 mov ecx,cifinwilj
 mov edx,10
 mov eax,4
 mov ebx,1
 int 0x80
 mov eax,[ciwiljc]
 call itos
 call prncij2
 mov ecx,":"
 mov edx,1
 call prnx
 call prnnull  
 mov eax,[ciwiljc]
 add eax,1
 mov [ciwiljc],eax
 pop ecx
 mov edx,[genseqts]
 mov bl,0
 mov [genseq+edx],bl
 sub edx,1
 mov [genseqts],edx  
 jmp _codegenerator
 
genbr2:
 mov edx,[genseqts]
 mov bl,[genseq+edx]
 mov bh,"l"
 cmp bl,bh
 je genendwil
 mov bh,"f"
 cmp bl,bh
 je genendif 
 mov bh,"e"
 cmp bl,bh
 je genfinelse  
 mov bh,"{"
 cmp bh,bl
 je genendfdf

;;;;;;;;;STR;;;;;;;
 genstr:
 mov edx,0
 mov [strc],edx
 call readstr
 movstr:
 push ecx
 mov ecx,"_CIS"
 mov edx,4
 call prnx2
 mov ecx,"TR_"
 mov edx,3
 call prnx2
 mov eax,[strvc]
 call itos
 call prncij2x
 mov ecx," db "
 mov edx,4
 call prnx2
 mov ecx,'"'
 mov edx,1
 call prnx2
 mov ecx,[strc]
 mov edx,0
 movstr2:
 push ecx
 push edx
 mov ecx,[strv+edx]
 mov edx,1
 call prnx2
 pop edx
 pop ecx
 add edx,1
 loop movstr2
 mov edx,4
 mov ecx,'",0x'
 call prnx2
 mov ecx,"a"
 mov edx,1
 call prnx2
 mov ecx,0xa
 call prnx2
 ; call prnnull
 mov ecx,"mov "
 mov edx,4
 call prnx
 call prneax
 mov ecx,"_CIS"
 mov edx,4
 call prnx
 mov ecx,"TR_"
 mov edx,3
 call prnx
 mov eax,[strvc]
 add eax,1
 mov [strvc],eax
 sub eax,1
 call itos
 call prncij2
 call prnnull
 mov ecx,"mov "
 mov edx,4
 call prnx
 call prnedx
 mov eax,[strc]
 call itos
 call prncij2
 call prnnull
 pop ecx
 fingenstr: 
 jmp codegenerator

;;;;;;;;BYTES;;;;;;
 genrolf:
  mov bl,"1"
  jmp genbytes;r
 genrorf:
  mov bl,"2"
  jmp genbytes ;q
 genshlf:
  mov bl,"3"
  jmp genbytes;p
 genshrf:
  mov bl,"4"
  jmp genbytes;n

 genbytes:
  mov edx,[genseqts]
  add edx,1
  mov [genseq+edx],bl
  mov [genseqts],edx
  jmp codegenerator
 genbytes2:
  call savee
  jmp codegenerator
  
 genfinbytes:
  call restore
  mov edx,[genseqts]
  mov bl,[genseq+edx]
  mov bh,0
  mov [genseq+edx],bh
  sub edx,1
  mov [genseqts],edx  
  mov bh,"1"
  cmp bh,bl
  je genfinrolf
  mov bh,"2"
  cmp bh,bl
  je genfinrorf
  mov bh,"3"
  cmp bh,bl
  je genfinshlf
  mov bh,"4"
  cmp bh,bl
  je genfinshrf
 
 genfinrolf:
  push ecx
  mov ecx,"call"
  mov edx,4
  call prnx
  mov ecx," _CI"
  call prnx
  mov ecx,"ROLf"
  call prnx
  mov ecx,"_"
  mov edx,1
  call prnx
  call prnnull
  pop ecx
  jmp codegenerator
 genfinrorf:
  push ecx
  mov ecx,"call"
  mov edx,4
  call prnx
  mov ecx," _CI"
  call prnx
  mov ecx,"RORf"
  call prnx
  mov ecx,"_"
  mov edx,1
  call prnx
  call prnnull
  pop ecx
  jmp codegenerator
 genfinshlf:
  push ecx
  mov ecx,"call"
  mov edx,4
  call prnx
  mov ecx," _CI"
  call prnx
  mov ecx,"SHLf"
  call prnx
  mov ecx,"_"
  mov edx,1
  call prnx
  call prnnull
  pop ecx
  jmp codegenerator
 genfinshrf:
  push ecx
  mov ecx,"call"
  mov edx,4
  call prnx
  mov ecx," _CI"
  call prnx
  mov ecx,"SHRf"
  call prnx
  mov ecx,"_"
  mov edx,1
  call prnx
  call prnnull
  pop ecx
  jmp codegenerator

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;genbits: get number of shifts then push it 
;;;;;;;;;BITS;;;;;;
 genrolt:
  mov bl,"5"
  jmp genbits;z
 genrort:
  mov bl,"6"
  jmp genbits ;y
 genshlt:
  mov bl,"7"
  jmp genbits ;v
 genshrt:
  mov bl,"8"
  jmp genbits;s

 genbits:
  mov edx,[genseqts]
  add edx,1
  mov [genseq+edx],bl
  mov [genseqts],edx
  call cgenread; 
  jmp genint
  genbitspsh:
  call savee
  jmp codegenerator
 genfinbits:
  mov edx,[genseqts]
  mov bl,0
  mov [genseq+edx],bl
  sub edx,1
  mov [genseqts],edx
  ;sub ecx,3
  jmp codegenerator

 genfinrolt:
  call popbitsb 
  push ecx
  mov ecx,"call"
  mov edx,4
  call prnx
  mov ecx," _CI"
  call prnx
  mov ecx,"ROL_"
  call prnx
  call prnnull
  pop ecx
  jmp genfinbits
 genfinrort:
  call popbitsb 
  push ecx
  mov ecx,"call"
  mov edx,4
  call prnx
  mov ecx," _CI"
  call prnx
  mov ecx,"ROR_"
  call prnx
  call prnnull
  pop ecx
  jmp genfinbits
 genfinshlt:
  call popbitsb 
  push ecx
  mov ecx,"call"
  mov edx,4
  call prnx
  mov ecx," _CI"
  call prnx
  mov ecx,"SHL_"
  call prnx
  call prnnull
  pop ecx
  jmp genfinbits
 genfinshrt:
  call popbitsb
  push ecx
  mov ecx,"call"
  mov edx,4
  call prnx
  mov ecx," _CI"
  call prnx
  mov ecx,"SHR_"
  call prnx
  call prnnull
  pop ecx
  jmp genfinbits

 chkforbits:
  mov edx,[genseqts]
  mov bl,[genseq+edx]
  mov bh,"5"
  cmp bh,bl
  je genfinrolt
  mov bh,"6"
  cmp bh,bl
  je genfinrort
  mov bh,"7"
  cmp bh,bl
  je genfinshlt
  mov bh,"8"
  cmp bh,bl
  je genfinshrt
  ret
 cgenbitsdot:
  call savee
  jmp codegenerator
 popbitsb:
   push ecx
   mov ecx,"mov "
   mov edx,4
   call prnx
   call prnecx
   mov ecx,"[esp"
   call prnx 
   mov ecx,"+"
   mov edx,1
   call prnx 
   mov eax,[stackc]
   sub eax,4
   mov [stackc],eax
   call itos
   call prncij2
   mov ecx,"]"
   mov edx,1
   call prnx 
   call prnnull
   mov ecx,"mov "
   mov edx,4
   call prnx
   call prnebx
   mov ecx,"[esp"
   call prnx 
   mov ecx,"+"
   mov edx,1
   call prnx 
   mov eax,[stackc]
   sub eax,4
   mov [stackc],eax
   call itos
   call prncij2
   mov ecx,"]"
   mov edx,1
   call prnx 
   call prnnull
   pop ecx
   ret
   
;;;;;;;;;CMP;;;;;;;;
 genneq: ;3
  call chkpres
  mov edx,[genseqts]
  mov bl,"a"
  add edx,1
  mov [genseq+edx],bl
  mov [genseqts],edx  
  jmp gencmp
 geneq2: ;4
  call chkpres
  mov edx,[genseqts]
  mov bl,"x"
  add edx,1
  mov [genseq+edx],bl
  mov [genseqts],edx  
  jmp gencmp 
 gengrt: ;5
  call chkpres
  mov edx,[genseqts]
  mov bl,"y"
  add edx,1
  mov [genseq+edx],bl
  mov [genseqts],edx  
  jmp gencmp 
 genles: ;6
  call chkpres
  mov edx,[genseqts]
  mov bl,"t"
  add edx,1
  mov [genseq+edx],bl
  mov [genseqts],edx  
  jmp gencmp 
 gengeq: ;7
  call chkpres
  mov edx,[genseqts]
  mov bl,"o"
  add edx,1
  mov [genseq+edx],bl
  mov [genseqts],edx  
  jmp gencmp 
 genleq: ;8
  call chkpres
  mov edx,[genseqts]
  mov bl,"g"
  add edx,1
  mov [genseq+edx],bl
  mov [genseqts],edx
  jmp gencmp 

 gencmp:
  call savee
  jmp codegenerator


 fingenneq:;jne
  call restore
  push ecx
  mov ecx,"call"
  mov edx,4
  call prnx
  mov ecx," _CI"
  call prnx
  mov ecx,"NEQ_"
  call prnx
  call prnnull
  pop ecx 
  mov bl,0
  mov edx,[genseqts]  
  mov [genseq+edx],bl
  dec edx
  mov [genseqts],edx  
  jmp codegenerator
 fingeneq2:;je
  call restore
  push ecx
  mov ecx,"call"
  mov edx,4
  call prnx
  mov ecx," _CI"
  call prnx
  mov ecx,"EQ2_"
  call prnx
  call prnnull
  pop ecx
  mov bl,0
   mov edx,[genseqts] 
  mov [genseq+edx],bl
  dec edx
  mov [genseqts],edx 
  jmp codegenerator
 fingengrt:;jg
  call restore
  push ecx
  mov ecx,"call"
  mov edx,4
  call prnx
  mov ecx," _CI"
  call prnx
  mov ecx,"GRT_"
  call prnx
  call prnnull
  pop ecx 
  mov bl,0
  mov edx,[genseqts] 
  mov [genseq+edx],bl
  dec edx
  mov [genseqts],edx  
  jmp codegenerator
 fingenles:;jl
  call restore
  push ecx
  mov ecx,"call"
  mov edx,4
  call prnx
  mov ecx," _CI"
  call prnx
  mov ecx,"LES_"
  call prnx
  call prnnull
  pop ecx 
  mov bl,0
  mov edx,[genseqts]  
  mov [genseq+edx],bl
  dec edx
  mov [genseqts],edx   
  jmp codegenerator
 fingengeq:;geq
  call restore
  push ecx
  mov ecx,"call"
  mov edx,4
  call prnx
  mov ecx," _CI"
  call prnx
  mov ecx,"GEQ_"
  call prnx
  call prnnull
  pop ecx 
  mov bl,0
  mov edx,[genseqts]  
  mov [genseq+edx],bl
  dec edx
  mov [genseqts],edx   
  jmp codegenerator
 fingenleq:;leq
  call restore
  push ecx
  mov ecx,"call"
  mov edx,4
  call prnx
  mov ecx," _CI"
  call prnx
  mov ecx,"LEQ_"
  call prnx
  call prnnull
  pop ecx 
  mov bl,0
  mov edx,[genseqts]  
  mov [genseq+edx],bl
  dec edx
  mov [genseqts],edx   
  jmp codegenerator
 
 chkpreexp:
  mov edx,[genseqts]
  mov bl,[genseq+edx]
  mov bh,"n"
  cmp bh,bl
  je genfinnot 
  sub ecx,3
  call chktoexp
  add ecx,3
  ret
 
 chktocmp:
  mov edx,[genseqts]
  mov bl,[genseq+edx]
  mov bh,"a"
  cmp bh,bl
  je fingenneq
  mov bh,"x"
  cmp bh,bl
  je fingeneq2
  mov bh,"y"
  cmp bh,bl
  je fingengrt
  mov bh,"t"
  cmp bh,bl
  je fingenles
  mov bh,"o"
  cmp bh,bl
  je fingengeq
  mov bh,"g"
  cmp bh,bl
  je fingenleq
  ret 
 
;;;;;;;;;CMA;;;;;;;;
 gencma:
  call chkpres
  mov edx,[genseqts]
  mov bl,[genseq+edx]
  mov bh,")"
  cmp bh,bl
  je genfclpar
  mov bh,"["
  cmp bh,bl 
  je genaddel
  mov bh,"p"
  cmp bh,bl 
  je genprint3
  mov bh,"1"
  cmp bh,bl
  je genbytes2
  mov bh,"2"
  cmp bh,bl
  je genbytes2
  mov bh,"3"
  cmp bh,bl
  je genbytes2
  mov bh,"4"
  cmp bh,bl
  je genbytes2 
  call chktocmp
  
;;;;;;;;;VAR;;;;;;;;
 genvar:
  mov edx,0
  mov eax,0
  call readid
  ;call setvarseq
  call setvarnpt
  push eax
  mov eax,[genseqts]
  mov bl,"v"
  add eax,1
  mov [genseq+eax],bl
  mov [genseqts],eax
  jmp codegenerator
 fingenvar:
  mov edx,[genseqts]
  mov bl,0
  mov [genseq+edx],bl
  sub edx,1
  mov [genseqts],edx
  pop eax
  push ecx
  push eax
  call prnmov
  mov ecx,"[esp"
  mov edx,4
  call prnx
  mov ecx,"+" 
  mov edx, 1
  call prnx
  pop eax
  push eax
  call itos
  call prncij2
  mov ecx,"],"
  mov edx,2
  call prnx
  mov edx,3
  call prneax
  call prnnull
  call prnmov
  mov ecx,"[esp"
  mov edx,4
  call prnx
  mov ecx,"+"
  mov edx,1
  call prnx
  pop eax
  add eax,4
  call itos
  call prncij2
  mov ecx,"],"
  mov edx,2
  call prnx
  mov edx,3
  call prnedx
  call prnnull 
  pop ecx
  mov eax,[stackc]
  add eax,8
  mov [stackc],eax
  mov [trmgenc],ecx 
  sub ecx,3
  jmp _codegenerator

 setvarseq:
  mov edx,[varsc]
  mov eax,0
  setvarseq2:
  mov bl,[idv2+eax] 
  mov [genvars+edx],bl
  inc eax
  inc edx
  cmp bl,"|"
  jne setvarseq2
  mov eax,[stackc]
  mov [genvars+edx],eax
  add edx,4
  mov bl,";"
  mov [genvars+edx],bl 
  inc edx
  mov [varsc],edx
  mov eax,[stackc]
  ret
  
 setvarnpt:
  mov edx,[nptcount]
  mov eax,0
  setvarnpt2:
  mov bl,[idv2+eax] 
  mov [gennvar+edx],bl
  inc eax
  inc edx
  cmp bl,"|"
  jne setvarnpt2
  mov ebx,[varsc2]
  mov [varsc],ebx
  mov eax,[stackc]
  mov [gennvar+edx],eax
  add edx,4
  mov bl,";"
  mov [gennvar+edx],bl 
  inc edx
  mov [nptcount],edx
  mov eax,[stackc]
  ret  
 
 movvar:
  mov bl,[idv2+eax]
  mov [genvars+edx],bl
  add edx,1
  add eax,1
  cmp bl,bh
  jne movvar
  mov [varsc],edx
  ret

;;;;;;;;INT;;;;;;;;;x=123;eax=reg(x);a=eax;z=str(a);print(z);?
genint:
 mov edx,0
 call readint
 push ecx
 call prnint 
 mov ecx,"mov "
 mov edx,4
 call prnx
 call prneax
 mov edx,4
 mov ecx,"_CII"
 call prnx
 mov edx,3
 mov ecx,"NT_"
 call prnx
 mov eax,[intc2]
 sub eax,1
 call itos
 call prncij2
 call prnnull
 mov ecx,"mov "
 mov edx,4
 call prnx
 call prnedx
 mov eax,[intc]
 call itos
 call prncij2
 call prnnull
 pop ecx
 add ecx,3
 mov edx,[genseqts]
 mov bl,byte[genseq+edx]
 mov bh,"n"
 cmp bh,bl
 je genfinnot 
 sub ecx,3
 mov bh,"~"
 cmp bh,bl
 je fingenneg
 call bwdxmath
 mov eax,[stackc]
 push eax
 call cgenread
 mov edx,[pls]
 cmp edx,ebx
 je exppls
 mov edx,[min]
 cmp edx,ebx
 je expmin
 mov edx,[mult]
 cmp edx,ebx
 je expmul
 mov edx,[divt]
 cmp edx,ebx
 je expdiv
 mov edx,[port]
 cmp edx,ebx
 je exppor
 pop eax
 sub ecx,3
 jmp codegenerator
 
genflt:
 mov edx,0
 call readint
 push ecx
 call prnflt
 push eax
 push edx
 mov ecx,"mov "
 mov edx,4
 call prnx
 call prneax
 mov edx,4
 mov ecx,"_CII"
 call prnx
 mov edx,3
 mov ecx,"NT_"
 call prnx
 mov eax,[intc2]
 sub eax,1
 call itos
 call prncij2
 call prnnull
 mov ecx,"mov "
 mov edx,4
 call prnx
 mov ecx,"dh,"
 mov edx,3
 call prnx
 pop eax
 call itos
 call prncij2
 call prnnull 
 mov ecx,"mov "
 mov edx,4
 call prnx
 mov ecx,"dl,"
 mov edx,3
 call prnx
 pop eax
 call itos
 call prncij2
 call prnnull  
 pop ecx
 add ecx,3
 mov edx,[genseqts]
 mov bl,byte[genseq+edx]
 mov bh,"n"
 cmp bh,bl
 je genfinnot 
 sub ecx,3
 mov bh,"~"
 cmp bh,bl
 je fingenneg
 call bwdxmath 
 mov eax,[stackc]
 push eax
 call cgenread
 mov edx,[pls]
 cmp edx,ebx
 je exppls
 mov edx,[min]
 cmp edx,ebx
 je expmin
 mov edx,[mult]
 cmp edx,ebx
 je expmul
 mov edx,[divt]
 cmp edx,ebx
 je expdiv
 mov edx,[port]
 cmp edx,ebx
 je exppor
 pop eax
 sub ecx,3
 jmp codegenerator
 
;;;;;;;;NOT;;;;;;;;;
 gennot:
  mov edx,[genseqts]
  mov bl,"n"
  add edx,1
  mov [genseq+edx],bl
  mov [genseqts],edx
  jmp codegenerator
 genfinnot:
  mov edx,[genseqts]
  mov bl,0
  mov [genseq+edx],bl
  sub edx,1
  mov [genseqts],edx 
  push ecx
  mov ecx,"call"
  mov edx,4
  call prnx
  mov ecx," _CI"
  call prnx
  mov ecx,"NOT_"
  call prnx
  call prnnull
  pop ecx
  sub ecx,3
  call chkpres
  jmp codegenerator
  
;;;;;;;;AND;;;;;;;;;
 genand:
  call chkpres
  mov edx,[genseqts]
  mov bl,"&"
  add edx,1
  mov [genseq+edx],bl
  mov [genseqts],edx 
  call savee
  jmp codegenerator
 genfinand:
  mov edx,[genseqts]
  mov bl,0
  mov [genseq+edx],bl
  sub edx,1
  mov [genseqts],edx 
  call restore
  push ecx
  mov ecx,"call"
  mov edx,4
  call prnx
  mov ecx," _CI"
  call prnx
  mov ecx,"AND_"
  call prnx
  call prnnull
  pop ecx
  jmp codegenerator
  
;;;;;;;;OR;;;;;;;;;
 genor:
  call chkpres
  mov edx,[genseqts]
  mov bl,"|"
  add edx,1
  mov [genseq+edx],bl
  mov [genseqts],edx 
  call savee
  jmp codegenerator
 genfinor:
  mov edx,[genseqts]
  mov bl,0
  mov [genseq+edx],bl
  sub edx,1
  mov [genseqts],edx 
  call restore
  push ecx
  mov ecx,"call"
  mov edx,4
  call prnx
  mov ecx," _CI"
  call prnx
  mov ecx,"OR_"
  mov edx,3
  call prnx
  call prnnull
  pop ecx
  jmp codegenerator
  
;;;;;;;;IDT;;;;;;;;;
 genidt:
  mov edx,0
  call readid
  mov bl,[fdfif]
  cmp bl,"o"
  je genfdfidt
  genidtx:
  mov edx,0
  mov eax,0
  call getidseq
  cmp ebx,1 
  je genidt3
 genidt2:
  push ecx
  push eax
  mov ecx,"mov "
  mov edx,4
  call prnx
  call prneax
  mov ecx,"[esp"
  call prnx
  mov ecx,"+"
  mov edx,1
  call prnx
  pop eax 
  push eax
  call itos
  call prncij2
  mov ecx,"]"
  mov edx,1
  call prnx
  call prnnull
  mov ecx,"mov "
  mov edx,4
  call prnx
  call prnedx
  mov ecx,"[esp"
  call prnx
  mov ecx,"+"
  mov edx,1
  call prnx
  pop eax
  add eax,4
  call itos
  call prncij2
  mov ecx,"]"
  mov edx,1
  call prnx
  call prnnull 
  pop ecx
  genidt3:
  add ecx,3
  mov edx,[genseqts]
  mov bl,byte[genseq+edx]
  mov bh,"n"
  cmp bh,bl
  je genfinnot 
  sub ecx,3
  mov bh,"~"
  cmp bh,bl
  je fingenneg
  call bwdxmath
  mov eax,[stackc]
  push eax
  call cgenread
  mov edx,[pls]
  cmp edx,ebx
  je exppls
  mov edx,[min]
  cmp edx,ebx
  je expmin
  mov edx,[mult]
  cmp edx,ebx
  je expmul
  mov edx,[divt]
  cmp edx,ebx
  je expdiv
  mov edx,[port]
  cmp edx,ebx 
  je exppor
  pop eax 
  sub ecx,3 
  jmp codegenerator  

 getidseq:
  mov bl,[idv2+eax]
  mov bh,[gennvar+edx]
  cmp bh,bl
  jne getidseq2
  add edx,1
  add eax,1
  mov bh,"|"
  cmp bh,bl
  jne getidseq
  mov eax,[gennvar+edx]
  mov ebx,0
  ret 
  getidseq2:
  mov bh,";"
  mov bl,[gennvar+edx]  
  add edx,1  
  cmp bh,bl
  jne getidseq2
  mov bl,[gennvar+edx]
  cmp bl,0 
  je getidseq3
  mov eax,0
  jmp getidseq
  getidseq3:
  mov edx,0
  mov eax,0 
  call _getidseq
  ;mov result to ci data
  mov eax,[stack+eax] 
  _movcisp:
  mov edx,0
  push ecx
  mov ecx,[gendatac]
  mov ebx,"_CII"
  mov [gendata+ecx],ebx 
  add ecx,4
  mov ebx,"D_"
  mov [gendata+ecx],ebx 
  add ecx,2
  mov [gendatac],ecx
  push eax 
  mov eax,[intc2]
  call itos
  call prncij2x
  mov eax,[intc2]
  add eax,1
  mov [intc2],eax
  pop eax
  inc ecx
  mov ebx," db "
  mov [gendata+ecx],ebx
  add ecx,4
  mov edx,0
  _moviddata: 
   mov bl,[eax+edx]
   mov [gendata+ecx],bl
   inc ecx 
   inc edx
   cmp bl,0xa 
   je _moviddata2 
   mov bl,","
   mov [gendata+ecx],bl
   inc ecx 
   jmp _moviddata
   _moviddata2:
   dec edx
   dec ecx
   mov ebx,"0xa"
   mov [gendata+ecx],ebx
   inc ecx
   inc ecx
   inc ecx 
   mov bl,0xa
   mov [gendata+ecx],bl
   inc ecx
   mov [gendatac],ecx
   ;
   push edx
   mov ecx,"mov "
   mov edx,4
   call prnx 
   mov ecx,"eax,"
   call prnx 
   mov ecx,"_CII"
   mov edx,4
   call prnx
   mov ecx,"D_"
   mov edx,2
   call prnx 
   mov eax,[intc2]
   dec eax
   call itos
   call prncij2 
   call prnnull 
   mov ecx,"mov "
   mov edx,4
   call prnx 
   mov ecx,"edx,"
   call prnx 
   pop eax ;edx to eax
   call itos 
   call prncij2
   call prnnull
   pop ecx
   mov ebx,1
   ret 
  
 genfdfidt:
   mov edx,[fdfco]
   mov eax,0
   call getfdfseq
   jmp genidt2
 
 getfdfseq:
   mov bl,[idv2+eax]
   mov bh,[genfuncs+edx]
   cmp bh,bl
   jne getfdfseq2
   add edx,1
   add eax,1
   mov bh,"|"
   cmp bh,bl
   jne getfdfseq
   mov eax,[genfuncs+edx]
   ret 
   getfdfseq2:
   mov bh,":"
   mov bl,[genfuncs+edx]  
   add edx,1  
   cmp bh,bl
   je getfdfseq3
   cmp bl,";"
   je genidtx
   jmp genidtx
   getfdfseq3:
   mov eax,0
   jmp getfdfseq
   
;;;;;;;;TRM;;;;;;;;;;
 genterm:
  call chkpres
  mov edx,[genseqts]
  mov bl,byte[genseq+edx]
  mov bh,"v"
  cmp bh,bl
  je fingenvar
  mov bh,"r"
  cmp bh,bl
  je fingenret 
  mov bh,"?"
  cmp bh,bl
  je cgenpush2
  mov bh,"$"
  cmp bh,bl
  je cgenpop2
  mov bl,[regf]
  mov bh,"o"
  cmp bh,bl
  je regdef2
  mov [trmgenc],ecx
  jmp lexstart

;;;;;;;;;;FDF;;;;;;;;;;
 genfdf:
  push ecx 
  mov ecx,"jmp "
  mov edx,4
  call prnx 
  mov ecx,"_CIF"
  call prnx 
  mov ecx,"J_"
  mov edx,2
  call prnx
  mov eax,[cgfjmpc]
  add eax,1
  mov [cgfjmpc],eax
  sub eax,1
  call itos 
  call prncij2
  call prnnull
  pop ecx
  add ecx,3
  mov edx,0
  call readid2
  mov edx,[funcc]
  mov eax,0
  mov bh,"|"
  call movarg
  inc edx
  mov [funcc],edx
  mov edx,[funcc]
  dec edx
  mov [fdfco],edx
 ;;;
  dec eax
  mov [idc],eax
  mov edx,[genseqts]
  mov bl,"{"
  add edx,1 
  mov [genseq+edx],bl
  mov [genseqts],edx
  pushad
  mov edx,[idc]
  mov [idc],edx
  mov ecx,idv
  mov edx,[idc]
  mov ebx,1
  mov eax,4
  int 0x80 
  mov bl,":"
  mov bh,0xa 
  mov [idv],bx 
  mov ecx,idv
  mov edx,2
  mov ebx,1
  mov eax,4
  int 0x80 
  popad
  jmp genfdf2
 genfdf2:
  call cgenread 
  mov edx,[idt]
  cmp edx,ebx
  je genfdfarg
  mov edx,[br1]
  cmp edx,ebx
  je genfinfdf
  mov edx,[term]
  cmp edx,ebx
  je genfinfdf
  mov edx,[cma]
  cmp edx,ebx
  je genfdf2
  jmp error2
 genfdfarg:
  mov edx,0
  call readid2
  mov edx,[funcc]
  mov bx,[genfuncs+edx-2]
  cmp bx,"||"
  je genfdfarg2
  genfdfarg3:
  mov eax,0
  mov bh,"|"
  call movarg
  mov eax,[stackc]
  mov [genfuncs+edx],eax
  add edx,4
  mov bl,":"
  mov [genfuncs+edx],bl
  inc edx 
  mov [funcc],edx
  add eax,8
  mov [stackc],eax
  jmp genfdf2
  genfdfarg2: 
  dec edx
  mov [funcc],edx 
  jmp genfdfarg3
 genfinfdf:
  mov bl,"o"
  mov [fdfif],bl
  mov edx,[funcc]
  dec edx
  mov bl,";"
  mov [genfuncs+edx],bl 
  inc edx
  mov [funcc],edx
  jmp lexstart

 movarg:
  mov bl,[idv+eax]
  mov [genfuncs+edx],bl
  add edx,1
  add eax,1
  cmp bl,bh
  jne movarg
  mov [genfuncs+edx],bl
  ;add edx,1
  mov [funcc],edx
  ret
 genendfdf:
  mov edx,[genseqts]
  mov bl,0
  mov [genseq+edx],bl
  dec edx
  mov [genseqts],edx
  mov bl,"z"
  mov [fdfif],bl
  push ecx 
  mov edx,4
  mov ecx,"_CIF"
  call prnx 
  mov ecx,"J_"
  mov edx,2
  call prnx
  mov eax,[cgfjmpc]
  sub eax,1
  call itos 
  call prncij2
  mov ecx,":"
  mov edx,1
  call prnx 
  call prnnull
  pop ecx 
  jmp lexstart
  
;;;;;;;;;;RET;;;;;;;;;;
 genret:
  mov edx,[genseqts]
  add edx,1
  mov bl,"r"
  mov [genseq+edx],bl
  mov [genseqts],edx
  jmp _codegenerator
 fingenret:
  mov edx,[genseqts]
  mov bl,0
  mov [genseq+edx],bl
  sub edx,1
  mov [genseqts],edx
  push ecx
  mov ecx,"ret"
  mov edx,3
  call prnx
  call prnnull
  call prnnull
  pop ecx
   call cgenread
   mov edx,[end]
   cmp edx,ebx 
   je genendfdf 
   sub ecx,3
   jmp genendfdf
   
;;;;;;;;;FCL;;;;;;;;
 genfcl:
  mov edx,0
  call readid2
  mov edx,0
  mov eax,0
  call findfunc ;finds func seq from sem file
  mov bl,[genfuncs+edx]
  mov bh,";"
  cmp bh,bl 
  jne genfcl2
  mov bh,"o"
  push bx
  jmp genfcl3
 genfcl2:
  mov bh,"z"
  push bx
 genfcl3:
  mov [genfc],edx
  call readpar
  mov eax,[genfuncs+edx]
  push eax 
  mov edx,[genseqts]
  mov bl,")"
  add edx,1
  mov [genseq+edx],bl
  mov [genseqts],edx
  call cgenread
  mov edx,[fce]
  cmp edx,ebx 
  je genfce
  sub ecx,3
  jmp _codegenerator
 
 genfce:
  push ecx
  mov ecx,"call"
  mov edx,4
  call prnx
  mov ecx," "
  mov edx,1
  call prnx
  call prnid1
  call prnnull
  pop ecx
  pop edx
  mov [genfc],edx
  mov edx,[genseqts]
  mov bl,0
  mov [genseq+edx],bl
  sub edx,1
  mov [genseqts],edx 
  genfcex:
  pop bx
  add ecx,3
  mov edx,[genseqts]
  mov bl,byte[genseq+edx]
  mov bh,"n"
  cmp bh,bl
  je genfinnot 
  sub ecx,3
  mov bh,"~"
  cmp bh,bl
  je fingenneg
  call bwdxmath 
  mov eax,[stackc]
  push eax
  call cgenread
  mov edx,[pls]
  cmp edx,ebx
  je exppls
  mov edx,[min]
  cmp edx,ebx
  je expmin
  mov edx,[mult]
  cmp edx,ebx
  je expmul
  mov edx,[divt]
  cmp edx,ebx
  je expdiv
  pop eax
  sub ecx,3
  jmp _codegenerator
  
 genfce2:
  call chkpres 
  pop eax
  call putpar
  push eax
  jmp genfce
 genfclpar:
  pop eax
  call putpar
  push eax
  jmp codegenerator
 
 putpar:
  push ecx
  push eax
  mov ecx,"mov "
  mov edx,4
  call prnx
  mov ecx,"[esp"
  call prnx
  mov ecx,"+"
  mov edx,1
  call prnx
  pop eax
  add eax,4
  push eax
  sub eax,4
  call itos
  call prncij2
  mov ecx,"],"
  mov edx,2
  call prnx
  mov edx,3
  call prneax
  call prnnull
  mov ecx,"mov "
  mov edx,4
  call prnx
  mov ecx,"[esp"
  call prnx
  mov ecx,"+"
  mov edx,1
  call prnx
  pop eax
  add eax,4
  push eax
  sub eax,4
  call itos
  call prncij2
  mov ecx,"]," 
  mov edx, 2
  call prnx
  mov edx,3
  call prnedx
  call prnnull
  pop eax
  pop ecx
  ret 
  
 findfunc:
  mov bl,[idv+eax]
  mov bh,[genfuncs+edx]
  cmp bh,bl
  jne findfunc2
  add edx,1
  add eax,1
  mov bh,"|"
  cmp bh,bl
  jne findfunc
  dec edx ;wasnt here before 
  ret 
 findfunc2:
  mov bh,";"
  mov bl,[genfuncs+edx]
  add edx,1 
  cmp bh,bl
  jne findfunc2
  mov eax,0
  jmp findfunc
 readpar:
  add edx,1
  mov bl,[genfuncs+edx]
  cmp bl,"|"
  jne readpar2
  add edx,1
  ret
  readpar2: ;wasnt here before
  cmp bl,";"
  jne readpar 
  add edx,1
  ret 
  
;;;;;;;;;ARD;;;;;;;;;
 genard:
  mov edx,[genseqts]
  add edx,1
  mov bl,"[" 
  mov [genseq+edx],bl
  mov [genseqts],edx
  mov edx,0
  call readid2
  call setnptard
  mov eax,0
  call setar
  jmp codegenerator
 genfinard:
  call chkpres
  call addel
  mov edx,[genseqts]
  mov bl,0
  mov [genseq+edx],bl
  sub edx,1
  mov [genseqts],edx
  jmp codegenerator
 genaddel:
  call addel
  mov edx,[ardec]
  add edx,1
  mov edx,[ardec]
  jmp codegenerator

 addel:
  mov eax,[stackc]
  push ecx
  push eax
  mov ecx,"mov "
  mov edx,4
  call prnx
  mov ecx,"[esp"
  call prnx
  mov edx,1
  mov ecx,"+"
  call prnx
  pop eax
  add eax,4 
  push eax
  sub eax,4
  call itos
  call prncij2
  mov ecx,"],"
  mov edx,2
  call prnx
  mov edx,3
  call prneax
  call prnnull
  mov ecx,"mov "
  mov edx,4
  call prnx
  mov ecx,"[esp"
  call prnx
  mov edx,1
  mov ecx,"+"
  call prnx
  pop eax
  add eax,4 
  push eax
  sub eax,4
  call itos
  call prncij2
  mov ecx,"],"
  mov edx,2
  call prnx
  mov edx,3
  call prnedx
  call prnnull
  pop eax
  mov eax,[stackc]
  add eax,8
  mov [stackc],eax
  pop ecx
  ret

 setar:
  mov edx,[ardcg]
  setar2:
  mov bl,[idv+eax]
  mov [genards+edx],bl
  inc eax
  inc edx
  cmp bl,"|"
  jne setar2
  mov eax,[stackc]
  mov [genards+edx],eax
  add edx,4
  mov bl,";"
  mov [genards+edx],bl 
  inc edx
  mov [ardcg],edx
  ret
 
 setnptard:
  mov edx,[nptcount]
  mov eax,0
  setnptard2:
  mov bl,[idv+eax] 
  mov [gennvar+edx],bl
  inc eax
  inc edx
  cmp bl,"|"
  jne setnptard2
  mov eax,[stackc]
  mov [gennvar+edx],eax
  add edx,4
  mov bl,";"
  mov [gennvar+edx],bl 
  inc edx
  mov [nptcount],edx
  mov eax,[stackc]
  ret   
  
;;;;;;;;;ARU;;;;;;;;
 genaru:
  mov edx,[genseqts]
  add edx,1
  mov bl,"]" 
  mov [genseq+edx],bl
  mov [genseqts],edx
  mov edx,0
  call readid2
  mov edx,0
  mov eax,0
  call findar
  mov eax,[genards+edx]
  push eax
  jmp codegenerator
 genfinaru:
  call chkpres
  pop eax 
  push ecx
  push eax
  mov ecx,"call"
  mov edx,4
  call prnx
  mov ecx," _CI"
  call prnx
  mov ecx,"MEM2"
  call prnx
  mov ecx,"REG_"
  call prnx
  call prnnull
  mov ecx,"mov "
  mov edx,4
  call prnx
  call prnebx
  mov ecx,"4"
  mov edx,1
  call prnx
  call prnnull
  mov ecx,"mul "
  mov edx,4
  call prnx
  mov edx,3
  call prnebx
  call prnnull
  mov ecx,"add "
  mov edx,4
  call prnx
  call prneax
  mov ecx,"4"
  mov edx,1
  call prnx
  call prnnull
  mov ecx,"mov "
  mov edx,4
  call prnx 
  call prnebx
  pop eax
  call itos 
  call prncij2
  call prnnull
  mov ecx,"add "
  mov edx,4
  call prnx
  call prneax
  dec edx
  call prnebx
  call prnnull 
  mov ecx,"mov "
  mov edx,4
  call prnx
  call prnebx
  mov edx,3
  call prneax
  call prnnull
  mov ecx,"mov "
  mov edx,4
  call prnx
  call prneax
  mov ecx,"[esp"
  call prnx
  mov ecx,"+"
  mov edx,1
  call prnx
  mov edx,3
  call prnebx
  mov ecx,"]"
  mov edx,1
  call prnx
  call prnnull
  mov ecx,"add "
  mov edx,4
  call prnx
  call prnebx
  mov ecx,"4"
  mov edx,1
  call prnx
  call prnnull 
  mov ecx,"mov "
  mov edx,4
  call prnx
  call prnedx
  mov ecx,"[esp"
  call prnx
  mov ecx,"+"
  mov edx,1
  call prnx
  mov edx,3
  call prnebx
  mov ecx,"]"
  mov edx,1
  call prnx
  call prnnull 
  pop ecx
  mov edx,[genseqts]
  mov bl,0
  mov [genseq+edx],bl
  sub edx, 1
  mov [genseqts],edx 
  call chkpres
  mov eax,[stackc]
  push eax
  call cgenread
  mov edx,[pls]
  cmp edx,ebx
  je exppls
  mov edx,[min]
  cmp edx,ebx
  je expmin
  mov edx,[mult]
  cmp edx,ebx
  je expmul
  mov edx,[divt]
  cmp edx,ebx
  je expdiv
  mov edx,[port]
  cmp edx,ebx
  je exppor
  pop eax
  sub ecx,3 
  jmp codegenerator 

 findar:
  mov bl,[idv+eax]
  mov bh,[genards+edx]
  cmp bh,bl
  jne findar2
  add edx,1
  add eax,1
  mov bh,"|"
  cmp bh,bl
  jne findar
  ret 
 findar2:
  mov bh,";"
  mov bl,[genards+edx]
  add edx,1 
  cmp bh,bl
  jne findar2
  mov eax,0
  jmp findar
   
;;;;;;;;;EXP;;;;;;;;;
 dwbmath:
  mov edx,[byt]
  cmp edx,ebx
  je xtobwd1
  mov edx,[wrd]
  cmp edx,ebx
  je xtobwd2
  mov edx,[dwrd]
  cmp edx,ebx
  je xtobwd3
  mov edx,[intt2]
  cmp edx,ebx
  je exptoint2
  mov edx,[flt]
  cmp edx,ebx
  je exptoflt
  mov edx,[ptrt]
  cmp edx,ebx
  je exptoptr
  mov edx,[true]
  cmp edx,ebx
  je exptotfn
  mov edx,[false]
  cmp edx,ebx
  je exptotfn 
  ret
  
 xtobwd1:
  call savee
  jmp genb
 xtobwd2:
  call savee
  jmp genw
 xtobwd3:
  call savee
  jmp gend
 
 regexp:
  push ebx
  mov eax,alf
  mov edx,"alR"
  cmp edx,ebx
  je exptoreg
  add eax,2
  mov edx,"ahR"
  cmp edx,ebx
  je exptoreg
  add eax,2
  mov edx,"axR"
  cmp edx,ebx
  je exptoreg
  add eax,2
  mov edx,"EAX"
  cmp edx,ebx
  je exptoreg
  add eax,2
  mov edx,"blR"
  cmp edx,ebx
  je exptoreg
  add eax,2
  mov edx,"bhR"
  cmp edx,ebx
  je exptoreg
  add eax,2
  mov edx,"bxR"
  cmp edx,ebx
  je exptoreg
  add eax,2
  mov edx,"EBX"
  cmp edx,ebx
  je exptoreg
  add eax,2
  mov edx,"clR"
  cmp edx,ebx
  je exptoreg
  add eax,2
  mov edx,"chR"
  cmp edx,ebx
  je exptoreg
  add eax,2
  mov edx,"cxR"
  cmp edx,ebx
  je exptoreg
  add eax,2
  mov edx,"ECX"
  cmp edx,ebx
  je exptoreg
  add eax,2
  mov edx,"dlR"
  cmp edx,ebx
  je exptoreg
  add eax,2
  mov edx,"dhR"
  cmp edx,ebx
  je exptoreg
  add eax,2
  mov edx,"dxR"
  cmp edx,ebx
  je exptoreg
  add eax,2
  mov edx,"EDX"
  cmp edx,ebx
  je exptoreg
  add eax,2
  mov edx,"ESI"
  cmp edx,ebx
  je exptoreg
  add eax,2
  mov edx,"EDI"
  cmp edx,ebx
  je exptoreg
  pop ebx
  ret
 restore:
  push ecx
  mov ecx,"mov "
  mov edx,4
  call prnx
  call prnecx
  mov edx,3
  call prnedx 
  call prnnull
  mov ecx,"mov "
  mov edx,4
  call prnx
  call prnebx
  mov edx,3
  call prneax
  call prnnull
  mov edx,4
  mov ecx,"mov "
  call prnx
  call prnedx
  mov ecx,"[esp"
  call prnx
  mov ecx,"+"
  mov edx,1
  call prnx
  mov eax,[stackc]
  sub eax,8
  mov [stackc],eax
  add eax,4
  call itos
  call prncij2
  mov ecx,"]"
  mov edx,1
  call prnx
  call prnnull
  mov edx,4
  mov ecx,"mov "
  call prnx
  call prneax
  mov ecx,"[esp"
  call prnx
  mov ecx,"+"
  mov edx,1
  call prnx
  mov eax,[stackc]
  sub eax,4
  mov [stackc],eax
  add eax,4
  call itos
  call prncij2
  mov ecx,"]"
  mov edx,1
  call prnx
  call prnnull
  pop ecx
  ret
 savee:
  push ecx
  mov edx,4
  mov ecx,"mov "
  call prnx
  mov ecx,"[esp"
  call prnx
  mov edx,1
  mov ecx,"+"
  call prnx
  mov eax,[stackc]
  add eax,4
  mov [stackc],eax
  sub eax,4
  call itos 
  call prncij2 
  mov ecx,"],"
  mov edx,2
  call prnx
  mov edx,3
  call prneax
  call prnnull
  mov edx,4
  mov ecx,"mov "
  call prnx
  mov ecx,"[esp"
  call prnx
  mov edx,1
  mov ecx,"+"
  call prnx
  mov eax,[stackc]
  add eax,4
  mov [stackc],eax
  sub eax,4
  call itos 
  call prncij2 
  mov ecx,"],"
  mov edx,2
  call prnx
  mov edx,3
  call prnedx
  call prnnull  
  mov ecx,"mov "
  mov edx,4
  call prnx
  call prneax
  mov edx,3
  call prnebx
  call prnnull
  mov ecx,"mov "
  mov edx,4
  call prnx
  call prnedx
  mov edx,3
  call prnecx
  call prnnull
  pop ecx
  ret
 chkops:
  mov edx,[genseqts]
  mov bl,[genseq+edx]
  mov bh,"+"
  cmp bh,bl
  je topls
  mov bh,"-"
  cmp bh,bl
  je tomin
  mov bh,"*"
  cmp bh,bl
  je tomul
  mov bh,"/"
  cmp bh,bl
  je todiv
  mov bh,"^"
  cmp bh,bl
  je topor
  pop eax
  mov [stackc],eax
  mov bl,"o"
  mov bh,[aodf]
  cmp bh,bl
  je doaodmath
  add ecx,3 ;idk really
  mov bl,[genseq+edx]
  cmp bl,"("
  je genlpr2
  sub ecx,3 ;idk man fr :|
  jmp codegenerator
 
 topls:
  call restore
  jmp dopls2
 tomin:
  call restore
  jmp domin2
 tomul:
  ;get eax back 
  call restore
  jmp domul2
 todiv:
  call restore
  jmp dodiv
 topor: 
  call restore
  jmp topor
  
 exptoout:
  push ecx
  mov edx,4
  mov ecx,"mov "
  call prnx
  mov ecx,"[esp"
  call prnx
  mov edx,1
  mov ecx,"+"
  call prnx
  mov eax,[stackc]
  add eax,4
  mov [stackc],eax
  sub eax,4
  call itos
  call prncij2
  mov ecx,"],"
  mov edx,2
  call prnx
  mov edx,3
  call prneax
  call prnnull
  mov edx,4
  mov ecx,"mov "
  call prnx
  mov ecx,"[esp"
  call prnx
  mov edx,1
  mov ecx,"+"
  call prnx
  mov eax,[stackc]
  add eax,4
  mov [stackc],eax
  sub eax,4
  call itos
  call prncij2
  mov ecx,"],"
  mov edx,2
  call prnx
  mov edx,3
  call prnedx
  call prnnull
  pop ecx
  ret
 
 exptofcl:  
  call exptoout
  jmp genfcl
 exptoaru:
  call exptoout
  jmp genaru
 exptoid:
  call exptoout
  jmp genidt
 exptonot:
  call exptoout
  jmp gennot
 exptoreg:
  push ebx
  call exptoout
  pop ebx
  add ecx,3
  jmp genregsx
 exptolpr:
  call savee
  jmp genlpr
 exptoaod:
  call savee
  jmp genaod
 exptoint2:
  call savee
  jmp gen2nt
 exptoflt:
  call savee
  jmp genflt
 exptoptr:
  call savee
  jmp genptr
 exptotfn:
  call savee
  sub ecx,3
  jmp codegenerator
  
 ;;;;!PLS!;;;;
 exppls:
  mov edx,[genseqts]
  mov bl,byte[genseq+edx]
  mov bh,"n"
  cmp bh,bl
  je exptonot 
  mov eax,[genseqts]
  mov bl,"+"
  add eax,1
  mov [genseq+eax],bl
  mov [genseqts],eax
 exppls2: 
  call cgenread
  call dwbmath
  mov edx,[lpr]
  cmp edx,ebx
  je exptolpr
  mov edx,[aod]
  cmp edx,ebx
  je exptoaod
  mov edx,[fcl]
  cmp edx,ebx
  je exptofcl
  mov edx,[aru]
  cmp edx,ebx
  je exptoaru
  mov edx,[idt]
  cmp edx,ebx
  je exptoid
  mov edx,[nott]
  cmp edx,ebx
  je exptonot 
  call regexp
  mov edx,0
  call readint 
  ;here we mov ebx,int
  push ecx
  call prnint 
  call prnnull
  mov ecx,"mov "
  mov edx,4
  call prnx
  call prnebx
  mov edx,4
  mov ecx,"_CII"
  call prnx
  mov edx,3
  mov ecx,"NT_"
  call prnx
  mov eax,[intc2]
  sub eax,1
  call itos
  call prncij2
  call prnnull
  mov ecx,"mov "
  mov edx,4
  call prnx
  call prnecx
  mov eax,[intc]
  call itos
  call prncij2
  call prnnull   
  pop ecx
 exppls3: 
  call cgenread
  mov edx,[pls]
  cmp edx,ebx
  je plstopls
  mov edx,[min]
  cmp edx,ebx
  je plstomin
  mov edx,[mult]
  cmp edx,ebx
  je plstomul
  mov edx,[divt]
  cmp edx,ebx
  je plstodiv
  mov edx,[port]
  cmp edx,ebx
  je plstopor
  jmp dopls

 plstopls:
  call movbadd
  jmp exppls
 plstomin:
  call movbadd
  jmp expmin
 plstomul:
  call savee
  jmp expmul
 plstodiv:
  call savee
  jmp expdiv
 plstopor:
  call savee
  jmp exppor
 
 dopls:
  call movbadd
  sub ecx,3
  jmp chkops
 dopls2:
  call movbadd
  jmp chkops
 
 movbadd:
  push ecx
  mov edx,4
  mov ecx,"call"
  call prnx
  mov ecx," _CI"
  call prnx 
  mov ecx,"ADD_"
  call prnx 
  call prnnull
  pop ecx
  mov edx,[genseqts]
  mov bl,0
  mov [genseq+edx],bl
  sub edx,1
  mov [genseqts],edx 
  ret

 outtopls:
  call restore
  jmp exppls3
 ;;min;;
 expmin:
  mov edx,[genseqts]
  mov bl,byte[genseq+edx]
  mov bh,"n"
  cmp bh,bl
  je exptonot 
  mov eax,[genseqts]
  mov bl,"-"
  add eax,1
  mov [genseq+eax],bl
  mov [genseqts],eax 
  call cgenread
  call dwbmath  
  mov edx,[lpr]
  cmp edx,ebx
  je exptolpr
  mov edx,[aod]
  cmp edx,ebx
  je exptoaod 
  mov edx,[fcl]
  cmp edx,ebx
  je exptofcl
  mov edx,[aru]
  cmp edx,ebx
  je exptoaru 
  mov edx,[idt]
  cmp edx,ebx
  je exptoid
  mov edx,[nott]
  cmp edx,ebx
  je exptonot  
  call regexp 
  mov edx,0
  call readint
  push ecx
  call prnint 
  call prnnull
  mov ecx,"mov "
  mov edx,4
  call prnx
  call prnebx
  mov edx,4
  mov ecx,"_CII"
  call prnx
  mov edx,3
  mov ecx,"NT_"
  call prnx
  mov eax,[intc2]
  sub eax,1
  call itos
  call prncij2
  call prnnull
  mov ecx,"mov "
  mov edx,4
  call prnx
  call prnecx
  mov eax,[intc]
  call itos
  call prncij2
  call prnnull   
  pop ecx
 expmin2: 
  call cgenread
  mov edx,[pls]
  cmp edx,ebx
  je mintopls
  mov edx,[min]
  cmp edx,ebx
  je mintomin
  mov edx,[mult]
  cmp edx,ebx
  je mintomul
  mov edx,[divt]
  cmp edx,ebx
  je mintodiv
  mov edx,[port]
  cmp edx,ebx
  je mintopor
  jmp domin

 mintopls:
  call savee
  jmp exppls
 mintomin:
  push ecx
  mov ecx,"call"
  mov edx,4
  call prnx
  mov ecx," _CI"
  call prnx
  mov ecx,"A2M_"
  call prnnull
  pop ecx
  call movbadd
  push ecx
  mov ecx,"call"
  mov edx,4
  call prnx
  mov ecx," _CI"
  call prnx
  mov ecx,"M2A_"
  call prnx
  call prnnull
  pop ecx  
  jmp expmin
 mintomul:
  call savee
  jmp expmul
 mintodiv:
  call savee
  jmp expdiv
 mintopor:
  call savee
  jmp exppor
  
 domin:
  sub ecx,3
 domin2:
  push ecx
  mov ecx,"call"
  mov edx,4
  call prnx
  mov ecx," _CI"
  call prnx
  mov ecx,"A2M_"
  call prnx
  call prnnull
  pop ecx
  call movbadd
  push ecx
  mov ecx,"call"
  mov edx,4
  call prnx
  mov ecx," _CI"
  call prnx
  mov ecx,"M2A_"
  call prnx
  call prnnull
  pop ecx
  jmp chkops

 ;;mul;;
 expmul:
  mov edx,[genseqts]
  mov bl,byte[genseq+edx]
  mov bh,"n"
  cmp bh,bl
  je exptonot 
  mov eax,[genseqts]
  mov bl,"*"
  add eax,1
  mov [genseq+eax],bl
  mov [genseqts],eax
  call cgenread
  call dwbmath
  mov edx,[lpr]
  cmp edx,ebx
  je exptolpr
  mov edx,[aod]
  cmp edx,ebx
  je exptoaod 
  mov edx,[fcl]
  cmp edx,ebx
  je exptofcl 
  mov edx,[aru]
  cmp edx,ebx
  je exptoaru 
  mov edx,[idt]
  cmp edx,ebx
  je exptoid
  mov edx,[nott]
  cmp edx,ebx
  je exptonot  
  mov edx,0
  call readint 
  push ecx
  call prnint 
  call prnnull
  mov ecx,"mov "
  mov edx,4
  call prnx
  call prnebx
  mov edx,4
  mov ecx,"_CII"
  call prnx
  mov edx,3
  mov ecx,"NT_"
  call prnx
  mov eax,[intc2]
  sub eax,1
  call itos
  call prncij2
  call prnnull
  mov ecx,"mov "
  mov edx,4
  call prnx
  call prnecx
  mov eax,[intc]
  call itos
  call prncij2
  call prnnull   
  pop ecx
 expmul2: 
  call cgenread
  mov edx,[pls]
  cmp edx,ebx
  je multopls
  mov edx,[min]
  cmp edx,ebx
  je multomin
  mov edx,[mult]
  cmp edx,ebx
  je multomul
  mov edx,[divt]
  cmp edx,ebx
  je multodiv
  mov edx,[port]
  cmp edx,ebx
  je multopor
  jmp domul 
 
 multopls:
  call movbmul
  jmp exppls 
 multomin: 
  call movbmul
  jmp expmin
 multomul:
  call movbmul
  jmp expmul 
 multodiv:
  call savee
  jmp expdiv
 multopor:
  call savee
  jmp exppor
  
 domul:
  sub ecx,3
 domul2:
  call movbmul
  jmp chkops

 movbmul:
  push ecx
  mov ecx,"call"
  mov edx,4
  call prnx
  mov ecx," _CI"
  call prnx
  mov ecx,"MUL_"
  call prnx
  call prnnull
  pop ecx
  mov edx,[genseqts]
  mov bl,0
  mov [genseq+edx],bl
  sub edx,1
  mov [genseqts],edx  
  ret

 outtomul:
  call restore
  jmp expmul2

 ;;div;;
 expdiv:
  mov edx,[genseqts]
  mov bl,byte[genseq+edx]
  mov bh,"n"
  cmp bh,bl
  je exptonot 
  mov eax,[genseqts]
  mov bl,"/"
  add eax,1
  mov [genseq+eax],bl
  mov [genseqts],eax
  call cgenread 
  call dwbmath
  mov edx,[lpr]
  cmp edx,ebx
  je exptolpr
  mov edx,[aod]
  cmp edx,ebx
  je exptoaod  
  mov edx,[fcl]
  cmp edx,ebx
  je exptofcl
  mov edx,[aru]
  cmp edx,ebx
  je exptoaru 
  mov edx,[idt]
  cmp edx,ebx
  je exptoid 
  mov edx,[nott]
  cmp edx,ebx
  je exptonot  
  mov edx,0
  call readint
  push ecx
  call prnint 
  call prnnull
  mov ecx,"mov "
  mov edx,4
  call prnx
  call prnebx
  mov edx,4
  mov ecx,"_CII"
  call prnx
  mov edx,3
  mov ecx,"NT_"
  call prnx
  mov eax,[intc2]
  sub eax,1
  call itos
  call prncij2
  call prnnull
  mov ecx,"mov "
  mov edx,4
  call prnx
  call prnecx
  mov eax,[intc]
  call itos
  call prncij2
  call prnnull   
  pop ecx
 expdiv2: 
  call cgenread 
  mov edx,[pls]
  cmp edx,ebx
  je divtopls
  mov edx,[min]
  cmp edx,ebx
  je divtomin
  mov edx,[mult]
  cmp edx,ebx
  je divtomul
  mov edx,[divt]
  cmp edx,ebx
  je divtodiv
  mov edx,[port]
  cmp edx,ebx
  je divtopor 
  call movbdiv
  sub ecx,3
  jmp chkops 

 dodiv:
  call movbdiv
  jmp chkops
 divtopls:
  call movbdiv
  jmp exppls
 divtomin:
  call movbdiv
  jmp expmin
 divtomul:
  call movbdiv
  jmp expmul
 divtodiv:
  call movbdiv
  jmp expdiv 
 divtopor:
  call savee
  jmp exppor  
 
 movbdiv:
  push ecx
  mov edx,4
  mov ecx,"call"
  call prnx
  mov ecx," _CI"
  call prnx 
  mov ecx,"DIV_"
  call prnx 
  call prnnull
  pop ecx
  mov edx,[genseqts]
  mov bl,0
  mov [genseq+edx],bl
  sub edx,1
  mov [genseqts],edx 
  ret
 outtodiv:
  call restore
  jmp expdiv2
  
 ;;por;;
 exppor:
  mov edx,[genseqts]
  mov bl,byte[genseq+edx]
  mov bh,"n"
  cmp bh,bl
  je exptonot 
  mov eax,[genseqts]
  mov bl,"^"
  add eax,1
  mov [genseq+eax],bl
  mov [genseqts],eax
  call cgenread 
  call dwbmath 
  mov edx,[lpr]
  cmp edx,ebx
  je exptolpr
  mov edx,[aod]
  cmp edx,ebx
  je exptoaod
  mov edx,[fcl]
  cmp edx,ebx
  je exptofcl
  mov edx,[aru]
  cmp edx,ebx
  je exptoaru 
  mov edx,[idt]
  cmp edx,ebx
  je exptoid 
  mov edx,[nott]
  cmp edx,ebx
  je exptonot  
  mov edx,0
  call readint
  push ecx
  call prnint 
  call prnnull
  mov ecx,"mov "
  mov edx,4
  call prnx
  call prnebx
  mov edx,4
  mov ecx,"_CII"
  call prnx
  mov edx,3
  mov ecx,"NT_"
  call prnx
  mov eax,[intc2]
  sub eax,1
  call itos
  call prncij2
  call prnnull
  mov ecx,"mov "
  mov edx,4
  call prnx
  call prnecx
  mov eax,[intc]
  call itos
  call prncij2
  call prnnull   
  pop ecx
 exppor2: 
  call cgenread 
  mov edx,[pls]
  cmp edx,ebx
  je portopls
  mov edx,[min]
  cmp edx,ebx
  je portomin
  mov edx,[mult]
  cmp edx,ebx
  je portomul
  mov edx,[divt]
  cmp edx,ebx
  je portodiv
  mov edx,[port]
  cmp edx,ebx
  je portopor
  call movbpor
  sub ecx,3
  jmp chkops 

 portopls:
  call movbpor
  jmp exppls
 portomin:
  call movbpor
  jmp expmin
 portomul:
  call movbpor
  jmp expmul
 portodiv:
  call movbpor
  jmp expdiv 
 portopor:
  call movbpor
  jmp exppor
 
 movbpor:
  push ecx
  mov edx,4
  mov ecx,"call"
  call prnx
  mov ecx," _CI"
  call prnx 
  mov ecx,"POR_"
  call prnx 
  call prnnull
  pop ecx
  mov edx,[genseqts]
  mov bl,0
  mov [genseq+edx],bl
  sub edx,1
  mov [genseqts],edx 
  ret
 outtopor:
  call restore
  jmp exppor2  
 
 dopor:
  call movbpor
  jmp chkops
 
;;;;;;;;;ROCK BOTTOM;;;;;;;;
 chkpres:
  mov edx,[genseqts]
  mov bl,byte[genseq+edx]
  mov bh,"n"
  cmp bh,bl
  je genfinnot 
  mov bh,"~"
  cmp bh,bl
  je fingenneg   
  sub ecx,3
  mov bh,"&"
  cmp bh,bl
  je genfinand
  mov bh,"|"
  cmp bh,bl
  je genfinor  
  call chktocmp 
  call chktoexp
  call chkforbits
  add ecx,3
  ret
 chktoexp:
  mov edx,[genseqts]
  mov bl,[genseq+edx]
  mov bh,"+"
  cmp bh,bl
  je topls
  mov bh,"-"
  cmp bh,bl
  je tomin
  mov bh,"*"
  cmp bh,bl
  je tomul
  mov bh,"/"
  cmp bh,bl
  je todiv
  mov bh,"^"
  cmp bh,bl
  je topor  
  ret
 
 regmathx:
  mov edx,"alR"
  cmp edx,ebx
  je genal
  mov edx,"ahR"
  cmp edx,ebx
  je genah
  mov edx,"axR"
  cmp edx,ebx
  je genax
  mov edx,"EAX"
  cmp edx,ebx
  je geneax
  mov edx,"blR"
  cmp edx,ebx
  je genbl
  mov edx,"bhR"
  cmp edx,ebx
  je genbh
  mov edx,"bxR"
  cmp edx,ebx
  je genbx
  mov edx,"EBX"
  cmp edx,ebx
  je genebx
  mov edx,"clR"
  cmp edx,ebx
  je gencl 
  mov edx,"chR"
  cmp edx,ebx
  je gench
  mov edx,"cxR"
  cmp edx,ebx
  je gencx
  mov edx,"ECX"
  cmp edx,ebx
  je genecx
  mov edx,"dlR"
  cmp edx,ebx
  je gendl
  mov edx,"dhR"
  cmp edx,ebx
  je gendh
  mov edx,"dxR"
  cmp edx,ebx
  je gendx
  mov edx,"EDX"
  cmp edx,ebx
  je genedx
  mov edx,"ESI"
  cmp edx,ebx
  je genesi
  mov edx,"EDI"
  cmp edx,ebx
  je genedi
 
 genal:
  push ecx 
  mov ecx,"mov "
  mov edx,4
  call prnx
  mov ecx,"edx,"
  call prnx 
  mov eax,[CIR+0]
  call itos 
  call prncij2
  call prnnull
  mov ecx,"movz"
  mov edx,4
  call prnx
  mov ecx,"x "
  mov edx,2
  call prnx 
  mov edx,4
  call prneax
  mov ecx,"byte"
  call prnx
  mov ecx,"[edx"
  call prnx
  mov ecx,"+"
  mov edx,1
  call prnx
  mov ecx,"3]"
  mov edx,2
  call prnx
  call prnnull
  pop ecx
  ret 
 genah:
  mov ecx,"mov "
  mov edx,4
  call prnx
  mov ecx,"edx,"
  call prnx 
  mov eax,[CIR+0]
  call itos 
  call prncij2
  call prnnull
  mov ecx,"movz"
  mov edx,4
  call prnx
  mov ecx,"x "
  mov edx,2
  call prnx 
  mov edx,4
  call prneax
  mov ecx,"byte"
  call prnx
  mov ecx,"[edx"
  call prnx
  mov ecx,"+"
  mov edx,1
  call prnx
  mov ecx,"2]"
  mov edx,2
  call prnx
  call prnnull
  ret  
 genax:
  mov ecx,"mov "
  mov edx,4
  call prnx
  mov ecx,"edx,"
  call prnx 
  mov eax,[CIR+0]
  call itos 
  call prncij2
  call prnnull
  mov ecx,"movz"
  mov edx,4
  call prnx
  mov ecx,"x "
  mov edx,2
  call prnx 
  mov edx,4
  call prneax
  mov ecx,"word"
  call prnx
  mov ecx,"[edx"
  call prnx
  mov ecx,"+"
  mov edx,1
  call prnx
  mov ecx,"2]"
  mov edx,2
  call prnx
  call prnnull
  ret    
 geneax:
  mov ecx,"mov "
  mov edx,4
  call prnx
  mov ecx,"edx,"
  call prnx 
  mov eax,[CIR+0]
  call itos 
  call prncij2
  call prnnull
  mov ecx,"movz"
  mov edx,4
  call prnx
  mov ecx,"x "
  mov edx,2
  call prnx 
  mov edx,4
  call prneax
  mov ecx,"dwor"
  call prnx
  mov ecx,"d"
  mov edx,1
  call prnx
  mov edx,4
  mov ecx,"[edx"
  call prnx
  mov ecx,"+"
  mov edx,1
  call prnx
  mov ecx,"0]"
  mov edx,2
  call prnx
  call prnnull
  ret  
 genbl:
  push ecx 
  mov ecx,"mov "
  mov edx,4
  call prnx
  mov ecx,"edx,"
  call prnx 
  mov eax,[CIR+4]
  call itos 
  call prncij2
  call prnnull
  mov ecx,"movz"
  mov edx,4
  call prnx
  mov ecx,"x "
  mov edx,2
  call prnx 
  mov edx,4
  call prneax
  mov ecx,"byte"
  call prnx
  mov ecx,"[edx"
  call prnx
  mov ecx,"+"
  mov edx,1
  call prnx
  mov ecx,"3]"
  mov edx,2
  call prnx
  call prnnull
  pop ecx
  ret 
 genbh:
  mov ecx,"mov "
  mov edx,4
  call prnx
  mov ecx,"edx,"
  call prnx 
  mov eax,[CIR+4]
  call itos 
  call prncij2
  call prnnull
  mov ecx,"movz"
  mov edx,4
  call prnx
  mov ecx,"x "
  mov edx,2
  call prnx 
  mov edx,4
  call prneax
  mov ecx,"byte"
  call prnx
  mov ecx,"[edx"
  call prnx
  mov ecx,"+"
  mov edx,1
  call prnx
  mov ecx,"2]"
  mov edx,2
  call prnx
  call prnnull
  ret  
 genbx:
  mov ecx,"mov "
  mov edx,4
  call prnx
  mov ecx,"edx,"
  call prnx 
  mov eax,[CIR+4]
  call itos 
  call prncij2
  call prnnull
  mov ecx,"movz"
  mov edx,4
  call prnx
  mov ecx,"x "
  mov edx,2
  call prnx 
  mov edx,4
  call prneax
  mov ecx,"word"
  call prnx
  mov ecx,"[edx"
  call prnx
  mov ecx,"+"
  mov edx,1
  call prnx
  mov ecx,"2]"
  mov edx,2
  call prnx
  call prnnull
  ret    
 genebx:
  mov ecx,"mov "
  mov edx,4
  call prnx
  mov ecx,"edx,"
  call prnx 
  mov eax,[CIR+4]
  call itos 
  call prncij2
  call prnnull
  mov ecx,"movz"
  mov edx,4
  call prnx
  mov ecx,"x "
  mov edx,2
  call prnx 
  mov edx,4
  call prneax
  mov ecx,"dwor"
  call prnx
  mov ecx,"d"
  mov edx,1
  call prnx
  mov edx,4
  mov ecx,"[edx"
  call prnx
  mov ecx,"+"
  mov edx,1
  call prnx
  mov ecx,"0]"
  mov edx,2
  call prnx
  call prnnull
  ret  
 gencl:
  push ecx 
  mov ecx,"mov "
  mov edx,4
  call prnx
  mov ecx,"edx,"
  call prnx 
  mov eax,[CIR+8]
  call itos 
  call prncij2
  call prnnull
  mov ecx,"movz"
  mov edx,4
  call prnx
  mov ecx,"x "
  mov edx,2
  call prnx 
  mov edx,4
  call prneax
  mov ecx,"byte"
  call prnx
  mov ecx,"[edx"
  call prnx
  mov ecx,"+"
  mov edx,1
  call prnx
  mov ecx,"3]"
  mov edx,2
  call prnx
  call prnnull
  pop ecx
  ret 
 gench:
  mov ecx,"mov "
  mov edx,4
  call prnx
  mov ecx,"edx,"
  call prnx 
  mov eax,[CIR+8]
  call itos 
  call prncij2
  call prnnull
  mov ecx,"movz"
  mov edx,4
  call prnx
  mov ecx,"x "
  mov edx,2
  call prnx 
  mov edx,4
  call prneax
  mov ecx,"byte"
  call prnx
  mov ecx,"[edx"
  call prnx
  mov ecx,"+"
  mov edx,1
  call prnx
  mov ecx,"2]"
  mov edx,2
  call prnx
  call prnnull
  ret  
 gencx:
  mov ecx,"mov "
  mov edx,4
  call prnx
  mov ecx,"edx,"
  call prnx 
  mov eax,[CIR+8]
  call itos 
  call prncij2
  call prnnull
  mov ecx,"movz"
  mov edx,4
  call prnx
  mov ecx,"x "
  mov edx,2
  call prnx 
  mov edx,4
  call prneax
  mov ecx,"word"
  call prnx
  mov ecx,"[edx"
  call prnx
  mov ecx,"+"
  mov edx,1
  call prnx
  mov ecx,"2]"
  mov edx,2
  call prnx
  call prnnull
  ret    
 genecx:
  mov ecx,"mov "
  mov edx,4
  call prnx
  mov ecx,"edx,"
  call prnx 
  mov eax,[CIR+8]
  call itos 
  call prncij2
  call prnnull
  mov ecx,"movz"
  mov edx,4
  call prnx
  mov ecx,"x "
  mov edx,2
  call prnx 
  mov edx,4
  call prneax
  mov ecx,"dwor"
  call prnx
  mov ecx,"d"
  mov edx,1
  call prnx
  mov edx,4
  mov ecx,"[edx"
  call prnx
  mov ecx,"+"
  mov edx,1
  call prnx
  mov ecx,"0]"
  mov edx,2
  call prnx
  call prnnull
  ret  
 gendl:
  push ecx 
  mov ecx,"mov "
  mov edx,4
  call prnx
  mov ecx,"edx,"
  call prnx 
  mov eax,[CIR+12]
  call itos 
  call prncij2
  call prnnull
  mov ecx,"movz"
  mov edx,4
  call prnx
  mov ecx,"x "
  mov edx,2
  call prnx 
  mov edx,4
  call prneax
  mov ecx,"byte"
  call prnx
  mov ecx,"[edx"
  call prnx
  mov ecx,"+"
  mov edx,1
  call prnx
  mov ecx,"3]"
  mov edx,2
  call prnx
  call prnnull
  pop ecx
  ret 
 gendh:
  mov ecx,"mov "
  mov edx,4
  call prnx
  mov ecx,"edx,"
  call prnx 
  mov eax,[CIR+12]
  call itos 
  call prncij2
  call prnnull
  mov ecx,"movz"
  mov edx,4
  call prnx
  mov ecx,"x "
  mov edx,2
  call prnx 
  mov edx,4
  call prneax
  mov ecx,"byte"
  call prnx
  mov ecx,"[edx"
  call prnx
  mov ecx,"+"
  mov edx,1
  call prnx
  mov ecx,"2]"
  mov edx,2
  call prnx
  call prnnull
  ret  
 gendx:
  mov ecx,"mov "
  mov edx,4
  call prnx
  mov ecx,"edx,"
  call prnx 
  mov eax,[CIR+12]
  call itos 
  call prncij2
  call prnnull
  mov ecx,"movz"
  mov edx,4
  call prnx
  mov ecx,"x "
  mov edx,2
  call prnx 
  mov edx,4
  call prneax
  mov ecx,"word"
  call prnx
  mov ecx,"[edx"
  call prnx
  mov ecx,"+"
  mov edx,1
  call prnx
  mov ecx,"2]"
  mov edx,2
  call prnx
  call prnnull
  ret    
 genedx:
  mov ecx,"mov "
  mov edx,4
  call prnx
  mov ecx,"edx,"
  call prnx 
  mov eax,[CIR+12]
  call itos 
  call prncij2
  call prnnull
  mov ecx,"movz"
  mov edx,4
  call prnx
  mov ecx,"x "
  mov edx,2
  call prnx 
  mov edx,4
  call prneax
  mov ecx,"dwor"
  call prnx
  mov ecx,"d"
  mov edx,1
  call prnx
  mov edx,4
  mov ecx,"[edx"
  call prnx
  mov ecx,"+"
  mov edx,1
  call prnx
  mov ecx,"0]"
  mov edx,2
  call prnx
  call prnnull
  ret  
 genesi:
  mov ecx,"mov "
  mov edx,4
  call prnx
  mov ecx,"edx,"
  call prnx 
  mov eax,[CIR+16]
  call itos 
  call prncij2
  call prnnull
  mov ecx,"movz"
  mov edx,4
  call prnx
  mov ecx,"x "
  mov edx,2
  call prnx 
  mov edx,4
  call prneax
  mov ecx,"dwor"
  call prnx
  mov ecx,"d"
  mov edx,1
  call prnx
  mov edx,4
  mov ecx,"[edx"
  call prnx
  mov ecx,"+"
  mov edx,1
  call prnx
  mov ecx,"0]"
  mov edx,2
  call prnx
  call prnnull
  ret  
 genedi:
  mov ecx,"mov "
  mov edx,4
  call prnx
  mov ecx,"edx,"
  call prnx 
  mov eax,[CIR+20]
  call itos 
  call prncij2
  call prnnull
  mov ecx,"movz"
  mov edx,4
  call prnx
  mov ecx,"x "
  mov edx,2
  call prnx 
  mov edx,4
  call prneax
  mov ecx,"dwor"
  call prnx
  mov ecx,"d"
  mov edx,1
  call prnx
  mov edx,4
  mov ecx,"[edx"
  call prnx
  mov ecx,"+"
  mov edx,1
  call prnx
  mov ecx,"0]"
  mov edx,2
  call prnx
  call prnnull
  ret  
 
 recreg:
  mov eax,alf
  mov edx,3
  mov bl,[eax]
  mov bh,"v"
  cmp bl,bh
  je genreg1 ;byte 1 number
  add eax,2
  mov edx,2
  mov bl,[eax];ah
  cmp bl,bh  
  je genreg1;byte 1 num
  add eax,2
  mov edx,2
  mov bl,[eax];ax
  cmp bl,bh
  je genreg1a;word 1 num 
  add eax,2
  mov edx,0
  mov bl,[eax];eax
  cmp bl,bh
  je genreg1b;dword 1 num 
  add eax,2
  mov edx,7
  mov bl,[eax];bl
  cmp bl,bh
  je genreg1;byte 1 num
  add eax,2
  mov edx,6
  mov bl,[eax];bh
  cmp bl,bh
  je genreg1;byte 1 num 
  add eax,2
  mov edx,6
  mov bl,[eax];bx
  cmp bl,bh
  je genreg1a;word 1 num 
  add eax,2
  mov edx,4
  mov bl,[eax];ebx
  cmp bl,bh
  je genreg1b;dword 1 num  
  add eax,2
  mov edx,11
  mov bl,[eax];cl
  cmp bl,bh
  je genreg2;byte 2 num
  add eax,2
  mov edx,10
  mov bl,[eax];ch
  cmp bl,bh
  je genreg2;byte 2 num 
  add eax,2
  mov edx,10
  mov bl,[eax];cx
  cmp bl,bh
  je genreg2a;word 2 num 
  add eax,2
  mov edx,8
  mov bl,[eax];ecx
  cmp bl,bh
  je genreg1b;dword 1 num   
  add eax,2
  mov edx,15
  mov bl,[eax];dl
  cmp bl,bh
  je genreg2;byte 1 num
  add eax,2
  mov edx,14
  mov bl,[eax];dh
  cmp bl,bh
  je genreg2;byte 1 num 
  add eax,2
  mov edx,14
  mov bl,[eax];dx
  cmp bl,bh
  je genreg2a;word 1 num 
  add eax,2
  mov edx,12
  mov bl,[eax];edx
  cmp bl,bh
  je genreg2b;dword 2 num
  add eax,2
  mov edx,16
  mov bl,[eax];esi
  cmp bl,bh
  je genreg2b;dword 2 num
  add eax,2
  mov edx,20
  mov bl,[eax];edi
  cmp bl,bh
  je genreg2b;dword 2 num 
  ret
 
genreg1:
 mov bl,"z"
 mov [eax],bl
 mov bl,[regfunc]
 mov [eax+1],bl
 mov [regf],bl
 mov eax,[CIR2+0]
 mov [CIR+edx],al
 ret
genreg1a:
 mov bl,"z"
 mov [eax],bl
 mov bl,[regfunc]
 mov [eax+1],bl
 mov [regf],bl
 mov eax,[CIR2+0]
 mov [CIR+edx],ax
 ret 
genreg1b:
 mov bl,[regf]
 mov [eax],bl
 mov bl,[regfunc]
 mov [eax+1],bl
 mov bl,"z"
 mov [regf],bl
 mov eax,[CIR2+0]
 mov [CIR+edx],eax
 pushad
 mov ebx,10
 xor edx,edx
 div ebx
 add dl,30h
 mov [cntn],dl
 call chk
 popad
 ret 
genreg2:
 mov bl,"z"
 mov [eax],bl
 mov [regf],bl
 mov eax,[CIR2+0]
 mov [CIR+edx],al
 ret
genreg2a:
 mov bl,"z"
 mov [eax],bl
 mov [regf],bl
 mov eax,[CIR2+0]
 mov [CIR+edx],ax
 ret 
genreg2b:
 mov bl,[regf]
 mov [eax],bl
 mov [regf],bl
 mov eax,[CIR2+0]
 mov [CIR+edx],eax
 ret 

 readint:
 mov [intc],edx
 mov bl,BYTE[CISYN+ecx]
 mov bh,"|"
 cmp bh,bl
 jne readintx
 mov [intv+edx],bl 
 add ecx,1
 mov edx,[cgdatac]
 cmp edx,40000000
 jge readintx2
 mov ebx,[intc]
 add edx,ebx 
 mov [cgdatac],edx  
 ret 
 readintx:
 mov [intv+edx],bl 
 inc edx;,1
 mov bl,","
 mov [intv+edx],bl 
 inc edx;,1 
 add ecx,1
 jmp readint 
 readintx2:
  mov bl,[cgover]
  add bl,1
  mov [cgover],bl 
  mov edx,[intc]
  mov [cgdatac],edx
  ret  
 
 readstr:
 mov bl,BYTE[CISYN+ecx]
 mov bh,"|"
 cmp bh,bl
 jne readstrx
 mov [strv+edx],bl 
 add ecx,1
 mov [strc],edx
 mov edx,[cgdatac]
 cmp edx,40000000
 jge readstrx2
 mov ebx,[strc]
 add edx,ebx 
 mov [cgdatac],edx 
 ret 
 readstrx:
 mov [strv+edx],bl 
 add edx,1
 add ecx,1
 jmp readstr 
 readstrx2:
 mov bl,[cgover]
 add bl,1
 mov [cgover],bl 
 mov edx,[strc]
 mov [cgdatac],edx
 ret 

 
 cgenfin:
 ;call chk
 call prnnull
 mov ecx,secd
 mov edx,lensd
 mov eax,4
 mov ebx,1
 int 0x80
 call prnnull
 mov edx,[gendatac]
 mov ecx,gendata
 mov eax,4
 mov ebx,1
 int 0x80
 call prnnull
 mov ecx,secb 
 mov edx,lesnb 
 mov eax,4
 mov ebx,1
 int 0x80 
 ;call prnnull 
 mov ecx,"cim "
 mov edx,4
 call prnx
 mov ecx,"resb"
 call prnx 
 mov ecx," 400"
 call prnx
 mov ecx,"0000"
 call prnx 
 mov ecx,"0"
 mov edx,1
 call prnx 
 call prnnull
 mov edx,3
 mov ecx,sukgg
 mov ebx,1
 mov eax,4
 int 0x80
 mov eax,11
 mov ebx,dir
 mov ecx,argv
 xor edx,edx
 int 0x80 
 mov ebx,0
 mov eax,1
 int 0x80 

 prnid1:
 pushad
 mov edx,[idc]
 mov eax,4
 mov ebx,1
 mov ecx,idv
 int 0x80 
 popad 
 ret 
 prnid2:
 pushad
 movzx edx,byte[idc2]
 mov eax,4
 mov ebx,1
 mov ecx,idv2
 int 0x80 
 popad 
 ret 
 prnpsh:
 pushad
 mov edx,5
 mov eax,4
 mov ebx,1
 mov ecx,pshg2
 int 0x80 
 popad 
 ret 
 prncall:
 pushad
 mov edx,5
 mov eax,4
 mov ebx,1
 mov ecx,calli
 int 0x80 
 popad 
 ret 
 prnmov: 
 pushad
 mov edx,4
 mov eax,4
 mov ebx,1
 mov ecx,movi
 int 0x80 
 popad 
 ret 
 prneax: 
 pushad
 mov eax,4
 mov ebx,1
 mov ecx,r1
 int 0x80 
 popad 
 ret 
 prnebx: 
 pushad
 mov eax,4
 mov ebx,1
 mov ecx,r2
 int 0x80 
 popad 
 ret  
 prnedx: 
 pushad
 mov eax,4
 mov ebx,1
 mov ecx,r4
 int 0x80 
 popad 
 ret  
 prnecx: 
 pushad
 mov eax,4
 mov ebx,1
 mov ecx,r3
 int 0x80 
 popad 
 ret  
 prnnull:
 pushad
 mov eax,4
 mov ecx,nullcg
 mov ebx,1
 mov edx,1
 int 0x80
 popad 
 ret
 prnint:
 pushad
 mov edx,4
 mov ecx,"_CII"
 call prnx2
 mov edx,3
 mov ecx,"NT_"
 call prnx2
 mov eax,[intc2]
 call itos
 call prncij2x
 mov eax,[intc2]
 add eax,1
 mov [intc2],eax
 mov ecx," db "
 mov edx,4
 call prnx2
 mov eax,0
 mov edx,0
 mov [intc],edx
 prnint2:
 mov bl,[intv+eax]
 cmp bl,","
 je prnint3
 cmp bl,"|"
 je prnint4
 mov ecx,ebx
 mov edx,1
 call prnx2
 mov edx,[intc]
 add edx,1
 mov [intc],edx
 add eax,1
 jmp prnint2
 prnint3:
 add eax,1
 mov ecx,ebx
 mov edx,1
 call prnx2
 jmp prnint2
 prnint4:
 mov ecx,"0"
 mov edx,1
 call prnx2
 mov ecx,0xa
 mov edx,1
 call prnx2 
 popad
 ret
 
 prnflt:
  mov edx,4
  mov ecx,"_CII"
  call prnx2
  mov edx,3
  mov ecx,"NT_"
  call prnx2
  mov eax,[intc2]
  add eax,1
  mov [intc2],eax
  sub eax,1
  call itos
  call prncij2x
  mov ecx," db "
  mov edx,4
  call prnx2
  mov bh,"."
  mov edx,0
  mov [fltc1],dl
 prnflt2:
  mov bl,[intv+edx]
  push edx
  mov ecx,ebx
  mov edx,1
  call prnx2
  pop edx
  cmp bl,bh
  je prnflt3
  add edx,1
  cmp bl,","
  je prnflt2
  mov eax,[fltc1]
  add eax,1
  mov [fltc1],eax
  jmp prnflt2
 prnflt3:
  sub edx,1
  push edx ;dl
  ;here print te dot 
  pop edx
  mov bh,"|"
  mov eax,0
  add edx,2
 prnflt4:
  mov bl,[intv+edx]
  cmp bl,bh
  je prnflt5
  push edx
  mov ecx,ebx
  mov edx,1
  call prnx2
  pop edx
  add edx,1
  cmp bl,","
  je prnflt4
  add eax,1
  jmp prnflt4
 prnflt5:
  mov ecx,"0"
  mov edx,1
  call prnx2
  mov ecx,0xa
  mov edx,1
  call prnx2
  mov edx,0
  mov edx,[fltc1]
  ret 
 
 prncij:
  pushad
  mov ecx,cijmps
  mov edx,7
  mov eax,4
  mov ebx,1
  int 0x80 
  popad 
  ret 
 prncij2:
  pushad
  mov ecx,cijmps2
  mov eax,4
  mov ebx,1
  int 0x80 
  popad 
  ret 
 prncij2x:
  pushad
  mov ecx,[cijmps2]
  call prnx2
  popad 
  ret  
 prnx:
  pushad
  mov [file],ecx
  mov ecx,file 
  mov eax,4
  mov ebx,1
  int 0x80 
  popad 
  ret 
 prnx2:
  pushad
  mov [file],ecx
  mov ecx,edx
  mov edx,0
  mov ebx,[gendatac]
  prnx2x:
  mov al,byte[file+edx]
  mov [gendata+ebx],al
  add ebx,1
  add edx,1
  loop prnx2x
  mov [gendatac],ebx
  popad
  ret

 itos:
  cmp eax,9 
  jle itos1
  cmp eax,99
  jle itos2 
  cmp eax,100 
  jge itos3
  jmp error 
  ret 
 
 itos3:
 xor edx,edx
 mov ebx,10
 div ebx
 add edx,30h
 mov [cijmps2+2],edx
 ;;;;;;;
 xor edx,edx
 div ebx
 add edx,30h
 mov [cijmps2+1],edx
 ;;;;;;;;
 xor edx,edx
 div ebx
 add edx,30h
 mov [cijmps2+0],edx
 mov edx,3
 ret  
 itos2:
 xor edx,edx
 mov ebx,10
 div ebx
 add edx,30h
 mov [cijmps2+1],edx
 xor edx,edx
 div ebx
 add dl,30h
 mov [cijmps2+0],dl
 mov edx,2
 ret 
 itos1:
 xor edx,edx
 mov ebx,10
 div ebx
 add edx,30h
 mov [cijmps2+0],edx
 mov edx,1
 ret
 
chk2:
 pushad
 mov [cntn],bl
 mov [cntn+1],bh
 mov ecx,cntn
 mov edx,5
 mov eax,4
 mov ebx,1
 int 0x80 
 popad 
 ret
;;;;;; DATA ;;;
;;;;;; DATA ;;;;;;
section .data

;ffile db "ARUf|INT3|PLSINT45|EQ2NOTSTRst|MULARUer|INT9|MININT3|PLSFCLf|INT45|CMAIDTid|PLSINT45|FCEGEQNEGIDTi|AREEQ2LPRNEGINT342|MINFCLo|FCEPLSIDTo|RPRARETRMeof",0
count db 0
suk db "Phase 3 : Success",0xa
suklen equ $-suk
nl2 db "|",0
err db "err",0
pointlesssh dd 0,0,0,0,0
varseq dd 0
ptrseq dd 0
parcount dd 0 
parcount2 dd 0
argc dd 0
fncsc dd 0 ;c 
semseqts dd 0 ;c
ardc dd 0 ;c 
rtype db "z",0,0,0
ntype db "z",0
;;;;;;;;;;;;flags;;;;;;;;;;;
;;;z;;;
zcf db "z",0
znf db "z",0
;;;var;;;
vfi db "z",0 ;indicates if vf is on o nah
xf db "z",0 ;2nt
of db "z",0 ;op1 
lf db "z",0 ;lpr 
idf db "z",0 ;if its idt 
vcf db "z",0
vf db "z",0
aruf db "z",0
sorff db "z",0
vnf db "z",0
pf db "z",0 ;ptr
;;;gen;;;
iff db "z",0 ;int
sf db "z",0 ;str
nf2 db "z",0 ;REAL null
chgf db "z",0
rf db "z",0 ;ret
;;
fcf dd "z",0,0,0,0
fnf db "z",0
;;
sorft db "z",0
pfi db "0",0
;tokenz
strt2 db "2TR",0

leq db "LEQ",0
grt db "GRT",0
geq db "GEQ",0
lpr db "LPR",0
true db "TRU",0
false db "FLS",0
lest db "LES",0
trm db "TRM",0
intt db "INT",0
strt db "STR",0
idt db "IDT",0
inct db "INC",0
dots db "DOT",0
dect db "DEC",0
negt db "NEG",0
null db "NUL",0 
psh db "PSH",0
endp db "NDP",0 ;end push
rett db "RET",0
seqend db "SQE",0
rpr db "RPR",0
neq db "NEQ",0
equt db "EQU",0
ado db "ADO",0
syniwf db "z",0
synsuc db "Phase 2 : Success",0xa
synsucl equ $-synsuc
sync dd 0
file db "000",0xa
rps db '0',0
useless db "z",0
nl db 0xa
fcs db 0
seqts dd 0
useless2 db "DEC",0
len2 equ $-useless2
ter db "TRM",0
synerr db "Syntax Error [!]",0
synelen equ $-synerr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
semerr1 db "Semantic Error : Can't use math operations with Strings/Null",0xa
lense1 equ $-semerr1
semerr2 db "Semantic Error : Can't increase or decrease Strings/Null",0xa
lense2 equ $-semerr2
semerr3 db "Semantic Error : Just a String/Null inside parenthesses",0xa
lense3 equ $-semerr3 
semerr4 db "Semantic Error : Undefined Variable",0xa
lense4 equ $-semerr4
semerr5 db "Semantic Error : Redefined Variable",0xa
lense5 equ $-semerr5 
semerr6 db "Semantic Error : Wrong number of parameters",0xa
lense6 equ $-semerr6 
semerr7 db "Semantic Error : Undefined Function",0xa
lense7 equ $-semerr7
semerr8 db "Semantic Error : Redefined Function",0xa
lense8 equ $-semerr8
semerr9 db "Semantic Error : String/Null can't be converted to String",0xa
lense9 equ $-semerr9 
semerr10 db "Semantic Error : Int/Null can't be converted to Int",0xa
lense10 equ $-semerr10
semerr11 db "Semantic Error : Pointer does not exist",0xa
lense11 equ $-semerr11 
semerr12 db "Semantic Error : Array does not exist",0xa
lense12 equ $-semerr12 
semerr13 db "Semantic Error : redefined Array",0xa
lense13 equ $-semerr13 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
newt db "NEW",0
byt db "BYT",0
wrd db "WRD",0
dwr db "DWR",0
min db "MIN",0
sb1 db "SB1",0
mult db "MUL",0
divt db "DIV",0
eq2 db "EQ2",0
cma db "CMA",0
movt db "MOV",0
movb db "MOB",0
bit db "BIT",0
espt db "ESP",0
movci db "MCI",0
var db "VAR",0
fcl db "FCL",0
fce db "FCE",0
pls db "PLS",0
aru db "ARU",0
sb2 db "SB2",0
are db "ARE",0
prn db "PRN",0
seqt db "SEQ",0
br1 db "BR1",0
br2 db "BR2",0
fprn db "FPR",0
fdf db "FDF",0
func db "FNC",0
andt db "AND",0
ort db "ORT",0
ift db "IFT",0
while db "WIL",0
endw db "EWL",0
endf2 db "EIF",0
shrt db "SHR",0
shlt db "SHL",0
nullt db  "NUL",0
dwrd db "DWR",0
print db "PRN",0
fprint db "FPR",0
end2 db "2ND",0
rort db "ROR",0
rolt db "ROL",0
intt2 db "2NT",0
rolf db "RLF",0
rorf db "RRF",0
shlf db "SLF",0
shrf db "SRF",0
port db "POR",0
nott db "NOT",0
endt db "2ND",0
ptrt db "PTR",0
aod db "ADO",0
seq db "SEQ",0
flt db "FLT",0
npt db "NPT",0
psht db "PSH",0
popt db "POP",0
ade db "ADE",0
ard db "ARD",0
got db "BR1",0
end db "END",0
input db "NPT",0
strf db "2TR",0
intf db "2NT",0
for db "FOR",0
if db "IFT",0
pt db "PTR",0
else db "ELS",0
intT db "TIN",0
term db "TRM",0
funct db "FNC",0
qm1 db "QM1",0
qm2 db "QM2",0
dot db "DOT",0
pps db "INC",0
mmn db "DEC",0
fl db "fl",0
return db "RET",0
synbrf db "z",0
synnf db "z",0
syncf db "z",0
synfilename db "_CISYN_",0
cntn2 db 0xa


lexe2 db "Semantic Error : Unsupported type",0
lene2 equ $-lexe2
lexe1 db "Tokenization Error : charecter not allowed",0
lene1 equ $-lexe1
lexmsg db "Phase 1 : Success",0
lenlex equ $-lexmsg
lexc dd 0
counter dd 0
ff db 0
;;;;;;;;;LEX DATA;;;;;;;;;;

len equ $-mmn
pusht db "PSH",0
eof db "eof",0
fe dw "func:",0
seq2 dw "seq",0 
shl2 dw "shl",0
str2 dw "str",0
shr2 dw "shr",0  
false2 db "false",0
while2 dw "while",0
ifn dw "ifn",0
int2 dw "int",0 
input2 dw "input",0
print2 dw "print",0
pop2 dw "pop",0
push2 dw "push",0
else2 dw "else",0
return2 dw "return ",0
rol2 dw "rol",0
ror2 dw "ror",0
true2 db "true",0
null2 db "null",0
eaxl db "EAX",0
ebxl db "EBX",0
ecxl db "ECX",0
edxl db "EDX",0
edil db "EDI",0
esil db "ESI",0
sukgg db "SUK",0
regsx db "00R",0
ints1 db "0","1","2","3","4","5","6","7","8","9",0xa 
letters db "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","_","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",0xa
ids db "0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","_","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",0xa
intc dd 0 
newline db 0xa
fdfcount dd 0
fdfcount2 dd 0
fdfcount3 dd 0
;;;;;;;;REGS FLAGS;;;;;;;
fdff db "z",0
fdfi db "z",0
eofdf db "z",0
jzero dd 0
fcfc db "z",0
semstack dd 0
gvseqc dd 0
stackc dd 0
ftempc dd 0
semco dd 0 ;semantic counter 
newc dd 0 ;syntax analyzer
newclx dd 0 ;lexical analyzer
newcsm dd 0 ;semantic analyzer
;;;;;;;;CGEN;;;;;;;;
regfaod db "z",0
arugens dd 0
addi db "add ",0 
sb1i db "[",0
sb2i db "]",0xa 
pshg2 db "push ",0
calli db "call ",0
movi db "mov ",0
r1 db "eax,",0
r2 db "ebx,",0
r3 db "ecx,",0
r4 db "edx,",0
espi db "esp",0
cmpi db "cmp ",0
jmps db "0000",0
cijmps db "_CIJMP_",0
cifinjmp db "_CIFINJ_",0
ciifj db "_CIIF_",0
cifinifj db "_CIFINIF_",0
ciwilj db "_CIWIL_",0
ciwilj2 db "_CIWILS_",0
cifinwilj db "_CIFINWIL_",0
cielsej db "_CIELSE_",0
cifinelsej db "_CIFINELSE_",0
pshg db "push esp",0xa
sec db "section .text",0
secd db "section .data",0
lensd equ $-secd
nullcg db 0xa
;;flags;;
fdfif db "z",0
aodf db "z",0
fclregf db "z",0
seqv db "z",0
iif db "z",0
cf db "z",0
cf2 db "z",0
calf db "z",0
pstt db "z",0
fclf db "z",0
strf2 db "z",0
gflt db "z",0
regf db "z",0
semfb db "z",0
alf db "i",0
ahf db "i",0
axf db "i",0
eaxf db "i",0
blf db "i",0
bhf db "i",0
bxf db "i",0
ebxf db "i",0
clf db "i",0
chf db "i",0
cxf db "i",0
ecxf db "i",0
dlf db "i",0
dhf db "i",0
dxf db "i",0
edxf db "i",0
esif db "i",0
edif db "i",0

alfs db "i",0 ;semantic
ahfs db "i",0
axfs db "i",0
eaxfs db "i",0
blfs db "i",0
bhfs db "i",0
bxfs db "i",0
ebxfs db "i",0
clfs db "i",0
chfs db "i",0
cxfs db "i",0
ecxfs db "i",0
dlfs db "i",0
dhfs db "i",0
dxfs db "i",0
edxfs db "i",0
esifs db "i",0
edifs db "i",0
;;counters;;
strv2 dd 1
strv3 dd 0
cijmps2 db 0,0,0,0,0,0,0,0
heapc dd 0
idc2 dd 0
idc dd 0
intc2 dd 0
strc dd 0
strvc dd 0
fincijc dd 1
cijmpcs dd 1
ciifjc dd 1
ciwiljc dd 1
cielsejc dd 1
varsc dd 0
varsc2 dd 0
funcc dd 0
ardec dd 0 ;elemetns counter
genseqts dd 0
genfc dd 0
fltc1 db 0
fltc2 dd 0
gendatac dd 0
fdfco dd 0
cgdatac dd 0
cgover db 0
cgfjmpc dd 0
cgfjmp db "_CIFJ_",0
cgtfnc dd 0 
ardcg dd 0 ;c 
trmgenc dd 0
nptcount dd 0
genseqtr dd 0
regfunc db "z",0
idfsem db "z",0
lexco dd 0
synco dd 0
semco2 dd 0
cgenco dd 0



secb db "section .bss",0xa
lesnb equ $-secb 
argv dd argv0,0 
dir db "usr/bin/gnome-terminal",0
argv0 db "Nothing",0

_CIPSV2_ db "-",1,0xa
_varstack dd 0


section .bss
ignoremeplz resd 10
CIR2 resb 28
_CIDIVS_ resb 28
_CIDIVS_2 resb 8 
_CIPSV_ resb 16
_CIPSV3_ resb 8
CIR resb 40 ;registers
stack resb 50000
cim resb 4000
inputCI resb 50000
CILEX resb 75000
CISYN resb 60000
track resb 5000
lex_int resb 255
synids resb 400
;this is real for me , i need this  
;this is a therapy for ME (me me me)
;;;;x=123;y=12+x;z=str(y);print(z);?
fdfundef resb 500
fdfundef2 resb 500
stack2 resb 5000
varid resb 100
idv2 resb 100
idv resb 100
vars resb 1000
ptrvar resb 500
defard resb 500 
funcs resb 500
gidseq resb 1000
ftemp resb 1000
semtrack resb 500
;;;;;gen shit
genvars resb 5000
genfuncs resb 5000
genards resb 5000
intv resb 100
strv resb 100
genseq resb 500
gennvar resb 500
gentext resb 10000
gendata resb 5000
semfbs resb 5
cntn resb 3