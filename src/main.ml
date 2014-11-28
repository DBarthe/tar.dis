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
    let tardis = Tardis.compress opts.filename source in
    TardisWriter.write tardis target_filename
  with
  | e -> raise e (* todo *)

let decompress opts = 
  try 
    let target_filename = opts.filename ^ ".undis" in (*to change*)
    match TardisReader.read opts.filename with
    | TardisReader.Err err_msg ->
      Printf.eprintf "error: %s\n" err_msg
    | TardisReader.Ok tardis ->  
      Source.to_file (Tardis.get_source tardis) target_filename
  with
  | e -> raise e (* todo *)

let main () =
  let opts = parse_arguments () in
  try
    match opts.mode with
    | Compress -> compress opts
    | Decompress -> decompress opts
  with
  | Sys_error s ->
      Printf.eprintf "error: sys_error: %s\n" s ;
      exit 1

let () = main ()