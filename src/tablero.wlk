import wollok.game.*
import models.*
import seleccionDificultad.*

//pantalla cargando.. eso estaria buenisimo!


object tablero { // candidato a clase?
	var property casa 
	var property lista = []
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
	   
	method espacioLibreEnMapa() { //  9 a 10 segundos de cargas en test 22 Baya
		const listaOcupados = []
		const listaTotal = []
		const alto = game.height() - 1 // 50PX 50PX  10 = 500
		const largo = game.width() - 1
		(1 .. largo).forEach{ x => (1 .. alto).forEach{ y => listaTotal.add(game.at(x, y))}} // falta 2,0
		
		// creo u ngame at aleatorio.      pregunto si hay alguien, si lo hay. vuelvo a crear
		return listaTotal.filter{ celda => game.getObjectsIn(celda).isEmpty() } // 225 pedidos
	}
	 
	
	method espacioLibreEnMapa2(){ //  < 2 segundo carga en test de 22 Baya
		var posicion = game.at(1.randomUpTo(13),1.randomUpTo(13))
		  
		if (game.getObjectsIn(posicion).isEmpty() && (not self.esRepetido(posicion))){ // verificar que no sea pos ya utilizada. 
			  // getter y setter? otra manera?
			  lista.add(posicion)
				return posicion
		}else{ 
		    return self.espacioLibreEnMapa2()
		}
	/*  
		if (game.getObjectsIn(posicion).isEmpty()){
			return posicion
		}else{
	 		
	return self.espacioLibreEnMapa2()
	 	}
		
		*/
		
	}
	
	 
	method esRepetido(pos){
		
		return lista.contains(pos)
	}
	method posRandom() { // arbol utiliza para saber donde aparecer, un tile ocupado por cualquier objeto descalifica
		return self.espacioLibreEnMapa2() 
		//  return self.espacioLibreEnMapa().anyOne()
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
	//	return self.espacioLibreAlrededor(sujeto).min{ pos => pos.distance(self.parteCasaMasCercana(pos)) } // busca el espacio alrededor con la menor distancia entre su posicion y la parte mas cercana
		
		//crear zombie y ver si 
	}
	
	method parteCasaMasCercana(posicion2){ // la parte mas cercana de la casa a tomar como referencia
		return casa.celdasOcupadas().min{ p => p.distance(posicion2)}
	}
	
	method hayEspacioLibre(sujeto){
		return not self.espacioLibreAlrededor(sujeto).isEmpty()
	}
	
	method estaAlBordeDeLaCasa(sujeto) {
		return self.posicionesProximas(sujeto).any{ c => casa.celdasOcupadas().contains(c)}
	} 
	 

}
 