%include 'io.inc'
%include 'mio.inc'
%include 'gfx.inc'
%include 'util.inc'

%define WIDTH  816
%define HEIGHT 816
%define COL    616

global main

section .text
main:
    .toroldAKepet:
; Prepare the matrix to be used
    mov     edi, rajz       ;es:edi = address of array of arrays
    mov     ecx, 616*616    ;ecx = size of array of arrays
    xor     eax, eax        ;eax = value to fill the integers with
    rep     stosd           ;Fill the array
; Prepare the minimatrix to be used
    mov     edi, resize     ;es:edi = address of array of arrays
    mov     ecx, 28*28      ;ecx = size of array of arrays
    xor     eax, eax        ;eax = value to fill the integers with
    rep     stosd           ;Fill the array
; Create the graphics window
    mov		eax, WIDTH		; window width (X)
	mov		ebx, HEIGHT		; window hieght (Y)
	mov		ecx, 0			; window mode (NOT fullscreen!)
	mov		edx, caption	; window caption
	call	gfx_init
	
	test	eax, eax		; if the return value is 0, something went wrong
	jnz		.init
	; Print error message and exit
	mov		eax, errormsg
	call	io_writestr
	call	io_writeln
	ret


.init:
    ;mov		eax, infomsg	; print some usage info
	;call	io_writestr
	;call	io_writeln

.mainloop:
    xor edi, edi
    call    gfx_map

    xor		ecx, ecx		; ECX - line (Y)
.yloop:
	cmp		ecx, HEIGHT
	jge		.yend	
	
	; Loop over the columns
	xor		edx, edx		; EDX - column (X)
.xloop:
	cmp		edx, WIDTH
	jge		.xend
	
	; Write the pixel           600x600 rajzfelulet
    cmp     edx, 100
    jl      .feher
    cmp     edx, 716
    jge     .feher
    cmp     ecx, 50
    jl      .feher
    cmp     ecx, 666
    jge     .feher
    
    ;fekete hatteru negyzet
    mov     ebx, [rajz+edi]
	mov		[eax], bl
    mov     ebx, [rajz+edi+1]
	mov		[eax+1], bl
    mov     ebx, [rajz+edi+2]
	mov		[eax+2], bl
    mov     ebx, [rajz+edi+3]
	mov		[eax+3], bl
    add edi, 4
    jmp     .kov

    ;feher hatteru ablak
.feher:
    cmp     ecx, 691
    jl      .nemgomb
    cmp     ecx, 791
    jge     .nemgomb
    cmp     edx, 100
    jl      .nemgomb
    cmp     edx, 716
    jge     .nemgomb
    
.gombok:
    cmp     edx, 325
    jle     .torlesGomb
    cmp     edx, 491
    jg      .vizsgalatGomb
    jmp     .nemgomb

.torlesGomb:
    mov     ebx, 56
	mov		[eax], bl
    mov     ebx, 38
	mov		[eax+1], bl
    mov     ebx, -25
	mov		[eax+2], bl
    xor     ebx, ebx
	mov		[eax+3], bl
    jmp .kov

.vizsgalatGomb:
    mov     ebx, 0
	mov		[eax], bl
    mov     ebx, 82
	mov		[eax+1], bl
    mov     ebx, 37
	mov		[eax+2], bl
    xor     ebx, ebx
	mov		[eax+3], bl
    jmp .kov

.nemgomb:
    mov     ebx, 116
	mov		[eax], bl
    mov     ebx, 119
	mov		[eax+1], bl
    mov     ebx, 107
	mov		[eax+2], bl
    xor     ebx, ebx
	mov		[eax+3], bl
	
.kov:
	add		eax, 4		    ; next pixel
	
	inc		edx
	jmp		.xloop

.xend:
	inc		ecx
	jmp		.yloop
	
.yend:
	call	gfx_unmap		; unmap the framebuffer
	call	gfx_draw		; draw the contents of the framebuffer (*must* be called once in each iteration!)
	
	
	; Query and handle the events (loop!)
	xor		ebx, ebx		; load some constants into registers: 0, -1, 1
	mov		ecx, -1
	mov		edx, 1

.eventloop:
	call	gfx_getevent
	
	
	; Handle movement: mouse
	cmp		eax, 1			; left button pressed
	jne		.eventloop1
	mov		dword [movemouse], 1
	call	gfx_getmouse
	mov		[prevmousex], eax
	mov		[prevmousey], ebx
	jmp		.eventloop
.eventloop1:
	cmp		eax, -1			; left button released
	jne		.eventloop2
	mov		dword [movemouse], 0
	jmp		.eventloop

.eventloop2:
	; Handle exit
	cmp		eax, 23			; the window close button was pressed: exit
	je		.end
	cmp		eax, 27			; ESC: exit
	je		.end


	; Query the mouse position if the left button is pressed, and update the offset
	cmp		dword [movemouse], 0
	je		.nincsvaltozas
	call	gfx_getmouse	; EAX - x, EBX - y
	mov		ecx, eax
	mov		edx, ebx
	sub		eax, [prevmousex]
	sub		ebx, [prevmousey]
	sub		[offsetx], eax
	sub		[offsety], ebx
	mov		[prevmousex], ecx
	mov		[prevmousey], edx
    jmp     .rajzolas
	
.nincsvaltozas:
    jmp     .mainloop

.rajzolas:
    mov     eax, [prevmousex];nezi ha a szelesseg kissebb vagy nagyobb a negyzetenel
    cmp     eax, 100
    jl      .nincsvaltozas
    cmp     eax, 700
    jg      .nincsvaltozas
    
    mov     eax, [prevmousey];figyeli ha a magassag nagyobb vagy kissebb a negyzetenel
    cmp     eax, 50
    jl      .nincsvaltozas
    cmp eax, 650
    jle     .startRajz
    jg      .vanefunkcioja;kitorli a rajzot a memoriabol es a kepernyorol is

.vanefunkcioja:
    cmp eax, 691
    jl .nincsvaltozas
    cmp eax, 791
    jg .nincsvaltozas
    mov eax, [prevmousex]
    cmp eax, 325
    jle .toroldAKepet
    cmp eax, 491
    jg .vizsgaldAKepet
    jmp .nincsvaltozas

.vizsgaldAKepet:
    call rajzEgyszerusites; ez biztos vegrehajtodik es biztos elsokent szoval szimplan meghivom
    mov eax, linTxt
    xor ebx, ebx
    call fio_open
    mov ebx, belvasottSzoveg
    mov ecx, 500
    call fio_read
    call fio_close
    mov ecx, 17;vizsgalando karakter alap poziciojanak beallitasa
;meghivasok es vizsgalatok
.meghivasok:
    mov al, [belvasottSzoveg+ecx]
    ;call mio_writechar
    cmp al, 76
    jne .nemLin
    add ecx, 7
    ;beolvas az in erteket
    xor edi, edi
    xor eax, eax
.linIn:
    mov al, [belvasottSzoveg+ecx]
    ;call mio_writechar;itt kiirattam a 13as karaktert is mielott lezartam volna az olvasast
    cmp al, 48
    jl .linInSkip
    cmp al, 57
    jg .linInSkip
    sub al, 48
    imul edi, 10
    add edi, eax
    inc ecx
    jmp .linIn
.linInSkip:
    mov [linbemenet], edi              ;edi tarolja az elso beolvasott erteket
    ;call io_writeint 
    ;call io_writeln
    add ecx, 5
    xor edi, edi
    xor eax, eax
.linOut:
    mov al, [belvasottSzoveg+ecx]
    ;call mio_writechar
    cmp al, 48
    jl .linOutSkip
    cmp al, 57
    jg .linOutSkip
    sub al, 48
    imul edi, 10
    add edi, eax
    inc ecx
    jmp .linOut
