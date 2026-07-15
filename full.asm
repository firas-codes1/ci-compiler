 section .stack 
.stack dd 4000h 

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
 
lexstart:
 mov ecx,0
 jmp mainlex

mainlex:
 call lexread
 mov bh,"e"
 cmp bh,bl
 je supposereg
 mov bh,"a"
 cmp bh,bl
 je supposeregx
 mov bh,"b"
 cmp bh,bl
 je supposeregx
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
;;;;;;;;;;;PUTS;;;;;;;;;;;
 putdots:
 push ecx
 mov ecx,[dots]
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
 jne adjusttoid
 call lexread
 call noid
 pop eax
 push ecx
 mov ecx,[esil]
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
 jmp mainlex
 terminator2:
 push ecx
 mov ecx,[newt]
 call putx
 pop ecx
 mov edx,[newc]
 add edx,1
 mov [newc],edx
 jmp mainlex
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
 jne adjusttoid
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
 mov ecx,1
 mov [seqts],ecx
 mov ecx,0
 mov [newc],ecx
 mov [fcs],ecx
 mov [sync],ecx
 mov edx,"z"
 mov [track+0],edx
 jmp synstart

synstart:
 mov bl,"z"
 mov [synnf],bl
 call read
 call synreg
 call synbwd
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
 je synstart
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
 mov edx,[seqts]
 mov eax,[track+edx]
 mov edx,"2"
 cmp edx,eax
 je error
 mov bl,"o"
 mov bh,[synbrf]
 cmp bh,bl
 jne error 
 mov bl,"z"
 mov [synbrf],bl
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
 jmp sttl 

 chkcma:
 mov eax,[seqts]
 mov edx,[track+eax]
 mov eax,"f"
 cmp edx,eax 
 jne error 
 jmp syn_fclcma
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
 ret 

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
 jmp synstart
 synnewl:
 push ecx
 mov ecx,[cntn]
 call puts
 pop ecx
 mov edx,[newc]
 add edx,1
 mov [newc],edx
 jmp synstart
 
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
 int 0x80  
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

semini:
 mov eax,"z"
 mov [semtrack],eax 
 mov ecx,0
 mov [newc],ecx
 mov [cntn],ecx
 mov [varseq],ecx
 jmp semstart 

semstart:
 call clearflags
 call semread
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
 jmp error2 
 
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
 jmp succ
;;;;;;;GENERAL;;;;;;;;
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
 mov edx,[endf]
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
 mov edx,[endf]
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
 mov edx,[endf]
 cmp edx,ebx
 je sem_endiow 
 mov edx,[rpr]
 cmp edx,ebx
 je zchkrpr
 jmp z_0
zrpr:
 call semread
 call z_ops
 call trms 
 mov edx,[endp]
 cmp edx,ebx
 je endpush 
 mov edx,[trm]
 cmp edx,ebx
 je succ
 mov edx,[endt]
 cmp edx,ebx
 je semfintostr
 mov edx,[rpr]
 cmp edx,ebx
 je zrpr
 mov edx,[endw]
 cmp edx,ebx
 je sem_endiow
 mov edx,[endf]
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
 mov edx,[intt]
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
 jmp ardef1
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
 call semread
 call trms
 sub ecx,3
 jmp semstts2
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
 add ecx,3
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
 call semread
 call trms
 jmp semstart 
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
 mov bl,"o"
 mov [chgf],bl
 mov bl,"s"
 mov [ntype],bl 
 call getidtype
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
 mov eax,alf
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
 jmp semvar2

