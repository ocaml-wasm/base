(module
   (import "env" "caml_copy_int64"
      (func $caml_copy_int64 (param i64) (result (ref eq))))
   (import "env" "Int64_val" (func $Int64_val (param (ref eq)) (result i64)))
   (import "env" "Int32_val" (func $Int32_val (param (ref eq)) (result i32)))
   (import "env" "caml_hash"
      (func $caml_hash
         (param (ref eq)) (param (ref eq)) (param (ref eq)) (param (ref eq))
         (result (ref eq))))
   (import "env" "caml_create_bytes"
      (func $caml_create_bytes (param (ref eq)) (result (ref eq))))
   (import "env" "caml_make_vect"
      (func $caml_make_vect
         (param (ref eq)) (param (ref eq)) (result (ref eq))))
   (import "env" "Double_val"
      (func $Double_val (param (ref eq)) (result f64)))

   (func (export "Base_int_math_int_popcount")
      (param (ref eq)) (result (ref eq))
      (ref.i31 (i32.popcnt (i31.get_u (ref.cast (ref i31) (local.get 0))))))

   (func (export "Base_int_math_int_clz")
      (param (ref eq)) (result (ref eq))
      (ref.i31
         (i32.clz
            (i32.or
               (i32.shl
                  (i31.get_s (ref.cast (ref i31) (local.get 0)))
                  (i32.const 1))
               (i32.const 1)))))

   (export "Base_int_math_nativeint_clz" (func $Base_int_math_int32_clz))
   (func $Base_int_math_int32_clz (export "Base_int_math_int32_clz")
      (param (ref eq)) (result (ref eq))
      (ref.i31 (i32.clz (call $Int32_val (local.get 0)))))

   (func (export "Base_int_math_int64_clz")
      (param (ref eq)) (result (ref eq))
      (ref.i31 (i32.wrap_i64 (i64.clz (call $Int64_val (local.get 0))))))

   (func (export "Base_int_math_int_ctz")
      (param (ref eq)) (result (ref eq))
      (ref.i31
         (i32.ctz (i31.get_s (ref.cast (ref i31) (local.get 0))) (i32.const 1))))

   (export "Base_int_math_nativeint_ctz" (func $Base_int_math_int32_ctz))
   (func $Base_int_math_int32_ctz (export "Base_int_math_int32_ctz")
      (param (ref eq)) (result (ref eq))
      (ref.i31 (i32.ctz (call $Int32_val (local.get 0)))))

   (func (export "Base_int_math_int64_ctz")
      (param (ref eq)) (result (ref eq))
      (ref.i31
         (i32.wrap_i64
            (i64.ctz (call $Int64_val (local.get 0))))))

   (func (export "Base_int_math_int_pow_stub")
      (param $vbase (ref eq)) (param $vexp (ref eq)) (result (ref eq))
      (local $base i32) (local $exp i32) (local $res i32)
      (local.set $base (i31.get_s (ref.cast (ref i31) (local.get $vbase))))
      (local.set $exp (i31.get_s (ref.cast (ref i31) (local.get $vexp))))
      (local.set $res (i32.const 1))
      (loop $loop
         (if (i32.ne (local.get $exp) (i32.const 0))
            (then
               (if (i32.and (local.get $exp) (i32.const 1))
                  (then
                     (local.set $res
                        (i32.mul (local.get $res) (local.get $base)))))
               (local.set $exp (i32.shr_u (local.get $exp) (i32.const 1)))
               (local.set $base (i32.mul (local.get $base) (local.get $base)))
               (br $loop))))
      (ref.i31 (local.get $res)))

   (func (export "Base_int_math_int64_pow_stub")
      (param $vbase (ref eq)) (param $vexp (ref eq)) (result (ref eq))
      (local $base i64) (local $exp i64) (local $res i64)
      (local.set $base (call $Int64_val (local.get $vbase)))
      (local.set $exp (call $Int64_val (local.get $vexp)))
      (local.set $res (i64.const 1))
      (loop $loop
         (if (i64.ne (local.get $exp) (i64.const 0))
            (then
               (if (i32.wrap_i64 (i64.and (local.get $exp) (i64.const 1)))
                  (then
                     (local.set $res
                        (i64.mul (local.get $res) (local.get $base)))))
               (local.set $exp (i64.shr_u (local.get $exp) (i64.const 1)))
               (local.set $base (i64.mul (local.get $base) (local.get $base)))
               (br $loop))))
      (return_call $caml_copy_int64 (local.get $res)))

   (func (export "Base_clear_caml_backtrace_pos")
      (param (ref eq)) (result (ref eq))
      (ref.i31 (i32.const 0)))

   (func (export "Base_caml_exn_is_most_recent_exn")
      (param (ref eq)) (result (ref eq))
      (ref.i31 (i32.const 1)))

   (func (export "Base_hash_string") (param $s (ref eq)) (result (ref eq))
      (return_call $caml_hash
         (ref.i31 (i32.const 1)) (ref.i31 (i32.const 1)) (ref.i31 (i32.const 0))
         (local.get $s)))

   (func (export "Base_hash_double") (param $d (ref eq)) (result (ref eq))
      (return_call $caml_hash
         (ref.i31 (i32.const 1)) (ref.i31 (i32.const 1)) (ref.i31 (i32.const 0))
         (local.get $d)))

   (global $Base_am_testing_flag (export "Base_am_testing_flag") (mut (i32))
      (i32.const 0))

   (func (export "Base_am_testing") (param (ref eq)) (result (ref eq))
      (ref.i31 (global.get $Base_am_testing_flag)))


   (func (export "caml_csel_value")
      (param $cond (ref eq)) (param $true (ref eq)) (param $false (ref eq))
      (result (ref eq))
      (select (local.get $true) (local.get $false)
         (i31.get_s (ref.cast (ref i31) (local.get $cond)))))

   (export "Base_unsafe_create_local_bytes" (func $caml_create_bytes))

   (export "caml_make_local_vect" (func $caml_make_vect))

   (func (export "caml_float_min")
      (param $x (ref eq)) (param $y (ref eq)) (result (ref eq))
      (if (result (ref eq))
          (f64.lt
             (call $Double_val (local.get $x))
             (call $Double_val (local.get $y)))
         (then (local.get $x))
         (else (local.get $y))))

   (func (export "caml_float_max")
      (param $x (ref eq)) (param $y (ref eq)) (result (ref eq))
      (if (result (ref eq))
          (f64.gt
             (call $Double_val (local.get $x))
             (call $Double_val (local.get $y)))
         (then (local.get $x))
         (else (local.get $y))))
)
