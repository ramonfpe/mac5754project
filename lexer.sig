signature LEXER =
  sig
    type lexer
    
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

    exception NotReady
    exception BadToken of {
      line : int,
      column : int, 
      errmsg : string
    }

    val init : TextIO.instream -> lexer
    val peek : lexer -> token 
    val next : lexer -> unit
  end


