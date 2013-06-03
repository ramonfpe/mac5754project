maestro
=======

Dependências
------------

* **SML/NJ** >= 110.75
* **Linux** >= 2.6.x

Organização do fonte
--------------------

#### Arquivos de build

* *maestro.cm*

#### Interfaces

* *lexer.sig*
* *parser.sig*
* *proc-manager.sig*
* *semantic.sig*

#### Functors

* *make-parser.fun*
* *make-semantic.fun*

#### Implementações

* *lexer.sml*
* *maestro.sml*
* *posix-proc-manager.sml*

Sintaxe da linguagem maestro (EBNF)
-----------------------------------

    maestro = { sub } .
    
    sub = "sub” ID “(” [ ID {“,” ID } ] “)” bloco .
    
    cmd = “se” expr bloco
        | “repetir” NUM bloco
        | [ ID “=” ] ID { expr } ";"
        | “retornar” expr ";" .
        
    expr = ID
         | “@” (“inicializado”|“suspenso”|“executando”|“finalizado”)
         | CADEIA
         | “[” ID { expr } “]”
         | (“verdadeiro”|“falso”) .
         
    bloco = “{” { cmd } “}” .


Comandos pré-definidos
----------------------

* `registar <cadeia>`
* `processo <cadeia>`
* `quando <processo> <estado> <comando-callback>`
* `dependencia <processo-dependente> <processo-dependencia>`
* `suborquestrador <comando>`

Carregando no sml
-----------------

Para carregar o maestro no SML basta carregar o arquivo "maestro.cm" utilizando o *CompilationManager*

    $ sml
    Standard ML of New Jersey v110.75 [built: Sun Jan 20 21:54:24 2013]
    - CM.make "maestro.cm";
    [autoloading]
    [library $smlnj/cm/cm.cm is stable]
    [library $smlnj/internal/cm-sig-lib.cm is stable]
    [library $/pgraph.cm is stable]
    [library $smlnj/internal/srcpath-lib.cm is stable]
    [library $SMLNJ-BASIS/basis.cm is stable]
    [autoloading done]
    [scanning maestro.cm]
    [loading (maestro.cm):semantic.sig]
    [loading (maestro.cm):lexer.sig]
    [loading (maestro.cm):lexer.sml]
    [loading (maestro.cm):parser.sig]
    [loading (maestro.cm):make-parser.fun]
    [loading (maestro.cm):proc-manager.sig]
    [loading (maestro.cm):make-semantic.fun]
    [loading (maestro.cm):debug-semantic.sml]
    [loading (maestro.cm):posix-proc-manager.sml]
    [loading (maestro.cm):maestro.sml]
    [New bindings added.]
    val it = true : bool
    -

Construção de imagem
--------------------

    ml-build maestro.cm Maestro.main maestro

Execução da imagem
------------------

    sml @SMLload=maestro.arquitetura+os
    
Obs: Substituir **arquitetura+os** pela arquitetura onde foi construída a imagem.

Arquivo binário para distribuição
---------------------------------

    heap2exec maestro.arquitetura+os maestro

Execução
--------

    $ ./maestro
    usage:
        
        maestro <source>
    

Exemplo
-------

Arquivo *teste.maestro* :

    sub main() {
      p = processo "ls -la";
      quando p @finalizado morreu;
    }
    
    sub morreu(processo, status) {
      registrar "p morreu !";
    }

Para executar:

    $ ./maestro teste.maestro

CTRL+C para encerrar o maestro.
Obs: O processo executará sem stdin, stdout e stderr. Espera-se que os processos sejam *daemons* embora o exemplo acima
utilize os clássico *ls*.
