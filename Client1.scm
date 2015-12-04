;INICIALIZAR LIBRERIA DE GRAFICOS
(require graphics/graphics)
;INICIALIZAR LIBRERIA DE RED
(require racket/tcp)
;ABRIR GRAFICOS
(open-graphics)
;MATRIZ INTERNA DEL JUGADOR
(define vec (make-vector 10))
(do ((row 0 (+ row 1)))
  ((= row 10))
  (vector-set! vec row (make-vector 10))
)
;PROTOCOLOS DE JUEGO
(define NEWGAME "NEWGAME")	;NUEVO JUEGO
(define READY "LISTO!")		;RESPUESTA AL ESTAR CONECTADOS AMBOS JUGADORES
(define COORDX 0) ;COORDENADA X DEL TIRO
(define COORDY 0) ;COORDENADA Y DEL TIRO
(define ATAQUE "LANZAR ATAQUE") ;MENSAJE AL SERVIDOR PARA DARLE LA INDICACIÓN QUE PUEDE REALIZAR EL ATAQUE
(define COORDXA 0) ;COORDENADA DE ATAQUE EN X QUE SERÁ RECIBIDA POR MEDIO DEL SERVIDOR 
(define COORDYA 0) ;COORDENADA DE ATAQUE EN Y QUE SERÁ RECIBIDA POR MEDIO DEL SERVIDOR 
(define ATACADOX "ATAQUE X RECIBIDO") ;MENSAJE ENVIADO AL SERVIDOR CONFIRMANDO QUE EL ATAQUE EN X SE HA RECIBIDO
(define ATACADOY "ATAQUE Y RECIBIDO") ;MENSAJE ENVIADO AL SERVIDOR CONFIRMANDO QUE EL ATAQUE EN Y SE HA RECIBIDO
;*******************
;VARIABLES GLOBALES QUE LUEGO CAMBIARÁN SU VALOR POR LAS COORDENADAS 'X' Y 'Y' DEL EVENTO MOUSE-CLICK
(define posx 0)
(define posy 0)
;VARIABLES QUE OBTEDRÁN EL VALOR DE LAS COORDENADAS 'X' Y 'Y' CON LAS CUALES ESTA ATACANDO EL OTRO JUGADOR
(define pposx 0)
(define pposy 0)
;VARIABLE GLOBAL PARA ALMACENAR EL NOMBRE DEL JUGADOR
(define player "")
;VARIABLE GLOBAL QUE CONTENDRÁ EL VALOR DE LA IP DEL SERVIDOR
(define ip "")
;VARIABLE PARA AVISARLE AL JUGADOR QUE HA PERDIDO
(define lost 0)
;FUNCIÓN PRINCIPAL DEL PROGRAMA, DENTRO DE ELLA ESTÁN CONTENIDAS TODAS LAS DEMÁS FUNCIONES QUE HARÁN USO DEL PROGRAMA
(define (client)
	(define (construir)
	;DEFINICION DE LA VENTANA PRINCIPAL
	(define win (open-viewport "Battleship" 900 600))
	((draw-viewport win) (make-rgb 0 0 0))
	;CUADRICULADO DEL JUGADOR
	;CICLO QUE GENERA LAS LINEAS VERTICALES
	(do
		((cont 50 (+ cont 35)))
		((= cont  435))
		((draw-line win) (make-posn cont 50) (make-posn cont 400) "white")
	)
	((draw-line win) (make-posn 450 0) (make-posn 450 450) "yellow")
	((draw-line win) (make-posn 0 450) (make-posn 900 450) "yellow")
	;CICLO QUE GENERA LAS LINEAS HORIZONTALES
	(do
		((cont 50 (+ cont 35)))
		((= cont 435))
		((draw-line win) (make-posn 50 cont) (make-posn 400 cont) "white")
	)
	;CUADRICULADO DEL OPONENTE
	;CICLO QUE GENERA LAS LINEAS VERTICALES
	(do
		((cont 500 (+ cont 35)))
		((= cont  885))
		((draw-line win) (make-posn cont 50) (make-posn cont 400) "white")
	)
	;CICLO QUE GENERA LAS LINEAS HORIZONTALES
	(do
		((cont 50 (+ cont 35)))
		((= cont 435))
		((draw-line win) (make-posn 500 cont) (make-posn 850 cont) "white")
	)
	;NUMERACION DE LAS COLUMNAS DE 1 - 10, TABLERO DEL JUGADOR
	(do
		((cont 1 (+ cont 1))
		(pos 65 (+ pos 35)))
		((= cont 10) ((draw-string win) (make-posn 375 40) "10" "white"))
		((draw-string win) (make-posn pos 40) (number->string cont) "white")
	)
	;CLASIFICACION DE LAS FILAS CON LETRAS DE LA A - J, TABLERO DEL JUGADOR
	((draw-string win) (make-posn 30 70) "A" "white")
	((draw-string win) (make-posn 30 105) "B" "white")
	((draw-string win) (make-posn 30 140) "C" "white")
	((draw-string win) (make-posn 30 175) "D" "white")
	((draw-string win) (make-posn 30 210) "E" "white")
	((draw-string win) (make-posn 30 245) "F" "white")
	((draw-string win) (make-posn 30 280) "G" "white")
	((draw-string win) (make-posn 30 315) "H" "white")
	((draw-string win) (make-posn 30 350) "I" "white")
	((draw-string win) (make-posn 30 385) "J" "white")
	;NUMERACION DE LAS COLUMNAS DE 1 - 10, TABLERO DEL OPONENTE
	(do
		((cont 1 (+ cont 1))
		(pos 515 (+ pos 35)))
		((= cont 10) ((draw-string win) (make-posn 825 40) "10" "white"))
		((draw-string win) (make-posn pos 40) (number->string cont) "white")
	)
	;CLASIFICACION DE LAS FILAS DE LA A - J, TABLERO DEL OPONENTE
	((draw-string win) (make-posn 480 70) "A" "white")
	((draw-string win) (make-posn 480 105) "B" "white")
	((draw-string win) (make-posn 480 140) "C" "white")
	((draw-string win) (make-posn 480 175) "D" "white")
	((draw-string win) (make-posn 480 210) "E" "white")
	((draw-string win) (make-posn 480 245) "F" "white")
	((draw-string win) (make-posn 480 280) "G" "white")
	((draw-string win) (make-posn 480 315) "H" "white")
	((draw-string win) (make-posn 480 350) "I" "white")
	((draw-string win) (make-posn 480 385) "J" "white")
	;DIBUJO DEL CHAT
	((draw-string win) (make-posn 20 470) "CHAT:" "red")
	(define chat ((draw-solid-rectangle win)(make-posn 15 480) 870 100 "yellow"))
	(print chat)
	(define chatcliente ((draw-solid-rectangle win)(make-posn 20 485) 430 90 "black"))
	(define servidor ((draw-solid-rectangle win)(make-posn 455 485) 425 90 "black"))
	(define enviar_bloke ((draw-solid-rectangle win)(make-posn 378 560) 61 15 "gray"))
	((draw-string win) (make-posn 380 573) "ENVIAR" "black")
	((draw-string win) (make-posn 23 500) "Ingrese su mensaje: " "white") 
	((draw-string win) (make-posn 460 500) "Servidor says..." "white")
	(newline)
	;SUBRUTINA PARA MARCAR LAS JUGADAS EN EL TABLERO
	(define (ataques)
		;VARIABLE DE COMPROBACION PARA FINALIZAR CICLO DO
		(define salir #f)
		;CLIC QUE ESTAR{A ESPRANDO EL JUEGO PARA PROCEDER A HACER LAS VERIFICACIONES}
		(define jugada (get-mouse-click win))
		;RECTANGULO DIBUJADO PARA BORRAR EL ULTIMO TEXTO DEL 5TO BARCO QUE SE INGRESO
		((draw-solid-rectangle win) (make-posn 50 410) 300 40 "black")
		;CAMBIO DE VALOR DE LAS VARIABLES GLOBALES PARA LAS COORDENADAS 'X' Y 'Y' DEL CLICK REALIZADO POR EL JUGADOR
		(set! posx (posn-x (mouse-click-posn jugada)))
		(set! posy (posn-y (mouse-click-posn jugada)))
		;CICLO QUE VERIFICA EL CLICK DEL JUGADOR PARA DEJAR MARCADO DICHA POSICION
		(do
			;VARIABLES QUE POSEEN EL RANGO EN EL QUE SE HACEN LOS CLICK'S PARA DIBUJAR CIRCULOS QUE INDICARÁN LAS POSICIONES
			;QUE VA MARCANDO EL JUGADOR
			((xpos posx)
			(ypos posy)
			(Cxpos 500 (+ Cxpos 35))
			(Cypos 50)
			(mposx 505 (+ mposx 35))
			(mposy 55)
			(modify 1 (+ modify 1)))
			;CONDICION FINAL PARA QUE FINALICE EL CICLO E INSTRUCCION A REALIZAR LUEGO DE TERMINADO DICHO CICLO
			((equal? salir #t) (ataques))
			;DE CUMPLIRSE DICHA OPERACION LOGICA DIBUJARA UN CIRCULO AZUL DONDE SE REALIZO EL CLICK
			(if (and (>= xpos Cxpos) (<= xpos (+ Cxpos 35)) (>= ypos Cypos) (<= ypos (+ Cypos 35)) (<= ypos 400))
				(begin
					;((draw-solid-ellipse win) (make-posn 400 400) 25 25 "red")
					((draw-solid-ellipse win) (make-posn mposx mposy) 25 25 "aqua")
					;MODIFICAR COORDENADA X CON LA POSICION X DEL MOUSE-CLICK Y ENVIAR LA COORDENADA AL SERVIDOR
					(set! COORDX posx)
					(write COORDX enviar) (newline)
					(newline enviar)
					(flush-output enviar)
					;RESPUESTA DEL SERVIDOR QUE LA COORDENADA X HA SIDO RECIBIDA
					(display (read leer))
					;MODIFICAR COORDENADA Y CON LA POSICION Y DEL MOUSE-CLICK Y ENVIAR LA COORDENADA AL SERVIDOR
					(set! COORDY posy)
					(write COORDY enviar) (newline)
					(newline enviar)
					(flush-output enviar)
					;RESPUESTA DEL SERVIDOR QUE LA COORDENADA Y HA SIDO RECIBIDA
					(display (read leer))
					(newline)
					;MANDAR AL SERVIDOR LA INSTRUCCION QUE PUEDE REALIZAR EL ATAQUE AL OTRO JUGADOR
					(write ATAQUE enviar)
					(newline enviar)
					(flush-output enviar)
					;RESPUESTA DEL SERVIDOR QUE EL ATAQUE SE HA REALIZADO
					(display (read leer))
					(newline)
					;COORDENADA DE ATAQUE X RECIBIDA DEL SERVIDOR, ATAQUE QUE HA REALIZADO EL JUGADOR OPONENTE
					(set! COORDXA (read leer))
					(display "GOLPE EN X: ")
					(display COORDXA)
					(newline)
					;RESPUESTA ENVIADA AL SERVIDOR QUE EL ATAQUE X SE HA RECIBIDO
					(write ATACADOX enviar)
					(newline enviar)
					(flush-output enviar)
					;COORDENADA DE ATAQUE Y RECIBIDA DEL SERVIDOR, ATAQUE QUE HA REALIZADO EL JUGADOR OPONENTE
					(set! COORDYA (read leer))
					(display "GOLPE EN Y: ")
					(display COORDYA)
					(newline)
					;RESPUESTA ENVIADA AL SERVIDOR QUE EL ATAQUE Y SE HA RECIBIDO
					(write ATACADOY enviar)
					(newline enviar)
					(flush-output enviar)
					(set! pposx COORDXA)
					(set! pposy COORDYA)
					(do
						;VARIABLES QUE POSEEN EL RANGO EN EL QUE SE HACEN LOS CLICK'S PARA DIBUJAR CIRCULOS QUE INDICARÁN LAS POSICIONES
						;QUE VA MARCANDO EL JUGADOR
						((xpos pposx)
						(ypos pposy)
						(Cxpos 500 (+ Cxpos 35))
						(Cypos 50)
						(mposx 505 (+ mposx 35))
						(mposy 55)
						(modify 1 (+ modify 1))
						;VARIABLES QUE CONTIENEN LAS FILAS Y COLUMNAS DE LA MATRIZ
						(px 1)
						(py 1 (+ py 1)))
						;CONDICION FINAL PARA QUE FINALICE EL CICLO E INSTRUCCION A REALIZAR LUEGO DE TERMINADO DICHO CICLO
						((equal? salir #t) (ataques))
						;DE CUMPLIRSE DICHA OPERACION LOGICA DIBUJARA UN CIRCULO AZUL DONDE SE REALIZO EL CLICK
						(if (and (>= xpos Cxpos) (<= xpos (+ Cxpos 35)) (>= ypos Cypos) (<= ypos (+ Cypos 35)) (<= ypos 400))
							;SI EL VALOR ENCONTRADO EN LA MATRIZ ES UNA "X" QUIERE DECIR QUE ESA POSICION ESTA OCUPADA POR LO 
							;TANTO DIBUJARA UN CIRCULO NEGRO, SI EN ESA POSICION DE LA MATRIZ NO HAY UNA "X" QUIERE DECIR QUE
							;ESTA VACIA Y DIBUJARA UN CIRCULO AQUA
							(if (equal? (vector-ref (vector-ref vec (- px 1))(- py 1)) "x")
								(begin
									((draw-solid-ellipse win) (make-posn (- mposx 450) mposy) 25 25 "black")
									(set! lost (+ lost 1))
									(if (= lost 17)
										;SI SE HA SIDO ATACADO 17 VECES QUE SON LA CANTIDAD DE POSICIONES QUE ABARCAN LOS 5 BARCOS
										;LE APARECERA UN MENSAJE AL JUGADOR QUE HA PERDIDO EL JUEGO
										((draw-string win) (make-posn 50 425) (string-append "HA PERDIDO!") "white")
										(set! salir #t)
									)
								)
								(begin
									((draw-solid-ellipse win) (make-posn (- mposx 450) mposy) 25 25 "aqua")
									(set! salir #t)
								)
							)
						)
						;CUANDO LA VARIABLE MODIFY SEA IGUAL A 10 SE CAMBIARA EL VALOR DE LAS SIGUIENTE VARIABLES CONTENIDAS DENTRO
						;DEL IF, LO QUE PERMITIRA QUE EL CICLO EMPIECE A BUSCAR EN LA SEGUNDA FILA, TERCERA FILA HASTA LLEGAR A LA 
						;FILA NUMERO 10, EN DADO CASO ENCUENTRE EL CLIC ANTES DE LLEGAR A DICHA FILA, ALLÍ FINALIZARÁ Y PROCEDERA
						;A REGRESAR AL INICIO DE LA FUNCIÓN, AL ENCONTRAR EL CLIC CORRECTO DIBUJARA EL CIRCULO EN LA POSICIÓN EN QUE
						;EL JUGADOR CONTRARIO HA ATACADO
						(if (= modify 10)
							(begin
								(set! Cxpos 465)
								(set! Cypos (+ Cypos 35))
								(set! mposx 470)
								(set! mposy (+ mposy 35))
								(set! modify 0)
								;SUMARLE UN VALOR A LAS FILAS PARA QUE PASE A LA FILA 2, 3, 4 HASTA LLEGAR A LA FILA 10
								(set! px (+ px 1))
								;REGRESAR EL VALOR DE COLUMNAS A 0, EN EL CICLO DO SE LE SUMARA UN VALOR 1 PARA QUE OBTENGA
								;ESE VALOR Y NUEVAMENTE EMPIEZA A COMPROBAR YA CON LA FILA CAMBIADA
								(set! py 0)
							)
						)
					)
				)
			)
			;AL LLEGAR LA VARIABLE MODIFY A VALOR DE 10 SE REALIZA UN CAMBIO DE VALOR A LAS RESPECTIVAS VARIABLES PARA QUE
			;EL CICLO PUEDA CONTINUAR COMPROBANDO LAS SIGUIENTES FILAS DEL TABLERO
			(if (= modify 10)
				(begin
					(set! Cxpos 465)
					(set! Cypos (+ Cypos 35))
					(set! mposx 470)
					(set! mposy (+ mposy 35))
					(set! modify 0)
				)
			)
		)	
	)
	;********************************************************************************
	;SUBRUTINA QUE MUESTRA MENSAJE DE QUE BARCO SE DE IR COLOCANDO
	(define (buskadorbarcos)
	;DEFINICION DE LAS VARIABLES A UTILIZAR EN EL CICLO DE LOS BARCOS
    (define contx 50)
    (define contxn 0)
    (define conta 35)
    (define conty 50)
    (define contyn 0)
    (define cont 0)
    (define cliks 0)
	;SUBRRUTINA PARA PODER MANDAR  A LLAMAR SIN REINICIAR ALGUNAS DE LAS DEFINICIONES A SU VALOR INICIAL
	(define (ciclo)
	    (define jugada (get-mouse-click win))
	    (set! cliks (+ 1 cliks))
	    ((draw-solid-rectangle win) (make-posn 50 410) 300 40 "black")
	    (define posx (posn-x (mouse-click-posn jugada)))
	    (define posy (posn-y (mouse-click-posn jugada)))
		(define (ciclo1)
		    (if (> posx contx)
		        (begin
		            (set! contx (+ 35 contx))
		            (set! contxn (+ 1 contxn))
		            (ciclo1)
		        )
		    )
		    (if (> posy conty)
		      	(begin
		        	(set! conty (+ 35 conty))
		            (set! contyn (+ 1 contyn))
		            (ciclo1)
		        )
		    )
			(define (buska)                
				(if (and (> posx 50)(< posx 400)(> posy 50)(< posy 400))
			        (begin                                                                
			            (if (and (>= posx contx)(<= posx (+ contx 35)))
			          		(begin
			                    (set! contx (+ 35 contx))
			              		(set! contxn (+ 1 contxn))
			              	)
			                (begin
			                    (set! contx (- contx 35))
			               		(set! contxn (- contxn 1))
			                    (buska)
			                )
			          	)                                            
			        	(if (and(>= posy conty)(<= posy (+ conty 35)))
			         		(begin
			                   	(set! conty (+ 35 conty))
			              		(set! contyn (+ 1 contyn))
			              	)
			                (begin
			            		(set! conty (- conty 35))
			                	(set! contyn (- contyn 1))
			                  	(buska)
			                )
			            )
			        )
			        (ciclo)
			    )
			    (newline)
			    (if (equal?(vector-ref (vector-ref vec (- contyn 1))(- contxn 1)) "x")
			        (begin
			            (set! cliks (- cliks 1))
			            ((draw-solid-rectangle win) (make-posn 50 410) 300 40 "black")
			            ((draw-string win) (make-posn 50 425) "YA EXISTE BARCO EN ESTA POCISION" "white")
			            (ciclo)
			        )
			        (begin
			        	(vector-set! (vector-ref vec (- contyn 1)) (- contxn 1) "x")                           
			            (if (<= cliks 17)
			                (if (<= cliks 2)
			                	(begin
			                        ((draw-solid-rectangle win) (make-posn (+ 51 (* 35 (- contxn 1))) (+ 51 (* 35 (- contyn 1)))) 34 34 "red")
			                        ((draw-string win) (make-posn 50 425) (string-append "UBICAR BARCO 1 DE 2 POSICIONES") "white")
			                    )
			               		(if (and (>= cliks 3)(<= cliks 5))
			               		    (begin
			                       	    ((draw-solid-rectangle win) (make-posn 50 410) 300 40 "black")
			                        	((draw-string win) (make-posn 50 425) (string-append "UBICAR BARCO 2 DE 3 POSICIONES") "white")
			                            ((draw-solid-rectangle win) (make-posn (+ 51 (* 35 (- contxn 1))) (+ 51 (* 35 (- contyn 1)))) 34 34 "red")
			                       	)
			                        (if (and (>= cliks 6)(<= cliks 8))
			                       	    (begin
			                                ((draw-solid-rectangle win) (make-posn 50 410) 300 40 "black")
			                               	((draw-string win) (make-posn 50 425) (string-append "UBICAR BARCO 3 DE 3 POSICIONES") "white")
			                                ((draw-solid-rectangle win) (make-posn (+ 51 (* 35 (- contxn 1))) (+ 51 (* 35 (- contyn 1)))) 34 34 "red")
			                            )
			                            (if (and (>= cliks 9)(<= cliks 12))
			                                (begin
			                                  	((draw-solid-rectangle win) (make-posn 50 410) 300 40 "black")
			                                  	((draw-string win) (make-posn 50 425) (string-append "UBICAR BARCO 4 DE 4 POSICIONES") "white")
			                                   	((draw-solid-rectangle win) (make-posn (+ 51 (* 35 (- contxn 1))) (+ 51 (* 35 (- contyn 1)))) 34 34 "red")
			                                )
			                                (if (and (>= cliks 13)(<= cliks 17))
			                                	(begin
			                           	     		((draw-solid-rectangle win) (make-posn 50 410) 300 40 "black")
			                                 		((draw-string win) (make-posn 50 425) (string-append "UBICAR BARCO 5 DE 5 POSICIONES") "white")
			                        	      		((draw-solid-rectangle win) (make-posn (+ 51 (* 35 (- contxn 1))) (+ 51 (* 35 (- contyn 1)))) 34 34 "red")
			                                   	)
			                              	)
			                            )
			                        )
			                    )
			                )
			                (ataques)
			            )
			            ;(display vec)(newline)
			            ;(display cliks)(newline)
				        ;(display contxn)(display ",")
				        ;(display contyn)(newline)
				        ;(display contx)(newline)
				        ;(display conty)(newline)
			            (ciclo)
			        )
			    )                        
			)
			(buska)
		)
		(ciclo1)
	)
	(ciclo)
	) 
	(buskadorbarcos)
	)
	;SOLICITUD DEL NOMBRE DEL JUGADOR
	(display "NOMBRE JUGADOR: ")
	(set! player (read-line))
	(display "CONECTARSE AL SERVIDOR: ") (newline)
	(display "INGRESE DIRECCION IP: ")
	;DIRECCIÓN IP QUE SE USARÁ PARA CONECTARSE AL SERVIDOR
	(set! ip (read-line))
	;VALUES LEER (INPUT-PORT) Y ENVIAR (OUTPUT-PORT) CONECTANDOSE AL PURTO 
	(define-values (leer enviar) (tcp-connect ip 2005))
	(newline)
	;ENVIO DEL NOMBRE DEL JUGADOR AL SERVIDOR
	(write player enviar)
	(newline enviar)
	(flush-output enviar)
	(display "Esperando segundo jugador...")
	;RESPUESTA DEL SERVIDOR DICIENDOLE AL JUGADOR QUE AUN HACE FALTA  QUE UN JUGADOR SE CONECTE
	(display (read leer))
	;MENSAJE ENVIADO AL SERVIDOR PARA SOLICITAR UN NUEVO JUEGO
	(write NEWGAME enviar)
	(newline enviar)
	(flush-output enviar)
	;RESPUESTA DEL SERVIDOR PARA PODER INICIAR A JUGAR
	(define con (read leer)) (newline)
	;COMPARACION DE LA RESPUESTA DEL SERVIDOR CON EL PROTOCOLO DE INICIO DEL CLIENTE, 
	;AL SER IGUALES AMBAS INSTRUCCIONES SE PROCEDE A LA CONSTRUCCION DEL TABLERO
	(if (equal? con READY)
		(begin
			(display con)
			(construir)
		)
	)
)
(client)