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

let create filename source encoding content =
  { filename; encoding; content; source }

let compress filename source =
  let freq_table = FreqTable.create source in
  let encoding = Huffman.algorithm freq_table in
  let content = PrefixCode.encode_source encoding source in
  create filename source encoding content

let decompress filename encoding content =
  let source = PrefixCode.decode_input encoding content in
  create filename source encoding content
  
let get_filename t =
  t.filename

let get_source t =
  t.source

let get_encoding t =
  t.encoding

let get_content t =
  t.content
