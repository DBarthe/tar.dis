(**
  The file format "tardis".
*)

type t = {
  encoding : PrefixCode.t ;
  content : PrefixCode.word ;
}

type parsing_result = Error of string | Ok of t

let magic_code = "TDIS"

let create encoding content =
  { encoding; content }

let get_encoding t =
  t.encoding

let get_content t =
  t.content

let open_file_out file_path =
  open_out_gen [
    Open_wronly;
    Open_trunc;
    Open_binary;
  ] file_path

let write t file_path =
  let oc = open_file_out file_path in
  ()

let read file_path =
  Error "undefined"
