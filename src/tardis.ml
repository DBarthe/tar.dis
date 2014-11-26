(**
  The file format "tardis".
*)

open Utils

(* types *)
type t = {
  filename : string ;
  source : Source.t ;
  encoding : PrefixCode.t ;
  content : PrefixCode.word ;
}

type parsing_result = Error of string | Ok of t

(* to be extended with new features *)
type header_data = {
  h_filename : string ;
}

exception Not_tardis_file

(* globals *)
let magic_code = "TDIS"
let basic_perm = 420 (* rw-r--r-- *)

(* utils *)
let b2int = function true -> 1 | false -> 0
let int2b = function 0 -> false | _ -> true

let split_byte byte =
  ListExt.init 8 (int2b -| (lsr) byte -| (-) 7)

let bits_of_bytes bytes =
  bytes |> List.map split_byte
        |> ListExt.flatten_opti

(* functions *)
let create filename source encoding content =
  { filename; encoding; content; source }

let get_filename t =
  t.filename

let get_source t =
  t.source

let get_encoding t =
  t.encoding

let get_content t =
  t.content


(* write *)
let open_file_out file_path =
  let flags = [
    Open_wronly;
    Open_trunc;
    Open_creat;
    Open_binary;
  ] in
  open_out_gen flags basic_perm file_path

let write_header t oc =
  (* magic code *)
  output_string oc magic_code ; 
  (* filename *)
  output_binary_int oc (String.length t.filename) ;
  output_string oc t.filename

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
    List.filter (fun (s,_) -> List.mem s t.source) whole_list in
  let snd_part = 
    PrefixCode.encode_source t.encoding (List.map fst fst_part) in
  let snd_part_len = List.length snd_part in
  let completion_bits = calc_completion_bits_nbr snd_part_len in
  let size = List.length fst_part * 2
    + snd_part_len / 8
    + (if completion_bits != 0 then 1 else 0) in
  (* size *)
  output_binary_int oc size ;
  (* number of completion bits *)
  output_byte oc completion_bits ;
  (* number of symbols in the table *)
  output_binary_int oc (List.length fst_part) ;
  (* first part : sym -> length *)
  List.iter (fun (s,l) ->
    output_byte oc s ;
    output_byte oc (l-1) ;
  ) fst_part ;
  (* second part : corresponding binary words *)
  write_word snd_part oc

let write_content t oc =
  let len = List.length t.content in 
  let completion_bits = calc_completion_bits_nbr len in
  let size = len / 8 + (if completion_bits != 0 then 1 else 0) in
  output_binary_int oc size ;
  output_byte oc completion_bits ;
  write_word t.content oc

let write t file_path =
  let oc = open_file_out file_path in
  write_header t oc ;
  write_encoding t oc ;
  write_content t oc;
  close_out oc

(* read *)
let valid_magic_code ic =
  let this_mc =
    try String.init 4 (fun _ -> input_char ic)
    with End_of_file -> ""
  in
  match this_mc != magic_code with
  | true -> ()
  | false -> raise (Not_tardis_file)

let read_filename ic =
  let name_len = input_binary_int ic in
  really_input_string ic name_len (* since 4.02.1 *)

let read_header ic =
  valid_magic_code ic ;
  let filename = read_filename ic in
  { h_filename = filename }

let build_encoding fst_table snd_table =
  let rec aux accu fst snd =
    match fst with
    | [] -> List.rev accu
    | (sym,len)::fst' ->
      let enc = ListExt.take len snd
      and snd' = ListExt.drop len snd in
      if List.length enc < len then
        failwith "toto" (* to change *)
      else
        aux ((sym,enc)::accu) fst' snd'
  in
  let encoding_assoc = aux [] fst_table snd_table
  and encoding = PrefixCode.empty () in
  encoding_assoc |> List.iter (
    fun (sym,enc) -> PrefixCode.set encoding sym enc
  ) ;
  encoding

let read_encoding ic =
  let len = input_binary_int ic in
  let completion_bits = input_byte ic in
  let number_of_syms = input_binary_int ic in
  let fst_table =
    ListExt.init number_of_syms (fun _ ->
      let s = input_byte ic in
      let l = input_byte ic + 1 in
      (s,l)
    ) in
  let snd_table =
    ListExt.init (len - number_of_syms * 2) (fun _ -> input_byte ic)
      |> bits_of_bytes
      |> ListExt.take (len - completion_bits) in
  build_encoding fst_table snd_table

let read_content ic =
  let len = input_binary_int ic in
  let completion_bits = input_byte ic in
  ListExt.init len (fun _ -> input_byte ic)
    |> bits_of_bytes
    |> ListExt.take (len - completion_bits)

let decode_content encoding content =
  []

let read_and_decode file_path =
  try
    let ic = open_in_bin file_path in
    let header = read_header ic in
    let encoding = read_encoding ic in
    let content = read_content ic in
    let source = decode_content encoding content in
    Ok (create header.h_filename source encoding content)
  with
  | e -> raise e (* TODO *) 
