(*
 * Maestro: orquestrador de processos
 * Licença: LGPL 2.0
 * Autores: 
 *   Fabio Alexandre Campos Tisovec
 *   Jorge Augusto Sabaliauskas
 *   Márcio Fernando Stabile Junior
 *   Ramon Fortes Pereira
 *)
structure DebugSemantic :> SEMANTIC =
  struct
    type maestro = unit
    type sub     = unit
    type bloco   = unit
    type cmd     = unit
    type expr    = unit
    type id      = unit
    type cadeia  = unit
    type num     = unit
    
    exception RuntimeError of string
    
    fun maestro subs = print "maestro\n"
    fun sub id ids bloco = print "sub\n"
    fun bloco cmds = print "bloco\n"
    fun cmdSe expr bloco = print "cmdSe\n"
    fun cmdRep num bloco = print "cmdRep\n"
    fun cmdAtr id expr = print "cmdAtr\n"
    fun cmdRet expr = print "cmdRet\n"
    fun cmdCall id exprs = print "cmdCall\n"
    fun exprId id = print "exprId\n" 
    val exprInic = ()
    val exprSusp = ()
    val exprExec = ()
    val exprFin = ()
    fun exprCad cad = print "exprCad\n"
    fun exprCall id exps = print "exprCall\n"
    val exprVerd = ()
    val exprFalso = ()
    fun id s = print ("id: " ^ s ^ "\n")
    fun num s = print ("num: " ^ s ^ "\n")
    fun cad s = print ("cad: " ^ s ^ "\n") 
  end


