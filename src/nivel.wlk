import wollok.game.*
import models.*
import tablero.*
import models.*

object nivel { // 750 * 750 

	const ancho = 15
	const alto = 15
	const casaActual = new Casa(estaRota = false)
	const roca = new Roca()
	const nube = new Nube()
	const personajePrincipal = new PersonajePrincipal(rocaConsejera = roca)

	method inicio() {
		self.configurarPantalla()
		game.addVisual(new Horario())
		casaActual.dibujar()
		tablero.casa(casaActual)
		visualYAtributos.addVisual(personajePrincipal)
		game.addVisual(roca)
		game.addVisual(nube)
		self.spawnear()
			// game.allVisuals().forEach{ v => v.reiniciarEstado()} // no hace falta al instanciar desde clase con cada mensaje inicio()
		game.allVisuals().forEach{ v => v.cobrarVida()}
		self.configurarTeclado()
	}

	method visualesComportamiento() { // se filtra para reducir el numero, por ej, quitar arboles, y reducir la carga del pedido
		return game.allVisuals().filter{ v => v.tieneComportamiento() }
	}

	method spawnear() {
		2.randomUpTo(6).times{ l => game.addVisual(new Arbol())}
		4.times{ l => game.addVisual(new BayasMedianas())}
		3.randomUpTo(5).times{ l => game.addVisual(new Zombie(hogar = casaActual, heroe = personajePrincipal))} // z
	}

	method configurarPantalla() {
		game.clear()
		game.height(alto)
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

	method escenarioDerrota(razon) {
		game.clear()
		game.width(ancho)
		game.title("fideosConTuco-casero")
		game.height(alto)
		game.addVisualIn(roca, game.center())
		game.say(roca, "has perdido: " + razon) // razon de derrota.
		game.schedule(3000, {=> game.say(roca, "presiona L para volver a comenzar")})
		keyboard.any().onPressDo{ game.clear() // como reinicio
			self.inicio()
		}
	}

}

class Horario inherits Visual {

	var property tiempoDelDia = 24000
	var property position = game.origin()
	var property estado = "dia"

	method image() {
		if (estado == "dia") {
			return "escenaDiaGrande.png"
		}
		return "escenaNocheGrande.png"
	}

	method cobrarVida() {
		game.onTick(tiempoDelDia, "dia cambia", {=>
			if (estado == "dia") {
				estado = "noche"
				nivel.visualesComportamiento().forEach{ v => v.comportamientoNoche(self)}
			} else {
				estado = "dia"
				nivel.visualesComportamiento().forEach{ v => v.comportamientoDia(self)} // preguntar a todos los visuals tilda
			}
		}) // preguntar
	}

	method esAtravesable() {
		return true
	}

}