.linOutSkip:
    mov [linkimenet], edi
    ;call io_writeint
    ;call io_writeln
    add ecx, 2
    ;beolvas az out erteket
    
    pusha
    call linearLayer
    popa
    jmp .meghivasok
.nemLin:
    cmp al, 82
    jne .nemReLU
    pusha
    call ReLU
    popa
    add ecx, 6
    jmp .meghivasok
.nemReLU:
    cmp al, 65
    jne .irkdihamered
    pusha
    call ArgMax
    popa
    

;     jmp .meghivasok
.irkdihamered:
    ;call mio_writechar
    ; call linearLayer
    ; call ReLU
    ; call ArgMax
    ;call Conv      ;hibas
    jmp .end

.startRajz:
    ;mov eax, [prevmousex]
    ;call io_writeint
    ;call io_writeln
    ;mov eax, [prevmousey]
    ;call io_writeint
    ;call io_writeln

    mov edx, [prevmousex];sor index
    sub edx, 100
    mov ecx, [prevmousey];oszlop index
    sub ecx, 50
	
    ;matrix offset kiszamitas
    mov eax, ecx
    imul eax, row_size
    add eax, edx

    ;memory address kiszamitasa
    mov ebx, eax
    shl ebx, 2
    lea esi, [rajz+ebx]

    ;erteket adunk az elemnek, amelyikre kattintottunk 
    mov byte [esi], 255
    mov byte [rajz+ebx], 255
    mov byte [esi+1], 255
    mov byte [rajz+ebx+1], 255
    mov byte [esi+2], 255
    mov byte [rajz+ebx+2], 255
    mov byte [esi+3], 255
    mov byte [rajz+ebx+3], 255
    mov byte [esi+4], 255
    mov byte [rajz+ebx+4], 255

    mov byte [esi+5], 255
    mov byte [rajz+ebx+5], 255
    mov byte [esi+6], 255
    mov byte [rajz+ebx+6], 255
    mov byte [esi+7], 255
    mov byte [rajz+ebx+7], 255
    mov byte [esi+8], 255
    mov byte [rajz+ebx+8], 255
    mov byte [esi+9], 255
    mov byte [rajz+ebx+9], 255
    mov byte [esi+10], 255
    mov byte [rajz+ebx+10], 255
    mov byte [esi+11], 255
    mov byte [rajz+ebx+11], 255
    mov byte [esi+12], 255
    mov byte [rajz+ebx+12], 255
    mov byte [esi+13], 255
    mov byte [rajz+ebx+13], 255
    mov byte [esi+14], 255
    mov byte [rajz+ebx+14], 255
    mov byte [esi+15], 255
    mov byte [rajz+ebx+15], 255
    mov byte [esi+16], 255
    mov byte [rajz+ebx+16], 255
    mov byte [esi+17], 255
    mov byte [rajz+ebx+17], 255
    mov byte [esi+18], 255
    mov byte [rajz+ebx+18], 255
    mov byte [esi+19], 255
    mov byte [rajz+ebx+19], 255
    mov byte [esi+20], 255
    mov byte [rajz+ebx+20], 255
    mov byte [esi+21], 255
    mov byte [rajz+ebx+21], 255
    mov byte [esi+22], 255
    mov byte [rajz+ebx+22], 255
    mov byte [esi+23], 255
    mov byte [rajz+ebx+23], 255
    mov byte [esi+24], 255
    mov byte [rajz+ebx+24], 255
    mov byte [esi+25], 255
    mov byte [rajz+ebx+25], 255
    mov byte [esi+26], 255
    mov byte [rajz+ebx+26], 255
    mov byte [esi+27], 255
    mov byte [rajz+ebx+27], 255
    mov byte [esi+28], 255
    mov byte [rajz+ebx+28], 255
    mov byte [esi+29], 255
    mov byte [rajz+ebx+29], 255
    mov byte [esi+30], 255
    mov byte [rajz+ebx+30], 255
    mov byte [esi+31], 255
    mov byte [rajz+ebx+31], 255
    mov byte [esi+32], 255
    mov byte [rajz+ebx+32], 255
    mov byte [esi+33], 255
    mov byte [rajz+ebx+33], 255
    mov byte [esi+34], 255
    mov byte [rajz+ebx+34], 255
    mov byte [esi+35], 255
    mov byte [rajz+ebx+35], 255
    mov byte [esi+36], 255
    mov byte [rajz+ebx+36], 255
    mov byte [esi+37], 255
    mov byte [rajz+ebx+37], 255
    mov byte [esi+38], 255
    mov byte [rajz+ebx+38], 255
    mov byte [esi+39], 255
    mov byte [rajz+ebx+39], 255
    mov byte [esi+40], 255
    mov byte [rajz+ebx+40], 255
    mov byte [esi+41], 255
    mov byte [rajz+ebx+41], 255
    mov byte [esi+42], 255
    mov byte [rajz+ebx+42], 255
    

