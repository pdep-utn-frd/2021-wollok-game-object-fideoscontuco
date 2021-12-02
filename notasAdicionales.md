Notas adicionales

##Respecto al problema de rendimiento al tener muchos zombies sueltos.

El juego se relentizaba cuando muchos zombies consultaban al tablero hacia donde deberia ser su siguiente paso.
 
el tablero respondia el siguiente grid menos lejos de la casa ( direccion hacia donde ir)
mediante grillasDisponibles.min{ grilla => grilla.distance(self.parteDeCasaMasCercana())} 


 - Manera de conocer la posicion mas cercana:

Problema:
Se utilizaba 
method distance(position) {
    self.checkNotNull(position, "distance")
    const deltaX = x - position.x()
    const deltaY = y - position.y()
    return (deltaX.square() + deltaY.square()).squareRoot() 
}

Para conocer la distancia al ser consultada en cada paso (12 consultas/3 seg).
Pero esta operacion resulta costosa por sqrt, ademas no nos es importante conocer la distancia con exactitud.


Se prefirio utilizar en su lugar distancia manhattan:
method distanciaABarato(pos1, pos2) {
		var deltaX = pos1.x() - pos2.x()
		var deltaY = pos1.y() - pos2.y()
		return deltaX.abs() + deltaY.abs()
}
 
https://bloggity.odatnurd.net/gamedev-math/manhattan/
  

 - Respecto a encontrar la parte de la casa hacia donde el zombie se dirige:

self.parteDeCasaMasCercana() devolvia mediante distance() la parte de casa mas cercana al zombie.
(la casa ocupa 4 grids)

Problemas: 
 - Esta funcion era ejecutada cada vez que tablero buscaba la pos siguiente disponible
 - utilizaba mensaje distance()

Se utilizo distanciaAMasBarata() para encontrar pos, y 
Se delego al zombie conocer su direccion al regresar al mapa - y no calcular en cada paso la parte de la casa con menor distancia

 - Aumentar el tiempo de demora entre pasos de los zombies
Por debajo de 3000ms entre cada paso la cosa se pone fea.


 - Soluciones que podrian haber ayudado pero no fueron la gran cosa:

Si un zombie comienza su trayecto desde el costado derecho inferior ej (10,0), es probable que no necesite tener en cuenta
en cada paso el grid que esta a su izquierda o debajo,  salvo que busque escapar.
Se utiliza metodo que toma en que cuadrante esta el zombie, y devuelve la lista de posiciones posibles a moverse, reduciendo
los posibles grids de 4 a 2. 
- se crea una lista reducida de grids posibles segun cuadrante de zombie
- se encuentra de esa lista reducida el mas cercano a la casa.

Lamentablemente volvia a los zombies algo simplones a la hora de elegir su camino,
y no mostro beneficios que justifiquen su perdida de juicio.




##Personaje comienza a trabarse luego de  moverse a los 10-15 minutos
asignar teclas para moverse mediante setter self.position().up(n)  
ej:
  keyboard.up().onPressDo({ self.moverse(self.position().up(1))})

mas informacion:
https://github.com/uqbar-project/wollok-game-ejemplo-cambios-de-posicion-bajan-la-performance



Para evitar esto se utiliza game.at() para obtener posicion nueva
keyboard.up().onPressDo({ 
			const haciaArriba = game.at(self.position().x(), self.position().y() + 1)
			self.moverse(haciaArriba)
		})
		 
  
