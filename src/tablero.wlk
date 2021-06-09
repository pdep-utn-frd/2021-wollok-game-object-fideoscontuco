import wollok.game.*
import models.*
object tablero {

	method celdasVaciasBordes() { // completar
		const posiciones = []
		const ancho = game.width() - 2
		const alto = game.height() - 2
		(0 .. alto  ).forEach{ num => posiciones.add(game.at(1, num))} // lado izquierdo
		(0 .. alto  ).forEach{ num => posiciones.add(game.at(ancho - 1, num))} // derecha 
		(0 .. ancho ).forEach{ num => posiciones.add(game.at(num, alto - 1))} // arriba 
		(0 .. ancho ).forEach{ num => posiciones.add(game.at(num, 1))}
		return posiciones.filter{ pos => game.getObjectsIn(pos).isEmpty() } // array solo con true
	}

	method espacioLibreAlrededor(posicion) { // tom 4 direcciones posibles  
		const posiciones = [ posicion.up(1), posicion.down(1), posicion.right(1), posicion.left(1) ]
		return posiciones.filter{ p => self.puedeMoverseA(p) } // check si esta fuera de limite o 
	}

	// logica repetida 
	method fueraDelLimite(nuevaPos) {
		const x = nuevaPos.x()
		const y = nuevaPos.y()
		return (x >= game.width() or x < 0) or ( y >= game.height() or y < 0)
	}

	// zombie huye solo a tiles vacios
	method puedeMoverseA(nuevaPos) { // si esta vacio y no esta fuera del limite
		return ( not self.fueraDelLimite(nuevaPos) and game.getObjectsIn(nuevaPos).isEmpty()) // get objectsIn devuelve lista. 
		//
	}
	
	method reiniciarEstado() {
	}

	method espacioLibreEnMapa() { // preguntar
		const listaOcupados = []
		const listaTotal = []
		const alto = game.height() - 1 // 50PX 50PX  10 = 500
		const largo = game.width() - 1
		(1 .. largo).forEach{ x => (1 .. alto).forEach{ y => listaTotal.add(game.at(x, y))}} // falta 2,0
			// (10 .. 10-1).forEach{ y => (y .. 10-1).forEach{ x => listaTotal.add(game.at(x,y))}}
		game.allVisuals().forEach{ v => listaOcupados.add(v.position())}
		listaTotal.removeAll(listaOcupados)
		return listaTotal
	}

	method posRandom() { // que no de repetidas
		return  self.espacioLibreEnMapa().anyOne()
	}
	
	method posicionMasCercanaACasa(sujeto){ // busco posicion menor dentro de las disponibles
	const listaEspaciosLibres = self.espacioLibreAlrededor(sujeto.position())
	return listaEspaciosLibres.min{ pos => pos.distance(casa.position())}
	}

}