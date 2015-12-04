(require racket/tcp)
;PROTOCOLOS DE JUEGO
(define NEWGAME "NEWGAME")	;NUEVO JUEGO
(define ESPERA "Esperando segundo jugador...")
(define READY "LISTO!")		;RESPUESTA AL ESTAR CONECTADOS AMBOS JUGADORES
(define COORDX 0) ;COORDENADA X DEL TIRO RECIBIDA POR EL JUGADOR PARA ATACAR AL OPONENTE
(define COORDY 0) ;COORDENADA Y DEL TIRO RECIBIDA POR EL JUGADOR PARA ATACAR AL OPONENTE
(define ACCEPTX "COORDENADA X RECIBIDA") ;RESPUESTA A LOS JUGADORES QUE LA COORDENADA X SE HA RECIBIDO
(define ACCEPTY "COORDENADA Y RECIBIDA") ;RESPUESTA A LOS JUGADORES QUE LA COORDENADA Y SE HA RECIBIDO
(define ATAQUER "ATAQUE REALIZADO") ;RESPUESTA A LOS JUGADORES QUE EL ATAQUE SE HA REALIZADO EXITOSAMENTE
(define COORDXO 0) ;COORDENADA X DEL TIRO RECIBIDA POR EL OPONENTE PARA ATACAR AL JUGADOR
(define COORDYO 0) ;COORDENADA Y DEL TIRO RECIBIDA POR EL OPONENTE PARA ATACAR AL JUGADOR
;*******************
;CONEXION Y LECTURA DE LAS CONEXIONES DE LOS DOS JUGADORES CLIENTES
(define listener (tcp-listen 2005))
;VALUES LEER (INPUT-PORT) Y ENVIAR (OUTPUT-PORT) PARA PRIMER JUGADOR
(define-values (leer enviar) (tcp-accept listener))
;VALUES LEER2 (INPUT-PORT) Y ENVIAR2 (OUTPUT-PORT) PARA SEGUNDO JUGADOR
(define-values (leer2 enviar2) (tcp-accept listener))
;FUNCION SERVER QUE POSEE LOS PROCEDIMIENTOS Y FUNCIONES PARA LA INTERACCION ENTRE AMBOS JUGADORES
;REALIZAR Y RECIBIR ATAQUES
(define (server)
	(define (cicloX)
		;COORDENADA X RECIBIDA POR EL JUGADOR
		(set! COORDX (read leer))
		(display "COORDENADA X: ") (display COORDX) (newline)
		;RESPUESTA DEL SERVIDOR AL JUGADOR DE COORDENADA X RECIBIDA
		(write ACCEPTX enviar)
		(newline enviar)
		(flush-output enviar)
		;SALTO AL cicloY
		(cicloY)
	)
	;(define JX1 (thread cicloX))
	(define (cicloY)
		;COORDENADA Y RECIBIDA POR EL JUGADOR
		(set! COORDY (read leer))
		(display "COORDENADA Y: ") (display COORDY) (newline)
		;RESPUESTA DEL SERVIDOR AL JUGADOR DE COORDENADA Y RECIBIDA
		(write ACCEPTY enviar)
		(newline enviar)
		(flush-output enviar)
		;SALTO AL cicloIN
		(cicloIN)
	)
	;(define JY1 (thread cicloY))
	(define (cicloIN)
		;MENSAJE RECIBIDO DEL JUGADOR PARA REALIZAR EL ATAQUE
		(display (read leer))
		(newline)
		;COORDENADA X ENVIADA AL JUGADOR OPONENTE
		(write COORDX enviar2)
		(newline enviar2)
		(flush-output enviar2)
		;SALTO AL cicloXA
		(cicloXA)
	)
	;(define JX2 (thread cicloX2))
	(define (cicloXA)
		;MENSAJE DEL JUGADOR OPONENTE QUE EL ATAQUE EN X HA SIDO RECIBIDO
		(display (read leer2))
		(newline)
		;COORDENADA Y ENVIADA AL JUGADOR OPONENTE
		(write COORDY enviar2)
		(newline enviar2)
		(flush-output enviar2)
		;SALTO AL cicloYA
		(cicloYA)
	)
	;(define JY2 (thread cicloY2))
	(define (cicloYA)
		;MENSAJE DEL JUGADOR OPONENTE QUE EL ATAQUE EN Y HA SIDO RECIBIDO
		(display (read leer2))
		(newline)
		;MENSAJE ENVIADO AL JUGADOR QUE EL ATAQUE SE HA REALIZADO
		(write ATAQUER enviar)
		(newline enviar)
		(flush-output enviar)
		;SALTO AL cicloXO
		(cicloXO)
	)
	(define (cicloXO)
		;COORDENADA X RECIBIDA POR EL OPONENTE
		(set! COORDXO (read leer2))
		(display "COORDENADA X OPONENTE: ") (display COORDXO) (newline)
		;RESPUESTA DEL SERVIDOR AL OPONENTE DE COORDENADA X RECIBIDA
		(write ACCEPTX enviar2)
		(newline enviar2)
		(flush-output enviar2)
		;SALTO AL cicloYO
		(cicloYO)
	)
	(define (cicloYO)
		;COORDENADA Y RECIBIDA POR EL OPONENTE
		(set! COORDYO (read leer2))
		(display "COORDENADA Y OPONENTE: ") (display COORDYO) (newline)
		;RESPUESTA DEL SERVIDOR AL OPONENTE DE COORDENADA Y RECIBIDA
		(write ACCEPTY enviar2)
		(newline enviar2)
		(flush-output enviar2)
		;SALTO AL cicloINO
		(cicloINO)
	)
	(define (cicloINO)
		;MENSAJE RECIBIDO DEL OPONENTE PARA REALIZAR EL ATAQUE
		(display (read leer2))
		(newline)
		;COORDENADA X ENVIADA AL JUGADOR
		(write COORDXO enviar)
		(newline enviar)
		(flush-output enviar)
		;SALTO AL cicloXOA
		(cicloXOA)
	)
	(define (cicloXOA)
		;MENSAJE DEL JUGADOR QUE EL ATAQUE EN X HA SIDO RECIBIDO
		(display (read leer))
		(newline)
		;COORDENADA Y ENVIADA AL JUGADOR
		(write COORDYO enviar)
		(newline enviar)
		(flush-output enviar)
		;SALTO AL cicloYOA
		(cicloYOA)
	)
	(define (cicloYOA)
		;MENSAJE DEL JUGADOR QUE EL ATAQUE EN Y HA SIDO RECIBIDO
		(display (read leer))
		(newline)
		;MENSAJE ENVIADO AL JUGADOR OPONENTE QUE EL ATAQUE SE HA REALIZADO
		(write ATAQUER enviar2)
		(newline enviar2)
		(flush-output enviar2)
		;SALTO AL cicloX
		(cicloX)
	)
	;FUNCI{ON QUE RECIBE EL NOMBRE Y SOLICITUD DE JUEGO DEL SEGUNDO JUGADOR
	(define (loading2)
		(define msg (read leer2))
		(display (string-append "JUGADOR " msg " CONECTADO"))
		(newline)
		;MENSAJE QUE ENVIA EL SERVIDOR AL JUGADOR PARA INDICARLE AMBOS ESTAN CONECTADOS
		(write "AMBOS JUGADORES CONECTADOS" enviar2)
		(newline enviar2)
		(flush-output enviar2)
		(define con (read leer2))
		;AL CUMPLIRSE LA CONDICION DE NUEVO JUEGO RECIBIDA POR EL JUGADOR PROCEDE A
		;AVISARLE A AMBOS JUGADORES
		(if (equal? con NEWGAME)
			(begin
				;RESPUESTA DEL SERVIDOR AL PRIMER JUGADOR QUE PUEDEN EMPEZAR EL JUEGO
				(write READY enviar)
				(newline enviar)
				(flush-output enviar)
				;RESPUESTA DEL SERVIDOR AL SEGUNDO JUGADOR QUE PUEDEN EMPEZAR EL JUEGO
				(write READY enviar2)
				(newline enviar2)
				(flush-output enviar2)
				;SALTO AL CICLO QUE PERMITE EMPEZAR A HACER LOS ATAQUES ENTRE JUGADORES
				(cicloX)
			)
		)
	)
	;FUNCION QUE RECIBE EL NOMBRE Y SOLICITUD DE JUEGO DEL PRIMER JUGADOR
	(define (loading1)
		(define msg (read leer))
		(display (string-append "JUGADOR " msg " CONECTADO"))
		(newline)
		;MENSAJE QUE ENVIA EL SERVIDOR AL JUGADOR PARA INDICARLE LA ESPERA DE OTRO JUGADOR
		(write ESPERA enviar) (newline enviar)
		(flush-output enviar)
		(define con (read leer))
		(if (equal? con NEWGAME)
			(loading2)
		)
	)
	;CARGAR PROCEDIMIENTE LOADING1 PARA RECIBIR LOS DATOS DEL PRIMER JUGADOR
	(loading1)
	(close-input-port leer)
	(close-output-port enviar)
	(close-input-port leer2)
	(close-output-port enviar2)
)
;LLAMADA AL SERVIDOR
(server)