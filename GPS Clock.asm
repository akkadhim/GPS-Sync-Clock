
_interrupt:

;GPS Clock.c,24 :: 		void interrupt() {
;GPS Clock.c,25 :: 		if (RCIF_bit == 1) {             // If interrupt is generated by RCIF
	BTFSS       RCIF_bit+0, BitPos(RCIF_bit+0) 
	GOTO        L_interrupt0
;GPS Clock.c,26 :: 		txt[i] = UART1_Read();         // Read data and store it to txrt string
	MOVLW       _txt+0
	ADDWF       _i+0, 0 
	MOVWF       FLOC__interrupt+0 
	MOVLW       hi_addr(_txt+0)
	ADDWFC      _i+1, 0 
	MOVWF       FLOC__interrupt+1 
	CALL        _UART1_Read+0, 0
	MOVFF       FLOC__interrupt+0, FSR1
	MOVFF       FLOC__interrupt+1, FSR1H
	MOVF        R0, 0 
	MOVWF       POSTINC1+0 
;GPS Clock.c,27 :: 		i++;                           // Increment string index
	INFSNZ      _i+0, 1 
	INCF        _i+1, 1 
;GPS Clock.c,28 :: 		if (i == 768) {                // If index = 768,
	MOVF        _i+1, 0 
	XORLW       3
	BTFSS       STATUS+0, 2 
	GOTO        L__interrupt9
	MOVLW       0
	XORWF       _i+0, 0 
L__interrupt9:
	BTFSS       STATUS+0, 2 
	GOTO        L_interrupt1
;GPS Clock.c,29 :: 		i = 0;                       //   set it to zero
	CLRF        _i+0 
	CLRF        _i+1 
;GPS Clock.c,30 :: 		ready = 1;                     // Ready for parsing GPS data
	MOVLW       1
	MOVWF       _ready+0 
;GPS Clock.c,31 :: 		}
L_interrupt1:
;GPS Clock.c,32 :: 		RCIF_bit = 0;                    // Set RCIF to 0 register for uart interrupt
	BCF         RCIF_bit+0, BitPos(RCIF_bit+0) 
;GPS Clock.c,33 :: 		}
L_interrupt0:
;GPS Clock.c,34 :: 		}
L_end_interrupt:
L__interrupt8:
	RETFIE      1
; end of _interrupt

_main:

