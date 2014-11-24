(**
  Module used to represent and use prefix codes for 8-bits words.

  @author Barthelemy Delemotte
*)

type word = bool list

type t = word array

exception Coding_undef

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
  | [] -> raise Coding_undef
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