;torold
    mov edx, [prevmousex];sor index
    sub edx, 100
    mov ecx, [prevmousey];oszlop index
    sub ecx, 49
    mov eax, ecx
    imul eax, row_size
    add eax, edx
    mov ebx, eax
    shl ebx, 2
    lea esi, [rajz+ebx]
    mov byte [esi], 255
    mov byte [rajz+ebx], 255
    mov byte [esi+1], 255
    mov byte [rajz+ebx+1], 255
    mov byte [esi+2], 255
    mov byte [rajz+ebx+2], 255
    mov byte [esi+3], 255
    mov byte [rajz+ebx+3], 255
    mov byte [esi+4], 255
    mov byte [rajz+ebx+4], 255
    mov byte [esi+5], 255
    mov byte [rajz+ebx+5], 255
    mov byte [esi+6], 255
    mov byte [rajz+ebx+6], 255
    mov byte [esi+7], 255
    mov byte [rajz+ebx+7], 255
    mov byte [esi+8], 255
    mov byte [rajz+ebx+8], 255
    mov byte [esi+9], 255
    mov byte [rajz+ebx+9], 255
    mov byte [esi+10], 255
    mov byte [rajz+ebx+10], 255
    mov byte [esi+11], 255
    mov byte [rajz+ebx+11], 255
    mov byte [esi+12], 255
    mov byte [rajz+ebx+12], 255
    mov byte [esi+13], 255
    mov byte [rajz+ebx+13], 255
    mov byte [esi+14], 255
    mov byte [rajz+ebx+14], 255
    mov byte [esi+15], 255
    mov byte [rajz+ebx+15], 255
    mov byte [esi+16], 255
    mov byte [rajz+ebx+16], 255
    mov byte [esi+17], 255
    mov byte [rajz+ebx+17], 255
    mov byte [esi+18], 255
    mov byte [rajz+ebx+18], 255
    mov byte [esi+19], 255
    mov byte [rajz+ebx+19], 255
    mov byte [esi+20], 255
    mov byte [rajz+ebx+20], 255
    mov byte [esi+21], 255
    mov byte [rajz+ebx+21], 255
    mov byte [esi+22], 255
    mov byte [rajz+ebx+22], 255
    mov byte [esi+23], 255
    mov byte [rajz+ebx+23], 255
    mov byte [esi+24], 255
    mov byte [rajz+ebx+24], 255
    mov byte [esi+25], 255
    mov byte [rajz+ebx+25], 255
    mov byte [esi+26], 255
    mov byte [rajz+ebx+26], 255
    mov byte [esi+27], 255
    mov byte [rajz+ebx+27], 255
    mov byte [esi+28], 255
    mov byte [rajz+ebx+28], 255
    mov byte [esi+29], 255
    mov byte [rajz+ebx+29], 255
    mov byte [esi+30], 255
    mov byte [rajz+ebx+30], 255
    mov byte [esi+31], 255
    mov byte [rajz+ebx+31], 255
    mov byte [esi+32], 255
    mov byte [rajz+ebx+32], 255
    mov byte [esi+33], 255
    mov byte [rajz+ebx+33], 255
    mov byte [esi+34], 255
    mov byte [rajz+ebx+34], 255
    mov byte [esi+35], 255
    mov byte [rajz+ebx+35], 255
    mov byte [esi+36], 255
    mov byte [rajz+ebx+36], 255
    mov byte [esi+37], 255
    mov byte [rajz+ebx+37], 255
    mov byte [esi+38], 255
    mov byte [rajz+ebx+38], 255
    mov byte [esi+39], 255
    mov byte [rajz+ebx+39], 255
    mov byte [esi+40], 255
    mov byte [rajz+ebx+40], 255
    mov byte [esi+41], 255
    mov byte [rajz+ebx+41], 255
    mov byte [esi+42], 255
    mov byte [rajz+ebx+42], 255
    mov edx, [prevmousex];sor index
    sub edx, 100
    mov ecx, [prevmousey];oszlop index
    sub ecx, 48
    mov eax, ecx
    imul eax, row_size
    add eax, edx
    mov ebx, eax
    shl ebx, 2
    lea esi, [rajz+ebx]
    mov byte [esi], 255
    mov byte [rajz+ebx], 255
    mov byte [esi+1], 255
    mov byte [rajz+ebx+1], 255
    mov byte [esi+2], 255
    mov byte [rajz+ebx+2], 255
    mov byte [esi+3], 255
    mov byte [rajz+ebx+3], 255
    mov byte [esi+4], 255
    mov byte [rajz+ebx+4], 255
    mov byte [esi+5], 255
    mov byte [rajz+ebx+5], 255
    mov byte [esi+6], 255
    mov byte [rajz+ebx+6], 255
    mov byte [esi+7], 255
    mov byte [rajz+ebx+7], 255
    mov byte [esi+8], 255
    mov byte [rajz+ebx+8], 255
    mov byte [esi+9], 255
    mov byte [rajz+ebx+9], 255
    mov byte [esi+10], 255
    mov byte [rajz+ebx+10], 255
    mov byte [esi+11], 255
    mov byte [rajz+ebx+11], 255
    mov byte [esi+12], 255
    mov byte [rajz+ebx+12], 255
    mov byte [esi+13], 255
    mov byte [rajz+ebx+13], 255
    mov byte [esi+14], 255
    mov byte [rajz+ebx+14], 255
    mov byte [esi+15], 255
    mov byte [rajz+ebx+15], 255
    mov byte [esi+16], 255
    mov byte [rajz+ebx+16], 255
    mov byte [esi+17], 255
    mov byte [rajz+ebx+17], 255
    mov byte [esi+18], 255
    mov byte [rajz+ebx+18], 255
    mov byte [esi+19], 255
    mov byte [rajz+ebx+19], 255
    mov byte [esi+20], 255
    mov byte [rajz+ebx+20], 255
    mov byte [esi+21], 255
    mov byte [rajz+ebx+21], 255
    mov byte [esi+22], 255
    mov byte [rajz+ebx+22], 255
    mov byte [esi+23], 255
    mov byte [rajz+ebx+23], 255
    mov byte [esi+24], 255
    mov byte [rajz+ebx+24], 255
    mov byte [esi+25], 255
    mov byte [rajz+ebx+25], 255
    mov byte [esi+26], 255
    mov byte [rajz+ebx+26], 255
    mov byte [esi+27], 255
    mov byte [rajz+ebx+27], 255
    mov byte [esi+28], 255
    mov byte [rajz+ebx+28], 255
    mov byte [esi+29], 255
    mov byte [rajz+ebx+29], 255
    mov byte [esi+30], 255
    mov byte [rajz+ebx+30], 255
    mov byte [esi+31], 255
    mov byte [rajz+ebx+31], 255
    mov byte [esi+32], 255
    mov byte [rajz+ebx+32], 255
    mov byte [esi+33], 255
    mov byte [rajz+ebx+33], 255
    mov byte [esi+34], 255
    mov byte [rajz+ebx+34], 255
    mov byte [esi+35], 255
    mov byte [rajz+ebx+35], 255
    mov byte [esi+36], 255
    mov byte [rajz+ebx+36], 255
    mov byte [esi+37], 255
    mov byte [rajz+ebx+37], 255
    mov byte [esi+38], 255
    mov byte [rajz+ebx+38], 255
    mov byte [esi+39], 255
    mov byte [rajz+ebx+39], 255
    mov byte [esi+40], 255
    mov byte [rajz+ebx+40], 255
    mov byte [esi+41], 255
    mov byte [rajz+ebx+41], 255
    mov byte [esi+42], 255
    mov byte [rajz+ebx+42], 255
    mov edx, [prevmousex];sor index
    sub edx, 100
    mov ecx, [prevmousey];oszlop index
    sub ecx, 47
    mov eax, ecx
    imul eax, row_size
    add eax, edx
    mov ebx, eax
    shl ebx, 2
    lea esi, [rajz+ebx]
    mov byte [esi], 255
    mov byte [rajz+ebx], 255
    mov byte [esi+1], 255
    mov byte [rajz+ebx+1], 255
    mov byte [esi+2], 255
    mov byte [rajz+ebx+2], 255
    mov byte [esi+3], 255
    mov byte [rajz+ebx+3], 255
    mov byte [esi+4], 255
    mov byte [rajz+ebx+4], 255
    mov byte [esi+5], 255
    mov byte [rajz+ebx+5], 255
    mov byte [esi+6], 255
    mov byte [rajz+ebx+6], 255
    mov byte [esi+7], 255
    mov byte [rajz+ebx+7], 255
    mov byte [esi+8], 255
    mov byte [rajz+ebx+8], 255
    mov byte [esi+9], 255
    mov byte [rajz+ebx+9], 255
    mov byte [esi+10], 255
    mov byte [rajz+ebx+10], 255
    mov byte [esi+11], 255
    mov byte [rajz+ebx+11], 255
    mov byte [esi+12], 255
    mov byte [rajz+ebx+12], 255
    mov byte [esi+13], 255
    mov byte [rajz+ebx+13], 255
    mov byte [esi+14], 255
    mov byte [rajz+ebx+14], 255
    mov byte [esi+15], 255
    mov byte [rajz+ebx+15], 255
    mov byte [esi+16], 255
    mov byte [rajz+ebx+16], 255
    mov byte [esi+17], 255
    mov byte [rajz+ebx+17], 255
    mov byte [esi+18], 255
    mov byte [rajz+ebx+18], 255
    mov byte [esi+19], 255
    mov byte [rajz+ebx+19], 255
    mov byte [esi+20], 255
    mov byte [rajz+ebx+20], 255
    mov byte [esi+21], 255
    mov byte [rajz+ebx+21], 255
    mov byte [esi+22], 255
    mov byte [rajz+ebx+22], 255
    mov byte [esi+23], 255
    mov byte [rajz+ebx+23], 255
    mov byte [esi+24], 255
    mov byte [rajz+ebx+24], 255
    mov byte [esi+25], 255
    mov byte [rajz+ebx+25], 255
    mov byte [esi+26], 255
    mov byte [rajz+ebx+26], 255
    mov byte [esi+27], 255
    mov byte [rajz+ebx+27], 255
    mov byte [esi+28], 255
    mov byte [rajz+ebx+28], 255
    mov byte [esi+29], 255
    mov byte [rajz+ebx+29], 255
    mov byte [esi+30], 255
    mov byte [rajz+ebx+30], 255
    mov byte [esi+31], 255
    mov byte [rajz+ebx+31], 255
    mov byte [esi+32], 255
    mov byte [rajz+ebx+32], 255
    mov byte [esi+33], 255
    mov byte [rajz+ebx+33], 255
    mov byte [esi+34], 255
    mov byte [rajz+ebx+34], 255
    mov byte [esi+35], 255
    mov byte [rajz+ebx+35], 255
    mov byte [esi+36], 255
    mov byte [rajz+ebx+36], 255
    mov byte [esi+37], 255
    mov byte [rajz+ebx+37], 255
    mov byte [esi+38], 255
    mov byte [rajz+ebx+38], 255
    mov byte [esi+39], 255
    mov byte [rajz+ebx+39], 255
    mov byte [esi+40], 255
    mov byte [rajz+ebx+40], 255
    mov byte [esi+41], 255
    mov byte [rajz+ebx+41], 255
    mov byte [esi+42], 255
    mov byte [rajz+ebx+42], 255
    mov edx, [prevmousex];sor index
    sub edx, 100
    mov ecx, [prevmousey];oszlop index
    sub ecx, 46
    mov eax, ecx
    imul eax, row_size
    add eax, edx
    mov ebx, eax
    shl ebx, 2
    lea esi, [rajz+ebx]
    mov byte [esi], 255
    mov byte [rajz+ebx], 255
    mov byte [esi+1], 255
    mov byte [rajz+ebx+1], 255
    mov byte [esi+2], 255
    mov byte [rajz+ebx+2], 255
    mov byte [esi+3], 255
    mov byte [rajz+ebx+3], 255
    mov byte [esi+4], 255
    mov byte [rajz+ebx+4], 255
    mov byte [esi+5], 255
    mov byte [rajz+ebx+5], 255
    mov byte [esi+6], 255
    mov byte [rajz+ebx+6], 255
    mov byte [esi+7], 255
    mov byte [rajz+ebx+7], 255
    mov byte [esi+8], 255
    mov byte [rajz+ebx+8], 255
    mov byte [esi+9], 255
    mov byte [rajz+ebx+9], 255
    mov byte [esi+10], 255
    mov byte [rajz+ebx+10], 255
    mov byte [esi+11], 255
    mov byte [rajz+ebx+11], 255
    mov byte [esi+12], 255
    mov byte [rajz+ebx+12], 255
    mov byte [esi+13], 255
    mov byte [rajz+ebx+13], 255
    mov byte [esi+14], 255
    mov byte [rajz+ebx+14], 255
    mov byte [esi+15], 255
    mov byte [rajz+ebx+15], 255
    mov byte [esi+16], 255
    mov byte [rajz+ebx+16], 255
    mov byte [esi+17], 255
    mov byte [rajz+ebx+17], 255
    mov byte [esi+18], 255
    mov byte [rajz+ebx+18], 255
    mov byte [esi+19], 255
    mov byte [rajz+ebx+19], 255
    mov byte [esi+20], 255
    mov byte [rajz+ebx+20], 255
    mov byte [esi+21], 255
    mov byte [rajz+ebx+21], 255
    mov byte [esi+22], 255
    mov byte [rajz+ebx+22], 255
    mov byte [esi+23], 255
    mov byte [rajz+ebx+23], 255
    mov byte [esi+24], 255
    mov byte [rajz+ebx+24], 255
    mov byte [esi+25], 255
    mov byte [rajz+ebx+25], 255
    mov byte [esi+26], 255
    mov byte [rajz+ebx+26], 255
    mov byte [esi+27], 255
    mov byte [rajz+ebx+27], 255
    mov byte [esi+28], 255
    mov byte [rajz+ebx+28], 255
    mov byte [esi+29], 255
    mov byte [rajz+ebx+29], 255
    mov byte [esi+30], 255
    mov byte [rajz+ebx+30], 255
    mov byte [esi+31], 255
    mov byte [rajz+ebx+31], 255
    mov byte [esi+32], 255
    mov byte [rajz+ebx+32], 255
    mov byte [esi+33], 255
    mov byte [rajz+ebx+33], 255
    mov byte [esi+34], 255
    mov byte [rajz+ebx+34], 255
    mov byte [esi+35], 255
    mov byte [rajz+ebx+35], 255
    mov byte [esi+36], 255
    mov byte [rajz+ebx+36], 255
    mov byte [esi+37], 255
    mov byte [rajz+ebx+37], 255
    mov byte [esi+38], 255
    mov byte [rajz+ebx+38], 255
    mov byte [esi+39], 255
    mov byte [rajz+ebx+39], 255
    mov byte [esi+40], 255
    mov byte [rajz+ebx+40], 255
    mov byte [esi+41], 255
    mov byte [rajz+ebx+41], 255
    mov byte [esi+42], 255
    mov byte [rajz+ebx+42], 255
    mov edx, [prevmousex];sor index
    sub edx, 100
    mov ecx, [prevmousey];oszlop index
    sub ecx, 45
    mov eax, ecx
    imul eax, row_size
    add eax, edx
    mov ebx, eax
    shl ebx, 2
    lea esi, [rajz+ebx]
    mov byte [esi], 255
    mov byte [rajz+ebx], 255
    mov byte [esi+1], 255
    mov byte [rajz+ebx+1], 255
    mov byte [esi+2], 255
    mov byte [rajz+ebx+2], 255
    mov byte [esi+3], 255
    mov byte [rajz+ebx+3], 255
    mov byte [esi+4], 255
    mov byte [rajz+ebx+4], 255
    mov byte [esi+5], 255
    mov byte [rajz+ebx+5], 255
    mov byte [esi+6], 255
    mov byte [rajz+ebx+6], 255
    mov byte [esi+7], 255
    mov byte [rajz+ebx+7], 255
    mov byte [esi+8], 255
    mov byte [rajz+ebx+8], 255
    mov byte [esi+9], 255
    mov byte [rajz+ebx+9], 255
    mov byte [esi+10], 255
    mov byte [rajz+ebx+10], 255
    mov byte [esi+11], 255
    mov byte [rajz+ebx+11], 255
    mov byte [esi+12], 255
    mov byte [rajz+ebx+12], 255
    mov byte [esi+13], 255
    mov byte [rajz+ebx+13], 255
    mov byte [esi+14], 255
    mov byte [rajz+ebx+14], 255
    mov byte [esi+15], 255
    mov byte [rajz+ebx+15], 255
    mov byte [esi+16], 255
    mov byte [rajz+ebx+16], 255
    mov byte [esi+17], 255
    mov byte [rajz+ebx+17], 255
    mov byte [esi+18], 255
    mov byte [rajz+ebx+18], 255
    mov byte [esi+19], 255
    mov byte [rajz+ebx+19], 255
    mov byte [esi+20], 255
    mov byte [rajz+ebx+20], 255
    mov byte [esi+21], 255
    mov byte [rajz+ebx+21], 255
    mov byte [esi+22], 255
    mov byte [rajz+ebx+22], 255
    mov byte [esi+23], 255
    mov byte [rajz+ebx+23], 255
    mov byte [esi+24], 255
    mov byte [rajz+ebx+24], 255
    mov byte [esi+25], 255
    mov byte [rajz+ebx+25], 255
    mov byte [esi+26], 255
    mov byte [rajz+ebx+26], 255
    mov byte [esi+27], 255
    mov byte [rajz+ebx+27], 255
    mov byte [esi+28], 255
    mov byte [rajz+ebx+28], 255
    mov byte [esi+29], 255
    mov byte [rajz+ebx+29], 255
    mov byte [esi+30], 255
    mov byte [rajz+ebx+30], 255
    mov byte [esi+31], 255
    mov byte [rajz+ebx+31], 255
    mov byte [esi+32], 255
    mov byte [rajz+ebx+32], 255
    mov byte [esi+33], 255
    mov byte [rajz+ebx+33], 255
    mov byte [esi+34], 255
    mov byte [rajz+ebx+34], 255
    mov byte [esi+35], 255
    mov byte [rajz+ebx+35], 255
    mov byte [esi+36], 255
    mov byte [rajz+ebx+36], 255
    mov byte [esi+37], 255
    mov byte [rajz+ebx+37], 255
    mov byte [esi+38], 255
    mov byte [rajz+ebx+38], 255
    mov byte [esi+39], 255
    mov byte [rajz+ebx+39], 255
    mov byte [esi+40], 255
    mov byte [rajz+ebx+40], 255
    mov byte [esi+41], 255
    mov byte [rajz+ebx+41], 255
    mov byte [esi+42], 255
    mov byte [rajz+ebx+42], 255
    mov edx, [prevmousex];sor index
    sub edx, 100
    mov ecx, [prevmousey];oszlop index
    sub ecx, 44
    mov eax, ecx
    imul eax, row_size
    add eax, edx
    mov ebx, eax
    shl ebx, 2
    lea esi, [rajz+ebx]
    mov byte [esi], 255
    mov byte [rajz+ebx], 255
    mov byte [esi+1], 255
    mov byte [rajz+ebx+1], 255
    mov byte [esi+2], 255
    mov byte [rajz+ebx+2], 255
    mov byte [esi+3], 255
    mov byte [rajz+ebx+3], 255
    mov byte [esi+4], 255
    mov byte [rajz+ebx+4], 255
    mov byte [esi+5], 255
    mov byte [rajz+ebx+5], 255
    mov byte [esi+6], 255
    mov byte [rajz+ebx+6], 255
    mov byte [esi+7], 255
    mov byte [rajz+ebx+7], 255
    mov byte [esi+8], 255
    mov byte [rajz+ebx+8], 255
    mov byte [esi+9], 255
    mov byte [rajz+ebx+9], 255
    mov byte [esi+10], 255
    mov byte [rajz+ebx+10], 255
    mov byte [esi+11], 255
    mov byte [rajz+ebx+11], 255
    mov byte [esi+12], 255
    mov byte [rajz+ebx+12], 255
    mov byte [esi+13], 255
    mov byte [rajz+ebx+13], 255
    mov byte [esi+14], 255
    mov byte [rajz+ebx+14], 255
    mov byte [esi+15], 255
    mov byte [rajz+ebx+15], 255
    mov byte [esi+16], 255
    mov byte [rajz+ebx+16], 255
    mov byte [esi+17], 255
    mov byte [rajz+ebx+17], 255
    mov byte [esi+18], 255
    mov byte [rajz+ebx+18], 255
    mov byte [esi+19], 255
    mov byte [rajz+ebx+19], 255
    mov byte [esi+20], 255
    mov byte [rajz+ebx+20], 255
    mov byte [esi+21], 255
    mov byte [rajz+ebx+21], 255
    mov byte [esi+22], 255
    mov byte [rajz+ebx+22], 255
    mov byte [esi+23], 255
    mov byte [rajz+ebx+23], 255
    mov byte [esi+24], 255
    mov byte [rajz+ebx+24], 255
    mov byte [esi+25], 255
    mov byte [rajz+ebx+25], 255
    mov byte [esi+26], 255
    mov byte [rajz+ebx+26], 255
    mov byte [esi+27], 255
    mov byte [rajz+ebx+27], 255
    mov byte [esi+28], 255
    mov byte [rajz+ebx+28], 255
    mov byte [esi+29], 255
    mov byte [rajz+ebx+29], 255
    mov byte [esi+30], 255
    mov byte [rajz+ebx+30], 255
    mov byte [esi+31], 255
    mov byte [rajz+ebx+31], 255
    mov byte [esi+32], 255
    mov byte [rajz+ebx+32], 255
    mov byte [esi+33], 255
    mov byte [rajz+ebx+33], 255
    mov byte [esi+34], 255
    mov byte [rajz+ebx+34], 255
    mov byte [esi+35], 255
    mov byte [rajz+ebx+35], 255
    mov byte [esi+36], 255
    mov byte [rajz+ebx+36], 255
    mov byte [esi+37], 255
    mov byte [rajz+ebx+37], 255
    mov byte [esi+38], 255
    mov byte [rajz+ebx+38], 255
    mov byte [esi+39], 255
    mov byte [rajz+ebx+39], 255
    mov byte [esi+40], 255
    mov byte [rajz+ebx+40], 255
    mov byte [esi+41], 255
    mov byte [rajz+ebx+41], 255
    mov byte [esi+42], 255
    mov byte [rajz+ebx+42], 255
    mov edx, [prevmousex];sor index
    sub edx, 100
    mov ecx, [prevmousey];oszlop index
    sub ecx, 43
    mov eax, ecx
    imul eax, row_size
    add eax, edx
    mov ebx, eax
    shl ebx, 2
    lea esi, [rajz+ebx]
    mov byte [esi], 255
    mov byte [rajz+ebx], 255
    mov byte [esi+1], 255
    mov byte [rajz+ebx+1], 255
    mov byte [esi+2], 255
    mov byte [rajz+ebx+2], 255
    mov byte [esi+3], 255
    mov byte [rajz+ebx+3], 255
    mov byte [esi+4], 255
    mov byte [rajz+ebx+4], 255
    mov byte [esi+5], 255
    mov byte [rajz+ebx+5], 255
    mov byte [esi+6], 255
    mov byte [rajz+ebx+6], 255
    mov byte [esi+7], 255
    mov byte [rajz+ebx+7], 255
    mov byte [esi+8], 255
    mov byte [rajz+ebx+8], 255
    mov byte [esi+9], 255
    mov byte [rajz+ebx+9], 255
    mov byte [esi+10], 255
    mov byte [rajz+ebx+10], 255
    mov byte [esi+11], 255
    mov byte [rajz+ebx+11], 255
    mov byte [esi+12], 255
    mov byte [rajz+ebx+12], 255
    mov byte [esi+13], 255
    mov byte [rajz+ebx+13], 255
    mov byte [esi+14], 255
    mov byte [rajz+ebx+14], 255
    mov byte [esi+15], 255
    mov byte [rajz+ebx+15], 255
    mov byte [esi+16], 255
    mov byte [rajz+ebx+16], 255
    mov byte [esi+17], 255
    mov byte [rajz+ebx+17], 255
    mov byte [esi+18], 255
    mov byte [rajz+ebx+18], 255
    mov byte [esi+19], 255
    mov byte [rajz+ebx+19], 255
    mov byte [esi+20], 255
    mov byte [rajz+ebx+20], 255
    mov byte [esi+21], 255
    mov byte [rajz+ebx+21], 255
    mov byte [esi+22], 255
    mov byte [rajz+ebx+22], 255
    mov byte [esi+23], 255
    mov byte [rajz+ebx+23], 255
    mov byte [esi+24], 255
    mov byte [rajz+ebx+24], 255
    mov byte [esi+25], 255
    mov byte [rajz+ebx+25], 255
    mov byte [esi+26], 255
    mov byte [rajz+ebx+26], 255
    mov byte [esi+27], 255
    mov byte [rajz+ebx+27], 255
    mov byte [esi+28], 255
    mov byte [rajz+ebx+28], 255
    mov byte [esi+29], 255
    mov byte [rajz+ebx+29], 255
    mov byte [esi+30], 255
    mov byte [rajz+ebx+30], 255
    mov byte [esi+31], 255
    mov byte [rajz+ebx+31], 255
    mov byte [esi+32], 255
    mov byte [rajz+ebx+32], 255
    mov byte [esi+33], 255
    mov byte [rajz+ebx+33], 255
    mov byte [esi+34], 255
    mov byte [rajz+ebx+34], 255
    mov byte [esi+35], 255
    mov byte [rajz+ebx+35], 255
    mov byte [esi+36], 255
    mov byte [rajz+ebx+36], 255
    mov byte [esi+37], 255
    mov byte [rajz+ebx+37], 255
    mov byte [esi+38], 255
    mov byte [rajz+ebx+38], 255
    mov byte [esi+39], 255
    mov byte [rajz+ebx+39], 255
    mov byte [esi+40], 255
    mov byte [rajz+ebx+40], 255
    mov byte [esi+41], 255
    mov byte [rajz+ebx+41], 255
    mov byte [esi+42], 255
    mov byte [rajz+ebx+42], 255
    mov edx, [prevmousex];sor index
    sub edx, 100
    mov ecx, [prevmousey];oszlop index
    sub ecx, 42
    mov eax, ecx
    imul eax, row_size
    add eax, edx
    mov ebx, eax
    shl ebx, 2
    lea esi, [rajz+ebx]
    mov byte [esi], 255
    mov byte [rajz+ebx], 255
    mov byte [esi+1], 255
    mov byte [rajz+ebx+1], 255
    mov byte [esi+2], 255
    mov byte [rajz+ebx+2], 255
    mov byte [esi+3], 255
    mov byte [rajz+ebx+3], 255
    mov byte [esi+4], 255
    mov byte [rajz+ebx+4], 255
    mov byte [esi+5], 255
    mov byte [rajz+ebx+5], 255
    mov byte [esi+6], 255
    mov byte [rajz+ebx+6], 255
    mov byte [esi+7], 255
    mov byte [rajz+ebx+7], 255
    mov byte [esi+8], 255
    mov byte [rajz+ebx+8], 255
    mov byte [esi+9], 255
    mov byte [rajz+ebx+9], 255
    mov byte [esi+10], 255
    mov byte [rajz+ebx+10], 255
    mov byte [esi+11], 255
    mov byte [rajz+ebx+11], 255
    mov byte [esi+12], 255
    mov byte [rajz+ebx+12], 255
    mov byte [esi+13], 255
    mov byte [rajz+ebx+13], 255
    mov byte [esi+14], 255
    mov byte [rajz+ebx+14], 255
    mov byte [esi+15], 255
    mov byte [rajz+ebx+15], 255
    mov byte [esi+16], 255
    mov byte [rajz+ebx+16], 255
    mov byte [esi+17], 255
    mov byte [rajz+ebx+17], 255
    mov byte [esi+18], 255
    mov byte [rajz+ebx+18], 255
    mov byte [esi+19], 255
    mov byte [rajz+ebx+19], 255
    mov byte [esi+20], 255
    mov byte [rajz+ebx+20], 255
    mov byte [esi+21], 255
    mov byte [rajz+ebx+21], 255
    mov byte [esi+22], 255
    mov byte [rajz+ebx+22], 255
    mov byte [esi+23], 255
    mov byte [rajz+ebx+23], 255
    mov byte [esi+24], 255
    mov byte [rajz+ebx+24], 255
    mov byte [esi+25], 255
    mov byte [rajz+ebx+25], 255
    mov byte [esi+26], 255
    mov byte [rajz+ebx+26], 255
    mov byte [esi+27], 255
    mov byte [rajz+ebx+27], 255
    mov byte [esi+28], 255
    mov byte [rajz+ebx+28], 255
    mov byte [esi+29], 255
    mov byte [rajz+ebx+29], 255
    mov byte [esi+30], 255
    mov byte [rajz+ebx+30], 255
    mov byte [esi+31], 255
    mov byte [rajz+ebx+31], 255
    mov byte [esi+32], 255
    mov byte [rajz+ebx+32], 255
    mov byte [esi+33], 255
    mov byte [rajz+ebx+33], 255
    mov byte [esi+34], 255
    mov byte [rajz+ebx+34], 255
    mov byte [esi+35], 255
    mov byte [rajz+ebx+35], 255
    mov byte [esi+36], 255
    mov byte [rajz+ebx+36], 255
    mov byte [esi+37], 255
    mov byte [rajz+ebx+37], 255
    mov byte [esi+38], 255
    mov byte [rajz+ebx+38], 255
    mov byte [esi+39], 255
    mov byte [rajz+ebx+39], 255
    mov byte [esi+40], 255
    mov byte [rajz+ebx+40], 255
    mov byte [esi+41], 255
    mov byte [rajz+ebx+41], 255
    mov byte [esi+42], 255
    mov byte [rajz+ebx+42], 255
    mov edx, [prevmousex];sor index
    sub edx, 100
    mov ecx, [prevmousey];oszlop index
    sub ecx, 41
    mov eax, ecx
    imul eax, row_size
    add eax, edx
    mov ebx, eax
    shl ebx, 2
    lea esi, [rajz+ebx]
    mov byte [esi], 255
    mov byte [rajz+ebx], 255
    mov byte [esi+1], 255
    mov byte [rajz+ebx+1], 255
    mov byte [esi+2], 255
    mov byte [rajz+ebx+2], 255
    mov byte [esi+3], 255
    mov byte [rajz+ebx+3], 255
    mov byte [esi+4], 255
    mov byte [rajz+ebx+4], 255
    mov byte [esi+5], 255
    mov byte [rajz+ebx+5], 255
    mov byte [esi+6], 255
    mov byte [rajz+ebx+6], 255
    mov byte [esi+7], 255
    mov byte [rajz+ebx+7], 255
    mov byte [esi+8], 255
    mov byte [rajz+ebx+8], 255
    mov byte [esi+9], 255
    mov byte [rajz+ebx+9], 255
    mov byte [esi+10], 255
    mov byte [rajz+ebx+10], 255
    mov byte [esi+11], 255
    mov byte [rajz+ebx+11], 255
    mov byte [esi+12], 255
    mov byte [rajz+ebx+12], 255
    mov byte [esi+13], 255
    mov byte [rajz+ebx+13], 255
    mov byte [esi+14], 255
    mov byte [rajz+ebx+14], 255
    mov byte [esi+15], 255
    mov byte [rajz+ebx+15], 255
    mov byte [esi+16], 255
    mov byte [rajz+ebx+16], 255
    mov byte [esi+17], 255
    mov byte [rajz+ebx+17], 255
    mov byte [esi+18], 255
    mov byte [rajz+ebx+18], 255
    mov byte [esi+19], 255
    mov byte [rajz+ebx+19], 255
    mov byte [esi+20], 255
    mov byte [rajz+ebx+20], 255
    mov byte [esi+21], 255
    mov byte [rajz+ebx+21], 255
    mov byte [esi+22], 255
    mov byte [rajz+ebx+22], 255
    mov byte [esi+23], 255
    mov byte [rajz+ebx+23], 255
    mov byte [esi+24], 255
    mov byte [rajz+ebx+24], 255
    mov byte [esi+25], 255
    mov byte [rajz+ebx+25], 255
    mov byte [esi+26], 255
    mov byte [rajz+ebx+26], 255
    mov byte [esi+27], 255
    mov byte [rajz+ebx+27], 255
    mov byte [esi+28], 255
    mov byte [rajz+ebx+28], 255
    mov byte [esi+29], 255
    mov byte [rajz+ebx+29], 255
    mov byte [esi+30], 255
    mov byte [rajz+ebx+30], 255
    mov byte [esi+31], 255
    mov byte [rajz+ebx+31], 255
    mov byte [esi+32], 255
    mov byte [rajz+ebx+32], 255
    mov byte [esi+33], 255
    mov byte [rajz+ebx+33], 255
    mov byte [esi+34], 255
    mov byte [rajz+ebx+34], 255
    mov byte [esi+35], 255
    mov byte [rajz+ebx+35], 255
    mov byte [esi+36], 255
    mov byte [rajz+ebx+36], 255
    mov byte [esi+37], 255
    mov byte [rajz+ebx+37], 255
    mov byte [esi+38], 255
    mov byte [rajz+ebx+38], 255
    mov byte [esi+39], 255
    mov byte [rajz+ebx+39], 255
    mov byte [esi+40], 255
    mov byte [rajz+ebx+40], 255
    mov byte [esi+41], 255
    mov byte [rajz+ebx+41], 255
    mov byte [esi+42], 255
    mov byte [rajz+ebx+42], 255
    mov edx, [prevmousex];sor index
    sub edx, 100
    mov ecx, [prevmousey];oszlop index
    sub ecx, 40
    mov eax, ecx
    imul eax, row_size
    add eax, edx
    mov ebx, eax
    shl ebx, 2
    lea esi, [rajz+ebx]
    mov byte [esi], 255
    mov byte [rajz+ebx], 255
    mov byte [esi+1], 255
    mov byte [rajz+ebx+1], 255
    mov byte [esi+2], 255
    mov byte [rajz+ebx+2], 255
    mov byte [esi+3], 255
    mov byte [rajz+ebx+3], 255
    mov byte [esi+4], 255
    mov byte [rajz+ebx+4], 255
    mov byte [esi+5], 255
    mov byte [rajz+ebx+5], 255
    mov byte [esi+6], 255
    mov byte [rajz+ebx+6], 255
    mov byte [esi+7], 255
    mov byte [rajz+ebx+7], 255
    mov byte [esi+8], 255
    mov byte [rajz+ebx+8], 255
    mov byte [esi+9], 255
    mov byte [rajz+ebx+9], 255
    mov byte [esi+10], 255
    mov byte [rajz+ebx+10], 255
    mov byte [esi+11], 255
    mov byte [rajz+ebx+11], 255
    mov byte [esi+12], 255
    mov byte [rajz+ebx+12], 255
    mov byte [esi+13], 255
    mov byte [rajz+ebx+13], 255
    mov byte [esi+14], 255
    mov byte [rajz+ebx+14], 255
    mov byte [esi+15], 255
    mov byte [rajz+ebx+15], 255
    mov byte [esi+16], 255
    mov byte [rajz+ebx+16], 255
    mov byte [esi+17], 255
    mov byte [rajz+ebx+17], 255
    mov byte [esi+18], 255
    mov byte [rajz+ebx+18], 255
    mov byte [esi+19], 255
    mov byte [rajz+ebx+19], 255
    mov byte [esi+20], 255
    mov byte [rajz+ebx+20], 255
    mov byte [esi+21], 255
    mov byte [rajz+ebx+21], 255
    mov byte [esi+22], 255
    mov byte [rajz+ebx+22], 255
    mov byte [esi+23], 255
    mov byte [rajz+ebx+23], 255
    mov byte [esi+24], 255
    mov byte [rajz+ebx+24], 255
    mov byte [esi+25], 255
    mov byte [rajz+ebx+25], 255
    mov byte [esi+26], 255
    mov byte [rajz+ebx+26], 255
    mov byte [esi+27], 255
    mov byte [rajz+ebx+27], 255
    mov byte [esi+28], 255
    mov byte [rajz+ebx+28], 255
    mov byte [esi+29], 255
    mov byte [rajz+ebx+29], 255
    mov byte [esi+30], 255
    mov byte [rajz+ebx+30], 255
    mov byte [esi+31], 255
    mov byte [rajz+ebx+31], 255
    mov byte [esi+32], 255
    mov byte [rajz+ebx+32], 255
    mov byte [esi+33], 255
    mov byte [rajz+ebx+33], 255
    mov byte [esi+34], 255
    mov byte [rajz+ebx+34], 255
    mov byte [esi+35], 255
    mov byte [rajz+ebx+35], 255
    mov byte [esi+36], 255
    mov byte [rajz+ebx+36], 255
    mov byte [esi+37], 255
    mov byte [rajz+ebx+37], 255
    mov byte [esi+38], 255
    mov byte [rajz+ebx+38], 255
    mov byte [esi+39], 255
    mov byte [rajz+ebx+39], 255
    mov byte [esi+40], 255
    mov byte [rajz+ebx+40], 255
    mov byte [esi+41], 255
    mov byte [rajz+ebx+41], 255
    mov byte [esi+42], 255
    mov byte [rajz+ebx+42], 255


