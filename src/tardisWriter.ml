(**
  Create files from tardis records.

  @author barthelemy delemotte
*)

open Utils

let basic_perm = 420 (* rw-r--r-- *)

let b2int = function true -> 1 | false -> 0

let open_file_out file_path =
  let flags = [
    Open_wronly;
    Open_trunc;
    Open_creat;
    Open_binary;
  ] in
  open_out_gen flags basic_perm file_path

let write_header oc t =
  let filename = Tardis.get_filename t in
  (* magic code *)
  output_string oc TardisSpec.magic_code ; 
  (* filename *)
  output_binary_int oc (String.length filename) ;
  output_string oc filename

let write_word oc w =
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

let write_encoding oc t = 
  let source = Tardis.get_source t
  and encoding = Tardis.get_encoding t in
  let fst_part =
    let whole_list = List.map
      (fun s -> (s, List.length (PrefixCode.encode_sym encoding s)))
      (range 0 255) in
    List.filter (fun (s,_) -> List.mem s source) whole_list in
  let snd_part = 
    PrefixCode.encode_source encoding (List.map fst fst_part) in
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
  write_word oc snd_part

let write_content oc t =
  let content = Tardis.get_content t in
  let len = List.length content in 
  let completion_bits = calc_completion_bits_nbr len in
  let size = len / 8 + (if completion_bits != 0 then 1 else 0) in
  output_binary_int oc size ;
  output_byte oc completion_bits ;
  write_word oc content

let write t file_path =
  let oc = open_file_out file_path in
  write_header oc t ;
  write_encoding oc t ;
  write_content oc t ;
  close_out oc
