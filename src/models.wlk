import wollok.game.*

object casa {
	var property esAtravesable = false
	var property position = game.center()

	method image() = "palmeraIntento3.png"

}

object palmera {

	var property position = game.at(3, 4)
	var property esAtravesable = false
	method image() = "casa.png"
	
}

object bayasMedianas {
	var property esAtravesable = true
	var property calorias = 10
	var property position = game.at(2, 4)

	method image() = "bayasMedianas.png"
	
}

class Visual { // arboles

	var property position
	var property image
	
}

object girasoles {

	var property energia = 150
	var property position = game.at(1, 3)

	method image() = "girasoles.png"

	method comerPosicion() {
		try {
			const itemFound = game.uniqueCollider(self) // objeto encontrado
			self.comer(itemFound)
		} catch e : wollok.lang.Exception {
			game.say(self, "no hay nada aqui para comer")
		}
	}

	method cansado() {
		return (energia == 0)
	}

	/*  
	method caminar() {
		energia = energia - 5 //
	}
	*/
	method puedeMoverseA(nuevaPos) { // arriba es un objeto
  	return 
    game.getObjectsIn(nuevaPos).all{sujeto => sujeto.esAtravesable()}
	}
	
	method irA(nuevaPos) { // toma objeto pos
		if (not self.cansado() && self.puedeMoverseA(nuevaPos)) { // si no esta cansado y casillero siguiente es objeto mov
			//const distancia = position.distance(nuevaPos) // sirve para viaja varios cuadrados a la vez
			//self.caminar(distancia) // pierde energia x la distancia recorrida, dist es contante no hace falta parametro
			energia = energia - 5
			position = nuevaPos // asigna nueva posicion
		}
		if (self.cansado()) {
			game.schedule(30000, { => game.stop()}) // expandir a pantalla de derrota
		}
	}
		
		 
/*  
 * 
 * 	
	method irHacia(nuevaPos){
		if (not self.cansado() && self.puedeMoverseA(nuevaPos()))
		
	}
 */
	method comer(sujetoComestible) { // chequear como desaparece
		if (sujetoComestible.calorias() != 0) {
			energia = energia + sujetoComestible.calorias()
			game.say(self, "yium")
			game.removeVisual(sujetoComestible)
		}
	}

}



object arriba {
  method posicionEnEsaDireccion() = girasoles.position().up(1)
}

object abajo {
  method posicionEnEsaDireccion() = girasoles.position().down(1)
}

object izquierda {
  method posicionEnEsaDireccion() = girasoles.position().left(1)
}

object derecha {
  method posicionEnEsaDireccion() = girasoles.position().right(1)
}