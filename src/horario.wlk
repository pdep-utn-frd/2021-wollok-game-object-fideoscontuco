import wollok.game.*
import models.*
import tablero.*
import models.*
import seleccionDificultad.*

class Horario inherits Visual {

	var property tiempoDelDia = 20000
	var property position = game.origin()
	var property estado = dia // polimorfismo? estado.ejecutar()

	method image() {
		/*  
		if (estado == "dia") {
			return "escenaDiaGrande.png"
		}
		return "escenaNocheGrande.png"
		 */
		return estado.getImagen() // probar
	}
	
	method quedaTiempoDisponible(nro) { //
		return tiempoDelDia - nro >= 1
	}
  
	method esDeDia() {
		return (estado.equals(dia))
	}
	 
	//method comportamiento       estado.cambiarHorario()
	method cobrarVida() {
		game.onTick(tiempoDelDia, "dia cambia", {=>
			/*  
			if (estado == "dia") { // probar ocn objeto en vez de string
				self.cambiar()
					// nivel.visualesComportamiento().forEach{ v => v.comportamientoNoche(self)}
				game.allVisuals().forEach{ v => v.comportamientoNoche(self)}
			} else {
				self.cambiar()
					//
					// nivel.visualesComportamiento().forEach{ v => v.comportamientoDia(self)}   
				game.allVisuals().forEach{ v => v.comportamientoDia(self)} // probar si tilda
			}*/
			var estadoSiguiente = estado.escenarioSiguiente()
			 self.cambiarEstado(estadoSiguiente) // estado dia cambia a noche, noche a dia
			 estadoSiguiente.ejecutar(self) 
		})
	}
	
	method cambiarEstado(nuevoEstado){
		estado = nuevoEstado
	}
	method esAtravesable() {
		return true
	}

}

object dia{
	method escenarioSiguiente() = noche
	method ejecutar(phorario){
		 
		game.allVisuals().forEach{ v => v.comportamientoDia(phorario)} 
	}
	
	
	
	method getImagen() = "escenaDiaGrande.png"
	
}

object noche{
	method escenarioSiguiente() = dia
	method ejecutar(phorario){
		game.allVisuals().forEach{ v => v.comportamientoNoche(phorario)}
	}
	
	method getImagen() = "escenaNocheGrande.png"
}