;eddig

    jmp 	.mainloop

	; Exit
.end:
	call	gfx_destroy
    ; mov eax, eredmenyszoveg
    ; call mio_writestr
    ret

kimentesFileba:
    mov eax, kiment
    mov ebx, 1
    call fio_open

    mov ebx, resize
    mov ecx, 3136
    call fio_write

    call fio_close

    ret

kimentesEredmeny:
    mov eax, mentEredmeny
    mov ebx, 1
    call fio_open

    mov ebx, resize;binolvas
    mov ecx, 4000
    call fio_write

    call fio_close

    ret



rajzEgyszerusites:      ;nearest neighbour method (tehat az elemek tobbsege 255 maybe)
    xor ecx, ecx
.huszonnyolcasCiklusSorokra:
    xor edx, edx
.huszonnyolcasCiklusOszlopokra:
    xor edi, edi
    xor eax, eax;osszeg tarolasara hasznalom
.huszonkettesCiklusSorokra:
    xor esi, esi
.huszonkettesCiklusOszlopokra:

    push esi
    push edi
    push edx
    push ecx
    imul ecx, 616;hany kis negyzetekbol allo sor van elotte
    imul edx, 22;hanny kis negyzet van elotte (bal oldalan) amit mar atneztem
    imul edi, 616;a kis negyzeten belul hany sort neztem mar at
    add ecx, edx
    add ecx, edi
    add ecx, esi
    mov esi, 255
    xor ebx, ebx;vagy ez vagy az also
    mov bl, [rajz+ecx*4]
    cmp esi, ebx
    ; cvtsi2ss xmm0, esi
    ; movss xmm1, [rajz+ecx*4]
    ; COMISS xmm1, xmm0;255
    jne .mindenVisszaEsFolytat
    inc eax
    .mindenVisszaEsFolytat:
    pop ecx
    pop edx
    pop edi
    pop esi

    inc esi
    cmp esi, 22
    jl .huszonkettesCiklusOszlopokra

    inc edi
    cmp edi, 22
    jl .huszonkettesCiklusSorokra

    imul eax, 2
    cvtsi2ss xmm5, eax
    ;push edi
    mov edi, 4;968
    cvtsi2ss xmm6, edi
    ;idiv edi;968
    divss xmm5, xmm6
    ;pop edi
    mov eax, 1
    cvtsi2ss xmm6, eax
    subss xmm5, xmm6

    mov eax, [holtartunk]
    movss [resize+eax*4], xmm5
    ; movss xmm0, xmm5
    ; call io_writeflt
    ; call io_writeln
    inc eax
    mov [holtartunk], eax
    ;megfelelo helyre pozicionalas

    add edx, 1
    cmp edx, 28
    jl .huszonnyolcasCiklusOszlopokra

    add ecx, 22;azert 22, mert minden kis negyzetben 22x22 elemet vizsgalunk igy 22 elemmel megyunk lejjebb az y on es 28x22=616
    cmp ecx, 616
    jl .huszonnyolcasCiklusSorokra
    call kimentesFileba
    ret
    

