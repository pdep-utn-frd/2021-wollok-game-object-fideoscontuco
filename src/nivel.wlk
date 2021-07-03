import wollok.game.*
import models.*
import tablero.*
import models.*

object nivel { // 750 * 750 

	var property ancho = 15
	var property alto = 15
	const casaActual = new Casa(estaRota = false)
	const roca = new Roca()
	const nube = new Nube() // hacerlos por fuera de nivel?
	const personajePrincipal = new PersonajePrincipal(rocaConsejera = roca)
	var property reiniciado = false
	
	method inicio() {
		self.configurarPantalla()
		game.addVisual(new Horario()) // que no sea al mismo tiempo.
		casaActual.dibujar()
		tablero.casa(casaActual)
		visualYAtributos.addVisual(personajePrincipal)
		game.addVisual(nube)
		self.spawnear()
		game.addVisual(roca)
		game.allVisuals().forEach{ v => v.cobrarVida()} // cobrar vida cumple dos funciones al mismo tiempo, da comportamiento de movimiento y tambien reinicia estado, 
		//no esta bueno dos propositos en mismo mensaje
		self.configurarTeclado()
	}
	/*  
	 * 
	 // rever,  discrimina  los objetos, preferible game.allvisuals
		method visualesComportamiento() { // se filtra para reducir el numero, por ej, quitar arboles, y reducir la carga del pedido.
	
		//return game.allVisuals().filter{ v => v.tieneComportamiento() }
		return game.allVisuals().filter{ v => (v.comportamientoDia()) == null && (v.comportamientoNoche() == null) } // si ambas dan null no tiene nada que ofrecer y es quitado de la lista
		// se quita para reducir la lista y que la transicion no demore mucho por una lista muy grande(muchos arboles)
	}
	*/
	method spawnear() { // buscar mejor manera que sea mas liviano.  cambiar spawn segun dificultad
		6.randomUpTo(12).times{ l => game.addVisual(new Arbol())}
		4.times{ l => game.addVisual(new BayasMedianas())}
		3.randomUpTo(24).times{ l => game.addVisual(new Zombie(hogar = casaActual, heroe = personajePrincipal))} // probar agregar zombie a lista y clear, o zombie preguntar si esta muerto y borrar de lista
	}
	

	method configurarPantalla() {
		// game.clear()
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
		keyboard.l().onPressDo({ 
			game.clear()
			game.addVisual(new Cargando()) // mas que nada para evitar esto de que se crean muchos elementos y de la nada el personaje no se puede mover con el tablero anterior ya dibujado( wollok esta creando el tablero)
		 	game.schedule(1, {=> self.inicio()}) // utilizo schedule para que wollok ejecute self.inicio() ejecute el bloque solo cuando termino de dibujar, sino se tildaria con la pantalla anterior dibujada.
			// onPressDo espera a que finalice  inicio para continuar por estar dentro de bloque.  game.schedule tiene su propio bloque
		})
	}

	method escenarioDerrota(razon) {
		game.clear()
			// game.addVisualIn("derrota.png", game.origin())
		game.width(ancho)
		game.title("fideosConTuco-casero")
		game.height(alto)
		game.addVisualIn(roca, game.center())
		game.say(roca, "has perdido: " + razon) // razon de derrota.
		game.schedule(6000, {=>
			game.say(roca, "presiona cualquier tecla para volver a comenzar")
			keyboard.any().onPressDo{ game.clear() // como reinicio
				game.addVisual(new Cargando())
				game.schedule(500, {=> self.inicio()})
			}
		})
	}

}

class Cargando inherits Visual { // pasar a clase

	method image() = "cargandoChico.png"

	method position() = game.at(8, 13)

	method cobrarVida() {
	}

}

class PantallaNegra inherits Visual { // pasar a clase

	method image() = "pantallaCarga1.gif"

	method position() = game.origin()

	method cobrarVida() {
	}

}

class Horario inherits Visual {

	var property tiempoDelDia = 20000
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
				//nivel.visualesComportamiento().forEach{ v => v.comportamientoNoche(self)}
				game.allVisuals().forEach{ v => v.comportamientoNoche(self)}
			} else {
				estado = "dia"
				//nivel.visualesComportamiento().forEach{ v => v.comportamientoDia(self)}   
				game.allVisuals().forEach{ v => v.comportamientoDia(self)} // probar si tilda
			}
		})  
	}

	method esAtravesable() {
		return true
	}

}

