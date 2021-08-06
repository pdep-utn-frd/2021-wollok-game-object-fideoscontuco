import wollok.game.*
import models.*
import tablero.*
import models.*
import horario.*
import fabricaSujetos.*
import seleccionDificultad.*
import escenarioDerrota.*
import escenarioMulti.*

const reloj = new Horario()

const anchoVentanas = 15

const altoVentanas = 15

object multiplicador { // utilizado para definir comportamiento de personajes segun la dificultad ej : personaje principal hace mas daño

	var property numero = 0
}

object listaBaya { // utilizado para que nube pueda identificar que en celda hay alguna baya y robarla

	var property lista = []

}

class Ventanas {

	var property ancho = anchoVentanas
	var property alto = anchoVentanas
	
// configurar pantalla podria ir aca y utilizarse super en otras.
}

class Dia inherits VisualUI{
	method cambiarImagen(nroDia) {
		image = 'd' + nroDia.toString() + '.png'
	}

}
/*  
object diasCartelera inherits Visual{
	var property position = null
	method image() = "diaCartelera3.png"

}
*/








// que hace siguiente? remarca al siguiente, lo elegido.  y lo pone como la decision actual
class Nivel inherits Ventanas { // 750 * 750  // plano de niveles

	// var property ancho = 15
	// var property alto = 15
	// var property multiplicador   // incrementa o reduce la capacidad de actores
	var property casaActual = new Casa(estaRota = false,salud = 500)
	const roca = new Roca()
	const nube = new Nube() // hacerlos por fuera de nivel?
	var property p1 = new PersonajePrincipal( rocaConsejera = roca)
	var property reiniciado = false
	
	var property contadorDias = 1
	
	var property numeroDia = new Dia(
		position = game.at(13, 14),
		image='d1.png' 
	)
 	
	
	method inicio() {
		game.clear()
		self.configurarPantalla()
		escenarioDerrota.nivel(self)	
	 	game.addVisual(reloj) // que no sea al mismo tiempo.
		mapa.crearParedesInvisibles()
	 	casaActual.dibujar()
		tablero.casa(casaActual)
		//visualYAtributos.addVisual(personajePrincipal)
	  	game.addVisualCharacter(p1)
		  // hace cambios segun respectivo modo (1jugador, 2 jugadores)
			// game.addVisualIn(dialogoCuidadoZombies, game.at(3,10) )
 		game.addVisual(nube)
	 	game.addVisual(roca)
	 	roca.construirRoca()
		
	 	game.addVisual(numeroDia)
	// 	game.addVisualIn(diasCartelera,game.at(11,14))
		game.addVisual(new VisualUI(image ="diaCartelera3.png", position = game.at(11,14)))
		 
			// 4.randomUpTo(8).times{ l => game.addVisual(new Zombie(hogar = casaActual, heroe = personajePrincipal))} // probar agregar zombie a lista y clear, o zombie preguntar si esta muerto y borrar de lista
	 	game.addVisual(new BayaMediana(position = game.at(8,1))) // baya test nube prueba
	 	game.addVisual(new Arbol(position = game.at(8,1))) // test 2 visuales mismo tile 
	    self.spawnear()
		
	    game.addVisual(flechas)
		//game.addVisual(new VisualUI(image = "flechas.png", position = game.at(0,0))) 
		
		modoJugadores.eleccion().iniciar()
	 	game.schedule(reloj.tiempoDelDia() / 2, {=> game.removeVisual(flechas)})
			// game.addVisualIn(flechas,game.at(10,9)
	 	mapa.crearParedesInvisibles()
		game.allVisuals().forEach{ v => v.cobrarVida()} // no esta bueno dos propositos en mismo mensaje
		self.eventoDias()
		 self.configurarTeclado(p1)
		self.teclasPrincipales()
		
	}

	/*  
	 * 
	 *  // rever,  discrimina  los objetos, preferible game.allvisuals
	 * 	method visualesComportamiento() { // se filtra para reducir el numero, por ej, quitar arboles, y reducir la carga del pedido.
	 * 
	 * 	//return game.allVisuals().filter{ v => v.tieneComportamiento() }
	 * 	return game.allVisuals().filter{ v => (v.comportamientoDia()) == null && (v.comportamientoNoche() == null) } // si ambas dan null no tiene nada que ofrecer y es quitado de la lista
	 * 	// se quita para reducir la lista y que la transicion no demore mucho por una lista muy grande(muchos arboles)
	 * }
	 */
	method spawnear()
	
	method eventoDias(){ 
	game.onTick(reloj.tiempoDelDia(), 'add score', {
			contadorDias = contadorDias + 1
			numeroDia.cambiarImagen(contadorDias)			
		})
		
		}
	
