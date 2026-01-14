open Ctypes
open Ctypes_zarith
open Unsigned

let to_string = (coerce (ptr char) string)
let is1_int   = Int.(equal one)

module DyadicRational = struct

  include Ctypes_type_description.DyadicRational
  open Ctypes_bindings.Function.DyadicRational
    
  let a x = (getf !@x s#members#a |> addr |> MPZ.to_z)
  let n x = (getf !@x s#members#n |> ULong.to_int)
  let to_string x = x |> to_string0 |> to_string

end


module DyadicInterval = struct

  include Types_generated.DyadicInterval
  include Ctypes_bindings.Function.DyadicInterval

  let a_open x = x |> a_open |> Size_t.(equal one)
  let b_open x = x |> b_open |> Size_t.(equal one)
  let is_point x = x |> is_point |> Size_t.(equal one)

end

module Ring = struct

  include Ctypes_type_description.Ring
  include Ctypes_bindings.Function.Ring

  let ref_count t = (getf !@t lp_int_ring_struct#members#ref_count) |> Size_t.to_int
  let is_prime t  = (getf !@t lp_int_ring_struct#members#is_prime) |> is1_int
  let modulus t   = (getf !@t lp_int_ring_struct#members#_M) |> addr |> MPZ.to_z
  let lb t = (getf !@t lp_int_ring_struct#members#lb) |> addr |> MPZ.to_z
  let ub t = (getf !@t lp_int_ring_struct#members#ub) |> addr |> MPZ.to_z

end


module UPolynomial = struct

  include Types_generated.UPolynomial
  include Ctypes_bindings.Function.UPolynomial
  let degree p = degree p |> Unsigned.Size_t.to_int
  let construct ring degree coeffs = construct ring (Size_t.of_int degree) coeffs
  let construct_from_int ring degree coeffs =
    construct_from_int ring (Size_t.of_int degree) coeffs
  let construct_power ring degree coeff =
    construct_power ring (Size_t.of_int degree) coeff
  let to_string x = x |> to_string0 |> to_string

end

module AlgebraicNumber = struct

  include Types_generated.AlgebraicNumber
  include Ctypes_bindings.Function.AlgebraicNumber

  let sgn_at_a t = (getf !@t lp_algebraic_number_struct#members#sgn_at_a |> is1_int)
  let sgn_at_b t = (getf !@t lp_algebraic_number_struct#members#sgn_at_b |> is1_int)
  let interval t = (getf !@t lp_algebraic_number_struct#members#_I |> addr)
  let f t = (getf !@t lp_algebraic_number_struct#members#f)

  let to_string x = x |> to_string0 |> to_string

  let make () = (make ~finalise:(fun p -> p |> addr |> destruct) t |> addr)

end