chkregsv:
 mov ebx,alf
 mov dl,[ebx]
 cmp dl,"v"
 je assignreg1
 mov ebx,ahf
 mov dl,[ebx]
 cmp dl,"v"
 je assignreg1
 mov ebx,axf
 mov dl,[ebx]
 cmp dl,"v"
 je assignreg2
 mov ebx,eaxf
 mov dl,[ebx]
 cmp dl,"v"
 je assignreg3
 mov ebx,blf
 mov dl,[ebx]
 cmp dl,"v"
 je assignreg1
 mov ebx,bhf
 mov dl,[ebx]
 cmp dl,"v"
 je assignreg1
 mov ebx,bxf
 mov dl,[ebx]
 cmp dl,"v"
 je assignreg2
 mov ebx,ebxf
 mov dl,[ebx]
 cmp dl,"v"
 je assignreg3
 mov ebx,clf
 mov dl,[ebx]
 cmp dl,"v"
 je assignreg1
 mov ebx,chf
 mov dl,[ebx]
 cmp dl,"v"
 je assignreg1
 mov ebx,cxf
 mov dl,[ebx]
 cmp dl,"v"
 je assignreg2
 mov ebx,ecxf
 mov dl,[ebx]
 cmp dl,"v"
 je assignreg3
 mov ebx,dlf
 mov dl,[ebx]
 cmp dl,"v"
 je assignreg1
 mov ebx,dhf
 mov dl,[ebx]
 cmp dl,"v"
 je assignreg1
 mov ebx,dxf
 mov dl,[ebx]
 cmp dl,"v"
 je assignreg2
 mov ebx,edxf
 mov dl,[ebx]
 cmp dl,"v"
 je assignreg3
 mov ebx,esif
 mov dl,[ebx]
 cmp dl,"v"
 je assignreg
 mov ebx,edif
 mov dl,[ebx]
 cmp dl,"v"
 je assignreg
 ret  
 
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
 mov dl,[iff]
 cmp dl,"o"
 je var_int
 jmp endvar
assignaod3:
 mov dl,"a"
 mov [ebx],dl
 sub ebx,2
 mov [ebx],dl
 sub ebx,2;5
 mov [ebx],dl
 sub ebx,2
 mov [ebx],dl
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
 mov eax,0
 mov edx,0
 call chkvar
semvar2:
 call semread
 call varregs
 mov edx,[ptrt]
 cmp edx,ebx
 je varptr
 mov edx,[aru]
 cmp edx,ebx
 je semaru
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
 jmp var

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
 call readid2 
 call getidtype 
 mov bl,"o"
 mov bh,[sf]
 cmp bh,bl 
 je var_idstr
 sub ecx,2 ;for readtonothing 
 jmp varint 

varint:
 mov bl,"o"
 mov [iff],bl
 call addvar

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
 mov bl,"o"
 mov [sf],bl
 ;mov [vf],bl
 call addvar 

var_input:
 add ecx,3 
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
 call addvar 

var_iod:
 call semread
 mov edx,[trm]
 cmp edx,ebx
 je endvar
 mov edx,[rpr]
 cmp edx,ebx
 je var_rpr
 call varops
 jmp var_0
var_int:
 call clearflags
 mov bl,"o"
 mov bh,[xf]
 cmp bh,bl 
 je semtoint
 mov bh,[of]
 cmp bh,bl
 je var_op 
 mov bh,[lf]
 cmp bh,bl
 je var_lpr 
 mov bh,[vcf]
 cmp bh,bl 
 je var_0
 mov bh,[vnf]
 cmp bh,bl
 je var_op2
 mov bh,[aruf]
 cmp bh,bl
 je tov
 mov bh,[vfi]
 cmp bh,bl
 je endvar2
 mov bh,[regf]
 cmp bh,bl
 je var_intt2
 jmp var_intt 
var_intt:
 call tonothing
var_intt2:
 call semread
 mov edx,[lpr]
 cmp edx,ebx
 je var_lpr 
 mov edx,[trm]
 cmp edx,ebx
 je endvar 
 mov edx,[rpr]
 cmp edx,ebx 
 je var_rpr
 mov edx,[inct]
 cmp edx,ebx
 je var_iod
 mov edx,[dect]
 cmp edx,ebx
 je var_iod
 call varops
 jmp var_0 ;cmp 
var_str:
 call tonothing
var_str2: 
 call semread
 call strerrors
 mov edx,[trm]
 cmp edx,ebx
 je endvar
 mov edx,[rpr]
 cmp edx,ebx
 je vchkrpr
 jmp var_0