	method configurarPantalla() {
		// game.clear()
		game.height(alto)
		game.width(ancho)
	}
	
	method configurarTeclado(p) {
	//	keyboard.c().onPressDo{ p.interactuarPosicion()}
		keyboard.enter().onPressDo{ p.interactuarPosicion()}
		
		keyboard.up().onPressDo({  // p.position es la posicion siguiente por el game.addVisualCharacter()
			if (not p.puedeMoverseA(p.position()) or p.estaAnimando()) {
				p.position(p.position().down(1)) // ir direccion contraria traba al visual en el lugar que esta
			} else { // puede moverse
				p.efectoDeCaminar() // setter energia e imagen, delego cambio a posicionNueva a game.addVisualCharacter por rendimiento	
				p.hacerPasos()
			} // position() devolveria la posicion final, luego de moverse por game.addVisualCharacter(personajePrincipal)
		})
		keyboard.down().onPressDo({ if (not p.puedeMoverseA(p.position()) or  p.estaAnimando() ) {
				p.position(p.position().up(1))
			} else {
				p.efectoDeCaminar()
				p.hacerPasos()
			}
		})
		keyboard.right().onPressDo({ if (not p.puedeMoverseA(p.position()) or p.estaAnimando() ) {
				p.position(p.position().left(1))
			} else {
				p.efectoDeCaminar()
				p.hacerPasos()
			}
		})
		keyboard.left().onPressDo({ if (not p.puedeMoverseA(p.position()) or p.estaAnimando() ) {
				p.position(p.position().right(1))
			} else { // puede moverse
				
				p.efectoDeCaminar()
				p.hacerPasos()
				
			}
		})
		
	}
	
	
	
	

	method teclasPrincipales() {
		keyboard.l().onPressDo({ // try{
			game.removeTickEvent("dia cambia")
				// } catch e : Exception{
				// no hace nada	
				// }
			listaBaya.lista().clear() //rever
			tablero.lista().clear()
			game.clear()
			reloj.estado(dia) // probar instanciar
		//	game.addVisual(new Cargando()) // mas que nada para evitar esto de que se crean muchos elementos y de la nada el personaje no se puede mover con el tablero anterior ya dibujado( wollok esta creando el tablero)
			game.addVisual(new VisualUI(image = "cargandoChico.png", position = game.at(8, 13) ))
				// game.schedule(1, {=> self.inicio()}) // utilizo schedule para que wollok ejecute self.inicio() ejecute el bloque solo cuando termino de dibujar, sino se tildaria con la pantalla anterior dibujada.
				// onPressDo espera a que finalice  inicio para continuar por estar dentro de bloque.  game.schedule tiene su propio bloque
			game.schedule(1, {=> seleccionDificultad.inicio()})
		})
		keyboard.x().onPressDo({ game.stop()})
	}

/*  
 * method escenarioDerrota(razon) {
 * 	game.clear()
 * 		// game.addVisualIn("derrota.png", game.origin())
 * 	game.width(ancho)
 * 	game.title("fideosConTuco-casero")
 * 	game.height(alto)
 * 	game.addVisualIn(roca, game.center())
 * 	game.say(roca, "has perdido: " + razon) // razon de derrota.
 * 	game.schedule(6000, {=>
 * 		game.say(roca, "presiona cualquier tecla para volver a comenzar")
 * 		keyboard.any().onPressDo{ game.clear() // como reinicio
 * 			game.addVisual(new Cargando())
 * 			game.schedule(500, {=> self.inicio()})
 * 		}
 * 	})
 * }
 */
}

//repite mucho factor = multiplicador, demasiados mensajes. ademas si aplica a todos tendria que repetir eso mil veces
//
object nivelFacil inherits Nivel { // y si la dificultad cambiase el comportamiento de zombies? 
	// es utilizado en el comportamiento de los sujetos que se mueven en el mapa para variar su dificultad

	override method inicio() {
		multiplicador.numero(2) // podria tambien pasando parametro multiplacador a cada instancia, 
			// pero seria mas corto que cada objeto conozca mensaje multiplicador.numero() y actue diferente
		super()
	}

