structure Tokens = Tokens

type pos = int
type svalue = Tokens.svalue
type ('a,'b) token = ('a,'b) Tokens.token
type lexresult= (svalue,pos) token
val pos = ref 0
fun eof () = Tokens.EOF(!pos,!pos)
fun error (e,l : int,_) = TextIO.output (TextIO.stdOut, String.concat[
  "line ", (Int.toString l), ": ", e, "\n"
      ])

%%
%header (functor MaestroLexFun(structure Tokens: Maestro_TOKENS));
%s C;
alpha=[A-Za-z];
digit=[0-9];
ws = [\ \t];
%%
<INITIAL>"$"(_|[0-9]|[A-Za-z])* => (Tokens.VAR(yytext,!pos,!pos));
<INITIAL>"\""([^"\""])*"\"" => (Tokens.CADEIA(yytext,!pos,!pos));
<INITIAL>\n       => (pos := (!pos) + 1; lex());
<INITIAL>{ws}+    => (lex());
<INITIAL>"/*" =>   (YYBEGIN C; lex());
<INITIAL>";"      => (Tokens.SEMI(!pos,!pos));
<INITIAL>","		=> (Tokens.VIRGULA(!pos,!pos));
<INITIAL>":="		=> (Tokens.ATRIB(!pos,!pos));
<INITIAL>"["		=> (Tokens.COLCH_E(!pos,!pos));
<INITIAL>"]"		=> (Tokens.COLCH_D(!pos,!pos));
<INITIAL>"("		=> (Tokens.PAREN_E(!pos,!pos));
<INITIAL>")"		=> (Tokens.PAREN_D(!pos,!pos));
<INITIAL>"{"		=> (Tokens.CHAVE_E(!pos,!pos));
<INITIAL>"}"		=> (Tokens.CHAVE_D(!pos,!pos));
<INITIAL>"@inicializado"	=> (Tokens.EST_INI(!pos,!pos));
<INITIAL>"@suspenso"     => (Tokens.EST_SUS(!pos,!pos));
<INITIAL>"@executando"	=> (Tokens.EST_EXE(!pos,!pos));
<INITIAL>"@finalizado"	=> (Tokens.EST_FIN(!pos,!pos));
<INITIAL>"verdadeiro"	=> (Tokens.BOOL_V(!pos,!pos));
<INITIAL>"falso"		=> (Tokens.BOOL_F(!pos,!pos));
<INITIAL>"se"		=> (Tokens.FLUX_SE(!pos,!pos));
<INITIAL>"repetir"	=> (Tokens.FLUX_REP(!pos,!pos));
<INITIAL>"retornar"	=> (Tokens.FLUX_RET(!pos,!pos));
<INITIAL>"sub"		=> (Tokens.SUB2(!pos,!pos));
<INITIAL>{digit}+ => (Tokens.NUM (valOf (Int.fromString yytext), !pos, !pos));
<INITIAL>(_|[A-Za-z])(_|[0-9]|[A-Za-z])* => (Tokens.ID(yytext,!pos,!pos));
<INITIAL>"."      => (error ("ignoring bad character "^yytext,!pos,!pos); lex());

<C>\n+		=> (pos := (!pos) + (String.size yytext); lex());
<C>[^()*\n]+	=> (lex());
<C>"/*"		=> (lex());
<C>"*/"		=> (YYBEGIN INITIAL; lex());
<C>[*()]	=> (lex());