linearLayer:
    mov esi, [linbemenet];eltaroljuk, hogy hany sor van
    mov edi, [linkimenet];oszlop
    imul edi, esi
    imul edi, 4
    ;mov eax, esi
    ;call io_writeint
    mov eax, linBin
    xor ebx, ebx
    call fio_open

    mov ebx, binskipmemory
    mov ecx, [binskip]
    call fio_read

    mov ebx, binolvas;beolvastam a matrixot
    mov ecx, edi
    call fio_read
    imul esi, 4
    mov ebx, sulyok;beolvastam a sulyokat
    mov ecx, edi
    call fio_read
    call fio_close

    ; add esi, edi
    mov esi, [linbemenet]
    mov edi, [linkimenet]
    imul esi, edi
    add esi, edi
    imul esi, 4
    mov edi, [binskip]
    add esi, edi
    mov [binskip], esi
    ; mov eax, esi
    ; call io_writeint
    ; call mio_writeln
    ; movss xmm0, [sulyok]
    ; call io_writeflt
    ; call io_writeln
    ; movss xmm0, [binolvas]
    ; call io_writeflt
    ; call io_writeln
    



    ;itt kezdodik a lenyegi resz
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor esi, esi
    xor edi, edi
    xorps xmm0, xmm0
    xorps xmm5, xmm5
    xorps xmm6, xmm6
    xorps xmm7, xmm7
