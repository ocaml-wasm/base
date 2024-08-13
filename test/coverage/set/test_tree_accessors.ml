open! Base
module Implementation = Base.Set.Using_comparator.Tree

let%expect_test "[Base.Set.Using_comparator.Tree] creators/accessors" =
  let open Functor.Test_accessors (Instances.Tree) (Implementation) in
  [%expect {| Functor.Test_accessors: running tests. |}]
;;

include (Implementation : Functor.Accessors with module Types := Instances.Types.Tree)
