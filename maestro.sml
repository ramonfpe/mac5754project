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
    

(* 
 * We need a function which given a lexer invokes the parser. The
 * function invoke does this.
 *)

  fun invoke lexstream =
      let fun print_error (s,i:int,_) =
	      TextIO.output(TextIO.stdOut,
			    "Error, line " ^ (Int.toString i) ^ ", " ^ s ^ "\n")
       in MaestroParser.parse(0,lexstream,print_error,())
      end

(* 
 * Finally, we need a driver function that reads one or more expressions
 * from the standard input. The function parse, shown below, does
 * this. It runs the calculator on the standard input and terminates when
 * an end-of-file is encountered.
 *)

  fun parse () = 
      let val lexer = MaestroParser.makeLexer (fn _ =>
                                               (case TextIO.inputLine TextIO.stdIn
                                                of SOME s => s
                                                 | _ => ""))
	  val dummyEOF = MaestroLrVals.Tokens.EOF(0,0)
	  val dummySEMI = MaestroLrVals.Tokens.SEMI(0,0)
	  fun loop lexer =
	      let val (result,lexer) = invoke lexer
		  val (nextToken,lexer) = MaestroParser.Stream.get lexer
		  val _ = case result
			    of SOME r =>
				TextIO.output(TextIO.stdOut,
				       "result = " ^ (Int.toString r) ^ "\n")
			     | NONE => ()
	       in if MaestroParser.sameToken(nextToken,dummyEOF) then ()
		  else loop lexer
	      end
       in loop lexer
      end

end (* structure Parser *)
