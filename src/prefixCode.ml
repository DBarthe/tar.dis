(**
  Module used to represent and use prefix codes for 8-bits words.

  @author Barthelemy Delemotte
*)

type word = bool list

type t = word array

exception Coding_undef of int
exception Undecodable of word
exception Decoding_failure of (Source.t * word)

let empty () = Array.make 256 []

let check_sym sym = 
  if sym < 0 || sym > 255 then
    raise (Invalid_argument "bad symbol")
  else ()

let set code sym coding =
  check_sym sym ;
  code.(sym) <- coding

let unset code sym =
  set code sym []

let encode_sym code sym =
  check_sym sym ;
  match code.(sym) with
  | [] -> raise (Coding_undef sym)
  | c -> c

(* tail-recursive version of flatten *)
let flatten_opti l = 
  let rec aux accu = function
  | [] -> List.rev accu
  | xs::xss -> aux (List.rev_append xs accu) xss
  in aux [] l 

let encode_source code src =
  let words = List.map (encode_sym code) src in
  flatten_opti words

let match_prefix word prefix =
  ListExt.take (List.length prefix) word = prefix

(* returns the first index of an array whom the value satisfys the predicat *)
let index_for p ar =
  let len = Array.length ar in
  let rec aux i =
    if i = len then None else
    if p ar.(i) then Some i else
    aux (i+1) in
  aux 0

let decode_next_sym code input =
  match index_for (fun x -> x != [] && match_prefix input x) code with
  | None -> raise (Undecodable input)
  | Some sym ->
      let input' = ListExt.drop (List.length code.(sym)) input in
      (sym, input')

let decode_input code input =
  let rec aux accu = function
  | [] -> List.rev accu
  | inp ->
    let (sym, inp') =
      try decode_next_sym code inp with
      | Undecodable _ ->
        raise (Decoding_failure (List.rev accu, inp))
    in aux (sym::accu) inp'
  in aux [] input

let show code =
  ignore begin
    Array.iteri (fun sym coding ->
      Printf.printf "x%02x -> " sym ;
      if coding = [] then
        print_endline "undefined"
      else
        List.iter (function
          | true -> print_char '1'
          | false -> print_char '0'
        ) coding ;
        print_newline ()
    ) code
  end
