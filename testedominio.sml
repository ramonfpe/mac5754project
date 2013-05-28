print "\n\tCarregando Dominios do Maestro:\n\n";
use "dominios.sml";
print "\n\tTestando Tipos Opacos:\n\n";

val inicial : Dominio.nomeestado = Dominio.inicializado;
val exec : Dominio.nomeestado = Dominio.executando;
val susp : Dominio.nomeestado = Dominio.suspenso;
val fina : Dominio.nomeestado = Dominio.finalizado;
val p : Dominio.processo = (Dominio.novoProcesso( "novo1" )) (1);
val gpro  : Dominio.grupoprocessos = Dominio.grupoProcessoVazio;
val dpen : Dominio.dependencias = Dominio.dependenciasVazia;

val filev  : Dominio.filaeventos = Dominio.filaEventosVazia;
val filus : Dominio.filaevusuario = Dominio.filaEvUsuarioVazia;
val amb  : Dominio.ambiente = Dominio.ambienteInicial;


(*
val est  : Dominio.estado = 
Estado 
(
    {
      resultado = (Dominio.VNomeEstado Dominio.inicializado)
      ,ambiente = amb
      ,dependencias = dpen
      ,eventos = filev
      ,eventosUsuario = filus
      ,processos = gpro
      ,mensagens = ["oi","oi2"]
    }
);
    
*)

print "\n\tTestando Tipos Transparentes:\n\n";

val testeid : Dominio.id = Dominio.Id "variavel x";
val valorBool : Dominio.valor = Dominio.VBooleano true;
val valorBool = Dominio.VBooleano false;
      
val valorcad : Dominio.valor = Dominio.VCadeia ("oi sou caracteres");
val valornomestado : Dominio.valor = Dominio.VNomeEstado Dominio.inicializado;
val valorproce : Dominio.valor = Dominio.VProcesso ((Dominio.novoProcesso( "novo1" )) (1));

(*  
    type comando =
        int * (int -> estado -> (estado * estado) -> estado)
val valorcom : Dominio.valor = Dominio.VComando of comando

*)

print "\n\tTestando Funcoes de Processo:\n\n";

val mapeaProcesso = Dominio.novoProcesso( "novo1" );
val processoX = mapeaProcesso(3);

val gpro  : Dominio.grupoprocessos = Dominio.grupoProcessoVazio;
(*
val funcao
    (* grupo processos *)
    val alterarProcessoGrupo : grupoprocessos -> processo -> nomeestado -> grupoprocessos


(*  *)
    (* processo *)
    val novoSubOrquestrador : comando -> int -> processo


print "\n\tTestando Funcoes de Dependencia:\n\n";

    (* dependencias *)
    val dependenciasVazia : dependencias
    val criarDependencia : dependencias -> processo -> processo -> dependencias
    val removerDependencia : dependencias -> processo -> processo -> dependencias

print "\n\tTestando Funcoes de Fila de Eventos:\n\n";

    (* filaeventos *)
    val filaEventosVazia : filaeventos
    val criarEscutadorEvento : filaeventos -> processo -> nomeestado -> comando -> filaeventos
    val removerEscutadorEvento : filaeventos -> processo -> nomeestado -> filaeventos

print "\n\tTestando Funcoes de Fila de Usuarios:\n\n";

    (* filaevusuario *)
    val filaEvUsuarioVazia : filaevusuario
    val criaEscutadorEvUsuario : filaevusuario -> processo -> string -> comando -> filaevusuario
    val removerEscutadorEvUsuario : filaevusuario -> processo -> string -> filaevusuario

print "\n\tTestando Funcoes de Ambiente:\n\n";

    (* ambiente *)
    exception NaoEncontrado of id
    val ambienteInicial : ambiente
    val extenderAmbiente : ambiente -> id -> valor -> ambiente
    val obterSimboloAmbiente : ambiente -> id -> valor

print "\n\tTestando Funcoes de Estado :\n\n";

    (*Marcio : estado *)
    val obterAmbiente : estado -> ambiente
    val atualizarAmbiente : estado -> ambiente -> estado
    val obterResultado : estado -> valor
    val atualizarResultado : estado -> valor -> estado
    val obterDependencias : estado -> dependencias
    val atualizarDependencias : estado -> dependencias -> estado
    val obterEventos : estado -> filaeventos
    val atualizarEventos : estado -> filaeventos -> estado
    val obterEventosUsuario : estado -> filaevusuario
    val atualizarEventosUsuario : estado -> filaevusuario -> estado
    val obterGrupoProcessos : estado -> grupoprocessos
    val atualizarGrupoProcessos : estado -> grupoprocessos -> estado
    val registrar : estado -> string -> estado

*)

(*
print "\n\tBrincando com DataTypes:\n\n";

datatype cor = verde | vermelho ;
fun esverdear unit = verde;
fun esvermelhar unit = vermelho ;
val carro : cor = esverdear();

print "\n\tBrincando com Records :\n\n";

{make="Toyota", model="Corolla", year=1986, color="silver"};

val meucarro = {color="silver",make="Toyota",model="Corolla",year=1986};

datatype carro = Carro of 
{
  color:string
  , make:string
  , model:string
  , year:int
} 

val meucarro2 : carro = Carro( {color="silver",make="Toyota",model="Corolla",year=1986} );
*)
