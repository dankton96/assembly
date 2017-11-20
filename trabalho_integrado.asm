;**************  - PROGRAMA SEMÁFORO *****************
;Aluno Jãozinho:			Matricula: 123454321
;#############################################################################
LIST   P=PIC16F628A
#INCLUDE <P16F628A.INC>
	__CONFIG _INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_ON & _BODEN_OFF & _LVP_OFF & _CP_OFF & _MCLRE_OFF & _DATA_CP_OFF 
	;ou __CONFIG H'3F10'

CBLOCK		0x20						;ENDEREÇO INICIAL DA MEMÓRIA DE USUÁRIO

	CONTADOR1
	CONTADOR2
	CONTADOR3
	CONTADOR4
	CONTADOR5
  
  	CONTADOR3_SEG
  	CONTADOR4_SEG
  	CONTADOR7_SEG
  
	ENDC							  ;FIM DO BLOCO DE MEMÓRIA		
;######################################################################################
	#DEFINE	BANK0	BCF STATUS,RP0	  ;SETA BANK 0 DE MEMÓRIA
	#DEFINE	BANK1	BSF STATUS,RP0	  ;SETA BANK 1 DE MEMÓRIA
;######################################################################################
	#DEFINE	BOTAO		PORTA,2		  ;BOTAO QUE SOLICITA TRAVESSIA DE PEDESTRE
	#DEFINE	S1RED 		PORTB,0		  ;LUZ VERMELHA DO SINAL1
	#DEFINE S1YELLOW 	PORTB,1		  ;LUZ AMARELA DO SINAL1
	#DEFINE S1GREEN		PORTB,2		  ;LUZ VERDE DO SINAL1
	#DEFINE	S2RED 		PORTB,3		  ;LUZ VERMELHA DO SINAL2
	#DEFINE S2YELLOW 	PORTB,4		  ;LUZ AMARELA DO SINAL2
	#DEFINE S2GREEN 	PORTB,5		  ;LUZ VERDE DO SINAL2
    #DEFINE VERIFICA	PORTA,3		  ;VARIAVEL QUE INFORMA A SITUACAO DO SEMAFORO

	ORG	0x00						  ;ENDEREÇO INICIAL DE PROCESSAMENTO
;######################################################################################
	CLRF		PORTA                 ;Limpa o portA
	CLRF		PORTB				  ;Limpa o portB
	MOVLW   	0x07                  ;7 desabilita os comparadores (ver datasheet)
	MOVWF   	CMCON              	  ;Escreve o Valor 7 no reg. CMCON
	BCF        	STATUS, RP1
	BSF        	STATUS, RP0
    
;######################################################################################
	GOTO	INICIO
;######################################################################################

INICIO
	BANK1			                 ;ALTERA PARA O BANCO 1	
	MOVLW	B'00000100'
	MOVWF	TRISA		             ;DEFINE RA2 COMO ENTRADA E DEMAIS COMO SAÍDAS
	MOVLW	B'00000000'
	MOVWF	TRISB		             ;DEFINE TODO O PORTB COMO SAÍDA
	MOVLW	B'00000000'
	MOVWF	INTCON		             ;TODAS AS INTERRUPÇÕES DESLIGADAS
	BANK0			                 ;RETORNA PARA O BANCO 0
	MOVLW	B'00000111'
	MOVWF	CMCON		             ;DEFINE O MODO DO COMPARADOR ANALÓGICO
    
CICLO
	CALL		ESTADOS_MAQUINAS
	GOTO 		CICLO

;################################################## ATRASO 1 SEGUNDO ##################################################################
ATRASO				
	MOVLW	0x31
	MOVWF	CONTADOR1               ;CONTADOR1 = 3
    MOVLW	0x1C
	MOVWF	CONTADOR2               ;CONTADOR2 = 27
    MOVLW	0xEB
	MOVWF	CONTADOR3               ;CONTADOR3 = 255
    CALL ATRASO2
;2d 2E
ATRASO1				
  CALL    ATRASO2					;CHAMA A FUNÇÃO ATRASO2
  NOP
  NOP
  NOP   
  NOP                                 
  DECFSZ CONTADOR1                 ;DECREMENTA O CONTADOR1
  GOTO 	 ATRASO1	               ;ENQUANTO CONTADOR1 != 0 CHAMA A FUNÇAO ATRASO 1 
					
  RETURN	                       ;SE ATRASO1 == 0 RETORNA 
ATRASO2				
  CALL    ATRASO3                  ;CHAMA A FUNÇÃO ATRASO3
  DECFSZ  CONTADOR2                ;DECREMENTA O CONTADOR2
  GOTO	  ATRASO2                  ;ENQUANTO CONTADOR2 != 0 CHAMA A FUNÇAO ATRASO 2
    
  CALL BOTAO_PRES
  MOVLW	0x1C
  MOVWF	CONTADOR2
  RETURN			  ;RETORNA
ATRASO3	
  DECFSZ CONTADOR3	  ;DECREMENTA CONTADOR3 
  GOTO   ATRASO3      ;CHAMA A FUNÇÃO ATRASO3
  
  MOVLW	0xEB
  MOVWF	CONTADOR3
  RETURN	          ;RETORNA
;################################################## ATRASO 3 SEGUNDOS #####################################################################
ATRASO_3_SEG    
    MOVLW	3
	MOVWF	CONTADOR3_SEG