var_lpr:
 mov bl,"z"
 mov [vcf],bl
 mov [vnf],bl
 mov [lf],bl
 call semread
 call regs 
 mov edx,[idt]
 cmp edx,ebx
 je var_id
 mov edx,[strt]
 cmp edx,ebx 
 je var_lpr2
 mov edx,[true]
 cmp edx,ebx
 je var_intt2
 mov edx,[false]
 cmp edx,ebx
 je var_intt2 
 mov edx,[fcl]
 cmp edx,ebx
 je semfcl
 mov edx,[aru]
 cmp edx,ebx
 je semaru
 mov edx,[lpr]
 cmp edx,ebx 
 je var_lpr 
 mov edx,[intt]
 cmp edx,ebx 
 je var_intt 
 mov edx,[flt]
 cmp edx,ebx
 je var_intt
 mov edx,[null]
 cmp edx,ebx
 je var_lpr3
 mov edx,[intt2]
 cmp edx,ebx
 je semtoint
 mov edx,[strt2]
 cmp edx,ebx
 je semtostr
 mov edx,[aod]
 cmp edx,ebx
 je var_aod2
 mov edx,[ptrt]
 cmp edx,ebx
 je semptr 
 call varops 
var_lpr2:
 call tonothing 
var_lpr3: 
 call semread
 call strerrors
 mov edx,[rpr]
 cmp edx,ebx
 je seme3
 jmp var_0 ;cmp 
var_rpr:
 call semread
 mov edx,[trm]
 cmp edx,ebx
 je endvar 
 mov edx,[rpr]
 cmp edx,ebx
 je var_rpr
 call varops 
 jmp var_0 ;cmp 
var_op:
 mov bh,"z"
 mov [vnf],bh
 mov [of],bh
 call semread
 call regs 
 mov edx,[true]
 cmp edx,ebx
 je var_intt2
 mov edx,[false]
 cmp edx,ebx
 je var_intt2  
 mov edx,[intt]
 cmp edx,ebx 
 je var_intt
 mov edx,[intt2]
 cmp edx,ebx 
 je semtoint
 mov edx,[flt]
 cmp edx,ebx 
 je var_intt ; ;tf too  
 mov edx,[idt]
 cmp edx,ebx 
 je var_idint 
 mov edx,[fcl]
 cmp edx,ebx
 je zfclint
 mov edx,[aru]
 cmp edx,ebx
 je semaru
 mov edx,[nott]
 cmp edx,ebx
 je var_op2 
 mov edx,[ptrt]
 cmp edx,ebx
 je semptr2   
 jmp var_lpr 
var_op2:
 mov bh,"o"
 mov [vnf],bh
 call semread
 call regs 
 mov edx,[intt]
 cmp edx,ebx
 je var_intt
 mov edx,[flt]
 cmp edx,ebx
 je var_intt 
 mov edx,[true]
 cmp edx,ebx
 je var_intt2
 mov edx,[null]
 cmp edx,ebx
 je var_intt2 
 mov edx,[false]
 cmp edx,ebx
 je var_intt2  
 mov edx,[strt]
 cmp edx,ebx 
 je var_intt
 mov edx,[idt]
 cmp edx,ebx
 je var_id2
 mov edx,[fcl]
 cmp edx,ebx
 je semfcl
 mov edx,[aru]
 cmp edx,ebx
 je semaru
 mov edx,[intt2]
 cmp edx,ebx
 je semtoint
 mov edx,[strt2]
 cmp edx,ebx
 je semtostr
 mov edx,[aod]
 cmp edx,ebx
 je var_aod
 mov edx,[ptrt]
 cmp edx,ebx
 je semptr
 call varops
var_id:
 mov edx,0
 call readid2
 call getidtype
 mov bl,[sf]
 mov bh,"o"
 cmp bh,bl
 je var_str2
 mov bl,[nf2]
 cmp bh,bl
 je var_null
 jmp var_intt2
var_id2:
 mov edx,0
 call readid2
 call getidtype
 call clearflags
 jmp var_intt2
var_null:
 jmp var_str2
