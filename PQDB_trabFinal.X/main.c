#include "config.h"
#include "lcd.h"
#include "adc.h"
#include "keypad.h"
#include "pwm.h"
#include "timer.h"
#include "bits.h"
#include "ssd.h"

void main(void) {
    unsigned int v, v0, v1, v2, v3; //pwm
    unsigned int t0, t1, t2, t3; //relogio
    char slot;//mistagem
    unsigned long int cont = 0;//contador
    unsigned int tecla = 16;
    //Inicializações
    lcdInit();
    ssdInit();
    adcInit();
    kpInit();
    pwmInit();
    timerInit();
    //
    for (;;) {
        timerReset(10000);
        ssdUpdate();
        v = adcRead(0);        
        switch(slot){       
            case 0:
                cont+=2;
                lcdPosition(0, 0);
                //conversão do contador para medida de tempo
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
                
                //Dionibiliza o horario do alarme no LCD
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
                    if (bitTst(tecla, 0)) //hora +
                        cont+=360000;
                    if (bitTst(tecla, 2)) // hora -
                        cont-=360000;
                    if (bitTst(tecla, 9)) // min +
                        cont+=6000; 
                    if (bitTst(tecla, 4)) // min -
                        cont-=6000; 
                    if (bitTst(tecla, 5)) // segundos + 
                        cont+=100;
                    if (bitTst(tecla, 7)) //segundos -
                        cont-=100;
                    if (bitTst(tecla, 3)) //desliga o alarme
                        pwmSet(0);
                }         
                slot = 3;
                ssdUpdate();
                break;
            case 3:
                //Mostra o horario do alarme no display
                ssdDigit(v3, 0);
                ssdDigit(v2, 1);
                ssdDigit(v1, 2);
                ssdDigit(v0, 3);
                slot = 0;  
                for(char i=0; i<50; i++)
                break;
            case 4:
                //Converte o valor para a medida de tempo
                v0= ((int)(v*1.4/ 1)) % 10;
                v1= ((int)(v*1.4/ 10)) % 6;
                v2= ((int)(v*1.4/ 60)) % 10;
                v3= ((int)(v*1.4/ 600)) % 6;               
                // verifica se deu a hora do alarme
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