
; ORIGINAL PROGRAM :
; Apple 30th Anniversary Tribute for Apple II by Dave Schmenk
; Original at https://www.applefritter.com/node/24600#comment-60100
; Disassembled, Commented, and ported to Apple II by J.B. Langston
; Assemble with `64tass -b -o a2apple30th.bin -L a2apple30th.lst`
; https://gist.github.com/jblang/5b9e9ba7e6bbfdc64ad2a55759e401d5

; THiS PROGRAM :
; enhenced with a text animation
; and mainly with a Delphi program to convert any BMP 40x23 4 bits grey pixels image 
; to data to copy/paste at the end of this program.
; see https://github.com/bruno185/Delphi-program-for-Apple-II-text-mode-image-display

KEYBD equ $c000		    ; keyboard register
KBSTRDBE equ $c010		; keyboard strobe register
spkr  equ $c030       ; clic
offscreen equ $2000		; base address of offscreen storage
gbascalc equ $f847 		; calc Address
home equ  $fc58
vtab equ $fc22        ; Moves the cursor to line in CV ($25).
cout equ $fded
wait equ $fca8 

ptr	equ $06				    ; pointer to current image
ptrlu equ $08
cv equ $25
gbasl equ $26 			  ; base address of text line, given by gbascalc

  XC        ; allow 65c02 opcodes

playnote MAC
        pha         ; save A
        txa 
        pha         ; save X
        tya
        pha         ; save Y
        lda #]1
        sta pitch
        lda #]2
        sta lengthhi
        lda #]3
        sta lengthlo
sound   ldy lengthlo
bip     lda $c030       ;4 cycles
        ldx pitch       ;3 cycles
inloop  nop             ;2 cycles
        ;nop             ;2 cycles
        ;nop             ;2 cycles
        nop             ;2 cycles
        dex             ;2 cycles
        bne inloop      ;3 cycles
        dey             ;2 cycles
        bne bip         ;3 cycles
        dec lengthhi    ;5 cycles
        bne sound         ;3 cycles
        pla 
        tay         ; restore Y
        pla
        tax         ; restore X
        pla         ; restore A
        <<<

******************** BEGINNIG ********************
	org $8000

  lda #17
  jsr cout        ; 40 col.
	jsr home

 ; init lookup table
  lda #<lookup    ; init prtlu = base address of lookup table
  sta ptrlu
  lda #>lookup
  sta ptrlu+1
  ldx #15       ; 16 bytes
luloop
  lda chars,x 
  tay
  txa
  sta (ptrlu),y
  dex
  bpl luloop

	lda	#<image			;load image address in ptr
	sta	ptr
	lda	#>image
	sta	ptr+1
	lda #$00			; init line
	sta line
	sta linelength		; init current line counter

decode
	ldy	#$00
	lda	(ptr),y		; load run length and character offset
	beq	anim 		  ; $00 indicates end of current image
	lsr	a			    ; get run length from upper nybble
	lsr	a
	lsr	a
	lsr	a
	tax				  ; x = number of identical pixels
	lda	(ptr),y	; get value of pixel from lower nibble 
  ;eor #$ff   ; for a negative image
	and	#$0F		; value = offset in chars table
	tay
	lda	chars,y	; load char at offset

* poke pixels in offsreen storage
* X = number of pixels (length)
* A = pixel value (=char)
	pha				; save pixel value
	txa 			; save length 
	pha				
	lda line		; get line number
	jsr gbascalc	; calc base address of line in gbasl/gbasl+1

	lda gbasl		; add base address of offsreen storage 
	clc
	adc #<offscreen
	sta gbasl		; store result in gbasl/gbasl+1
	lda gbasl+1
	adc #>offscreen
	sta gbasl+1

	lda gbasl		; add number of byte already written 
	clc	
	adc linelength ; 
	sta gbasl		; store result in gbasl/gbasl+1
	lda gbasl+1
	adc #$00
	sta gbasl+1

	pla 			; restore length
	tay				; y = length (number of identical pixels)
	dey 			; adjut length (ex : length of 1 ==> offset = 0)

	clc 		
	adc linelength	; update number of pixel on this line
	sta linelength	; and save it


	cmp #40			; end of line ?
	bne suite		; no
	inc line		; yes : adjust line and linelength variables
	lda #$00
	sta linelength
suite
	pla 			; restore pixel value
loopoff
	sta (gbasl),y 	; poke pixel in offsreen
	dey 
	bpl loopoff		; loop 
	inc	ptr		; process the next run of characters
	bne	decode
	inc	ptr+1
	bne	decode

