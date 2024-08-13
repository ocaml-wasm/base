(* This module is included in [Import].  It is aimed at modules that define the standard
   combinators for [sexp_of], [of_sexp], [compare] and [hash] and are included in
   [Import]. *)

include (
  Shadow_stdlib :
    module type of struct
      include Shadow_stdlib
    end
    with type 'a ref := 'a ref
    with type ('a, 'b, 'c) format := ('a, 'b, 'c) format
    with type ('a, 'b, 'c, 'd) format4 := ('a, 'b, 'c, 'd) format4
    with type ('a, 'b, 'c, 'd, 'e, 'f) format6 := ('a, 'b, 'c, 'd, 'e, 'f) format6
    (* These modules are redefined in Base *)
    with module Array := Shadow_stdlib.Array
    with module Atomic := Shadow_stdlib.Atomic
    with module Bool := Shadow_stdlib.Bool
    with module Buffer := Shadow_stdlib.Buffer
    with module Bytes := Shadow_stdlib.Bytes
    with module Char := Shadow_stdlib.Char
    with module Either := Shadow_stdlib.Either
    with module Float := Shadow_stdlib.Float
    with module Hashtbl := Shadow_stdlib.Hashtbl
    with module Int := Shadow_stdlib.Int
    with module Int32 := Shadow_stdlib.Int32
    with module Int64 := Shadow_stdlib.Int64
    with module Lazy := Shadow_stdlib.Lazy
    with module List := Shadow_stdlib.List
    with module Map := Shadow_stdlib.Map
    with module Nativeint := Shadow_stdlib.Nativeint
    with module Option := Shadow_stdlib.Option
    with module Printf := Shadow_stdlib.Printf
    with module Queue := Shadow_stdlib.Queue
    with module Random := Shadow_stdlib.Random
    with module Result := Shadow_stdlib.Result
    with module Set := Shadow_stdlib.Set
    with module Stack := Shadow_stdlib.Stack
    with module String := Shadow_stdlib.String
    with module Sys := Shadow_stdlib.Sys
    with module Uchar := Shadow_stdlib.Uchar
    with module Unit := Shadow_stdlib.Unit)
[@ocaml.warning "-3"]

type 'a ref = 'a Stdlib.ref = { mutable contents : 'a }

(* Reshuffle [Stdlib] so that we choose the modules using labels when available. *)
module Stdlib = struct
  include Stdlib
  include Stdlib.StdLabels
  include Stdlib.MoreLabels
end

external ( |> ) : 'a -> (('a -> 'b)[@local_opt]) -> 'b = "%revapply"

(* These need to be declared as an external to get the lazy behavior *)
external ( && ) : (bool[@local_opt]) -> (bool[@local_opt]) -> bool = "%sequand"
external ( || ) : (bool[@local_opt]) -> (bool[@local_opt]) -> bool = "%sequor"
external not : (bool[@local_opt]) -> bool = "%boolnot"

(* We use [Obj.magic] here as other implementations generate a conditional jump and the
   performance difference is noticeable. *)
let bool_to_int (x : bool) : int = Stdlib.Obj.magic x

(* This needs to be declared as an external for the warnings to work properly *)
external ignore : _ -> unit = "%ignore"

let ( != ) = Stdlib.( != )
let ( * ) = Stdlib.( * )

external ( ** )
  :  (float[@local_opt])
  -> (float[@local_opt])
  -> float
  = "caml_power_float" "pow"
[@@unboxed] [@@noalloc]

external ( *. )
  :  (float[@local_opt])
  -> (float[@local_opt])
  -> (float[@local_opt])
  = "%mulfloat"

let ( + ) = Stdlib.( + )

external ( +. )
  :  (float[@local_opt])
  -> (float[@local_opt])
  -> (float[@local_opt])
  = "%addfloat"

let ( - ) = Stdlib.( - )

external ( -. )
  :  (float[@local_opt])
  -> (float[@local_opt])
  -> (float[@local_opt])
  = "%subfloat"

let ( / ) = Stdlib.( / )

external ( /. )
  :  (float[@local_opt])
  -> (float[@local_opt])
  -> (float[@local_opt])
  = "%divfloat"

module Poly = Poly0 (** @canonical Base.Poly *)

include Replace_polymorphic_compare
include Int_replace_polymorphic_compare

(* This needs to be defined as an external so that the compiler can specialize it as a
   direct set or caml_modify. *)
external ( := ) : ('a ref[@local_opt]) -> 'a -> unit = "%setfield0"

(* These need to be defined as an external otherwise the compiler won't unbox
   references. *)
external ( ! ) : ('a ref[@local_opt]) -> 'a = "%field0"
external ref : 'a -> ('a ref[@local_opt]) = "%makemutable"

let ( @ ) = Stdlib.( @ )
let ( ^ ) = Stdlib.( ^ )
let ( ~- ) = Stdlib.( ~- )

external ( ~-. ) : (float[@local_opt]) -> (float[@local_opt]) = "%negfloat"

let ( asr ) = Stdlib.( asr )
let ( land ) = Stdlib.( land )
let lnot = Stdlib.lnot
let ( lor ) = Stdlib.( lor )
let ( lsl ) = Stdlib.( lsl )
let ( lsr ) = Stdlib.( lsr )
let ( lxor ) = Stdlib.( lxor )
let ( mod ) = Stdlib.( mod )
let abs = Stdlib.abs
let failwith = Stdlib.failwith
let fst = Stdlib.fst
let invalid_arg = Stdlib.invalid_arg
let snd = Stdlib.snd

(* [raise] needs to be defined as an external as the compiler automatically replaces
   '%raise' by '%reraise' when appropriate. *)
external raise : exn -> _ = "%raise"
external phys_equal : ('a[@local_opt]) -> ('a[@local_opt]) -> bool = "%eq"
external decr : (int ref[@local_opt]) -> unit = "%decr"
external incr : (int ref[@local_opt]) -> unit = "%incr"

(* Used by sexp_conv, which float0 depends on through option. *)
let float_of_string = Stdlib.float_of_string

(* [am_testing] is used in a few places to behave differently when in testing mode, such
   as in [random.ml].  [am_testing] is implemented using [Base_am_testing], a weak C/js
   primitive that returns [false], but when linking an inline-test-runner executable, is
   overridden by another primitive that returns [true]. *)
external am_testing : unit -> bool = "Base_am_testing"

let am_testing = am_testing ()
