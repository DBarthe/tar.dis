(**
  Module used to represent and use prefix codes for 8-bits words.

  @author Barthelemy Delemotte
*)

(** The type [t] represents a prefix code. *)
type t

(** The type [word] is a list of booleans and represents a binary word. *)
type word = bool list

exception Coding_undef of int
exception Decoding_failure of (Source.t * word)

(** [empty ()] returns a new fresh and undefined prefix code. *)
val empty : unit -> t

(** [set code sym word] defines the encoding of [sym]. *)
val set : t -> Source.byte -> word -> unit

(** [unset code sym] removes the definition of the encoding of [sym]. *)
val unset : t -> Source.byte -> unit

(** [encode_sym code sym] returns the word which encodes [sym].
  
    @raise Coding_undef ([sym]) if the coding is not defined for [sym]. *)
val encode_sym : t -> Source.byte -> word

(** [encode_source code src] returns a long word which is the concatenation
    of the encoding of all symbols contained in [src].

    @raise Coding_undef (sym) if [sym] is a symbol if [src] that has no
    defined coding.*)
val encode_source : t -> Source.t -> word

(** [decode_input code input] decodes [input] with [code] and returns the
    source decoded.

    @raise Decoding_failure (decoded, remaining) if the [input] can't be
    decoded. *)
val decode_input : t -> word -> Source.t

(** [show code] print the code in the standard output *)
val show : t -> unit