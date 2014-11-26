(**
  Read and write "tar.dis" file.

  @author barthelemy
*)

(** This type contains significant data of a tardis file. *)
type t

(** The type returned by the tardis parser. *)
type parsing_result = Error of string | Ok of t

(** [create filename source encoding content] constructs and returns a value
    of type [t].
      - [filename]: the name of the file to compressed.
      - [source] : the source to compress.
      - [encoding]: the prefix code used to compress the source.
      - [content]: the compressed source. *)
val create : string -> Source.t -> PrefixCode.t -> PrefixCode.word -> t

(** [get_filename t] returns the filename contained in [t]. *)
val get_filename : t -> string

(** [get_source t] returns the source contained in [t]. *)
val get_source : t -> Source.t

(** [get_encoding t] returns the encoding table contained in [t]. *)
val get_encoding : t -> PrefixCode.t

(** [get_content t] returns the compressed data contained in [t]. *)
val get_content : t -> PrefixCode.word

(** [write t file_path] writes [t] in the file [file_path].
    @raise Sys_error if a problems occurs with file. *)
val write : t -> string -> unit

(** [read_and_decode file_path] reads the file [file_path], parses it, and
    returns a [parsing_result]. *)
val read_and_decode : string -> parsing_result