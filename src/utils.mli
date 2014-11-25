(**
  Utils functions.

  @author barthelemy delemotte
*)

(** [f -| g] returns the composition [f o g]. *)
val ( -| ) : ('b -> 'c) -> ('a -> 'b) -> ('a -> 'c)


(** [range a b] returns [\[a; a+1; ...; b\]]. *)
val range : int -> int -> int list

