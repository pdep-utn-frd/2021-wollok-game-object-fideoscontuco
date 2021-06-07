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
	 
		game.addVisual(palmera) // visualIn ini objeto ya con pos
		
		game.addVisual(casa) // el add visual de la casa podria construir todo junto
	 	game.addVisual(techoCasa)
	 	game.addVisual(jardinCasa)
	 	game.addVisual(chimeneaCasa)
	 	
	 	/*  probar hacer coleciones de bayas
	 	game.addVisual(baya1)
	 	game.addVisual(baya2)
	 	game.addVisual(baya3)
	 	game.addVisual(baya4)
	 	game.addVisual(baya5)
	 	game.addVisual(baya6)
	 	game.addVisual(baya7)
	 	game.addVisual(baya8)
	 	game.addVisual(baya9)
	 	*/
	    game.addVisual(zombie)
	    game.showAttributes(zombie)
	    
		game.addVisual(bayasMedianas)
			// game.addVisualCharacter(girasolesSentientes)
		game.addVisual(girasolesSentientes)
		game.addVisual(roca)
		game.addVisual(nube)
			// atributos
		game.showAttributes(girasolesSentientes)
		game.showAttributes(casa)
		game.showAttributes(bayasMedianas)
		game.showAttributes(palmera)
		game.say(roca, roca.mensajeDeBienvenida())
	//	game.onTick(6000, "rocaDaConsejos", { => roca.darConsejo()})
		game.onTick(800, "nubesSeMueven", {=> nube.moverDerecha()})
		
			// colisiones
		keyboard.c().onPressDo{ girasolesSentientes.interactuarPosicion()}
		keyboard.up().onPressDo({ girasolesSentientes.irA(girasolesSentientes.position().up(1))})
		keyboard.down().onPressDo({ girasolesSentientes.irA(girasolesSentientes.position().down(1))})
		keyboard.right().onPressDo({ girasolesSentientes.irA(girasolesSentientes.position().right(1))})
		keyboard.left().onPressDo({ girasolesSentientes.irA(girasolesSentientes.position().left(1))})
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
