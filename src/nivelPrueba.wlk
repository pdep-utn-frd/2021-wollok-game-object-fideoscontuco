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

}

class Dia inherits VisualUI {
	 
	method cambiarImagen(nroDia) {
		image = 'd' + nroDia.toString() + '.png'
	}

}

class Nivel inherits Ventanas { // 750 * 750  // plano de niveles

	var property casaActual = new Casa(estaRota = false, salud = 200)
	const roca = new Roca()
	const nube = new Nube() 
	var property contadorDias = 1 // polimorfico
	var property numeroDia = new Dia(position = game.at(13, 14), image = 'd1.png')

	method reiniciarDias() {
		self.contadorDias(1)
		numeroDia.cambiarImagen(self.contadorDias())
	}

	method inicio() {	 
		self.configurarPantalla()
		estadisticasDias.contador(1)
		escenarioDerrota.nivel(self)
		self.agregarVisuales()
		mapa.crearParedesInvisibles()
		casaActual.dibujar()
		tablero.casa(casaActual)
		personaje1.rocaConsejera(roca)
		roca.construirRoca()
		
		self.spawnear() // se encarga de los zombies, bayas y arboles
		modoJugadores.eleccion().iniciar()
		self.temporizarFlechas() // flechas desaparecen luego de un rato
		game.allVisuals().forEach{ v => v.cobrarVida()} // no esta bueno dos propositos en mismo mensaje
		self.eventoDias()
		self.teclasPrincipales()
	}

	method spawnear()

	method temporizarFlechas() {
		game.schedule(reloj.tiempoDelDia() / 2, {=> game.removeVisual(flechas)})
	}

	method agregarVisuales() {
		
		game.addVisual(reloj) // que no sea al mismo tiempo. dia/noche
		game.addVisual(nube)
		game.addVisual(roca)
		game.addVisual(new BayaMediana(position = game.at(8, 1))) // baya test nube roba
		game.addVisual(new VisualUI(image = "diaCartelera3.png", position = game.at(11, 14)))
		game.addVisual(numeroDia)
		game.addVisual(flechas)
	}

	method eventoDias() {
		game.onTick(reloj.tiempoDelDia(), 'add score', { 
		 	estadisticasDias.incrementarContador()
		 	self.contadorDias(self.contadorDias() + 1)
			numeroDia.cambiarImagen(self.contadorDias())
		})
	}
	
	 
	method configurarPantalla() {
		game.clear()
		game.height(alto)
		game.width(ancho)
	}

	method teclasPrincipales() {
		keyboard.l().onPressDo({ 
			listaBaya.lista().clear()  
			tablero.lista().clear()		
			reloj.estado(dia) 
			game.clear() // necesario para que limpie el mapa
			 
			game.addVisual(new VisualUI(image = "cargandoChico.png", position = game.at(8, 13)))
				// game.schedule(1, {=> self.inicio()}) // utilizo schedule para que wollok ejecute self.inicio() ejecute el bloque solo cuando termino de dibujar, sino se tildaria con la pantalla anterior dibujada.
				// onPressDo espera a que finalice  inicio para continuar por estar dentro de bloque.  game.schedule tiene su propio bloque
			
			game.schedule(1, {=> seleccionDificultad.inicio()})
			
		})
		keyboard.x().onPressDo({ game.stop()})
	}

}


class NivelFacil inherits Nivel {  
	// es utilizado en el comportamiento de los sujetos que se mueven en el mapa para variar su dificultad

	override method inicio() {
		multiplicador.numero(2) // podria tambien pasando parametro multiplacador a cada instancia, 
			// pero seria mas corto que cada objeto conozca mensaje multiplicador.numero() y actue diferente
		super()
	}

	override method spawnear() { // truncate?
		new FabricaSujetos(nivel = self, nZombies = 1.randomUpTo(4), nBaya = 8.randomUpTo(18), nArboles = 8.randomUpTo(12), nBayasBonus = 2).iniciar()
  
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

class NivelDificil inherits Nivel {

	override method inicio() {
		multiplicador.numero(0.5)
		super()
	}

	override method spawnear() {
		new FabricaSujetos(nivel = self, nZombies = 7.randomUpTo(10), nBaya = 3.randomUpTo(5), nArboles = 2.randomUpTo(4), nBayasBonus = 1).iniciar()
 
	}

}

class NivelNormal inherits Nivel {

	override method inicio() {
		multiplicador.numero(1) 
		super()
	}

	override method spawnear() { //
		new FabricaSujetos(nivel = self, nZombies = 4.randomUpTo(7), nBaya = 6.randomUpTo(10), nArboles = 4.randomUpTo(6), nBayasBonus = 3).iniciar()
 
	}

}

