(module
   (import "env" "Int64_val" (func $Int64_val (param (ref eq)) (result i64)))
   (import "env" "Double_val"
      (func $Double_val (param (ref eq)) (result f64)))
   (import "env" "caml_hash_mix_int"
      (func $caml_hash_mix_int (param i32) (param i32) (result i32)))
   (import "env" "caml_hash_mix_int64"
      (func $caml_hash_mix_int64 (param i32) (param i64) (result i32)))
   (import "env" "caml_hash_mix_float"
      (func $caml_hash_mix_float (param i32) (param f64) (result i32)))
   (import "env" "caml_hash_mix_string"
      (func $caml_hash_mix_string
         (param i32) (param (ref $string)) (result i32)))
   (import "env" "caml_hash_mix_final"
      (func $caml_hash_mix_final (param i32) (result i32)))

   (type $string (array (mut i8)))

   (func (export "Base_internalhash_fold_int64")
      (param (ref eq)) (param (ref eq)) (result (ref eq))
      (ref.i31
         (call $caml_hash_mix_int64
            (i31.get_s (ref.cast (ref i31) (local.get 0)))
            (call $Int64_val (local.get 1)))))

   (func (export "Base_internalhash_fold_int")
      (param (ref eq)) (param (ref eq)) (result (ref eq))
      (ref.i31
         (call $caml_hash_mix_int
            (i31.get_s (ref.cast (ref i31) (local.get 0)))
            (i31.get_s (ref.cast (ref i31) (local.get 1))))))

   (func (export "Base_internalhash_fold_float")
      (param (ref eq)) (param (ref eq)) (result (ref eq))
      (ref.i31
         (call $caml_hash_mix_float
            (i31.get_s (ref.cast (ref i31) (local.get 0)))
            (call $Double_val (local.get 1)))))

   (func (export "Base_internalhash_fold_string")
      (param (ref eq)) (param (ref eq)) (result (ref eq))
      (ref.i31
         (call $caml_hash_mix_string
            (i31.get_s (ref.cast (ref i31) (local.get 0)))
            (ref.cast (ref $string) (local.get 1)))))

   (func (export "Base_internalhash_get_hash_value")
      (param (ref eq)) (result (ref eq))
      (ref.i31
         (call $caml_hash_mix_final
            (i31.get_s (ref.cast (ref i31) (local.get 0))))))
)