.kovsorkezdes:
    xor ecx, ecx
.muveletvegzes:

    ;muveletek
    movss xmm5, [binolvas+edi+ecx*4];nezd meg, hogy melyik lesz vegul a hosszabb es melyik a rovidebb
    movss xmm6, [resize+ecx*4]
    ;movss xmm7, [beolvasott+linkimenet*linbemenet+ecx*4];ez csak akkor ha kovetkez sorbe kell lepni, akkor elvegzodik az eredmeny matrixba pakolas is meg minden ilyen

    mulss xmm5, xmm6
    addss xmm0, xmm5;ide kerul a sok szorzas eredmenye


    ;a 0 indexeles miatt mindig egyel kevesebb az ecx mint kene
    ;kovsor
    
    inc ecx
    cmp ecx, [linbemenet]
    jle .muveletvegzes
    movss xmm7, [sulyok+eax*4];nem tokeletes a meghatarozasa \\\\\\ eax talan mar jo
    addss xmm0, xmm7
    movss [eredmeny+eax*4], xmm0
    inc eax
    xorps xmm0, xmm0
    add esi, [linbemenet]
    mov edi, esi
    imul edi, 4
    inc ebx
    cmp ebx, [linkimenet]
    jl .kovsorkezdes


    xor eax, eax
