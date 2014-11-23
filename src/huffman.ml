(**
  Huffman algorithm : find an optimal prefix code for a source.

  @author Barthelemy Delemotte
*)

type tree = Leaf of Source.byte | Node of float * tree * tree

let get_frequency freq_table = function
| Leaf sym -> freq_table.(sym)
| Node (f,_,_) -> f

let full_leaf_list =
  let rec aux accu = function
  | -1 -> accu
  | sym -> aux (Leaf sym :: accu) (sym - 1)
  in aux [] 255

let code_of_tree root =
  let code = PrefixCode.empty () in
  let rec aux w = function
  | Leaf sym -> PrefixCode.set code sym (List.rev w)
  | Node (_,t0,t1) -> aux (false::w) t0 ; aux (true::w) t1 in
  let () = aux [] root in
  code

let algorithm freq_table =

  let get_freq = get_frequency freq_table in

  let rec aux ts =
    match
      List.sort (fun t1 t2 ->
        Pervasives.compare (get_freq t1) (get_freq t2)
      ) ts
    with
    | [] -> assert false (* unreachable *)
    | [t] -> t
    | t1::t2::ts' ->
      let t = Node (get_freq t1 +. get_freq t2, t1, t2) in
      aux (t::ts') in

  let root = aux full_leaf_list in
  code_of_tree root






