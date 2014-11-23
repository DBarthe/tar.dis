(**
  A source of symbols. Basicaly a file.

  @author Barthelemy Delemotte
*)

(** A type for byte. *)
type byte = int

(** The source type. A synonym for list of bytes *)
type t = byte list

(** [from_file file_path] constructs a source from a file.
    @raise Sys_error when a problem occurs with the file. *)
val from_file : string -> t