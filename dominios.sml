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
        int * int -> estado -> estado * estado -> estado
    datatype id =
        Id of string
    datatype valor =
        Booleano of bool
      | Cadeia of string
      | NomeEstado of nomeestado
      | Comando of comando
      | Processo of processo

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
    val removerEscutadorEvento : filaeventos -> processo -> filaeventos

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
