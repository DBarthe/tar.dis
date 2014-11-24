(**
  The main module.

  @author barthelemy delemotte
*)

(*
  basic program syntax:
  -c (compress, default)
  -d (decompress)
  filename (anywhere, file to compress or decompress)
*)

type mode = Compress | Decompress

type options = {
  mode : mode;
  filename: string;
}

let progname = Sys.argv.(0)

let usage_msg =
  Printf.sprintf "usage: %s [-c|-d] filename" progname

(* exit program when the command line is incorrect *)
let parse_arguments () =
  let compress = ref true (* false for decompress *)
  and filename = ref "" in
  let speclist = [
    "-c", Arg.Set compress, "compression mode" ;
    "-d", Arg.Clear compress, "decompression mode" ;
  ] in
  Arg.parse speclist ((:=) filename) usage_msg ;
  let mode = if !compress then Compress else Decompress in
  if !filename = "" then begin
    prerr_endline "error: no filename." ;
    exit 1
  end else
    { mode; filename = !filename }

let compress opts =
  try
    let target_filename = opts.filename ^ ".dis" 
    and source = Source.from_file opts.filename in
    let freq_table = FreqTable.create source in
    let encoding = Huffman.algorithm freq_table in
    let content = PrefixCode.encode_source encoding source in
    let tardis = Tardis.create opts.filename source encoding content in
    Tardis.write tardis target_filename
  with
  | Sys_error s ->
      Printf.eprintf "error: %s: %s\n" opts.filename s ;
      exit 1

let decompress opts = 
  ()

let main () =
  let opts = parse_arguments () in
  match opts.mode with
  | Compress -> compress opts
  | Decompress -> decompress opts

let () = main ()