	override method spawnear() { // truncate?
		new FabricaSujetos(nivel = self, nZombies = 1.randomUpTo(3), nBaya = 10.randomUpTo(18), nArboles = 8.randomUpTo(12)).iniciar()
	// new FabricaSujetos(nivel = self, nZombies = 4, nBaya = 15, nArboles =4).iniciar()
	// game.addVisual(new BayaMediana(position = game.at(7,11)))
	/* 
	 * 		6.randomUpTo(12).times{ l => game.addVisual(new Arbol())}
	 * 			// 4.randomUpTo(10).times{ l => listaBaya.lista().add(new BayaMediana())} // guardo en una lista para que nube pregunte si se topa con una de las Baya
	 * 			// 22.times{ l => listaBaya.lista().add(new BayaMediana())} // guardo en una lista para que nube pregunte si se topa con una de las Baya
	 * 		6.randomUpTo(12).times{ l => listaBaya.lista().add(new BayaMediana())} // guardo en una lista para que nube pregunte si se topa con una de las Baya
	 * 		listaBaya.lista().forEach{ l => game.addVisual(l)}
	 * 			// 8.times{ l => game.addVisual(new Arbol())}
	 * 		1.randomUpTo(3).times{ l => game.addVisual(new Zombie(hogar = casaActual, heroe = personajePrincipal))} // probar agregar zombie a lista y clear, o zombie preguntar si esta muerto y borrar de lista
	 * 		// 24.times{ l => game.addVisual(new Zombie(hogar = casaActual, heroe = personajePrincipal))} // probar agregar zombie a lista y clear, o zombie preguntar si esta muerto y borrar de lista
	 */
	}

}

object nivelDificil inherits Nivel {

	// es utilizado en el comportamiento de los sujetos que se mueven en el mapa para variar su dificultad
	override method inicio() {
		multiplicador.numero(0.2) // podria tambien pasando parametro multiplacador a cada instancia, 
			// pero seria mas corto que cada objeto conozca mensaje multiplicador.numero() y actue diferente
		super()
	}

	override method spawnear() {
		new FabricaSujetos(nivel = self, nZombies = 7.randomUpTo(12), nBaya = 2.randomUpTo(4), nArboles = 2.randomUpTo(6)).iniciar()
	/*  
	 * const listaBaya = []
	 * 3.randomUpTo(6).times{ l => game.addVisual(new Arbol())}
	 * 	// 4.times{ l => game.addVisual(new BayaMediana())}
	 * 2.randomUpTo(9).times{ l => listaBaya.lista().add(new BayaMediana())} // guardo en una lista para que nube pregunte si se topa con una de las Baya
	 * 	// 20.times{ l => listaBaya.lista().add(new BayaMediana())} // guardo en una lista para que nube pregunte si se topa con una de las Baya
	 * listaBaya.lista().forEach{ l => game.addVisual(l)}
	 * 6.randomUpTo(12).times{ l => game.addVisual(new Zombie(hogar = casaActual, heroe = personajePrincipal))} // probar agregar zombie a lista y clear, o zombie preguntar si esta muerto y borrar de lista
	 * 	}
	 */
	}

}

object nivelNormal inherits Nivel {

	override method inicio() {
		multiplicador.numero(1) // podria tambien pasando parametro multiplacador a cada instancia, 
			// pero seria mas corto que cada objeto conozca mensaje multiplicador.numero() y actue diferente
		super()
	}

	override method spawnear() { //
		new FabricaSujetos(nivel = self, nZombies = 2.randomUpTo(6), nBaya = 5.randomUpTo(10), nArboles = 6.randomUpTo(12)).iniciar()
	/*  
	 * 4.randomUpTo(10).times{ l => game.addVisual(new Arbol())}
	 * 	// 9.times{ l => game.addVisual(new BayaMediana())}
	 * 4.randomUpTo(9).times{ l => listaBaya.lista().add(new BayaMediana())} // guardo en una lista para que nube pregunte si se topa con una de las Baya
	 * listaBaya.lista().forEach{ l => game.addVisual(l)}
	 * 4.randomUpTo(7).times{ l => game.addVisual(new Zombie(hogar = casaActual, heroe = personajePrincipal))} // probar agregar zombie a lista y clear, o zombie preguntar si esta muerto y borrar de lista
	 */
	}

}
/*  
<<<<<<< HEAD
 
=======
object escenarioDerrota inherits Ventanas { // metodo?
	const roca1 = new Roca()

	method inicio(razon) {
		game.clear()
			// game.addVisualIn("derrota.png", game.origin())
		game.width(ancho)
		game.title("fideosConTuco-casero")
		game.height(alto)
		game.addVisualIn(roca1, game.center())
		game.say(roca1, "has perdido: " + razon) // razon de derrota.
		game.schedule(6000, {=>
			game.say(roca1, "presiona cualquier tecla para volver a comenzar")
			keyboard.any().onPressDo{ // game.removeTickEvent("dia cambia")
				listaBaya.lista().clear() // candidato clase
				game.clear() // como reinicio
				reloj.estado(dia)
				tablero.lista().clear()
				game.addVisual(new Cargando()) // es necesario?
				game.schedule(500, {=> seleccionDificultad.inicio()})
			}
		})
	}

}
*/

/* 
class Cargando inherits Visual { // pasar a clase

	override method image() = "cargandoChico.png"

	override method position() = game.at(8, 13)

	 

} */
 