(**
  The file format "tardis".
*)

open Utils

(* types *)
type t = {
  filename : string ;
  encoding : PrefixCode.t ;
  content : PrefixCode.word ;
}

type parsing_result = Error of string | Ok of t

(* globals *)
let magic_code = "TDIS"
let basic_perm = 420 (* rw-r--r-- *)

(* functions *)
let create filename encoding content =
  { filename; encoding; content }

let get_filename t =
  t.filename

let get_encoding t =
  t.encoding

let get_content t =
  t.content

(* write *)
let open_file_out file_path =
  let flags = [
    Open_wronly;
    Open_trunc;
    Open_binary;
  ] in
  open_out_gen flags basic_perm file_path

let write_header t oc =
  (* magic code *)
  output_string oc magic_code ; 
  (* filename *)
  output_binary_int oc (String.length t.filename) ;
  output_string oc t.filename

let b2int = function true -> 1 | false -> 0

let write_word w oc =
  let rec aux accu_b accu_l w =
    if accu_l = 8 then begin
      output_byte oc accu_b ;
      aux 0 0 w
    end else
      match w with
      | [] -> if accu_l > 0 then aux accu_b accu_l [false] else ()
      | b::bs -> aux ((accu_b lsl 1) lor b2int b) (accu_l+1) bs
  in aux 0 0 w

(* calc number of bits to add to have a multiple of 8 *)
let calc_completion_bits_nbr nbits =
  match nbits mod 8 with
  | 0 -> 0
  | r -> 8 - r

let write_encoding t oc = 
  let fst_part =
    let whole_list = List.map
      (fun s -> (s, List.length (PrefixCode.encode_sym t.encoding s)))
      (range 0 255) in
    List.filter ((<) 0 -| snd) whole_list in
  let snd_part = 
    PrefixCode.encode_source t.encoding (List.map fst fst_part) in
  let snd_part_len = List.length snd_part in
  let completion_bits = calc_completion_bits_nbr snd_part_len in
  let size = List.length fst_part* 2
    + snd_part_len / 8
    + (if completion_bits != 0 then 1 else 0) in
  (* size *)
  output_binary_int oc size ;
  (* number of completion bits *)
  output_byte oc completion_bits ;
  (* first part : sym -> length *)
  List.iter (fun (s,l) ->
    output_byte oc s ;
    output_byte oc l ;
  ) fst_part ;
  (* second part : corresponding binary words *)
  write_word snd_part 

let write_content t oc =
  let len = List.length t.content in 
  let completion_bits = calc_completion_bits_nbr len in
  let size = len / 8 + (if completion_bits != 0 then 1 else 0) in
  output_binary_int oc size ;
  output_byte oc completion_bits ;
  write_word t.content

let write t file_path =
  let oc = open_file_out file_path in
  write_header t oc ;
  write_encoding t oc ;
  write_content t oc;
  close_out oc

(* read *)
let read file_path =
  Error "undefined"
