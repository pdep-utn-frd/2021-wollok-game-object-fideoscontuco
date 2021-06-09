import wollok.game.*

object pos {

	var diccio = new Dictionary()
	var posiciones = []
	var pos = [ "xx", "xc" ]
	
	method llenarDiccio(){
		diccio.put("1","xc")
	}
	
	method traducirDiccio(){
		diccio.forEach{k,v => game.at(v,k)}
	}
	
	method traducirLista() {
		(0 .. pos.size()).forEach{ p => (0 .. pos.get(p).length())
		.forEach{ indice => posiciones.add(game.at(pos.get(p).charAt(indice).trad(), p))}}
	}

	method lugarDeLaLetra() {
	}

}

object traducir {

}

