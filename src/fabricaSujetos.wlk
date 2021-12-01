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
	var property nBayasBonus 
	
	method iniciar(){
		nArboles.times{ l => game.addVisual(new Arbol())}
		nZombies.times{ l => game.addVisual(new Zombie(hogar = nivel.casaActual(), heroe = personaje1))} // probar agregar zombie a lista y clear, o zombie preguntar si esta muerto y borrar de lista
		self.agregarBaya() // Baya se agregan a una lista para luego nube tomarlas en su paso
		self.agregarBayasBonus()
	}
	
	method agregarBaya(){
		const lista = listaBaya.lista()
		nBaya.times{ l => lista.add(new BayaMediana())} // guardo en una lista para que nube pregunte si se topa con una de las Baya
		lista.forEach{ l => game.addVisual(l)}
	}
	
	method agregarBayasBonus(){
		nBayasBonus.times{ l => 
			const baya =  new BayaAuto(position = game.at(9 + l,5 - l)) // sumo 1 pos a la derecha y bajo uno
			listaBaya.lista().add(baya) 
			game.addVisual(baya)	
		}
	}
	//comentario para sacar el truncate
}