anim
; compare offsreen and text screen
; while each byte not equal, inc text screen byte
; in chars table, and update flag
; repeat full loop until no inc (flag = 0)

	lda #$00
	sta line		; line #
	tay         ; horizontal position
  sta permut  ; boolean flag 

outerloop
	lda line      ; outer loop
	jsr gbascalc  ; get line base address
  lda #<offscreen ; calc base address in offscreen
  clc           ; line base address + offscreen base storage address
  adc gbasl
  sta ptr       ; ==> in ptr
  lda #>offscreen
  adc gbasl+1
  sta ptr+1

loopcmp
  lda (gbasl),y ; get byte in text page
  cmp (ptr),y   ; compare with byte in offsreen
  beq noinc     ; if equal : next byte
  ; get next char in lookup table
  tax           ; move byte to x
  lda lookup,x  ; get index in lookup table
  inc           ; next index
  tax           ; index in x
  lda chars,x   ; get char in chars table
  sta (gbasl),y ; poke vale in text page

  tya           ; changes on every loop (h position)
  and #%00000111 ; One on 8
  bne noclic    ; jmmp over clic 
  jsr clic      ; make some noise
  jmp nowait    ; 
noclic
  lda #$08      ; no sound but delay
  jsr wait
nowait
  lda #$01      ; update flag "an update occured"
  sta permut

noinc
  iny           ; next byte on the line
  cpy #40       ; end of line ?     
  bne loopcmp   ; no : loop
  ldy #$00      ; reset beginning of line 
  inc line      ; next line
  lda line      ; last line ?
  cmp #23
  bne outerloop ; no : loop
  lda permut    ; did an update occured ?
  bne anim      ; yes : loop from the beginning

  ldx #40
bigwait 
  lda #$81
  jsr wait
  dex
  bne bigwait
  playnote $88;$10;$20; bip !
  
  ; print spaces before text
  lda #23       ; vtab on last line
  sta cv
  jsr vtab
  lda	#$28		  ; screen width (40 decimal)
  sec
  sbc mytext    ; substract text length
  lsr           ; div by 2
  tax           ; save in X
spaceloop
  lda #$A0      ; space char in A
  jsr cout      ; print it
  dex           ; next 
  bne spaceloop
  ldx #$00
print          ; now print text
  lda mytext+1,x 
  beq endprint
  jsr cout
  inx
  jmp print

  lda #$fe    ; wait
  jsr wait
  playnote $80;$10;$20; bip !

endprint
  jsr waitkey
  rts         ; end of program


*************** ROUTINES ***************
waitkey 
  lda KEYBD
  bpl waitkey
  bit KBSTRDBE
  rts

clic
  pha         ; save registers
  txa 
  pha
  tya
  pha
  ldy #$03    ; duration
doclic 
  ldx #$10     ; pitch
  lda spkr    ; sound
wait1
  dex
  nop 
  nop
  nop
  nop
  nop 
  nop
  bne wait1
  dey 
  bne doclic
  pla 
  tay
  pla
  tax
  pla
  rts



line	 db $00
linelength  db $00
permut db $00

pitch       hex 00
lengthlo    hex 00
lengthhi    hex 00
tempo       hex 00


chars
	 db	$A0,$AE,$BA,$AC	;  .:,
	 db	$BB,$A1,$AD,$DE	; ;!-^
	 db	$AB,$BD,$BF,$A6	; +=/&
	 db	$AA,$A5,$A3,$C0	; *%#@

;; Images are run-length encoded with one run per byte
;; Run ength in the upper nybble
;; Offset into the character table above in the lower nybble
;; End of image data is indicated by a $00 byte
;; Next byte contains length of caption
;; Remaining bytes contain caption text
;; Last image is indicated by $00 byte after caption

mytext
 str "Digital democraty"
  db 00 
  
