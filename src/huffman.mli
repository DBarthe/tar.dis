(**
  Huffman algorithm : find an optimal prefix code for a source.

  @author Barthelemy Delemotte
*)

(** [algorithm freq_table] returns an optimal prefix code for a source
    with the given frenquency table [freq_table]. *)
val algorithm : FreqTable.t -> PrefixCode.t