var_0:
 mov bl,"z"
 mov [vnf],bl
 mov bl,"o"
 mov [vcf],bl
 call semread
 call regs 
 call sors
 call varops
 mov edx,[lpr]
 cmp edx,ebx
 je var_lpr
 mov edx,[fcl]
 cmp edx,ebx 
 je semfcl
 mov edx,[aru]
 cmp edx,ebx 
 je semaru
 mov edx,[idt]
 cmp edx,ebx 
 je var_id 
 mov edx,[null]
 cmp edx,ebx
 je var_null
 mov edx,[intt]
 cmp edx,ebx 
 je var_intt
 mov edx,[true]
 cmp edx,ebx
 je var_intt2
 mov edx,[false]
 cmp edx,ebx
 je var_intt2 
 mov edx,[flt]
 cmp edx,ebx
 je var_intt 
 mov edx,[intt2]
 cmp edx,ebx
 je semtoint
 mov edx,[strt2]
 cmp edx,ebx
 je semtostr
 mov edx,[strt]
 cmp edx,ebx 
 je var_str
 mov edx,[ptrt]
 cmp edx,ebx
 je semptr   
 jmp error
var_aod2:
 mov edx,0
 call readid2
 call getidtype
 jmp var_lpr3
var_aod:
 mov edx,0
 call readid2
 call getidtype
 mov bl,"o"
 mov bh,[vnf]
 cmp bh,bl
 je var_intt2
 jmp var_str2

vchkrpr:
 mov bl,[vcf]
 mov bh,"o"
 cmp bh,bl
 je var_rpr
 jmp error

chknf2:
 mov bh,"o"
 mov bl,[vnf]
 cmp bh,bl 
 je var_intt2
 jmp var_str2
var_idint:
 mov edx,0 
 call readid2
 call getidtype
 mov bl,[iff]
 mov bh,"o"
 cmp bh,bl 
 jne error
 jmp var_intt2
 
addvar:
 mov bl,"o"
 mov bh,[fdfi]
 cmp bh,bl
 je addvarfdf
 mov [vf],bl
 call chkregsv
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
 call setgvarseq
 mov eax,[varseq]
 mov bl,"o"
 mov bh,[iff]
 cmp bh,bl 
 je varisint 
 mov bh,[nf2]
 cmp bh,bl
 je varisnull
 mov edx,"s;"
 mov [vars+eax],edx
 add eax,2 
 mov [varseq],eax
 jmp endvar
varisint:
 mov dx,"i;"
 mov [vars+eax],dx
 add eax,2 
 mov [varseq],eax
 jmp var_int
varisnull:
 mov edx,"n;"
 mov [vars+eax],edx
 add eax,2 
 mov [varseq],eax
 jmp endvar

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
 
varops:
 mov edx,[nott]
 cmp edx,ebx
 je var_op2
 mov edx,[negt]
 cmp edx,ebx
 je var_op
 mov edx,[pls]
 cmp edx,ebx 
 je var_op 
 mov edx,[min]
 cmp edx,ebx 
 je var_op  
 mov edx,[mult]
 cmp edx,ebx 
 je var_op  
 mov edx,[divt]
 cmp edx,ebx 
 je var_op 
 ret  

endvar:
 sub ecx,3
 mov bl,"z"
 mov [vcf],bl 
 mov bl,"o"
 mov [vfi],bl
 mov bh,[vf]
 cmp bh,bl 
 jne varint
endvar2: 
 add ecx,3
 mov edx,[semseqts]
 mov bl,0
 mov [semtrack+edx],bl 
 sub edx,1
 mov [semseqts],edx
 mov bl,"z"
 mov [vcf],bl
 mov [iff],bl
 mov [sf],bl
 mov [vnf],bl
 mov [vfi],bl
 mov [nf2],bl
 mov [lf],bl 
 mov [pf],bl 
 mov [xf],bl
 jmp succ
 
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

int_chkvflag:
 mov bl,[vf]
 mov bh,"o"
 cmp bh,bl 
 je tov 
 jmp varint
str_chkvflag:
 mov bl,[vf]
 mov bh,"o"
 cmp bh,bl 
 je chknf
 jmp varstrx
chknf:
 mov bl,[vnf]
 mov bh,"o"
 cmp bh,bl
 je tov
 jmp varstr2

