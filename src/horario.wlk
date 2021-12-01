import wollok.game.*
import models.*
import tablero.*
import models.*
import seleccionDificultad.*

class Horario inherits Visual {

	var property tiempoDelDia = 30000
	// var property position = game.origin()
	var property estado = dia // polimorfismo? estado.ejecutar()

	method position() = game.origin()

	method image() {
		/*  
		 * if (estado == "dia") {  // si hay varias partes del dia seria if grande
		 * 	return "escenaDiaGrande.png"
		 * }
		 * return "escenaNocheGrande.png"
		 */
		return estado.getImagen() // probar
	}

	method quedaTiempoDisponible(nro){
		return tiempoDelDia - nro >= 1
	}

	method esDeDia() {
		return (estado == dia) // ==
	}

	// method comportamiento       estado.cambiarHorario()
	override method cobrarVida() {
		game.onTick(tiempoDelDia, "dia cambia", {=>
				/*  
				 * if (estado == "dia") { // probar ocn objeto en vez de string
				 * 	self.cambiar()
				 * 		// nivel.visualesComportamiento().forEach{ v => v.comportamientoNoche(self)}
				 * 	game.allVisuals().forEach{ v => v.comportamientoNoche(self)}
				 * } else {
				 * 	self.cambiar()
				 * 		//
				 * 		// nivel.visualesComportamiento().forEach{ v => v.comportamientoDia(self)}   
				 * 	game.allVisuals().forEach{ v => v.comportamientoDia(self)} // probar si tilda
				 }*/
			self.cambiarEstado() // estado dia cambia a noche, noche a dia
			estado.ejecutar(self)
		})
	}

	method cambiarEstado() {
		estado = estado.escenarioSiguiente()
	// Mas claro si este metodo se encarga
	}

}

class Escenario {

	method ejecutar(phorario) {
		game.allVisuals().forEach{ v => self.comportamiento(v, phorario)}
	}

	method comportamiento(visual, horario)

}

object dia inherits Escenario {

	method escenarioSiguiente() = noche // ahhhhhhh

	override method comportamiento(v, phorario) { // v cada visual
		v.comportamientoDia(phorario) //
	}

	// Variante para no repetir logica entre escenarios
	// podrian agregarse métodos
	method getImagen() {
		return "escenaDiaGrande.png"
	}

}

object noche inherits Escenario {

	method escenarioSiguiente() = dia

	// method ejecutar(phorario){
	// game.allVisuals().forEach{ v => v.comportamientoNoche(phorario)}
	// }
	override method comportamiento(v, phorario) {
		v.comportamientoNoche(phorario)
	}

	method getImagen() = "escenaNocheGrande.png"

}

/*  
 * object tarde inherits Escenario{
 * 	method escenarioSiguiente() = noche
 * 	method ejecutar(phorario){
 * 		//no hace nada
 * 	}
 * 	
 * 	method getImagen() = "escenaTardeGrande.png"
 } */
