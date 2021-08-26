import wollok.game.*
import models.*
import tablero.*
import models.*
import horario.*
import fabricaSujetos.*
import nivelPrueba.*
import seleccionDificultad.*

class Estadistica inherits VisualUI {

	var property contador
	var property posicionNro

	method incrementarContador() {
		contador = contador + 1
	}

	method reiniciar() {
		contador = 0
	}

}
/*carteleras de estadisticas */
const estadisticasZombie = new Estadistica(contador = 0, image = "zombieCartelera5.png", position = game.at(0, 2), posicionNro = game.at(8, 2)) /*posicion*/

const estadisticasBayas = new Estadistica(contador = 0, image = "bayasCartelera1.png", position = game.at(0, 4), posicionNro = game.at(12, 4))

const estadisticasDias = new Estadistica(contador = 0, image = "cartelera4.png", position = game.origin(), posicionNro = game.at(7, 0))

object escenarioDerrota inherits Ventanas { // metodo?

	const roca1 = new Roca()
	var property nivel = null

	method inicio(razon) { // nivel para estadisticas
		self.configPantalla()
		/*si se tienen muchas estadisticas, con agregarlas a la lista es suficiente */
		self.mostrarEstadis([estadisticasZombie, 
							 estadisticasBayas, 
							 estadisticasDias
		])
		self.dibujarRoca(razon)
		self.eventoFinPartida()
	}

	method eventoFinPartida() {
		game.schedule(10000, {=>
			game.say(roca1, "reiniciar con") // fondo negro taparia letras, divido en 2 game say
			game.say(roca1, "cualquier tecla")
			keyboard.any().onPressDo{ // game.removeTickEvent("dia cambia")
				estadisticasBayas.reiniciar() // candidato clase
				game.clear() // como reinicio
				reloj.estado(dia)
				tablero.lista().clear()
				game.addVisual(new Cargando()) // es necesario?
				game.schedule(500, {=> seleccionDificultad.inicio()})
			}
		})
	}

	method mostrarEstadis(lista) {
		lista.forEach{ i => self.dibujarEstadisticas(i)}
	}

	method dibujarRoca(razon) {
		game.addVisualIn(roca1, game.center())
		game.say(roca1, "has perdido: ") // razon de derrota.
		game.say(roca1, razon)
	}

	method configPantalla() {
		game.clear()
		game.addVisual(new VisualUI(image = "pantallaNegra.png", position = game.origin()))
	}

	method dibujarEstadisticas(pestadisticas) {
		const contadorDias = pestadisticas.contador()
		const derrota = new Dia( /*numero de dias */ image = 'd' + contadorDias.toString() + '.png', position = pestadisticas.posicionNro())
		pestadisticas.reiniciar() /*contador de dias a 0 */
		game.addVisual(pestadisticas) /* pestadisticas ya tiene visual y position */
		game.addVisual(derrota)
	}

}

class Cargando inherits Visual { // pasar a clase

	method image() = "cargandoChico.png"

	method position() = game.at(8, 13)

}

