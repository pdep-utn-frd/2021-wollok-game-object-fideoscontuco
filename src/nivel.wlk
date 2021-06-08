import wollok.game.*
import models.*

object nivel {

	const largo = 10
	const ancho = 10

	method inicio() {
		game.clear()
		game.height(10) // 50PX 50PX  10 = 500
		game.width(10)
		game.title("fideosConTuco-casero")
		
		
		// game.cellSize(50) // imagenes mas grandes
		
		//visuales
		// game.addVisual(new Arbol(position = game.at(3,2)))// visualIn ini objeto ya con pos
		// game.addVisual(new Arbol(position = game.at(3,6)))
		// game.addVisual(new Arbol(position = game.at(4,8)))
		game.addVisual(new BayasMedianas())
		game.addVisual(new BayasMedianas(position = game.at(5, 7)))
		game.addVisual(casa) // el add visual de la casa podria construir todo junto
		game.addVisual(techoCasa)
		game.addVisual(jardinCasa)
		game.addVisual(chimeneaCasa)
		game.addVisual(zombie)
		game.showAttributes(zombie)
			// game.addVisual(bayasMedianas)
		game.addVisual(personajePrincipal)
		game.addVisual(roca)
		game.addVisual(nube)
			/*  
			 * 		game.addVisual(new Arbol())
			 * 	 	game.addVisual(new Arbol())
			 * 	 	game.addVisual(new Arbol())
			 * 	 	game.addVisual(new Arbol())
			 * 	 	game.addVisual(new Arbol())
			 * 	 	game.addVisual(new Arbol())
			 * 	 	game.addVisual(new Arbol())
			 * 	 	game.addVisual(new Arbol())
			 */
		bosque.sembrarBosque(12)
		
		
		game.showAttributes(personajePrincipal)
			// game.showAttributes(casa)
			// game.showAttributes(bayasMedianas)
			// game.showAttributes(arbol) 
		game.say(roca, roca.mensajeDeBienvenida())
		game.onTick(800, "nubesSeMueven", {=> nube.moverDerecha()})
		game.allVisuals().forEach{ v => v.reiniciarEstado()} // preguntar
		
		
		//keys
		keyboard.c().onPressDo{ personajePrincipal.interactuarPosicion()}
		keyboard.up().onPressDo({ personajePrincipal.irA(personajePrincipal.position().up(1))})
		keyboard.down().onPressDo({ personajePrincipal.irA(personajePrincipal.position().down(1))})
		keyboard.right().onPressDo({ personajePrincipal.irA(personajePrincipal.position().right(1))})
		keyboard.left().onPressDo({ personajePrincipal.irA(personajePrincipal.position().left(1))})
		 
			keyboard.l().onPressDo({ game.clear() self.inicio()})//testing
	
	}

	method escenarioDerrota() {
		game.clear()
		game.width(10)
		game.title("fideosConTuco-casero")
		game.height(10)
		game.ground("0.png")
		game.addVisualIn(roca, game.center())
		game.say(roca, "has perdido")
		keyboard.any().onPressDo{ game.clear()
			self.inicio()
		}
	}
	 
}

