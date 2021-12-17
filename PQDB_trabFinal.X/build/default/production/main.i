# 1 "main.c"
# 1 "<built-in>" 1
# 1 "<built-in>" 3
# 288 "<built-in>" 3
# 1 "<command line>" 1
# 1 "<built-in>" 2
# 1 "C:/Program Files (x86)/Microchip/MPLABX/v5.35/packs/Microchip/PIC18Fxxxx_DFP/1.2.26/xc8\\pic\\include\\language_support.h" 1 3
# 2 "<built-in>" 2
# 1 "main.c" 2
# 1 "./config.h" 1
# 26 "./config.h"
#pragma config OSC=HS
#pragma config FCMEN = OFF
#pragma config IESO = OFF
#pragma config PWRT = OFF
#pragma config BOREN = OFF
#pragma config BORV = 46
#pragma config WDT=OFF
#pragma config WDTPS = 1
#pragma config MCLRE=ON
#pragma config LPT1OSC = OFF
#pragma config PBADEN = ON
#pragma config CCP2MX = PORTC
#pragma config STVREN = OFF
#pragma config LVP=OFF
#pragma config XINST = OFF
#pragma config DEBUG = OFF

#pragma config CP0 = OFF
#pragma config CP1 = OFF
#pragma config CP2 = OFF
#pragma config CP3 = OFF
#pragma config CPB = OFF
#pragma config CPD = OFF

#pragma config WRT0 = OFF
#pragma config WRT1 = OFF
#pragma config WRT2 = OFF
#pragma config WRT3 = OFF
#pragma config WRTB = OFF
#pragma config WRTC = OFF
#pragma config WRTD = OFF

#pragma config EBTR0 = OFF
#pragma config EBTR1 = OFF
#pragma config EBTR2 = OFF
#pragma config EBTR3 = OFF
#pragma config EBTRB = OFF
# 1 "main.c" 2

# 1 "./lcd.h" 1


  void lcdCommand(char value);
  void lcdChar(char value);
  void lcdString(char msg[]);
  void lcdNumber(int value);
  void lcdPosition(int line, int col);
  void lcdInit(void);
# 2 "main.c" 2

# 1 "./adc.h" 1
# 22 "./adc.h"
 void adcInit(void);
 int adcRead(unsigned int channel);
# 3 "main.c" 2

# 1 "./keypad.h" 1


 unsigned int kpRead(void);
    char kpReadKey(void);
 void kpDebounce(void);
 void kpInit(void);
# 4 "main.c" 2

# 1 "./pwm.h" 1
# 23 "./pwm.h"
 void pwmSet(unsigned char porcento);
 void pwmFrequency(unsigned int freq);
 void pwmInit(void);
# 5 "main.c" 2

# 1 "./timer.h" 1
# 23 "./timer.h"
 char timerEnded(void);
 void timerWait(void);

 void timerReset(unsigned int tempo);
 void timerInit(void);
# 6 "main.c" 2

# 1 "./bits.h" 1
# 7 "main.c" 2

# 1 "./ssd.h" 1
# 22 "./ssd.h"
 void ssdDigit(char val, char pos);
 void ssdUpdate(void);
 void ssdInit(void);
# 8 "main.c" 2


void main(void) {
    unsigned int v, v0, v1, v2, v3;
    unsigned int t0, t1, t2, t3;
    char slot;
    unsigned long int cont = 0;
    unsigned int tecla = 16;

    lcdInit();
    ssdInit();
    adcInit();
    kpInit();
    pwmInit();
    timerInit();

    for (;;) {
        timerReset(10000);
        ssdUpdate();
        v = adcRead(0);
        switch(slot){
            case 0:
                cont+=2;
                lcdPosition(0, 0);

                t3=(((cont / 360000) % 24) / 10);
                t2=(((cont / 360000) % 24) % 10);
                t1=(((cont / 60000) % 6) % 10);
                t0=(((cont / 6000) % 10) % 10);
                lcdChar(t3 + 48);
                lcdChar(t2 + 48);
                lcdChar(':');
                lcdChar(t1 + 48);
                lcdChar(t0 + 48);
                lcdChar(':');
                lcdChar((cont / 1000) % 6 + 48);
                lcdChar((cont / 100) % 10 + 48);


                lcdPosition(1, 0);
                lcdChar(v3+48);
                lcdChar(v2+48);
                lcdChar(':');
                lcdChar(v1+48);
                lcdChar(v0+48);
                ssdUpdate();
                slot = 1;
                break;
            case 1:
                kpDebounce();
                slot = 2;
                break;
            case 2:
                if (kpRead() != tecla) {
                    tecla = kpRead();
                    if (((tecla) & (1<<(0))))
                        cont+=360000;
                    if (((tecla) & (1<<(2))))
                        cont-=360000;
                    if (((tecla) & (1<<(9))))
                        cont+=6000;
                    if (((tecla) & (1<<(4))))
                        cont-=6000;
                    if (((tecla) & (1<<(5))))
                        cont+=100;
                    if (((tecla) & (1<<(7))))
                        cont-=100;
                    if (((tecla) & (1<<(3))))
                        pwmSet(0);
                }
                slot = 3;
                ssdUpdate();
                break;
            case 3:

                ssdDigit(v3, 0);
                ssdDigit(v2, 1);
                ssdDigit(v1, 2);
                ssdDigit(v0, 3);
                slot = 0;
                for(char i=0; i<50; i++)
                break;
            case 4:

                v0= ((int)(v*1.4/ 1)) % 10;
                v1= ((int)(v*1.4/ 10)) % 6;
                v2= ((int)(v*1.4/ 60)) % 10;
                v3= ((int)(v*1.4/ 600)) % 6;

                if(t0==v0 && t1==v1 && t2==v2 && t3==v3){
                    pwmSet(100);
                }
                slot = 0;
                break;
            default:
                slot = 0;
                break;
        }
        timerWait();
    }
}