.masolas:
    movss xmm0, [eredmeny+eax*4]
    movss [resize+eax*4], xmm0
    inc eax
    cmp eax, [linkimenet]
    jle .masolas
    

    ; pusha
    ; mov ecx, [linkimenet]  ; Number of elements in the vectors
    ; mov esi, eredmeny  ; Source vector address
    ; mov edi, rajz      ; Destination vector address
    ; copy_loop:
    ; mov al, [esi]
    ; mov [edi], al
    ; inc esi
    ; inc edi
    ; dec ecx
    ; jnz copy_loop
    ; popa

    call kimentesEredmeny
    ret



ReLU:;vegigmengy a vektoron es minden elemet osszehasonlit 0val, amin <0, 0 lesz

    pusha
    xor ebx, ebx
.osszesElemVizsgalata:
    movss xmm6, [resize+ebx*4]
    xorps xmm5, xmm5
    comiss xmm6, xmm5
    ja .nagyobbmintNULL
    movss [resize+ebx*4], xmm5
.nagyobbmintNULL:
    inc ebx
    cmp ebx, [linkimenet]
    jl .osszesElemVizsgalata
    popa
    call kimentesEredmeny
    ret



ArgMax:
    pusha
    xor ebx, ebx
    xor ecx, ecx
    xor esi, esi
    movss xmm5, [eredmeny+ebx*4]
    inc ebx
