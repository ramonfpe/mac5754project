maestro
=======

#### Dependências:

* **SML/NJ** >= 110.75
* **Linux** >= 2.6.x

#### Carregando no sml

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

#### Construção de imagem

    ml-build maestro.cm Maestro.main maestro

#### Execução da imagem

    sml @SMLload=maestro.arquitetura+os
    
Obs: Substituir **arquitetura+os** pela arquitetura onde foi construída a imagem.

#### Arquivo binário para distribuição

    heap2exec maestro.arquitetura+os maestro

#### Execução

    $ ./maestro
    usage:
        
        maestro <source>


