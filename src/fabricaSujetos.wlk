import wollok.game.*
import models.*
import tablero.*
import models.*
import horario.*
import nivelPrueba.*
import seleccionDificultad.*


class FabricaSujetos{
	var property nZombies
	var property nBayas
	var property nArboles
	var property nivel
	
	 
	method iniciar(){
		nArboles.times{ l => game.addVisual(new Arbol())}
		nZombies.times{ l => game.addVisual(new Zombie(hogar = nivel.casaActual(), heroe = nivel.personajePrincipal()))} // probar agregar zombie a lista y clear, o zombie preguntar si esta muerto y borrar de lista
		self.agregarBayas() // bayas se agregan a una lista para luego nube tomarlas en su paso
	}
	
	method agregarBayas(){
		var lista = listaBayas.lista()
		nBayas.truncate(0).times{ l => lista.add(new BayasMedianas())} // guardo en una lista para que nube pregunte si se topa con una de las bayas
		lista.forEach{ l => game.addVisual(l)}
	//nBayas.times{ l => game.addVisual(new BayasMedianas())}
	}
	
}


