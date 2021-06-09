import wollok.game.*
import models.*
import tablero.*
object nivel {

	const largo = 10
	const ancho = 10

	method inicio() {
	 	game.clear()
		game.height(10) // 50PX 50PX  10 = 500
		game.width(10)
		game.title("fideosConTuco-casero")
		
		casa.dibujar()
 
		
		visualYAtributos.addVisual(personajePrincipal)
		game.addVisual(roca)
		game.errorReporter(roca)
		//game.say(roca, roca.mensajeDeBienvenida())
		game.addVisual(nube)
			
	 	6.times{ l =>  game.addVisual((new Arbol()))}  // preguntar por manera con fabrica
		4.times{ l => game.addVisual(new BayasMedianas())}
		2.times{ l => game.addVisual(new Zombie())}
		game.allVisuals().forEach{ v => v.reiniciarEstado()}  
		
		game.allVisuals().forEach{ v => v.cobrarVida()}  
		
		game.onTick(15000, "avanza el tiempo", { => dia.cambiarEstado()})
		game.onTick(800, "nubesSeMueven", {=> nube.moverDerecha()})
	 	
		
	    
		
		
			// keys
		keyboard.c().onPressDo{ personajePrincipal.interactuarPosicion()}
		keyboard.up().onPressDo({ personajePrincipal.irA(personajePrincipal.position().up(1))})
		keyboard.down().onPressDo({ personajePrincipal.irA(personajePrincipal.position().down(1))})
		keyboard.right().onPressDo({ personajePrincipal.irA(personajePrincipal.position().right(1))})
		keyboard.left().onPressDo({ personajePrincipal.irA(personajePrincipal.position().left(1))})
		keyboard.l().onPressDo({ game.clear()
			self.inicio()
		}) // testing
	}

	method escenarioDerrota() {
		game.clear()
		game.width(10)
		game.title("fideosConTuco-casero")
		game.height(10)
		game.ground("0.png")
		game.addVisualIn(roca, game.center())
		game.say(roca, "has perdido")
		game.schedule(3000,{=> game.say(roca,"presiona una tecla para continuar")})
		keyboard.any().onPressDo{ game.clear()
			self.inicio()
		}
	}

}

