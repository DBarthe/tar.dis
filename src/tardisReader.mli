(**
  Read and parse tardis files.

  @author barthelemy delemotte
*)

(** The type returned by the tardis parser. *)
type parsing_result = Error of string | Ok of Tardis.t

(** [read file_path] reads the file [file_path], parses it, and
    returns a [parsing_result]. *)
val read : string -> parsing_result
