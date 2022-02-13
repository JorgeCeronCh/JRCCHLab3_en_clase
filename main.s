/*	
    Archivo:		main.S
    Dispositivo:	PIC16F887
    Autor:		Jorge Cerón 20288
    Compilador:		pic-as (v2.30), MPLABX V6.00

    Programa:		Contador hexadecimal de 4 bits
    Hardware:		Contador hexadecimal de 4 bits en 7 segmentos

    Creado:			9/02/22
    Última modificación:	12/02/22	
*/
PROCESSOR 16F887
#include <xc.inc>

; configuracion 1
  CONFIG  FOSC = INTRC_NOCLKOUT // Oscillador Interno sin salidas
  CONFIG  WDTE = OFF            // WDT (Watchdog Timer Enable bit) disabled (reinicio repetitivo del pic)
  CONFIG  PWRTE = ON            // PWRT enabled (Power-up Timer Enable bit) (espera de 72 ms al iniciar)
  CONFIG  MCLRE = OFF           // El pin de MCL se utiliza como I/O
  CONFIG  CP = OFF              // Sin proteccion de codigo
  CONFIG  CPD = OFF             // Sin proteccion de datos
  
  CONFIG  BOREN = OFF           // Sin reinicio cunado el voltaje de alimentación baja de 4V
  CONFIG  IESO = OFF            // Reinicio sin cambio de reloj de interno a externo
  CONFIG  FCMEN = OFF           // Cambio de reloj externo a interno en caso de fallo
  CONFIG  LVP = ON              // programación en bajo voltaje permitida

; configuracion  2
  CONFIG  WRT = OFF             // Protección de autoescritura por el programa desactivada
  CONFIG  BOR4V = BOR40V        // Reinicio abajo de 4V, (BOR21V = 2.1V)
  
PSECT resVect, class=CODE, abs, delta=2
;----------------vector reset----------------
ORG 00h
resVect:
    PAGESEL main    //Cambio de página
    GOTO main
PSECT code, abs, delta=2
;----------------configuracion----------------
ORG 100h
main:
    BANKSEL ANSEL	// Direccionar al banco 11
    CLRF    ANSEL	// I/O digitales
    CLRF    ANSELH	// I/O digitales
    BANKSEL TRISA	// Direccionar al banco 01
    BSF	    TRISA, 0	// RA0 como entrada
    BSF	    TRISA, 1	// RA1 como entrada
    CLRF    TRISC
    BCF	    TRISD, 0
    BCF	    TRISD, 1
    BCF	    TRISD, 2
    BCF	    TRISD, 3
    BANKSEL PORTA	// Direccionar al banco 00
    CLRF    PORTA
    CLRF    PORTC
    CLRF    PORTD
    BANKSEL PORTA
    
CHECKBOTONS:
    BTFSC   PORTA, 0	// Analiza RA0 si esta presionado (si no está presionado salta una linea) 
    CALL    SUMACONT1   // Si está presionado pasa a sumar a cont1
    BTFSC   PORTA, 1	// Analiza RA1 si esta presionado (si no está presionado salta una linea)
    CALL    RESTACONT1  // Sí está presionado pasa a restar a cont1
    GOTO    CHECKBOTONS // Si no están presionados regresa a revisar

SUMACONT1:
    BTFSC   PORTA, 0	// Analiza RA0 si no está presionado salta una linea
    GOTO    $-1		// Se mantiene en bucle hasta que se deje de presionar
    INCF    PORTD	// Incremento en 1 en el contador
    MOVF    PORTD, W	// Valor del contador a W para que lo busque en la table
    CALL    TABLA	// Se busca caracter de CONT en la tabla ASCII
    MOVWF   PORTC	// Se guarda el caracter de CONT en ASCII
    
    RETURN    
    
RESTACONT1:
    BTFSC   PORTA, 1	// Analiza RA1 si no está presionado salta una linea
    GOTO    $-1		// Se mantiene en bucle hasta que se deje de presionar
    DECF    PORTD	// Disminuye en 1 en el contador
    MOVF    PORTD, W	// Valor del contador a W para que lo busque en la table
    CALL    TABLA	// Se busca caracter de CONT en la tabla ASCII
    MOVWF   PORTC	// Se guarda el caracter de CONT en ASCII
    RETURN
    
ORG 200h
TABLA:
    CLRF    PCLATH	// Se limpia el registro PCLATH
    BSF	    PCLATH, 1	
    ANDLW   0x0F	// Solo deja pasar valores menores a 16
    ADDWF   PCL		// Se añade al PC el caracter en ASCII del contador
    RETLW   00111111B	// Return que devuelve una literal a la vez 0
    RETLW   00000110B	// Return que devuelve una literal a la vez 1
    RETLW   01011011B	// Return que devuelve una literal a la vez 2
    RETLW   01001111B	// Return que devuelve una literal a la vez 3
    RETLW   01100110B	// Return que devuelve una literal a la vez 4
    RETLW   01101101B	// Return que devuelve una literal a la vez 5
    RETLW   01111101B	// Return que devuelve una literal a la vez 6
    RETLW   00000111B	// Return que devuelve una literal a la vez 7
    RETLW   01111111B	// Return que devuelve una literal a la vez 8
    RETLW   01101111B	// Return que devuelve una literal a la vez 9
    RETLW   01110111B	// Return que devuelve una literal a la vez A
    RETLW   01111100B	// Return que devuelve una literal a la vez b
    RETLW   00111001B	// Return que devuelve una literal a la vez C
    RETLW   01011110B	// Return que devuelve una literal a la vez d
    RETLW   01111001B	// Return que devuelve una literal a la vez E
    RETLW   01110001B	// Return que devuelve una literal a la vez F   
END