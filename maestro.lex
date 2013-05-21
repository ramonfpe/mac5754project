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
alpha=[A-Za-z];
digit=[0-9];
ws = [\ \t];
%%

"$"(_|[0-9]|[A-Za-z])* => (Tokens.VAR(yytext,!pos,!pos));

"\""([^"\""])*"\"" => (Tokens.CADEIA(yytext,!pos,!pos));

\n       => (pos := (!pos) + 1; lex());
{ws}+    => (lex());



";"      => (Tokens.SEMI(!pos,!pos));
","		=> (Tokens.VIRGULA(!pos,!pos));
":="		=> (Tokens.ATRIB(!pos,!pos));
"["		=> (Tokens.COLCH_E(!pos,!pos));
"]"		=> (Tokens.COLCH_D(!pos,!pos));
"("		=> (Tokens.PAREN_E(!pos,!pos));
")"		=> (Tokens.PAREN_D(!pos,!pos));
"{"		=> (Tokens.CHAVE_E(!pos,!pos));
"}"		=> (Tokens.CHAVE_D(!pos,!pos));
"@inicializado"	=> (Tokens.EST_INI(!pos,!pos));
"@suspenso"     => (Tokens.EST_SUS(!pos,!pos));
"@executando"	=> (Tokens.EST_EXE(!pos,!pos));
"@finalizado"	=> (Tokens.EST_FIN(!pos,!pos));
"verdadeiro"	=> (Tokens.BOOL_V(!pos,!pos));
"falso"		=> (Tokens.BOOL_F(!pos,!pos));
"se"		=> (Tokens.FLUX_SE(!pos,!pos));
"repetir"	=> (Tokens.FLUX_REP(!pos,!pos));
"retornar"	=> (Tokens.FLUX_RET(!pos,!pos));
"sub"		=> (Tokens.SUB2(!pos,!pos));

{digit}+ => (Tokens.NUM (valOf (Int.fromString yytext), !pos, !pos));
(_|[A-Za-z])(_|[0-9]|[A-Za-z])* => (Tokens.ID(yytext,!pos,!pos));

"."      => (error ("ignoring bad character "^yytext,!pos,!pos);
             lex());
