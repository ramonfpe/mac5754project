(* usado para criar e observar processos *)
signature PROC_MANAGER =
  sig
    eqtype pid

    datatype status =
        Initialized
      | Executing
      | Stopped
      | Finished

    val execute : string -> pid
    val executeInNewProc : (unit -> 'a) -> pid
    val wait : unit -> (pid * status) option
    val stop : pid -> unit
    val kill : pid -> unit
    val continue : pid -> unit
  end


