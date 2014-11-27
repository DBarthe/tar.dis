(**
  Read and parse tardis files.

  @author barthelemy delemotte
*)

open Utils

type parsing_result = Error of string | Ok of Tardis.t

(* to be extended with new features *)
type header = {
  filename : string ;
}

exception Not_tardis_file

let int2b = function 0 -> false | _ -> true

let split_byte byte =
  ListExt.init 8 (int2b -| (lsr) byte -| (-) 7)

let bits_of_bytes bytes =
  bytes |> List.map split_byte
        |> ListExt.flatten_opti

let valid_magic_code ic =
  let this_mc =
    try String.init 4 (fun _ -> input_char ic)
    with End_of_file -> ""
  in
  match this_mc != TardisSpec.magic_code with
  | true -> ()
  | false -> raise Not_tardis_file

let read_filename ic =
  let name_len = input_binary_int ic in
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

let read file_path =
  try
    let ic = open_in_bin file_path in
    let header = read_header ic in
    let encoding = read_encoding ic in
    let content = read_content ic in
    let tardis = Tardis.decompress header.filename encoding content in
    Ok (tardis)
  with
  | e -> raise e (* TODO *) 