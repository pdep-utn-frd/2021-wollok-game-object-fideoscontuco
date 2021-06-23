import wollok.game.*
import models.*


//pantalla cargando.. eso estaria buenisimo!


object tablero { // candidato a clase?
	var property casa 
	method celdasVaciasBordes() { // completar
		const posiciones = []
		const ancho = game.width() - 1
		const alto = game.height() - 1
		(0 .. alto  ).forEach{ num => posiciones.add(game.at(1, num))} // lado izquierdo
		(0 .. alto  ).forEach{ num => posiciones.add(game.at(ancho - 1, num))} // derecha 
		(0 .. ancho ).forEach{ num => posiciones.add(game.at(num, alto - 1))} // arriba 
		(0 .. ancho ).forEach{ num => posiciones.add(game.at(num, 1))}
		return posiciones.filter{ pos => game.getObjectsIn(pos).isEmpty() } // array solo con true
	}

	method espacioLibreAlrededor(sujeto) { // tom 4 direcciones posibles  
		return self.posicionesProximas(sujeto).filter{ p => sujeto.puedeMoverseA(p) } // check si esta fuera de limite o 
	}

	// logica repetida 
	method fueraDelLimite(nuevaPos) {
		const x = nuevaPos.x()
		const y = nuevaPos.y()
		return (x > game.width() - 1 or x < 0) or ( y > game.height() - 1 or y < 0)
	}

	method posicionesProximas(sujeto) {
		return [ sujeto.position().up(1), sujeto.position().down(1), sujeto.position().right(1), sujeto.position().left(1) ]
	}

	method reiniciarEstado() {
	}

	method espacioLibreEnMapa() { // preguntar
		const listaOcupados = []
		const listaTotal = []
		const alto = game.height() - 1 // 50PX 50PX  10 = 500
		const largo = game.width() - 1
		(1 .. largo).forEach{ x => (1 .. alto).forEach{ y => listaTotal.add(game.at(x, y))}} // falta 2,0
		return listaTotal.filter{ celda => game.getObjectsIn(celda).isEmpty() }
	}

	method posRandom() {
		return self.espacioLibreEnMapa().anyOne()
	}

	method posicionMasCercanaACasa(sujeto) { // busco posicion menor dentro de las disponibles
		//const listaEspaciosLibres = self.espacioLibreAlrededor(sujeto)
		/*  
		try {
			return self.espacioLibreAlrededor(sujeto).min{ pos => pos.distance(casa.celdasOcupadas().min{ p => p.distance(pos)}) }
		} catch e : Exception { // no hay espacio libre
			//e.printStackTrace() 
			return sujeto.position()
		} 
		*/
		return self.espacioLibreAlrededor(sujeto).min{ pos => pos.distance(casa.celdasOcupadas().min{ p => p.distance(pos)}) }
	}
	
	method hayEspacioLibre(sujeto){
		return not self.espacioLibreAlrededor(sujeto).isEmpty()
	}
	
	method estaAlBordeDeLaCasa(sujeto) {
		return self.posicionesProximas(sujeto).any{ c => casa.celdasOcupadas().contains(c)}
	} 
	 

}
 