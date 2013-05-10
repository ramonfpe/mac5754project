type comando = int * int -> estado -> estado * estado -> estado

signature NOMEESTADO =
  sig
    type nomeestado
    val inicializado : nomeestado
    val executando : nomeestado
    val suspenso : nomeestado
    val finalizado : nomeestado
  end

signature PROCESSO =
  sig
    type processo
    val novoProcesso : string -> int -> processo
    val novoSubOrquestrador : comando -> int -> processo
  end

signature GRUPOPROCESSOS =
  sig
    type grupoprocessos
    val alterarProcessoGrupo : grupoprocessos -> Processo.processo -> NOMEESTADO.nomeestado -> grupoprocessos
    val grupoProcessoVazio : grupoprocessos
  end

signature DEPENDENCIAS =
  sig
    type dependencias
    val dependenciasVazia : dependencias
    val criarDependencia : dependencias -> PROCESSO.processo -> PROCESSO.processo -> dependencias
    val removerDependencia : dependencias -> PROCESSO.processo -> PROCESSO.processo -> dependencias
  end

signature FILAEVENTOS =
  sig
    type filaeventos
    val filaEventosVazia : filaeventos
    val criarEscutadorEvento : filaeventos -> PROCESSO.processo -> NOMEESTADO.nomeestado -> comando -> filaeventos
    val removerEscutadorEvento : filaeventos -> PROCESSO.processo -> filaeventos
  end

signature FILAEVUSUARIO =
  sig
    type filaevusuario
    val filaEvUsuarioVazia : filaevusuario
    val criaEscutadorEvUsuario : filaevusuario -> PROCESSO.processo -> string -> comando -> filaevusuario
    val removerEscutadorEvUsuario : filaevusuario -> PROCESSO.processo -> filaevusuario
  end

signature AMBIENTE = 
  sig
    type ambiente
    val ambienteInicial : ambiente
    val extenderAmbiente : ambiente -> id -> valor -> ambiente
    val obterSimboloAmbiente : ambiente -> id -> valor -> ambiente
    val empilharAmbiente : ambiente -> ambiente
  end

signature ESTADO =
  sig
    type estado
    val obterAmbiente : estado -> AMBIENTE.ambiente
    val atualizarAmbiente : estado -> AMBIENTE.ambiente -> estado
    val obterResultado : estado -> valor
    val atualizarResultado : estado -> valor -> estado
    val obterDependencias : estado -> DEPENDENCIAS.dependencias
    val atualizarDependencias : estado -> DEPENDENCIAS.dependencias -> estado
    val obterEventos : estado -> FILAEVENTOS.filaeventos
    val atualizarEventos : estado -> FILAEVENTOS.filaeventos -> estado
    val obterEventosUsuario : estado -> FILAEVUSUARIO.filaevusuario
    val atualizarEventosUsuario : estado -> FILAEVUSUARIO.filaevusuario
    val obterGrupoProcessos :
    val atualizarGrupoProcessos :
    val registrar :
  end

datatype valor =
  Booleano of bool
| Cadeia of string
| NOMEESTADO of NOMEESTADO.nomeestado
| Comando of comando
| Processo of PROCESSO.processo

datatype id = Id of string

