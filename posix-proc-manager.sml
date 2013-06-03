(*
 * Maestro: orquestrador de processos
 * Licença: LGPL 2.0
 * Autores: 
 *   Fabio Alexandre Campos Tisovec
 *   Jorge Augusto Sabaliauskas
 *   Márcio Fernando Stabile Junior
 *   Ramon Fortes Pereira
 *)


(*
 * nosso gerenciador de processos no Unix
 * Obs: W_IFCONTINUED, enviado ao processo pai na continuacao
 * de um processo filho nao esta presente em todos os UNIXes
 * e no sml nao tem, ficaremos devendo acoes sobre continuacao
 * de um processo
 *)
structure PosixProcManager :> PROC_MANAGER =
  struct
    structure P   = Posix
    structure PP  = Posix.Process
    structure PS  = Posix.Signal
    structure PIO = Posix.IO
    structure PFS = Posix.FileSys
    structure PPE = Posix.ProcEnv

    type pid = PP.pid

    datatype status =
        Initialized
      | Executing
      | Stopped
      | Finished

    val children    : int ref      = ref 0
    val initialized : pid list ref = ref []

    fun forkAndExec f asGroupLeader =
      case PP.fork () of
        SOME pid =>
          let
            val () = children := (!children) + 1
            val () = initialized := pid :: (!initialized)
          in
            pid
          end
      | NONE =>
          let
            (* lider de um grupo de processos ? *)
            val () = 
              if asGroupLeader
                then PPE.setpgid {pid=NONE, pgid=NONE}
                else ()
            (* importante: limpar dados de subprocessos do filho*)
            val () = children := 0 
            val () = initialized := []
            (* executa f no processo filho *)
            val _  = f () 
          in
            OS.Process.exit(OS.Process.success)
          end
 
    fun execute str =
      let 
        fun exec () =
          let
            val ps = (String.tokens Char.isSpace str)
            (*
             * O processo filho vai executar como daemon, isto e, sem stdin,
             * stdout e stderr. O filho que logue suas acoes em algum lugar...
             *)
            val () = List.app PIO.close [PFS.stdin, PFS.stdout, PFS.stderr]
            val pname = (List.hd ps)
          in
            PP.execp (pname, ps)
          end
      in
        forkAndExec exec false
      end

    and executeInNewProc f = forkAndExec f true

    fun wait () =
      case !initialized of
        pid :: pids =>
          let val () = initialized := pids in
            SOME (pid, Initialized)
          end
      | [] =>
        if (!children) <= 0
          then NONE
          else
            let val (pid, status) = PP.waitpid (PP.W_ANY_CHILD, [PP.W.untraced]) in
              case status of
                PP.W_STOPPED _ => SOME (pid, Stopped)
              | _             =>
                  let val () = children := !children - 1 in
                    SOME (pid, Finished)
                  end
            end

    fun signal pid sign = PP.kill ((PP.K_PROC pid), sign)
 
    fun stop pid = signal pid PS.stop

    fun kill pid = signal pid PS.term

    fun continue pid = signal pid PS.cont
        
  end


