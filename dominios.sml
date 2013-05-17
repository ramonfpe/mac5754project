(* interface do dominio *)
signature DOMINIO =
  sig
    (* tipos opacos *)
    type nomeestado
    type processo
    type grupoprocessos
    type dependencias
    type filaeventos
    type filaevusuario
    type ambiente
    type estado

    (* tipos transparentes *)
    type comando =
        int * (int -> estado -> (estado * estado) -> estado)
    datatype id =
        Id of string
    datatype valor =
        VBooleano of bool
      | VCadeia of string
      | VNomeEstado of nomeestado
      | VComando of comando
      | VProcesso of processo

		(* nomeestado *)
    val inicializado : nomeestado
    val executando : nomeestado
    val suspenso : nomeestado
    val finalizado : nomeestado

		(* processo *)
    val novoProcesso : string -> int -> processo
    val novoSubOrquestrador : comando -> int -> processo

    (* grupo processos *)
    val alterarProcessoGrupo : grupoprocessos -> processo -> nomeestado -> grupoprocessos
    val grupoProcessoVazio : grupoprocessos

    (* dependencias *)
    val dependenciasVazia : dependencias
    val criarDependencia : dependencias -> processo -> processo -> dependencias
    val removerDependencia : dependencias -> processo -> processo -> dependencias

    (* filaeventos *)
    val filaEventosVazia : filaeventos
    val criarEscutadorEvento : filaeventos -> processo -> nomeestado -> comando -> filaeventos
    val removerEscutadorEvento : filaeventos -> processo -> nomeestado -> filaeventos

    (* filaevusuario *)
    val filaEvUsuarioVazia : filaevusuario
    val criaEscutadorEvUsuario : filaevusuario -> processo -> string -> comando -> filaevusuario
    val removerEscutadorEvUsuario : filaevusuario -> processo -> filaevusuario

    (* ambiente *)
    val ambienteInicial : ambiente
    val extenderAmbiente : ambiente -> id -> valor -> ambiente
    val obterSimboloAmbiente : ambiente -> id -> valor -> ambiente
    val empilharAmbiente : ambiente -> ambiente

    (* estado *)
    val obterAmbiente : estado -> ambiente
    val atualizarAmbiente : estado -> ambiente -> estado
    val obterResultado : estado -> valor
    val atualizarResultado : estado -> valor -> estado
    val obterDependencias : estado -> dependencias
    val atualizarDependencias : estado -> dependencias -> estado
    val obterEventos : estado -> filaeventos
    val atualizarEventos : estado -> filaeventos -> estado
    val obterEventosUsuario : estado -> filaevusuario
    val atualizarEventosUsuario : estado -> filaevusuario
    val obterGrupoProcessos : estado -> grupoprocessos
    val atualizarGrupoProcessos : estado -> grupoprocessos -> estado
    val registrar : estado -> string -> estado
  end

(* implementacao do dominio *)
structure Dominio :> DOMINIO =
  struct
    datatype nomeestado = 
        Inicializado
      | Executando
      | Finalizado
      | Suspenso

    and processo =
        Processo of string * int
      | SubOrquestrador of comando * int

    and ambiente =
        AmbienteVazio
      | Ambiente of ((id * valor) list * ambiente)

    and id =
        Id of string

    and valor =
        VBooleano of bool
      | VCadeia of string
      | VNomeEstado of nomeestado
      | VComando of comando
      | VProcesso of processo

    and grupoprocessos = 
        GrupoProcessos of (processo * nomeestado) list

    and dependencias = 
        Dependencias of (processo * processo) list

    and filaeventos =
        FilaEventos of (processo * nomeestado * comando) list

    and filaevusuario =
        FilaEvUsuario of (processo * string * comando) list
 
    and estado =
        Estado of {
          resultado      : valor,
          ambiente       : ambiente,
          dependencias   : dependencias,
          eventos        : filaeventos,
          eventosUsuario : filaevusuario,
          processos      : grupoprocessos,
          mensagens      : string list
        }

    withtype comando = int * (int -> estado -> (estado * estado) -> estado)


		(* nomeestado *)
    val inicializado = Inicializado
    val executando = Executando
    val suspenso = Suspenso
    val finalizado = Finalizado

    (* processo *)
    fun novoProcesso nome pid =
      Processo (nome, pid)
    fun novoSubOrquestrador comando pid =
      SubOrquestrador (comando, pid)
    fun equals (Processo (_, pid1)) (Processo (_, pid2)) = pid1 = pid2
      | equals (SubOrquestrador (_, pid1)) (SubOrquestrador (_, pid2)) = pid1 = pid2
      | equals (_:processo) (_:processo) = false
    fun notEquals (p:processo) (q:processo) = not (equals p q)

    (* grupo processos *)
    val grupoProcessoVazio = GrupoProcessos []
    fun alterarProcessoGrupo (GrupoProcessos l) processo nomeestado =
      let
        fun isNotProcesso (p, _) = notEquals p processo
        val l2 = List.filter isNotProcesso l
        val l3 = (processo, nomeestado) :: l2
      in
        GrupoProcessos l3
      end
    

    (* dependencias *)
    val dependenciasVazia = Dependencias []
    fun criarDependencia (Dependencias l) dependent dependency =
      Dependencias ((dependent, dependency) :: l)
    fun removerDependencia (Dependencias l) dependent dependency =
      let
        fun isNotDep (dt, dy) =
          (notEquals dt dependent) orelse (notEquals dy dependency)
        val l2 = List.filter isNotDep l 
      in 
        Dependencias l2
      end

    (* filaeventos *)
    val filaEventosVazia  = FilaEventos []
    fun criarEscutadorEvento filaeventos processo nomeestado comando = 
      let
        val (FilaEventos l2) =
          removerEscutadorEvento filaeventos processo nomeestado
        val l3 = (processo, nomeestado, comando) :: l2
      in
        FilaEventos l3
      end
    and removerEscutadorEvento (FilaEventos l) processo nomeestado =
      let
        fun isNotEscutador (p, ne, _) =
          ne <> nomeestado andalso (notEquals p processo)
        val l2 = List.filter isNotEscutador l
      in
        FilaEventos l2
      end
      

    (* filaevusuario *)
    val filaEvUsuarioVazia = FilaEvUsuario []
    fun criaEscutadorEvUsuario filaevusuario processo string comando =
      raise Match
    fun removerEscutadorEvUsuario filaevusuario processo =
      raise Match

    (* ambiente *)
    val ambienteInicial = AmbienteVazio
    fun extenderAmbiente ambiente id valor =
      raise Match
    fun obterSimboloAmbiente ambiente id valor =
      raise Match
    fun empilharAmbiente ambiente =
      raise Match

    (* estado *)
    fun obterAmbiente estado =
      raise Match
    fun atualizarAmbiente estado ambiente =
      raise Match
    fun obterResultado estado =
      raise Match
    fun atualizarResultado estado valor =
      raise Match
    fun obterDependencias estado =
      raise Match
    fun atualizarDependencias estado dependencias =
      raise Match
    fun obterEventos estado =
      raise Match
    fun atualizarEventos estado filaeventos =
      raise Match
    fun obterEventosUsuario estado =
      raise Match 
    fun atualizarEventosUsuario estado =
      raise Match
    fun obterGrupoProcessos estado =
      raise Match
    fun atualizarGrupoProcessos estado grupoprocessos =
      raise Match
    fun registrar estado string =
      raise Match

  end