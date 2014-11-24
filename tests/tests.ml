(**
  Tests file.
*)

let test_huffman () =
  let src = Source.from_file "/home/barth/.bashrc" in
  let ft = FreqTable.create src in
  let code = Huffman.algorithm ft in
  PrefixCode.show code

let () = test_huffman ()
