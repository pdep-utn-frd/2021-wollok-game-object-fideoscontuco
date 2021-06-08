import wollok.game.*
import models.*

object nivel{
	const largo = 10
	const ancho = 10
	
	method inicio() {
		game.clear() // importante para reiniciar 
		
		game.height(10) // 50PX 50PX  10 = 500
		game.width(10)
		game.title("fideosConTuco-casero")
		game.cellSize(50) // imagenes mas grandes
			// game.boardGround("Map002.jpg") 
			// visuales
	 
		game.addVisual(arbol) // visualIn ini objeto ya con pos
		
		game.addVisual(casa) // el add visual de la casa podria construir todo junto
	 	game.addVisual(techoCasa)
	 	game.addVisual(jardinCasa)
	 	game.addVisual(chimeneaCasa)
	 	

	    game.addVisual(zombie)
	    game.showAttributes(zombie)
	    
		game.addVisual(bayasMedianas)
			// game.addVisualCharacter(personajePrincipal)
		game.addVisual(personajePrincipal)
		game.addVisual(roca)
		game.addVisual(nube)
			// atributos
		game.showAttributes(personajePrincipal)
		game.showAttributes(casa)
		game.showAttributes(bayasMedianas)
		game.showAttributes(arbol)
		game.say(roca, roca.mensajeDeBienvenida())
		game.onTick(800, "nubesSeMueven", {=> nube.moverDerecha()})
		
			// colisiones
		keyboard.c().onPressDo{ personajePrincipal.interactuarPosicion()}
		keyboard.up().onPressDo({ personajePrincipal.irA(personajePrincipal.position().up(1))})
		keyboard.down().onPressDo({ personajePrincipal.irA(personajePrincipal.position().down(1))})
		keyboard.right().onPressDo({ personajePrincipal.irA(personajePrincipal.position().right(1))})
		keyboard.left().onPressDo({ personajePrincipal.irA(personajePrincipal.position().left(1))})
	// mejor hacer la guia por ontick
	// keyboard.any().onPressDo({game.say(roca,"presiona c para interactuar con lugares")})
	//
		 
	}
	
	method escenarioDerrota(){
		game.clear()
		game.width(10) 
		game.title("fideosConTuco-casero")
		game.height(10)
		game.ground("0.png" )
		game.addVisualIn(roca,game.center())
//		game.allElements().forEach{ e => e.reiniciarEstado()} 
		// ciclar por todos los objetos, ver como lo hace
		//game.addVisualIn(bannerPasos, game.origin())
		game.say(roca, "has perdido")
		game.schedule(3000,{ => game.say(roca,"presiona otra tecla para continuar")})
		keyboard.any().onPressDo{self.inicio()}
		
	}
}
