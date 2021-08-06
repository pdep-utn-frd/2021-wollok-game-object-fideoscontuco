import wollok.game.*
import models.*
import tablero.*
import models.*
import horario.*
import nivelPrueba.*
import escenarioDerrota.*
import escenarioMulti.*

class FabricaSujetos{
	var property nZombies
	var property nBaya
	var property nArboles
	var property nivel
	
	 
	method iniciar(){
		nArboles.times{ l => game.addVisual(new Arbol())}
		nZombies.times{ l => game.addVisual(new Zombie(hogar = nivel.casaActual(), heroe = personaje1))} // probar agregar zombie a lista y clear, o zombie preguntar si esta muerto y borrar de lista
		self.agregarBaya() // Baya se agregan a una lista para luego nube tomarlas en su paso
	}
	
	method agregarBaya(){
		var lista = listaBaya.lista()
		nBaya.times{ l => lista.add(new BayaMediana())} // guardo en una lista para que nube pregunte si se topa con una de las Baya
		lista.forEach{ l => game.addVisual(l)}
	//nBaya.times{ l => game.addVisual(new BayaMediana())}
	}
	//comentario para sacar el truncate
}


