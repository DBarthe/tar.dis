(**
  Utils functions.
*)

let ( -| ) f g = fun x -> f (g x)

let ( ^$ ) f x = f x

let range a b = 
  let rec aux accu i =
    if i < a then accu else
    aux (i::accu) (i-1) in
  aux [] b