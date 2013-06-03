structure Lexer :> LEXER =
  struct
    type position = {
      line :   int ref,
      column : int ref
    }

    datatype tokentype =
        Sub
      | Se
      | Repetir
      | Retornar
      | Inicializado
      | Suspenso
      | Executando
      | Finalizado
      | Verdadeiro
      | Falso
      | Cadeia
      | Id
      | Num
      | LParen
      | RParen
      | LBracket
      | RBracket
      | LCurly
      | RCurly
      | Comma
      | EQ
      | Semi
      | EOF

    type token = {
      tokentype : tokentype,
      text      : string
    }
      
    type lexer = {
      input    : TextIO.instream,
      token    : (token option) ref,
      position : position
    }

    exception NotReady
    exception BadToken of {
      line : int,
      column : int, 
      errmsg : string
    }
    
    (* le um token de input *)
    fun readToken input line column =
      let
        (* inicio do token *)
        val beginLine   = !line
        val beginColumn = !column
        (* caracter corrente na entrada, não o consome *)
        fun peek () =
          TextIO.lookahead input
        (* caracter corrente na entrada, o consome e atualiza linha e coluna *)
        and next () = 
          let
            fun updateLineColumn #"\n" = (line := !line + 1; column := 1)
              | updateLineColumn  _    = column := !column + 1
            val optC = TextIO.input1 input
          in
            case optC of
              NONE   => optC
            | SOME c => (updateLineColumn c; optC)
          end
        (* estado inicial do automato *)
        and s    NONE       _     = {tokentype=EOF, text=""}
          | s (SOME #"(")   _     = {tokentype=LParen, text=""}
          | s (SOME #")")   _     = {tokentype=RParen, text=""}
          | s (SOME #"[")   _     = {tokentype=LBracket, text=""}
          | s (SOME #"]")   _     = {tokentype=RBracket, text=""}
          | s (SOME #"{")   _     = {tokentype=LCurly, text=""}
          | s (SOME #"}")   _     = {tokentype=RCurly, text=""}
          | s (SOME #",")   _     = {tokentype=Comma, text=""}
          | s (SOME #"=")   _     = {tokentype=EQ, text=""}
          | s (SOME #";")   _     = {tokentype=Semi, text=""}
          | s (SOME #"@")   clist = estado (#"@" :: clist)
          | s (SOME #"\"")  clist = cadeia clist
          (*| s (SOME #"#")  = comentario ()*)
          | s (SOME c) clist = 
              if (Char.isSpace c)
                then s (next ()) []
                else
                  let
                    val clist2 = c :: clist
                  in 
                    if (Char.isDigit c) 
                      then num clist2
                      else if (Char.isAlpha c)
                        then keywordOrId clist2
                        else error (Char.toString c)
                  end
        (* leitura de estado *)
        and estado clist =
          let val word = readWord clist in 
            case word of
              "@inicializado" => {tokentype=Inicializado, text=""}
            | "@suspenso"     => {tokentype=Suspenso, text=""}
            | "@executando"   => {tokentype=Executando, text=""}
            | "@finalizado"   => {tokentype=Finalizado, text=""}
            |  s => error s
          end
        (* leitura de cadeia *)
        and cadeia clist =
          let
            fun loop (SOME #"\"") clist = {tokentype=Cadeia, text=strByRevCharList clist}
              | loop (SOME c)     clist = loop (next ()) (c :: clist)
              | loop  NONE        _     = error "EOF"
          in
            loop (next ()) clist
          end
        (* leitura de numero *)
        and num clist = 
          let
            fun loop clist =
              case (peek ()) of
                NONE => {tokentype=Num, text=strByRevCharList clist}
              | SOME c =>
                  if (Char.isDigit c)
                    then (next (); loop (c::clist))
                    else {tokentype=Num, text=strByRevCharList clist}
          in
            loop clist
          end
        (* Leitura de palavra chave ou identificador *)
        and keywordOrId clist =
          case (readWord clist) of
            "sub"      => {tokentype=Sub, text=""}
          | "se"       => {tokentype=Se, text=""}
          | "repetir"  => {tokentype=Repetir, text=""}
          | "retornar" => {tokentype=Retornar, text=""}
          | "true"     => {tokentype=Verdadeiro, text=""}
          | "false"    => {tokentype=Falso, text=""}
          |  s         => {tokentype=Id, text=s}
        (* auxiliar: le uma palavra *)
        and readWord clist =
          let
            fun loop clist =
              case (peek ()) of
                NONE   => strByRevCharList clist
              | SOME c =>
                  if (Char.isAlphaNum c) 
                    then (next (); loop (c :: clist))
                    else strByRevCharList clist
          in
            loop clist
          end
        (* auxiliar: de lista de caracters em ordem inversa para string *)
        and strByRevCharList l =
          String.implode (List.rev l)
        (* auxiliar: erro *)
        and error msg = raise BadToken {
          line   = beginLine,
          column = beginColumn,
          errmsg = msg
        }
      in
        s (next ()) []
      end
      
    fun init input = { 
      input    = input,
      token    = ref NONE,
      position = {
	line   = ref 0,
	column = ref 0
      }
    }
    
    fun peek ({token=curtoken, ...} : lexer) =
      case (!curtoken) of
        NONE  => raise NotReady
      | SOME token => token
  
    fun next ({input=input, token=token, position={line=line, column=column}}) =
      token := SOME (readToken input line column)
  
  end


