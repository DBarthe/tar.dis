(**
  Frequency table of symbols found in sources.

  @author Barthelemy Delemotte
*)

type t = float array

(* alphabet size *)

let count_symbols src =
  let t = Array.make 256 0 in
  List.iter (
    fun sym ->
      if sym < 0 || sym > 255 then
        raise (Invalid_argument "bad symbol")
      else t.(sym) <- t.(sym) + 1
  ) src ;
  t

let create src =
  let total = float_of_int (List.length src)
  and count_table = count_symbols src in
  Array.map (
    fun cnt -> float_of_int cnt /. total
  ) count_table
