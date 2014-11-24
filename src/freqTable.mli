(**
  Frequency table of symbols found in sources.

  @author Barthelemy Delemotte
*)

(** The main type. A 256-table of probabilities. The indexes of the table
    corresponds to the value of the binary symbols (from 0 to 255). *)
type t = float array

(** [create src] returns the frequency table corresponding the source [src].
    @raise Invalid_argument if [src] contains symbols not in \[0..255\]. *)
val create : Source.t -> t