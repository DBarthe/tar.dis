(**
  Read and write "tar.dis" file.

  @author barthelemy
*)

(** This type contains significant data of a tardis file. *)
type t

(** [compress filename source] compresses the [source] and creates a [t]
    with the name [filename]. *)
val compress : string -> Source.t -> t

(** [decompress filename encoding content] decompress the [content]
    which has been encoded with [encoding], then creates a [t] with the
    name [filename]. *)
val decompress : string -> PrefixCode.t -> PrefixCode.word -> t

(** [get_filename t] returns the filename contained in [t]. *)
val get_filename : t -> string

(** [get_source t] returns the source contained in [t]. *)
val get_source : t -> Source.t

(** [get_encoding t] returns the encoding table contained in [t]. *)
val get_encoding : t -> PrefixCode.t

(** [get_content t] returns the compressed data contained in [t]. *)
val get_content : t -> PrefixCode.word



