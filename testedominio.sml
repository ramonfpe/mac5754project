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
val est  : Dominio.estado = Dominio.estadoInicial;


print "\n\tTestando Tipos Transparentes:\n\n";

val testeid : Dominio.id = Dominio.Id "variavel x";

val comdVazio : Dominio.comando 
= (1,
fn ( x: int) 
      => fn (m1:Dominio.estado) 
	    => fn (n1:Dominio.estado, n2:Dominio.estado) => n1
);

val valorBool : Dominio.valor = Dominio.VBooleano true;
val valorBool = Dominio.VBooleano false;
      
val valorcad : Dominio.valor = Dominio.VCadeia ("oi sou caracteres");
val valornomestado : Dominio.valor = Dominio.VNomeEstado Dominio.inicializado;
val valorproce : Dominio.valor = Dominio.VProcesso ((Dominio.novoProcesso( "novo1" )) (1));
val valorcom : Dominio.valor = Dominio.VComando 
(
    (1,
    fn ( x: int) 
	      => fn (m1:Dominio.estado) 
		=> fn (n1:Dominio.estado, n2:Dominio.estado) => n1
    )
);

print "\n\tTestando Funcoes de Processo:\n\n";

val processoX : Dominio.processo = Dominio.novoProcesso "processoX" 3;
val gpro  : Dominio.grupoprocessos = Dominio.grupoProcessoVazio;
val gpro2  : Dominio.grupoprocessos = Dominio.alterarProcessoGrupo gpro processoX Dominio.inicializado;
val processoSubOrquestador : Dominio.processo = Dominio.novoSubOrquestrador comdVazio 7;

    (* processo
    val novoProcesso : string -> int -> processo
    val novoSubOrquestrador : comando -> int -> processo
    val alterarProcessoGrupo : grupoprocessos -> processo -> nomeestado -> grupoprocessos
    val grupoProcessoVazio : grupoprocessos
    *)

print "\n\tTestando Funcoes de Dependencia:\n\n";

val dependencias : Dominio.dependencias = Dominio.dependenciasVazia;
val dependenciasAtualizadas : Dominio.dependencias = Dominio.criarDependencia dependencias processoX processoSubOrquestador;
val dependenciasAtualizadas : Dominio.dependencias = Dominio.removerDependencia dependencias processoX processoSubOrquestador;

    (* dependencias 
    val dependenciasVazia : dependencias
    val criarDependencia : dependencias -> processo -> processo -> dependencias
    val removerDependencia : dependencias -> processo -> processo -> dependencias
    *)
print "\n\tTestando Funcoes de Fila de Eventos:\n\n";

val filaEventos : Dominio.filaeventos = Dominio.filaEventosVazia;
val filaEventosAtualizada : Dominio.filaeventos = Dominio.criarEscutadorEvento filaEventos processoX Dominio.inicializado comdVazio;
val filaEventosAtualizada : Dominio.filaeventos = Dominio.removerEscutadorEvento filaEventos processoX Dominio.inicializado;

    (* filaeventos 
    val filaEventosVazia : filaeventos
    val criarEscutadorEvento : filaeventos -> processo -> nomeestado -> comando -> filaeventos
    val removerEscutadorEvento : filaeventos -> processo -> nomeestado -> filaeventos
    *)
print "\n\tTestando Funcoes de Fila de Usuarios:\n\n";

val filaEventosUsuario : Dominio.filaevusuario = Dominio.filaEvUsuarioVazia;
val filaEventosAtualizada : Dominio.filaevusuario = Dominio.criaEscutadorEvUsuario filaEventosUsuario processoX "teste" comdVazio;
val filaEventosAtualizada : Dominio.filaevusuario = Dominio.removerEscutadorEvUsuario filaEventosUsuario processoX "teste";

    (* filaevusuario 
    val filaEvUsuarioVazia : filaevusuario
    val criaEscutadorEvUsuario : filaevusuario -> processo -> string -> comando -> filaevusuario
    val removerEscutadorEvUsuario : filaevusuario -> processo -> string -> filaevusuario
    *)
print "\n\tTestando Funcoes de Ambiente:\n\n";

val ambiente : Dominio.ambiente = Dominio.ambienteInicial;
val ambiente : Dominio.ambiente  = Dominio.extenderAmbiente ambiente (Dominio.Id("id")) (Dominio.VCadeia("valor"));
val valorObtido : Dominio.valor = Dominio.obterSimboloAmbiente ambiente (Dominio.Id("id"));

    (* ambiente 
    val ambienteInicial : ambiente
    val extenderAmbiente : ambiente -> id -> valor -> ambiente
    val obterSimboloAmbiente : ambiente -> id -> valor
    *)
print "\n\tTestando Funcoes de Estado :\n\n";

val estadoInicial = (Dominio.estadoInicial);
print "\n";
val ambienteObtido = Dominio.obterAmbiente( estadoInicial );
val funcAtualizaAmbiente = Dominio.atualizarAmbiente (estadoInicial);
val estadoAtualizado = funcAtualizaAmbiente(ambienteObtido);
val estadoAtualizado = Dominio.atualizarAmbiente estadoInicial ambienteObtido;

print "\n";
val resultadoObtido = Dominio.obterResultado(estadoAtualizado);
val funcAtualizaResultado = Dominio.atualizarResultado (estadoInicial);
val estadoAtualizado = funcAtualizaResultado(Dominio.VCadeia("resultado"));
val estadoAtualizado = Dominio.atualizarResultado estadoInicial (Dominio.VCadeia("resultado"));
val resultadoObtido = Dominio.obterResultado(estadoAtualizado);
print "\n";
val dependenciasObtidas = Dominio.obterDependencias(estadoAtualizado);
val funcAtualizaDependencias = Dominio.atualizarDependencias (estadoInicial);
val estadoAtualizado = funcAtualizaDependencias(dependenciasObtidas);
print "\n";
val eventosObtidos = Dominio.obterEventos(estadoAtualizado);
val funcAtualizaEventos = Dominio.atualizarEventos (estadoInicial);
val estadoAtualizado = funcAtualizaEventos(eventosObtidos);
print "\n";
val eventosObtidosUsuario = Dominio.obterEventosUsuario(estadoAtualizado);
val funcAtualizaEventosUsuario = Dominio.atualizarEventosUsuario (estadoInicial);
val estadoAtualizado = funcAtualizaEventosUsuario(eventosObtidosUsuario);
print "\n";
val grupoProcessosObtidos = Dominio.obterGrupoProcessos(estadoAtualizado);
val funcAtualizaGrupoProcessos = Dominio.atualizarGrupoProcessos (estadoInicial);
val estadoAtualizado = funcAtualizaGrupoProcessos(grupoProcessosObtidos);
print "\n";
val funcAtualizaRegistros = Dominio.registrar(estadoAtualizado);
val estadoAtualizado = funcAtualizaRegistros("teste");
print "\n";


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

print "\n\tBrincando com Funcoes:\n\n";

fun prim(n1:int, n2:int) : int = n1
