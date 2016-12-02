(** [Result] is often used to handle error messages. *)

open! Import

(** ['ok] is a function's expected return type, and ['err] is often an error message
    string.

    {[
      let ric_of_ticker = function
        | "IBM" -> Ok "IBM.N"
        | "MSFT" -> Ok "MSFT.OQ"
        | "AA" -> Ok "AA.N"
        | "CSCO" -> Ok "CSCO.OQ"
        | _ as ticker -> Error (sprintf "can't find ric of %s" ticker)
    ]}

    The return type of ric_of_ticker could be [string option], but [(string, string)
    Result.t] gives more control over the error message. *)
type ('ok, 'err) t = ('ok, 'err) Pervasives.result =
  | Ok of 'ok
  | Error of 'err
[@@deriving_inline sexp, compare, hash]
include
sig
  [@@@ocaml.warning "-32"]
  val hash_fold_t :
    (Ppx_hash_lib.Std.Hash.state -> 'ok -> Ppx_hash_lib.Std.Hash.state) ->
    (Ppx_hash_lib.Std.Hash.state -> 'err -> Ppx_hash_lib.Std.Hash.state)
    ->
    Ppx_hash_lib.Std.Hash.state ->
    ('ok,'err) t -> Ppx_hash_lib.Std.Hash.state
  val compare :
    ('ok -> 'ok -> int) ->
    ('err -> 'err -> int) -> ('ok,'err) t -> ('ok,'err) t -> int
  val t_of_sexp :
    (Sexplib.Sexp.t -> 'ok) ->
    (Sexplib.Sexp.t -> 'err) -> Sexplib.Sexp.t -> ('ok,'err) t
  val sexp_of_t :
    ('ok -> Sexplib.Sexp.t) ->
    ('err -> Sexplib.Sexp.t) -> ('ok,'err) t -> Sexplib.Sexp.t
end
[@@@end]

include Monad.S2 with type ('a,'err) t := ('a,'err) t

val ignore : (_, 'err) t -> (unit, 'err) t


val fail : 'err -> (_, 'err) t

(** e.g. [failf "Couldn't find bloogle %s" (Bloogle.to_string b)] *)
val failf : ('a, unit, string, (_, string) t) format4 -> 'a

val is_ok    : (_, _) t -> bool
val is_error : (_, _) t -> bool

val ok             : ('ok, _     ) t -> 'ok option
val ok_exn         : ('ok, exn   ) t -> 'ok
val ok_or_failwith : ('ok, string) t -> 'ok

val error : (_  , 'err) t -> 'err option

val of_option : 'ok option -> error:'err -> ('ok, 'err) t

val iter       : ('ok, _   ) t -> f:('ok  -> unit) -> unit
val iter_error : (_  , 'err) t -> f:('err -> unit) -> unit

val map       : ('ok, 'err) t -> f:('ok  -> 'c) -> ('c , 'err) t
val map_error : ('ok, 'err) t -> f:('err -> 'c) -> ('ok, 'c  ) t

(** Returns [Ok] if both are [Ok] and [Error] otherwise. *)
val combine
  :  ('ok1, 'err) t
  -> ('ok2, 'err) t
  -> ok: ('ok1 -> 'ok2 -> 'ok3)
  -> err:('err -> 'err -> 'err)
  -> ('ok3, 'err) t

(** [ok_fst] is useful with [List.partition_map].  Continuing the above example:
    {[
      let rics, errors = List.partition_map ~f:Result.ok_fst
                           (List.map ~f:ric_of_ticker ["AA"; "F"; "CSCO"; "AAPL"]) ]} *)
val ok_fst : ('ok, 'err) t -> [ `Fst of 'ok | `Snd of 'err ]

(** [ok_if_true] returns [Ok ()] if [bool] is true, and [Error error] if it is false *)
val ok_if_true : bool -> error : 'err -> (unit, 'err) t

val try_with : (unit -> 'a) -> ('a, exn) t

(** [ok_unit = Ok ()], used to avoid allocation as a performance hack *)
val ok_unit : (unit, _) t

module Export : sig
  type ('ok, 'err) _result
    = ('ok, 'err) t
    = Ok of 'ok
    | Error of 'err

  val is_ok    : (_, _) t -> bool
  val is_error : (_, _) t -> bool
end

