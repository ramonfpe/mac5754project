(*
 * Maestro: orquestrador de processos
 * Licença: LGPL 2.0
 * Autores: 
 *   Fabio Alexandre Campos Tisovec
 *   Jorge Augusto Sabaliauskas
 *   Márcio Fernando Stabile Junior
 *   Ramon Fortes Pereira
 *)

functor MakeSemantic(PM : PROC_MANAGER) : SEMANTIC =
  struct
    (* valores manipulados pelo programador *)
    datatype valor =
      ValBooleano of bool
    | ValCadeia of cadeia
    | ValStatus of PM.status
    | ValComando of comando
    | ValProcesso of PM.pid
    
    (* listeners de processo: mutavel ! *)
    and listeners = Listeners of (PM.pid * PM.status * (comando ref)) list ref

    (* contexto atua como lista de associacoes de id para valor ref: mutavel ! *)
    withtype context = (string * (valor ref)) list ref
    
    (* ambiente atua como pilha de contextos: mutavel ! *)
    and environment = context list ref

    (* lista de dependencias: mutavel ! *)
    and dependencies = (PM.pid * PM.pid) list ref

    (* estado do programa: mutavel ! *)
    and estado = { 
        env       : environment,  (* ambiente *)
        result    : valor ref,    (* resultado de uma expressao *)
        listeners : listeners,    (* listeners de processo *)
        deps      : dependencies  (* dependencias *)
      }    

    (* tipo de um comando *)
    and comando = estado -> valor list -> estado
    
    (* valores manipulados pelo parser *)
    and maestro = unit -> unit
    and sub     = string * valor
    and bloco   = estado -> estado
    and cmd     = (estado -> estado) -> (estado -> estado)
    and expr    = estado -> estado
    and id      = string
    and cadeia  = string
    and num     = int
    
    exception RuntimeError of string
    exception IllegalState (* representa um erro de programacao *)

    (* procura uma referencia para um valor em um contexto *)
    fun lookupCtx (ctx:context) (id:string) : valor ref option =
      let
        fun lookupCtx []                   = NONE
          | lookupCtx ((curId:string, cell)::ctx) =
              if id = curId
                then SOME cell
                else lookupCtx ctx
      in
        lookupCtx (!ctx)
      end

    (* procura um valor no ambiente recursivamente *)
    fun lookupVal (env:environment) (id:string) : valor =
      let
        fun lookupVal []          =
              raise RuntimeError ("nome " ^ id ^ "desconhecido")
          | lookupVal (ctx::ctxs) =
              case lookupCtx ctx id of
                SOME cell => !cell
              | NONE      => lookupVal ctxs
       in
         lookupVal (!env)
       end

    (* associa um nome a um valor em um contexto *)
    fun bindValCtx (ctx:context) (id:string) (valor:valor) : unit =
      case lookupCtx ctx id of
        SOME cell => cell := valor
      | NONE      => ctx := (id, ref valor) :: !ctx

    (* associa um nome a um valor no contexto mais ao topo do ambiente *)
    fun bindVal (env:environment) (id:string) (valor:valor) : unit =
      case !env of
        []       => raise IllegalState
      | (ctx::_) => bindValCtx ctx id valor

    (* prepara o estado para uma chamada de comando (empilha novo contexto) *)
    fun enterCall (estado:estado) : unit =
      let val env = #env estado in
        env := (ref []) :: !env
      end

    (* corrige o estado apos uma chamada de funcao (desempilha novo contexto) *)
    fun leaveCall (estado:estado) : unit =
      let val env = #env estado in
        env := List.tl (!env)
      end
    
    (* realiza a chamada de uma funcao *)
    fun call (estado:estado) (valor:valor) (aparams:valor list) : estado =
      case valor of
        ValComando cmd => cmd estado aparams
      | _              => raise RuntimeError "chamada de nao-comando"

    (* atualiza o resultado de uma expressao *)
    fun updateResult (estado:estado) (valor:valor) : estado = 
      let val () = (#result estado) := valor in
        estado 
      end

    (* de uma lista de expressoes para uma lista de valores *)
    fun evalExprs (estado:estado) (exprs:expr list) = 
      let
        fun evalExprs e []        vs = (e, List.rev vs)
          | evalExprs (e:estado) (ex::exs) vs =
              let
                val e2    = ex e 
                val valor = #result e2
              in
                evalExprs e2 exs (!valor :: vs)
              end
      in
        evalExprs estado exprs []
      end

    (* de um valor booleano para seu valor negado *)
    fun boolNao (estado:estado) (ValBooleano b::[]) = 
        updateResult estado (ValBooleano (not b))
      | boolNao _ _ =
          raise RuntimeError "parametros incorretos para a funcao Nao"

    (* de dois valores booleanos para um valor booleano *)
    fun boolE (estado:estado) (ValBooleano b1::(ValBooleano b2::[])) = 
        updateResult estado (ValBooleano (b1 andalso b2))
      | boolE _ _ =
          raise RuntimeError "parametros incorretos para a funcao E"

    (* de dois valores booleanos para um valor booleano *)
    fun boolOu (estado:estado) (ValBooleano b1::(ValBooleano b2::[])) = 
        updateResult estado (ValBooleano (b1 orelse b2))
      | boolOu _ _ =
          raise RuntimeError "parametros incorretos para a funcao Ou"

    (* procura por um callback para um processo + status *)
    fun getListenerCmdRef listeners (pid:PM.pid) (status:PM.status) : comando ref option =
      let
        fun find [] = NONE
          | find ((p:PM.pid, s:PM.status, cmdref:comando ref)::ls) =
              if (p = pid) andalso (s = status)
                then SOME cmdref
                else find ls
      in
        find (!listeners)
      end

    fun getListenerCmd (estado:estado) (pid:PM.pid) (status:PM.status) : comando option =
      let val (Listeners listeners) = #listeners estado in
        case getListenerCmdRef listeners pid status of
          SOME cmdref => SOME (!cmdref)
        | NONE        => NONE
      end

    (* adiciona um listener para um processo *)
    fun addListerner (estado:estado) (pid:PM.pid) (status:PM.status) (cmd:comando) : estado =
      let
        val (Listeners listeners) = #listeners estado
        val () =
          case getListenerCmdRef listeners pid status of
            SOME cmdref => cmdref := cmd
          | NONE => listeners := (pid, status, ref cmd) :: !listeners
      in
        estado
      end

    (* funcao pre-definida: exibe mensagens de texto *)
    fun registrar estado (ValCadeia msg::[]) =
          (print (msg ^ "\n"); estado)
      | registrar _ _ =
          raise RuntimeError "parametros incorretos para a funcao registrar"

    (* funcao pre-definida: cria um novo processo *)
    fun processo estado (ValCadeia cmdline::[]) =
          updateResult estado (ValProcesso (PM.execute cmdline))
      | processo _ _ =
          raise RuntimeError "parametros incorretos para a funcao processo"

    (* funcao pre-definida: adiciona um listener a um processo *)
    fun quando estado ((ValProcesso pid)::(ValStatus status)::(ValComando cmd)::[]) =
          addListerner estado pid status cmd 
      | quando _ _ =
          raise RuntimeError "parametros incorretos para a funcao quando"

    (* funcao pre-definida: adiciona uma dependencia a um processo *)
    fun dependencia (estado:estado) ((ValProcesso dependency)::(ValProcesso dependent)::[]) =
          let
            val deps  = #deps estado
            val duple = (dependent, dependency)
            val () =
              case List.find (fn d => d = duple) (!deps) of
                SOME _ => ()
              | NONE   => deps := duple :: !deps
          in
            estado
          end
      | dependencia _ _ =
          raise RuntimeError "parametros incorretos para a funcao dependencia"

    (*
     * propaga para as dependencias de um processo que mudou de estado
     * uma acao que faca com que suas dependencias fiquem no mesmo estado
     * do processo que dependem
     *)
    fun propagate (estado:estado) (dependent:PM.pid) (status:PM.status) : estado =
      let
        val deps = #deps estado
        fun forDepsDo depedent f =
          List.app (fn (d, dy) => if d = depedent then f dy else ()) (!deps)
        fun stopDeps dependent =
          forDepsDo dependent (fn dy => (stopDeps dy; PM.stop dy))
        fun continueDeps dependent =
          forDepsDo dependent (fn dy => (continueDeps dy; PM.continue dy))
        fun killDeps dependent =
          let
            val (drop, retain) = List.partition (fn (d, _) => d = dependent) (!deps)
            val () = deps := retain
            val () = List.app (fn (_, dy) => killDeps dy) drop
          in
            List.app (fn (_, dy) => PM.kill dy) drop
          end
        val () =
          case status of
            PM.Initialized => ()
          | PM.Stopped => stopDeps dependent
          | PM.Executing => continueDeps dependent
          | PM.Finished => killDeps dependent
      in
        estado
      end

    (* loop de disparo de callbacks *)
    fun dispatchLoop estado =
      case PM.wait () of
        NONE => estado
      | SOME (pid, status) =>
          let val estado =
            case getListenerCmd estado pid status of
              SOME comando => comando estado [ValProcesso pid, ValStatus status]
            | NONE => estado
          in
            dispatchLoop (propagate estado pid status)
          end

    (* funcao pre-definida: criacao de um suborquestrador *)
    fun suborquestrador (estado:estado) ((ValComando comando)::[]) =
          let
            fun sub () =
              let
                val {
                      deps      = deps,
                      listeners = Listeners listeners,
                      result    = _,
                      env       = _
                    } = estado
                val ()        = listeners := []
                val ()        = deps := []
              in
                dispatchLoop (comando estado [])
              end
          in
            updateResult estado (ValProcesso (PM.executeInNewProc sub))
          end
      | suborquestrador _ _ =
          raise RuntimeError "parametros incorretos para o suborquestrador"

    (* constroi o estado inicial do maestro *) 
    fun mkEstadoInicial () : estado =
      let
        val empty = ValCadeia ""
        fun mkCtx cmdlist =
          ref (List.map (fn (id, cmd) => (id, ref (ValComando cmd))) cmdlist)
        val builtinCtx = mkCtx [
          ("registrar", registrar),
          ("processo", processo),
          ("quando", quando),
          ("dependencia", dependencia),
          ("nao", boolNao),
          ("e", boolE),
          ("ou", boolOu),
          ("suborquestrador", suborquestrador)
        ]
        val env = ref [builtinCtx]
      in
        {env=env, result=ref empty, listeners=Listeners (ref []), deps=ref []}
      end


    (* funcao de avaliacao do maestro *)
    fun maestro (subs:sub list) : maestro = 
      fn () => 
        let
          val estado  = mkEstadoInicial ()
          val env     = #env estado
          val ()      = List.app (fn (subId, cmdVal) => bindVal env subId cmdVal) subs
          val subMain = lookupVal env "main"
       in
          ignore (dispatchLoop (call estado subMain []))
        end
    
    (* funcao de avaliacao para uma sub  *)
    fun sub (id:string) (ids:string list) (bloco:bloco) : sub =
      let
        fun bindParams (estado:estado) binds =
          let val env = #env estado in
            List.app (fn (id, expr) => bindVal env id expr) binds
          end
        fun comando estado aparams =
          if (List.length aparams) <> (List.length ids)
            then
              let
                val expected = Int.toString (List.length ids)
                val found    = Int.toString (List.length aparams)
              in
                raise RuntimeError (id ^ " esperava " ^ expected 
                  ^ " mas encontrou " ^ found ^ " parametros" )
              end
            else
              let
                val ()  = enterCall estado
                val ()  = bindParams estado (ListPair.zip (ids, aparams))
                val res = bloco estado
                val ()  = leaveCall estado
              in
                res
              end
      in
        (id, ValComando comando)
      end
    
    (* funcao skip, nao faz nada *)
    fun skip (e:estado) : estado = e
    
    (* funcao de avaliacao para um bloco *)
    fun bloco (cmds:cmd list) : bloco =
      List.foldr (fn (cmd, next) => cmd next) skip cmds
    
    (* funcao de avaliacao para o comando "se" *)
    fun cmdSe (expr:expr) (bloco:bloco) : cmd =
      fn next => fn (estado:estado) =>
        let
          val estado:estado = expr estado
          val valor  = #result estado
        in
          case !valor of
            ValBooleano flag => next (if flag then (bloco estado) else estado)
          | _                => raise RuntimeError "obrigatorio uso de booleano em condicional"
        end
            
    (* funcao de avaliacao para o comando "repetir" *)
    fun cmdRep (num:int) (bloco:bloco) : cmd =
      fn next => fn estado =>
        let
          fun loop i e =
            if i <= 0
              then next e
              else loop (i-1) (bloco e)
        in
          loop num estado
        end
    
    (* funcao de avaliacao para o comando de atribuicao *)
    fun cmdAtr (id:string) (expr:expr) : cmd =
      fn next => fn (estado:estado) =>
        let 
          val (estado:estado) = expr estado
          val valor           = #result estado
          val ()              = bindVal (#env estado) id (!valor)
        in
          next estado
        end
    
    (* funcao de avaliacao para o comando de retorno *)
    fun cmdRet (expr:expr) : cmd =
      fn _ => fn estado => expr estado

    (* funcao de avaliacao para o comando de chamada *)
    fun cmdCall (id:string) (exprs:expr list) : cmd =
      fn next => fn (estado:estado) =>
        let val (estado, aparams) = evalExprs estado exprs in
          next (call estado (lookupVal (#env estado) id) aparams)
        end
    
    (* funcao de avaliacao para valor de variavel *)
    fun exprId (id:string) : expr =
      fn estado => updateResult estado (lookupVal (#env estado) id)

    (* funcao de avaliacao para o estado @inicializado *)
    val exprInic : expr =
      fn estado => updateResult estado (ValStatus PM.Initialized)
    
    (* funcao de avaliacao para o estado @suspenso *)
    val exprSusp : expr =
      fn estado => updateResult estado (ValStatus PM.Stopped)
    
    (* funcao de avaliacao para o estado @executando *)
    val exprExec : expr =
      fn estado => updateResult estado (ValStatus PM.Executing)
    
    (* funcao de avaliacao para o estado @finalizado *)
    val exprFin : expr =
      fn estado => updateResult estado (ValStatus PM.Finished)
    
    (* funcao de avaliacao para uma cadeia *)
    fun exprCad (cad:cadeia) : expr =
      fn estado => updateResult estado (ValCadeia cad)
    
    (* funcao de avaliacao de uma chamada como expressao *)
    fun exprCall (id:string) (exps:expr list) : expr =
      fn (estado:estado) =>
        let val (estado, aparams) = evalExprs estado exps in
          call estado (lookupVal (#env estado) id) aparams
        end
    
    (* funcao de avaliacao para o valor verdadeiro *)
    val exprVerd : expr =
      fn estado => updateResult estado (ValBooleano true)

    (* funcao de avaliacao para o valor falso *)
    val exprFalso : expr =
      fn estado => updateResult estado (ValBooleano false)

    fun id s = s
    fun num s =
      case Int.fromString s of
        NONE   => raise IllegalState
      | SOME i => i
    fun cad s = s
    
  end
 
