#line 1 "D:/programming&CCt Design/Microcontroller/Projects/GPS Clock/GPS Clock/GPS Clock.c"

sbit LCD_RS at LATB4_bit;
sbit LCD_EN at LATB5_bit;
sbit LCD_D4 at LATB0_bit;
sbit LCD_D5 at LATB1_bit;
sbit LCD_D6 at LATB2_bit;
sbit LCD_D7 at LATB3_bit;

sbit LCD_RS_Direction at TRISB4_bit;
sbit LCD_EN_Direction at TRISB5_bit;
sbit LCD_D4_Direction at TRISB0_bit;
sbit LCD_D5_Direction at TRISB1_bit;
sbit LCD_D6_Direction at TRISB2_bit;
sbit LCD_D7_Direction at TRISB3_bit;


char txt[768];
char *string;
int i ;
int hour, minute;
unsigned short ready;
char hh[4], mm[4];

void interrupt() {
 if (RCIF_bit == 1) {
 txt[i] = UART1_Read();
 i++;
 if (i == 768) {
 i = 0;
 ready = 1;
 }
 RCIF_bit = 0;
 }
}

void main(){
 ANSELB = 0;
 ANSELD=0;
 ANSELC=0;

 Lcd_Init();

 Lcd_Cmd(_LCD_CLEAR);
 Lcd_Cmd(_LCD_CURSOR_OFF);
 Lcd_out(1,1,"GPS Time:");
 Lcd_out(2,1,"Waiting");

 ready = 0;
 i = 0;

 UART1_Init(9600);

 RC1IE_bit = 1;
 GIE_bit = 1;
 PEIE_bit = 1;

 while(1) {
 OERR1_bit = 0;
 FERR1_bit = 0;

 if(ready == 1) {
 ready = 0;
 string = strstr(txt,"$GPGLL");
 if(string != 0) {
 if(string[7] != ',') {


 hour = (string[31]-48)*100 + (string[32]-48)*10 + (string[33]-48) + 3;
 minute = (string[33]-48)*100 + (string[34]-48)*10 + (string[35]-48);

 ByteToStr(hour, hh);
 ByteToStr(minute, mm);

 Lcd_Cmd(_LCD_CLEAR);
 Lcd_Cmd(_LCD_CURSOR_OFF);
 Lcd_out(1,1,"GPS Time:");
 Lcd_out(2,1,hh);
 Lcd_Chr_Cp(':');
 Lcd_out_Cp(mm);


 }
 }
 }
 }
}