arutovar:
 mov bl,"o"
 mov bh,[vf]
 cmp bh,bl
 je tov
 call semread
 mov edx,[trm]
 cmp edx,ebx
 jne arutovar2
 mov [iff],bl
 call addvar
arutovar2:
 sub ecx,3
 mov [aruf],bl
 jmp varint

chkvf2: 
 mov bl,[vf]
 mov bh,"o"
 cmp bh,bl
 je endvar
 sub ecx,3
 jmp varint
chkvf: ;tostr
 mov bl,[vf]
 mov bh,"o"
 cmp bh,bl
 je endvar
 sub ecx,3
 mov bl,[vnf]
 cmp bh,bl
 je varint
 add ecx,3
 jmp varstr2
 
varregs:
 mov eax,alf
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
 jmp error

 semfinard:
 mov edx,[semseqts]
 mov eax,0
 mov [semtrack+edx],eax
 sub edx,1
 mov [semseqts],edx
 add ecx,3 ;trm
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
 mov [fcf],dl
 mov edx,0
 mov [parcount],edx
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
 mov bh,[rtype]
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
 mov bl,"s"
 cmp bh,bl
 je tof2
 jmp tof

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

addpar:
 mov eax,[parcount]
 add eax,1
 mov [parcount],eax
 jmp fclsem2 

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
 jmp error 

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
 mov eax,[semtrack+edx]
 mov edx,"v"
 cmp eax,edx
 je arutovar
 mov bl,"o"
 mov bh,[rf]
 cmp bh,bl
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
 mov bl,"o"
 mov [fdfi],bl 
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
 call readid
 call saveftemp
 mov edx,[argc]
 add edx,1
 mov [argc],edx
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
 jmp semstart

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
 mov [eofdf],bl
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
 mov eax,alf
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
 je error 
 sub eax,1
 jmp fdfspecial2
 fdfspecial4:
 mov bl,"z"
 mov [iff],bl
 mov [sf],bl
 mov [nf2],bl
 ret
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
 call semread
 mov edx,[rpr]
 cmp edx,ebx 
 je var_rpr
 mov edx,[trm]
 cmp edx,ebx 
 je chkvf2
 mov edx,[inct]
 cmp edx,ebx
 je var_iod
 mov edx,[dect]
 cmp edx,ebx
 je var_iod
 call varops 
 jmp z_0
 tov2:
 call semread
 mov edx,[trm]
 cmp edx,ebx
 je chkvf
 mov edx,[rpr]
 cmp edx,ebx
 je chkvcf
 call strerrors
 jmp var_0
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
 
 chkvcf:
 mov bl,[vcf]
 mov bh,"o"
 cmp bh,bl
 je var_rpr
 mov bl,[vnf]
 cmp bl,bh
 jne seme3
 jmp var_rpr 
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
 ret 
 
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
 mov dl,"o"
 mov dh,[eofdf]
 cmp dh,dl
 jne semstart
 mov dl,"z"
 mov [eofdf],dl
 mov [fdff],dl
 jmp semstart
 
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
;;;;;; DATA ;;;;;;

section .data

;ffile db "ARUf|INT3|PLSINT45|EQ2NOTSTRst|MULARUer|INT9|MININT3|PLSFCLf|INT45|CMAIDTid|PLSINT45|FCEGEQNEGIDTi|AREEQ2LPRNEGINT342|MINFCLo|FCEPLSIDTo|RPRARETRMeof",0
count db 0
suk db "Phase 3 : Success",0xa
suklen equ $-suk
nl2 db "|",0
val db "x12|",0
val2 db "x13|",0
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
regf db "z",0
fdff db "z",0
fdfi db "z",0
eofdf db "z",0
jzero dd 0
fcfc db "z",0
semstack dd 0
gvseqc dd 0
stackc dd 0
ftempc dd 0
newc dd 0

section .bss
inputCI resb 50000
CILEX resb 75000
CISYN resb 60000
track resb 5000
lex_int resb 255
synids resb 400
;this is real for me , i need this 
;this is a therapy for ME (me me me)
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
cntn resb 3