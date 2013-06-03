(*
 * Maestro: orquestrador de processos
 * Licença: LGPL 2.0
 * Autores: 
 *   Fabio Alexandre Campos Tisovec
 *   Jorge Augusto Sabaliauskas
 *   Márcio Fernando Stabile Junior
 *   Ramon Fortes Pereira
 *)
functor MakeParser(Semantic:SEMANTIC) : PARSER =
  struct
    type result = Semantic.maestro

    exception SyntaxError
    
    fun parse input =
      let
        val lexer = Lexer.init input
        (* auxilar: avanca proximo token *)
        fun next () = 
          let
            val token = Lexer.peek lexer
            val _     = Lexer.next lexer
          in
            token
          end
        (* auxiliar: tokentype atual *)
        fun peekTokenType () =
          #tokentype (Lexer.peek lexer)
        (* auxiliar: testa um token *)
        fun isTokenType tokentype =
          tokentype = (peekTokenType ())
        (* auxilar: consome um token *)
        fun consume tokentype =
          let
            val token = Lexer.peek lexer
          in
            if (isTokenType tokentype)
              then (next (); token)
              else raise SyntaxError
          end
        (* maestro = { sub }. *)
        fun maestro () =
          let
            val subs =
              let
                val subsmut = ref []
                val () =
                  while (isTokenType Lexer.Sub) do
                    subsmut := (sub ()) :: !subsmut
              in
                List.rev (!subsmut)
              end             
          in
            Semantic.maestro subs
          end
        (* sub = "sub” ID “(” [ ID {“,” ID } ] “)” bloco. *)
        and sub () =
          let
            val _   = consume Lexer.Sub
            val id  = Semantic.id (#text (consume Lexer.Id))
            val _   = consume Lexer.LParen
            val fparams =
              let 
                val fpsref = ref []
                val () =
                  if not (isTokenType Lexer.RParen)              
                    then
                      let
                        fun consumeId () =
                          let
                            val idstr = #text (consume Lexer.Id)
                          in
                            fpsref := (Semantic.id idstr) :: !fpsref
                          end
                        val _ = consumeId ()
                      in
                        while not (isTokenType Lexer.RParen) do
                          let
                            val _  = consume Lexer.Comma
                          in
                            consumeId ()
                          end
                      end
                    else ()
              in
                List.rev (!fpsref)
              end
            val _ = next ()
            val bloco = bloco ()
          in
            Semantic.sub id fparams bloco
          end
        (*
         * cmd = “se” expr bloco
         *     | “repetir” NUM bloco
         *     | [ ID “=” ] ID { expr } ";"
         *     | “retornar” expr ";".
         *)
        and cmd () =
          case (peekTokenType ()) of
            Lexer.Se =>
              let
                val _     = next ()
                val expr  = expr ()
                val bloco = bloco ()
              in
                Semantic.cmdSe expr bloco
              end
          | Lexer.Repetir =>
              let
                val _     = next ()
                val num   = Semantic.num (#text (consume Lexer.Num))
                val bloco = bloco ()
              in
                Semantic.cmdRep num bloco
              end
          | Lexer.Id =>
              let
                val id = Semantic.id (#text (next ()))
                fun exprs () =
                  let
                    val exprsmut = ref []
                    val () =
                      while not (isTokenType Lexer.Semi) do
                        exprsmut := (expr ()) :: !exprsmut
                    val _ = next ()
                  in
                    List.rev (!exprsmut)
                  end
              in
                if (isTokenType Lexer.EQ)
                  then
                    let
                      val _     = next ()
                      val subid = Semantic.id (#text (next ()))
                      val expr  = Semantic.exprCall subid (exprs ())
                    in
                      Semantic.cmdAtr id expr
                    end
                  else
                    Semantic.cmdCall id (exprs ())
              end
          | Lexer.Retornar => 
              let
                val _    = next ()
                val expr = expr ()
                val _    = consume Lexer.Semi
              in
                Semantic.cmdRet expr
              end
          | _ =>
              raise SyntaxError
        (* 
         * expr = ID
         *      | “@” (“inicializado”|“suspenso”|“executando”|“finalizado”)
         *      | CADEIA
         *      | “[” ID { expr } “]”
         *      | (“verdadeiro”|“falso”)
         *)
        and expr () =
           case peekTokenType () of
             Lexer.Inicializado => 
               let
                 val _ = next ()
               in
                 Semantic.exprInic
               end
           | Lexer.Suspenso => 
               let
                 val _ = next ()
               in
                 Semantic.exprSusp
               end
           | Lexer.Executando => 
               let
                 val _ = next ()
               in
                 Semantic.exprExec
               end
           | Lexer.Finalizado => 
               let
                 val _ = next ()
               in
                 Semantic.exprFin
               end
           | Lexer.Cadeia => 
               let
                 val str = #text (next ())
               in 
                 Semantic.exprCad (Semantic.cad str)
               end
           | Lexer.LBracket => 
               let
                 val _  = next ()
                 val id =
                   let
                     val idstr = #text (consume Lexer.Id)
                   in
                     Semantic.id idstr
                   end
                 val exprs =
                   let
                     val exprsmut = ref []
                     val _ =
                       while not (isTokenType Lexer.RBracket) do
                         exprsmut := (expr ()) :: !exprsmut
                   in
                     List.rev (!exprsmut)
                   end
                 val _ = next ()
               in
                 Semantic.exprCall id exprs
               end
           | Lexer.Verdadeiro =>
               let
                 val _ = next ()
               in
                 Semantic.exprVerd
               end
           | Lexer.Falso =>
               let
                 val _ = next ()
               in
                 Semantic.exprFalso
               end
           | Lexer.Id =>
               let
                 val idstr = #text (next ())
               in
                 Semantic.exprId (Semantic.id idstr)
               end
           | _ =>
               raise SyntaxError
        (* bloco = “{” { cmd } “}” . *)
        and bloco () =
          let
            val _ = consume Lexer.LCurly
            val cmds =
              let
                val cmdsmut = ref []
                val () =
                  while not (isTokenType Lexer.RCurly) do
                    cmdsmut := (cmd ()) :: !cmdsmut
              in
                !cmdsmut
              end
            val _ = next ()
          in
            Semantic.bloco (List.rev cmds)
          end
        (* inicializa o lexer *)
        val () = Lexer.next lexer
      in
        maestro ()
      end
  end


