structure Maestro =
  struct
    structure PosixSemantic = MakeSemantic(PosixProcManager)
    structure Parser = MakeParser(PosixSemantic)

    fun maestro filename =
      let
        fun printError errmsg =
          print ("error: " ^ errmsg ^ "\n")
      in
        Parser.parse (TextIO.openIn filename) ()
        handle
          Lexer.BadToken {line=_, column=_, errmsg=msg} => printError msg
        | Parser.SyntaxError => printError "erro de sintaxe"
        | PosixSemantic.RuntimeError msg => printError msg
      end

    fun main (name:string, args:string list) : OS.Process.status =
      let val () =
        case CommandLine.arguments () of
          filename::[] => maestro filename
        | _ => print "usage:\n\n   maestro <source>\n\n"
      in
        OS.Process.success
      end

  end
