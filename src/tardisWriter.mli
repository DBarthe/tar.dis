(**
  Create files from tardis records.

  @author barthelemy delemotte
*)

(** [write t file_path] writes [t] in the file [file_path].
    @raise Sys_error if a problems occurs with file. *)
val write : Tardis.t -> string -> unit