(*
 * Maestro: orquestrador de processos
 * Licença: LGPL 2.0
 * Autores: 
 *   Fabio Alexandre Campos Tisovec
 *   Jorge Augusto Sabaliauskas
 *   Márcio Fernando Stabile Junior
 *   Ramon Fortes Pereira
 *)
signature PARSER =
  sig
    type result

    exception SyntaxError

    val parse : TextIO.instream -> result

  end
