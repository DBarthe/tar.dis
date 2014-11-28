(**
  A source of symbols. Basicaly a file.
*)

(* a 8-bits integer *)
type byte = int

(* the main source type is a list of bytes *)
type t = byte list

(* construct a source from a file. raise Sys_error if problem with file *)
let from_file file_path = 
  let ic = open_in_bin file_path in
  let len = in_channel_length ic in
  let buffer = Array.init len (fun _ -> input_byte ic) in
  close_in ic ;
  Array.to_list buffer

let to_file source file_path =
  let flags = [
    Open_wronly;
    Open_trunc;
    Open_creat;
    Open_binary;
    Open_excl;
  ] in
  let oc = open_out_gen flags 420 file_path in
  List.iter (output_byte oc) source ;
  close_out oc


