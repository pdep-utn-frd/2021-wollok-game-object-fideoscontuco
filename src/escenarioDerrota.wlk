import wollok.game.*
import models.*
import tablero.*
import models.*
import horario.*
import fabricaSujetos.*
import nivelPrueba.*
import seleccionDificultad.*

 class Estadistica{
 	var property contador 
 	
 	method incrementarContador(){
		contador = contador + 1
	} 
	
	method reiniciar(){
		contador = 0
	}
 }

const estadisticasZombie = new Estadistica( contador = 0)  
const estadisticasBayas = new Estadistica(contador = 0) 
 

 
 
object escenarioDerrota inherits Ventanas { // metodo?
	const roca1 = new Roca()
	var property nivel
	method inicio(razon) { // nivel para estadisticas
		self.configPantalla()
		self.dibujarEstadisticasDia()
		self.dibujarEstadisticasZombie()
		self.dibujarEstadisticasBayasRobadas()
		game.addVisualIn(roca1, game.center())
		
		game.say(roca1, "has perdido: ") // razon de derrota.
		game.say(roca1,razon)
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
	
	method configPantalla(){
		game.clear()
		// game.addVisualIn("derrota.png", game.origin())
		game.width(ancho)
		game.title("fideosConTuco-casero")
		game.height(alto)
		game.addVisualIn(pantallaNegra, game.origin())
	}
	
	 
	
	method dibujarEstadisticasDia(){
		var numero = nivel.contadorDias()
		const diasDerrota  = new Dia(
		image='d' + numero.toString()  + '.png', position = game.at(7,0))
		game.addVisualIn(cartelera,game.origin())
		game.addVisual(diasDerrota)
		
	}
	
	
	method dibujarEstadisticasZombie(){
		var numero = estadisticasZombie.contador()
		const zombiesDerrota = new Dia(
		image='d' + numero.toString()  + '.png', position = game.at(8,2))
		estadisticasZombie.reiniciar()
		game.addVisualIn(carteleraZombie, game.at(0,2))
		game.addVisual(zombiesDerrota)
	}
	
	method dibujarEstadisticasBayasRobadas(){
		var numero = estadisticasBayas.contador()
		const bayasRobadas = new Dia(
		image='d' + numero.toString()  + '.png', position = game.at(12,4))
		estadisticasBayas.reiniciar()
		game.addVisualIn(carteleraBayas, game.at(0,4))
		game.addVisual(bayasRobadas)
	}
	 

}

object carteleraBayas{
	var property position
	method image() = "bayasCartelera1.png"
}

object carteleraZombie{
	var property position
	method image() = "zombieCartelera5.png"
}


object cartelera{
	var property position
	method image() = "cartelera4.png"
}

class Cargando inherits Visual { // pasar a clase

	method image() = "cargandoChico.png"

	method position() = game.at(8, 13)

	method cobrarVida() {
	}

	method esAtravesable() = true

}

 