image
  db $16,$5F,$19,$17
  db $9F,$15,$19,$7F
  db $16,$19,$CF,$13
  db $6F,$17,$15,$8F
  db $15,$17,$6F,$17
  db $15,$DF,$11,$1C
  db $6F,$15,$13,$1E
  db $6F,$16,$15,$5F
  db $19,$12,$1B,$DF
  db $10,$19,$7F,$15
  db $13,$1C,$5F,$19
  db $16,$1C,$3F,$1B
  db $12,$17,$EF,$10
  db $17,$8F,$15,$13
  db $1B,$1F,$1E,$19
  db $17,$25,$13,$14
  db $19,$1A,$26,$1D
  db $9F,$1C,$1B,$3F
  db $11,$15,$8F,$1D
  db $16,$18,$17,$15
  db $14,$15,$23,$22
  db $21,$15,$18,$7F
  db $1E,$19,$17,$1A
  db $1E,$3F,$11,$14
  db $9F,$1D,$24,$13
  db $45,$24,$12,$13
  db $11,$14,$1B,$4F
  db $1C,$17,$13,$17
  db $1D,$5F,$12,$15
  db $9F,$19,$10,$12
  db $16,$18,$29,$18
  db $39,$15,$13,$12
  db $11,$1D,$1E,$19
  db $15,$12,$16,$1D
  db $7F,$13,$16,$8F
  db $1B,$10,$13,$18
  db $1D,$1C,$18,$15
  db $18,$17,$18,$1A
  db $19,$17,$13,$11
  db $13,$15,$12,$16
  db $1C,$9F,$24,$19
  db $1D,$6A,$14,$11
  db $18,$1E,$1A,$15
  db $14,$18,$1A,$19
  db $18,$26,$27,$12
  db $11,$15,$1C,$BF
  db $14,$15,$17,$12
  db $14,$16,$14,$23
  db $14,$13,$15,$1D
  db $19,$13,$16,$2B
  db $2A,$19,$18,$16
  db $14,$16,$14,$10
  db $16,$CF,$15,$28
  db $14,$1B,$2F,$2E
  db $18,$11,$19,$1A
  db $13,$17,$1C,$29
  db $1A,$16,$12,$14
  db $17,$15,$14,$13
  db $10,$14,$CF,$19
  db $28,$16,$15,$4F
  db $1A,$12,$18,$14
  db $15,$1A,$15,$12
  db $18,$1B,$13,$12
  db $26,$23,$14,$10
  db $11,$18,$1B,$1A
  db $4B,$2C,$1E,$19
  db $18,$1A,$18,$1A
  db $14,$12,$1D,$3F
  db $18,$12,$15,$12
  db $16,$15,$16,$18
  db $2B,$14,$18,$1B
  db $17,$22,$16,$15
  db $11,$10,$12,$23
  db $24,$16,$17,$18
  db $1B,$1C,$15,$17
  db $19,$1B,$15,$24
  db $16,$14,$23,$17
  db $18,$14,$15,$17
  db $1B,$1D,$19,$23
  db $18,$19,$18,$16
  db $13,$16,$18,$11
  db $15,$2C,$1D,$1E
  db $6F,$1E,$17,$1C
  db $17,$12,$21,$14
  db $15,$27,$19,$16
  db $15,$19,$3B,$16
  db $11,$12,$29,$16
  db $15,$12,$15,$18
  db $12,$1B,$BF,$1C
  db $18,$11,$20,$14
  db $3F,$1E,$18,$14
  db $17,$39,$1A,$19
  db $17,$16,$18,$19
  db $16,$14,$11,$12
  db $16,$14,$1A,$BF
  db $18,$32,$13,$12
  db $1D,$2F,$1E,$15
  db $12,$16,$28,$19
  db $1A,$28,$27,$18
  db $15,$13,$31,$12
  db $1C,$BF,$14,$17
  db $13,$17,$14,$10
  db $17,$3F,$14,$11
  db $15,$17,$18,$19
  db $2A,$19,$18,$17
  db $16,$14,$12,$11
  db $22,$13,$CF,$18
  db $24,$19,$11,$15
  db $17,$19,$1E,$1F
  db $1E,$12,$16,$19
  db $18,$29,$17,$16
  db $15,$13,$12,$13
  db $12,$10,$14,$15
  db $11,$1D,$BF,$15
  db $10,$17,$26,$1B
  db $17,$16,$19,$1F
  db $1A,$13,$15,$17
  db $19,$17,$15,$34
  db $13,$32,$11,$12
  db $11,$14,$1D,$BF
  db $11,$14,$19,$15
  db $17,$18,$13,$18
  db $19,$18,$19,$18
  db $23,$16,$24,$25
  db $24,$13,$32,$11
  db $14,$19,$1A,$BF
  db $13,$18,$1A,$26
  db $14,$16,$19,$18
  db $29,$18,$1A,$24
  db $25,$14,$15,$34
  db $13,$22,$11,$17
  db $1A,$17,$1E,$AF
  db $00

lookup
  ds 256