ATRASO_3
    CALL ATRASO             ;CHAMA A FUNÇÃO QUE FAZ 1 SEG
	DECFSZ	CONTADOR3_SEG   ;DECREMENTA O CONTADOR7_SEG
    GOTO	ATRASO_3        ;SE CONTADOR != 0 CHAMA A PROPRIA FUNÇÃO 

    RETURN
;################################################## ATRASO 4 SEGUNDOS #####################################################################
ATRASO_4_SEG    
    MOVLW	4
	MOVWF	CONTADOR4_SEG
ATRASO_4
    CALL ATRASO             ;CHAMA A FUNÇÃO QUE FAZ 1 SEG
	DECFSZ	CONTADOR4_SEG   ;DECREMENTA O CONTADOR7_SEG
    GOTO	ATRASO_4        ;SE CONTADOR != 0 CHAMA A PROPRIA FUNÇÃO 
  
    RETURN
;################################################# ATRASO 7 SEGUNDOS #######################################################################
ATRASO_7_SEG    
    MOVLW	7
	MOVWF	CONTADOR7_SEG
ATRASO_7
    CALL ATRASO            ;CHAMA A FUNÇÃO QUE FAZ 1 SEG
	DECFSZ	CONTADOR7_SEG   ;DECREMENTA O CONTADOR7_SEG
    GOTO	ATRASO_7        ;SE CONTADOR != 0 CHAMA A PROPRIA FUNÇÃO 

    RETURN
;##############################################################################################################################################
BOTAO_PRES
	BTFSS	BOTAO			 		;O BOTÃO ESTÁ PRESSIONADO?
	RETURN				       		;NAO, ESPERA SER PRESSIONADO
	GOTO	BOTAO_PRES1				;SIM, ENTÃO TRATA BOTÃO PRESSIONADO

BOTAO_PRES1
	;BTFSC	BOTAO			        ;O BOTÃO AINDA ESTÁ PRESSIONADO?
    ;GOTO	BOTAO_PRES1		        ;SIM, ENTÃO ESPERA DESLIGAR
    BTFSC	VERIFICA        	    ;O SINAL 1 ESTÁ VERMELHO?
	GOTO	RETORNO_BOTAO_VERMELHO	;SIM, REINICIA VERMELHO
	GOTO	ESTADOS_MAQUINAS_2	    ;NAO, COMECA AMARELO
;###############################################################################################################################################
;	FLUXO MAIOR(S1):
;	7SEGS VERDE, 3SEGS AMARELO, 4SEGS VERMELHO
;	FLUXO MENOR(S2):
;	10SEGS VERMELHO, 2AMARELO, 2SEGS VERDE

; É PARA TER RETURN
ESTADOS_MAQUINAS
		
        BSF VERIFICA
    	
	;#10SEG		S1: RED -> GREEN (7) -> YELLOW (3)	/	S2: YELLOW -> RED (10)
		BCF S1RED 		;APAGA
		BCF S2YELLOW 	;APAGA

		BSF S1GREEN 	;7 SEG
		BSF S2RED
		CALL ATRASO_7_SEG

RETORNO_DE_ESTADOS_2
		BCF S1GREEN 	;APAGA		
		BSF S1YELLOW 	;3 SEG
		CALL ATRASO_3_SEG

	;#4SEG(2+2)		S1: YELLOW -> RED (4)	/ S2 RED -> GREEN (2) -> YELLOW (2)
    	BCF S1YELLOW 	;APAGA
		BCF S2RED 	 	;APAGA
		
        BCF VERIFICA
		BSF S1RED    	;4 SEG
		BSF	S2GREEN 	;2 SEG
		CALL ATRASO
        CALL ATRASO
				
		BCF S2GREEN 	;APAGA
		BSF S2YELLOW  	;2 SEG
		CALL ATRASO
        CALL ATRASO
	
	RETURN
;##########################################################
;###############################################################################################################################################
;	FLUXO MAIOR(S1):
;	7 SEGS VERMELHO, 3 SEGS AMARELO, 4 SEGS VERDE
;	FLUXO MENOR(S2):
;	4 SEGS VERDE, 3 SEGS AMARELO, 7 SEGS VERMELHO

; NAO É PARA TER RETURN
ESTADOS_MAQUINAS_2
		
    BSF VERIFICA
    	
	;#7SEG		S1: GREEN -> YELLOW (3) -> RED (7)	/	S2: RED -> GREEN (4)
		BCF S1GREEN 	;APAGA

		BSF S1YELLOW 	;3 SEG
		
        CALL ATRASO_3_SEG

RETORNO_BOTAO_VERMELHO
	 	BCF S2RED		;APAGA
		BCF S1YELLOW 	;APAGA
		BCF S2YELLOW	
		BCF VERIFICA
		BSF S1RED 		;4+3 SEG
        BSF S2GREEN		;4 SEG
		
		CALL ATRASO_4_SEG

	;#7SEG		S1: RED -> GREEN (4)	/	S2: GREEN -> YELLOW (3) -> RED (7)
    	
        BCF S2GREEN		;APAGA
        
        BSF S2YELLOW	;3 SEG
        
        CALL ATRASO_3_SEG
        
        BCF S2YELLOW 	;APAGA
		BSF VERIFICA
		BCF S1RED 	 	;APAGA
        
        BSF S2RED		;4 SEG
        BSF S1GREEN		;4 SEG

		CALL ATRASO_4_SEG
      	
   GOTO RETORNO_DE_ESTADOS_2

;##########################################################
END