.maxkereses:
    movss xmm6, [eredmeny+ebx*4]
    comiss xmm6, xmm5
    jb .nemerdekes
    movss xmm5, xmm6
    mov esi, ebx
.nemerdekes:
    inc ebx
    cmp ebx, 9
    jle .maxkereses
    
    mov eax, [eredmenyszoveg]
    call mio_writestr
    mov eax, esi
    call io_writeint
    call io_writeln
    popa
    call kimentesEredmeny
    ret

Conv:
    xor ecx, ecx
.huszonnyolcasCiklusSorokra:
    xor edx, edx
.huszonnyolcasCiklusOszlopokra:
    xor edi, edi
    xor eax, eax;osszeg tarolasara hasznalom
.huszonkettesCiklusSorokra:
    xor esi, esi
.huszonkettesCiklusOszlopokra:

    push esi
    push edi
    push edx
    push ecx
    imul ecx, 616;hany kis negyzetekbol allo sor van elotte
    imul edx, 22;hanny kis negyzet van elotte (bal oldalan) amit mar atneztem
    imul edi, 616;a kis negyzeten belul hany sort neztem mar at
    add ecx, edx
    add ecx, edi
    add ecx, esi
    ; mov esi, 255
    ; xor ebx, ebx;vagy ez vagy az also                 itt lesz a szorzas
    ; mov bl, [resize+ecx*4]
    ; cmp esi, ebx
    ; jne .mindenVisszaEsFolytat
    ; inc eax
    ; .mindenVisszaEsFolytat:
    movss xmm5, [resize+ecx*4]
    ;movss xmm6, [beconv+eax*4];meg nincs beolvasva es deklaralva se
    mulss xmm5, xmm6
    addss xmm0, xmm5

    pop ecx
    pop edx
    pop edi
    pop esi

    inc esi
    cmp esi, 22
    jl .huszonkettesCiklusOszlopokra

    inc edi
    cmp edi, 22
    jl .huszonkettesCiklusSorokra

    imul eax, 2
    cvtsi2ss xmm5, eax
    ;push edi
    mov edi, 4;968
    cvtsi2ss xmm6, edi
    ;idiv edi;968
    divss xmm5, xmm6
    ;pop edi
    mov eax, 1
    cvtsi2ss xmm6, eax
    subss xmm5, xmm6

    mov eax, [holtartunk]
    movss [eredmeny+eax*4], xmm5
    ; movss xmm0, xmm5
    ; call io_writeflt
    ; call io_writeln
    inc eax
    mov [holtartunk], eax
    ;megfelelo helyre pozicionalas

    add edx, 1
    cmp edx, 28
    jl .huszonnyolcasCiklusOszlopokra

    add ecx, 22;azert 22, mert minden kis negyzetben 22x22 elemet vizsgalunk igy 22 elemmel megyunk lejjebb az y on es 28x22=616
    cmp ecx, 616
    jl .huszonnyolcasCiklusSorokra
    ret

section .bss
    rajz resd 1000*1000
    resize resd 400000
    sulyok resd 400000;ezt kell betolteni majd a linearis layerbez a .bin filebol
    eredmeny resd 400000
    filter resd 3*3
    belvasottSzoveg resd 500
    binolvas resd 40000000
    binskipmemory resd 400000000


section .data
    caption db "Rajzfelulet", 0
	infomsg db "Rajzolj egy szamot az eger hasznalataval a fekete negyzetbe.", 0
	errormsg db "ERROR: could not initialize graphics!", 0
    eredmenyszoveg db "Eredmeny", 0


    ;fileok nevei
    kiment db "kimentes.bin", 0
    mentEredmeny db "eredmenyvektor.bin", 0
    linBin db "lin_model.bin", 0
    linTxt db "lin_model.txt", 0
    linbemenet dd 0
    linkimenet dd 0
    convBin db "conv_model.bin", 0
    convTxt db "conv_model.txt", 0
    holtartunk dd 0
    binskip dd 0

    
	
	; These are used for moving the image
	offsetx dd 0
	offsety dd 0
	
	movemouse dd 0  ; bool (true while the left button is pressed)
	prevmousex dd 0
	prevmousey dd 0

    row_size equ 616
    original_size equ 28

    lebegopontosSzam dd 2.0
	