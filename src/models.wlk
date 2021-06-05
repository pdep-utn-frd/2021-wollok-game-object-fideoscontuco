import wollok.game.*

object casa {

	var property position = game.center()

	method image() = "palmeraIntento3.png"

}

object palmera {

	var property position = game.at(3, 4)

	method image() = "casa.png"

}

object bayasMedianas {

	var property calorias = 10
	var property position = game.at(2, 4)

	method image() = "bayasMedianas.png"

}

class Visual { // arboles

	var property position
	var property image

}

object girasoles {

	var property energia = 50
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

	method caminar(distancia) {
		energia = energia - distancia * 1
	}

	method irA(nuevaPos) { // toma objeto pos
		if (not self.cansado()) { // si no esta cansado
			const distancia = position.distance(nuevaPos) // calcula distancia entre dos pos
			self.caminar(distancia) // pierde energia x la distancia recorrida
			position = nuevaPos // asigna nueva posicion
		}
		if (self.cansado()) {
			game.stop()
		}
	}

	method comer(sujetoComestible) { // chequear como desaparece
		if (sujetoComestible.calorias() != 0) {
			energia = energia + sujetoComestible.calorias()
			game.say(self, "yium")
			game.removeVisual(sujetoComestible)
		}
	}

}