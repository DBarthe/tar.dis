(**
  Read and parse tardis files.

  @author barthelemy delemotte
*)

open Utils

(* to be extended with new features *)
type header = {
  filename : string ;
}

type parsing_result = Err of string | Ok of Tardis.t

type parsing_error =
    Not_tardis_file
  | Negative_size
  | Value_out_of_range
  | File_truncated
  | Decoding_failure

exception Parsing_failure of parsing_error

let int2b = function 0 -> false | _ -> true

let split_byte byte =
  ListExt.init 8 (int2b -| (land) 1 -| (lsr) byte -| (-) 7)

let bits_of_bytes bytes =
  bytes |> List.map split_byte
        |> ListExt.flatten_opti

let input_size ic =
  let size = input_binary_int ic in
  if size < 0 then
    raise (Parsing_failure Negative_size)
  else
    size

let input_bounded_byte ?(inf=0) ic sup =
  let byte = input_byte ic in
  if byte < inf || byte > sup then
    raise (Parsing_failure Value_out_of_range)
  else
    byte

let valid_magic_code ic =
  let this_mc =
    try
      String.init 4 (fun _ -> input_char ic)
    with
    | End_of_file -> ""
  in
  if this_mc != TardisSpec.magic_code then
    raise (Parsing_failure Not_tardis_file)
  else ()

let read_filename ic =
  let name_len = input_size ic in
  really_input_string ic name_len (* since 4.02.1 *)

let read_header ic =
  valid_magic_code ic ;
  let filename = read_filename ic in
  { filename }

let build_encoding fst_table snd_table =
  let rec aux accu fst snd =
    match fst with
    | [] -> List.rev accu
    | (sym,len)::fst' ->
      let enc = ListExt.take len snd
      and snd' = ListExt.drop len snd in
      assert (List.length enc = len) ;
      aux ((sym,enc)::accu) fst' snd'
  in
  let encoding_assoc = aux [] fst_table snd_table
  and encoding = PrefixCode.empty () in
  encoding_assoc |> List.iter (
    fun (sym,enc) ->
      PrefixCode.set encoding sym enc
  ) ;
  encoding

let read_encoding ic =
  let len = input_size ic in
  let number_of_syms = input_size ic in
  let fst_table =
    ListExt.init number_of_syms (
      fun _ ->
        let s = input_byte ic in
        let l = input_byte ic + 1 in
        (s,l)
    ) in
  let snd_table_len = len - number_of_syms * 2 in
  let snd_table =
    ListExt.init snd_table_len (fun _ -> input_byte ic)
      |> bits_of_bytes in
  build_encoding fst_table snd_table

let read_content ic =
  let len = input_binary_int ic in
  let completion_bits = input_bounded_byte ic 7 in
  ListExt.init len (fun _ -> input_byte ic)
    |> bits_of_bytes
    |> ListExt.take (len*8 - completion_bits)
 
(* shorcut to make and format error *)
let mk_err file err =
  let desc =
    match err with
    | Not_tardis_file -> "not a tardis file"
    | Negative_size -> "invalid data (negative size)"
    | Value_out_of_range -> "invalid data"
    | File_truncated -> "file truncated or incorrect data"
    | Decoding_failure -> "impossible to decompress"
  in
  Err (Printf.sprintf "%s: %s" file desc)

let read file_path =
  try
    let ic = open_in_bin file_path in
    let header = read_header ic in
    let encoding = read_encoding ic in
    let content = read_content ic in
    let tardis = Tardis.decompress header.filename encoding content in
    close_in ic ;
    Ok (tardis)
  with
  | Parsing_failure err -> mk_err file_path err
  | End_of_file -> mk_err file_path File_truncated
  | PrefixCode.Decoding_failure _ -> mk_err file_path Decoding_failure
