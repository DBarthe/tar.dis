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

type arguments = {
  mode : mode;
  input_file: string;
  output_file: string option;
}

let progname = Sys.argv.(0)

let usage_msg =
  Printf.sprintf "usage: %s [-c|-d] [-f output_file ] input_file" progname

let create_arguments compress input_file output_file =
  if input_file = "" then begin
    prerr_endline "error: an input file is required" ;
    exit 1
  end else
    let mode =
      if compress then Compress else Decompress
    and output_file =
      if output_file = "" then None else Some output_file
    in
    { mode ; input_file ; output_file } 

(* exit program when the command line is incorrect *)
let parse_arguments () =
  let compress_ref = ref true (* false for decompress *)
  and input_file_ref = ref ""
  and output_file_ref = ref "" in
  let speclist = [
    "-c", Arg.Set compress_ref, "compression mode (default)" ;
    "-d", Arg.Clear compress_ref, "decompression mode" ;
    "-f", Arg.Set_string output_file_ref, "optional output file";
  ] in
  Arg.parse speclist ((:=) input_file_ref) usage_msg ;
  create_arguments !compress_ref !input_file_ref !output_file_ref

let calc_deflation t =
  let source_len = List.length (Tardis.get_source t)
  and content_len = List.length (Tardis.get_content t) / 8 in
  let difference = source_len - content_len in
  int_of_float (
    float_of_int difference *. 100.0 /. float_of_int source_len
  )

let compress opts =
  let output_file =
    match opts.output_file with
    | Some f -> f
    | None -> opts.input_file ^ ".dis"
  in
  let source = Source.from_file opts.input_file in
  let tardis = Tardis.compress opts.input_file source in
  TardisWriter.write tardis output_file ;
  Printf.printf "%s -> %s (%d%% deflated)\n"
    opts.input_file output_file (calc_deflation tardis)

let decompress opts =
  match TardisReader.read opts.input_file with
  | TardisReader.Err err_msg ->
    Printf.eprintf "error: %s\n" err_msg
  | TardisReader.Ok tardis ->  
    let output_file =
      match opts.output_file with
      | Some f -> f
      | None -> Tardis.get_filename tardis
    in
    Source.to_file (Tardis.get_source tardis) output_file ;
    Printf.printf "%s -> %s\n"
      opts.input_file output_file


let main () =
  let opts = parse_arguments () in
  try
    match opts.mode with
    | Compress -> compress opts
    | Decompress -> decompress opts
  with
  | Sys_error s ->
      Printf.eprintf "error: %s\n" s ;
      exit 1

let () = main ()