;GPS Clock.c,36 :: 		void main(){
;GPS Clock.c,37 :: 		ANSELB = 0;                        // Configure PORTB pins as digital
	CLRF        ANSELB+0 
;GPS Clock.c,38 :: 		ANSELD=0;
	CLRF        ANSELD+0 
;GPS Clock.c,39 :: 		ANSELC=0;
	CLRF        ANSELC+0 
;GPS Clock.c,41 :: 		Lcd_Init();                        // Initialize Lcd
	CALL        _Lcd_Init+0, 0
;GPS Clock.c,43 :: 		Lcd_Cmd(_LCD_CLEAR);               // Clear display
	MOVLW       1
	MOVWF       FARG_Lcd_Cmd_out_char+0 
	CALL        _Lcd_Cmd+0, 0
;GPS Clock.c,44 :: 		Lcd_Cmd(_LCD_CURSOR_OFF);          // Cursor off
	MOVLW       12
	MOVWF       FARG_Lcd_Cmd_out_char+0 
	CALL        _Lcd_Cmd+0, 0
;GPS Clock.c,45 :: 		Lcd_out(1,1,"GPS Time:");
	MOVLW       1
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       ?lstr1_GPS_32Clock+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(?lstr1_GPS_32Clock+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
;GPS Clock.c,46 :: 		Lcd_out(2,1,"Waiting");
	MOVLW       2
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       ?lstr2_GPS_32Clock+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(?lstr2_GPS_32Clock+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
;GPS Clock.c,48 :: 		ready = 0;                       // Initialize variables
	CLRF        _ready+0 
;GPS Clock.c,49 :: 		i = 0;
	CLRF        _i+0 
	CLRF        _i+1 
;GPS Clock.c,51 :: 		UART1_Init(9600);                // Initialize UART module at 9600
	BSF         BAUDCON+0, 3, 0
	MOVLW       3
	MOVWF       SPBRGH+0 
	MOVLW       64
	MOVWF       SPBRG+0 
	BSF         TXSTA+0, 2, 0
	CALL        _UART1_Init+0, 0
;GPS Clock.c,53 :: 		RC1IE_bit = 1;                   // Enable USART Receiver interrupt
	BSF         RC1IE_bit+0, BitPos(RC1IE_bit+0) 
;GPS Clock.c,54 :: 		GIE_bit = 1;                     // Enable Global interrupt
	BSF         GIE_bit+0, BitPos(GIE_bit+0) 
;GPS Clock.c,55 :: 		PEIE_bit = 1;                    // Enable Peripheral interrupt
	BSF         PEIE_bit+0, BitPos(PEIE_bit+0) 
;GPS Clock.c,57 :: 		while(1) {
L_main2:
;GPS Clock.c,58 :: 		OERR1_bit = 0;                 // Set OERR to 0  overrun error bit in uart
	BCF         OERR1_bit+0, BitPos(OERR1_bit+0) 
;GPS Clock.c,59 :: 		FERR1_bit = 0;                 // Set FERR to 0  framming error bit in uart
	BCF         FERR1_bit+0, BitPos(FERR1_bit+0) 
;GPS Clock.c,61 :: 		if(ready == 1) {               // If the data in txt array is ready do:
	MOVF        _ready+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_main4
;GPS Clock.c,62 :: 		ready = 0;
	CLRF        _ready+0 
;GPS Clock.c,63 :: 		string = strstr(txt,"$GPGLL");   //locates the first position of $GPGLL in txt
	MOVLW       _txt+0
	MOVWF       FARG_strstr_s1+0 
	MOVLW       hi_addr(_txt+0)
	MOVWF       FARG_strstr_s1+1 
	MOVLW       ?lstr3_GPS_32Clock+0
	MOVWF       FARG_strstr_s2+0 
	MOVLW       hi_addr(?lstr3_GPS_32Clock+0)
	MOVWF       FARG_strstr_s2+1 
	CALL        _strstr+0, 0
	MOVF        R0, 0 
	MOVWF       _string+0 
	MOVF        R1, 0 
	MOVWF       _string+1 
;GPS Clock.c,64 :: 		if(string != 0) {            // If txt array contains "$GPGLL" string we proceed...
	MOVLW       0
	XORWF       R1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main11
	MOVLW       0
	XORWF       R0, 0 
L__main11:
	BTFSC       STATUS+0, 2 
	GOTO        L_main5
;GPS Clock.c,65 :: 		if(string[7] != ',') {     // If "$GPGLL" NMEA message have ',' sign in the 8-th
	MOVLW       7
	ADDWF       _string+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      _string+1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	XORLW       44
	BTFSC       STATUS+0, 2 
	GOTO        L_main6
;GPS Clock.c,68 :: 		hour = (string[31]-48)*100 + (string[32]-48)*10 + (string[33]-48) + 3;
	MOVLW       31
	ADDWF       _string+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      _string+1, 0 
	MOVWF       FSR0H 
	MOVLW       48
	SUBWF       POSTINC0+0, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	SUBWFB      R1, 1 
	MOVLW       100
	MOVWF       R4 
	MOVLW       0
	MOVWF       R5 
	CALL        _Mul_16x16_U+0, 0
	MOVF        R0, 0 
	MOVWF       FLOC__main+0 
	MOVF        R1, 0 
	MOVWF       FLOC__main+1 
	MOVLW       32
	ADDWF       _string+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      _string+1, 0 
	MOVWF       FSR0H 
	MOVLW       48
	SUBWF       POSTINC0+0, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	SUBWFB      R1, 1 
	MOVLW       10
	MOVWF       R4 
	MOVLW       0
	MOVWF       R5 
	CALL        _Mul_16x16_U+0, 0
	MOVF        R0, 0 
	ADDWF       FLOC__main+0, 0 
	MOVWF       _hour+0 
	MOVF        R1, 0 
	ADDWFC      FLOC__main+1, 0 
	MOVWF       _hour+1 
	MOVLW       33
	ADDWF       _string+0, 0 
	MOVWF       R2 
	MOVLW       0
	ADDWFC      _string+1, 0 
	MOVWF       R3 
	MOVFF       R2, FSR0
	MOVFF       R3, FSR0H
	MOVLW       48
	SUBWF       POSTINC0+0, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	SUBWFB      R1, 1 
	MOVF        R0, 0 
	ADDWF       _hour+0, 1 
	MOVF        R1, 0 
	ADDWFC      _hour+1, 1 
	MOVLW       3
	ADDWF       _hour+0, 1 
	MOVLW       0
	ADDWFC      _hour+1, 1 
;GPS Clock.c,69 :: 		minute = (string[33]-48)*100 + (string[34]-48)*10 + (string[35]-48);
	MOVFF       R2, FSR0
	MOVFF       R3, FSR0H
	MOVLW       48
	SUBWF       POSTINC0+0, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	SUBWFB      R1, 1 
	MOVLW       100
	MOVWF       R4 
	MOVLW       0
	MOVWF       R5 
	CALL        _Mul_16x16_U+0, 0
	MOVF        R0, 0 
	MOVWF       FLOC__main+0 
	MOVF        R1, 0 
	MOVWF       FLOC__main+1 
	MOVLW       34
	ADDWF       _string+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      _string+1, 0 
	MOVWF       FSR0H 
	MOVLW       48
	SUBWF       POSTINC0+0, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	SUBWFB      R1, 1 
	MOVLW       10
	MOVWF       R4 
	MOVLW       0
	MOVWF       R5 
	CALL        _Mul_16x16_U+0, 0
	MOVF        R0, 0 
	ADDWF       FLOC__main+0, 0 
	MOVWF       _minute+0 
	MOVF        R1, 0 
	ADDWFC      FLOC__main+1, 0 
	MOVWF       _minute+1 
	MOVLW       35
	ADDWF       _string+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      _string+1, 0 
	MOVWF       FSR0H 
	MOVLW       48
	SUBWF       POSTINC0+0, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	SUBWFB      R1, 1 
	MOVF        R0, 0 
	ADDWF       _minute+0, 1 
	MOVF        R1, 0 
	ADDWFC      _minute+1, 1 
;GPS Clock.c,71 :: 		ByteToStr(hour, hh);
	MOVF        _hour+0, 0 
	MOVWF       FARG_ByteToStr_input+0 
	MOVLW       _hh+0
	MOVWF       FARG_ByteToStr_output+0 
	MOVLW       hi_addr(_hh+0)
	MOVWF       FARG_ByteToStr_output+1 
	CALL        _ByteToStr+0, 0
;GPS Clock.c,72 :: 		ByteToStr(minute, mm);
	MOVF        _minute+0, 0 
	MOVWF       FARG_ByteToStr_input+0 
	MOVLW       _mm+0
	MOVWF       FARG_ByteToStr_output+0 
	MOVLW       hi_addr(_mm+0)
	MOVWF       FARG_ByteToStr_output+1 
	CALL        _ByteToStr+0, 0
;GPS Clock.c,74 :: 		Lcd_Cmd(_LCD_CLEAR);
	MOVLW       1
	MOVWF       FARG_Lcd_Cmd_out_char+0 
	CALL        _Lcd_Cmd+0, 0
;GPS Clock.c,75 :: 		Lcd_Cmd(_LCD_CURSOR_OFF);
	MOVLW       12
	MOVWF       FARG_Lcd_Cmd_out_char+0 
	CALL        _Lcd_Cmd+0, 0
;GPS Clock.c,76 :: 		Lcd_out(1,1,"GPS Time:");
	MOVLW       1
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       ?lstr4_GPS_32Clock+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(?lstr4_GPS_32Clock+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
;GPS Clock.c,77 :: 		Lcd_out(2,1,hh);
	MOVLW       2
	MOVWF       FARG_Lcd_Out_row+0 
	MOVLW       1
	MOVWF       FARG_Lcd_Out_column+0 
	MOVLW       _hh+0
	MOVWF       FARG_Lcd_Out_text+0 
	MOVLW       hi_addr(_hh+0)
	MOVWF       FARG_Lcd_Out_text+1 
	CALL        _Lcd_Out+0, 0
;GPS Clock.c,78 :: 		Lcd_Chr_Cp(':');
	MOVLW       58
	MOVWF       FARG_Lcd_Chr_CP_out_char+0 
	CALL        _Lcd_Chr_CP+0, 0
;GPS Clock.c,79 :: 		Lcd_out_Cp(mm);
	MOVLW       _mm+0
	MOVWF       FARG_Lcd_Out_CP_text+0 
	MOVLW       hi_addr(_mm+0)
	MOVWF       FARG_Lcd_Out_CP_text+1 
	CALL        _Lcd_Out_CP+0, 0
;GPS Clock.c,82 :: 		}
L_main6:
;GPS Clock.c,83 :: 		}
L_main5:
;GPS Clock.c,84 :: 		}
L_main4:
;GPS Clock.c,85 :: 		}
	GOTO        L_main2
;GPS Clock.c,86 :: 		}
L_end_main:
	GOTO        $+0
; end of _main
