(* calc.sml *)

(* This file provides glue code for building the calculator using the
 * parser and lexer specified in calc.lex and calc.grm.
*)

(*structure Calc : sig val parse : unit -> unit  end = struct*)

(* parser.sml *)
(* driver for Pascal parser *)


(*structure Parser : sig val parse : unit -> unit  end = struct*)
structure Maestro = struct

(* 
 * We apply the functors generated from calc.lex and calc.grm to produce
 * the CalcParser structure.
 *)

  
structure MaestroLrVals = MaestroLrValsFun(structure Token = LrParser.Token)

structure MaestroLex = MaestroLexFun(structure Tokens = MaestroLrVals.Tokens)


structure MaestroParser =   Join(structure Lex = MaestroLex
  		      structure LrParser = LrParser
			      structure ParserData = MaestroLrVals.ParserData)


fun parse s =
    let val dev = TextIO.openIn s
	val stream = MaestroParser.makeLexer(fn i => TextIO.inputN(dev,i))
	fun error (e,i:int,_) =
	    TextIO.output(TextIO.stdOut,
               s ^ "," ^ " line " ^ (Int.toString i) ^ ", Error: " ^ e ^ "\n")
     in MaestroLex.UserDeclarations.pos := 1;
        MaestroParser.parse(30,stream,error,())
        before TextIO.closeIn dev
    end

fun keybd () =
    let val stream = 
	    MaestroParser.makeLexer (fn i => (case TextIO.inputLine TextIO.stdIn
                                              of SOME s => s
                                               | _ => ""))
        fun error (e,i:int,_) =
	    TextIO.output(TextIO.stdOut,
              "std_in," ^ " line " ^ (Int.toString i) ^ ", Error: " ^ e ^ "\n")
     in MaestroLex.UserDeclarations.pos := 1;
	MaestroParser.parse(0,stream,error,())
    end

end (* structure Parser *)
