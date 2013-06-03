(*
 * Maestro: orquestrador de processos
 * Licença: LGPL 2.0
 * Autores: 
 *   Fabio Alexandre Campos Tisovec
 *   Jorge Augusto Sabaliauskas
 *   Márcio Fernando Stabile Junior
 *   Ramon Fortes Pereira
 *)

signature SEMANTIC =
  sig
    type maestro
    type sub
    type bloco
    type cmd
    type expr
    type id
    type cadeia
    type num

    exception RuntimeError of string
    
    val maestro : sub list -> maestro
    val sub : id -> id list -> bloco -> sub
    val bloco : cmd list -> bloco
    val cmdSe : expr -> bloco -> cmd
    val cmdRep : num -> bloco -> cmd
    val cmdAtr : id -> expr -> cmd
    val cmdRet : expr -> cmd
    val cmdCall : id -> expr list -> cmd
    val exprId : id -> expr
    val exprInic : expr
    val exprSusp : expr
    val exprExec : expr
    val exprFin : expr
    val exprCad : cadeia -> expr
    val exprCall : id -> expr list -> expr
    val exprVerd : expr
    val exprFalso : expr
    val id : string -> id
    val num : string -> num
    val cad : string -> cadeia
  end

