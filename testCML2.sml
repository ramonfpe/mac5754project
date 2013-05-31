CM.make "$cml/basis.cm";
CM.make "$cml/cml.cm";

fun prog() = (CML.spawn (fn() => print "hello!"); print "goodbye!");
val q = Time.fromMilliseconds(1);
RunCML.doit(prog, SOME(q));


  val prog2 = "/bin/ls";

  fun doit () = 
  let
		val proc = Unix.execute(prog2, [])
		val (fin,fout) = Unix.streamsOf proc
		fun echo () = (
				case TextIO.inputLine fin
			       			of SOME("") => () | SOME(s) => (TextIO.output(TextIO.stdOut, s); echo())
				      (* end case *)
				)

        in
	  TextIO.closeOut fout;
	  
	 echo ();

	  TextIO.closeIn fin;
	  ignore(Unix.reap proc);
	  ()
        end;

  fun run () = RunCML.doit(doit, SOME(Time.fromMilliseconds 100));
  run();
