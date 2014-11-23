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
  Array.to_list buffer


