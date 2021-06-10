import wollok.game.*
import models.*
import tablero.*

object nivel {
	const ancho = 15
	const alto = 15
	method inicio() {
		self.configurarPantalla()
		game.boardGround("escenaDia.png")
		casa.dibujar()
		visualYAtributos.addVisual(personajePrincipal)
		game.addVisual(roca)
			// game.errorReporter(roca)
		game.addVisual(nube)
		3.times{ l => game.addVisual((new Arbol(position = tablero.posRandom())))} // preguntar por manera con fabrica
		4.times{ l => game.addVisual(new BayasMedianas())}
		2.times{ l => game.addVisual(new Zombie())}
		game.allVisuals().forEach{ v => v.reiniciarEstado()} // preguntar
		game.allVisuals().forEach{ v => v.cobrarVida()}
		self.configurarTeclado()
	}

	method configurarPantalla() {
		game.clear()
		game.height(alto) // 50PX 50PX  10 = 500
		game.width(ancho)
		game.title("fideosConTuco-casero - C para interactuar / L para reiniciar")
	}

	method configurarTeclado() {
		keyboard.c().onPressDo{ personajePrincipal.interactuarPosicion()}
		keyboard.up().onPressDo({ personajePrincipal.irA(personajePrincipal.position().up(1))})
		keyboard.down().onPressDo({ personajePrincipal.irA(personajePrincipal.position().down(1))})
		keyboard.right().onPressDo({ personajePrincipal.irA(personajePrincipal.position().right(1))})
		keyboard.left().onPressDo({ personajePrincipal.irA(personajePrincipal.position().left(1))})
		keyboard.l().onPressDo({ game.clear()
			self.inicio()
		})
	}

	method escenarioDerrota() {
		game.clear()
		game.width(ancho)
		game.title("fideosConTuco-casero")
		game.height(alto)
		game.addVisualIn(roca, game.center())
		game.say(roca, "has perdido")
		game.schedule(3000, {=> game.say(roca, "presiona una tecla para continuar")})
		keyboard.any().onPressDo{ game.clear()
			self.inicio()
		}
	}


}

