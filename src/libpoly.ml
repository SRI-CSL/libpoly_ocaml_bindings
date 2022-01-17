open Ctypes_zarith
open Unsigned
open Libpoly_structs

let int = Ctypes.typedef Ctypes.int "int"

let to_string = Ctypes.(coerce (ptr char) string)
let is1_int   = Int.(equal one)

module DyadicRational = struct

  type s = lp_dyadic_rational_struct_0
  type t = s Ctypes.structure
  let t : t Ctypes.typ  = lp_dyadic_rational_struct_0

  let s =
    let field_0 = Ctypes.field lp_dyadic_rational_struct_0 "a" MPZ.t in
    let field_1 = Ctypes.field lp_dyadic_rational_struct_0 "n" Ctypes.ulong in
    let () = Ctypes.seal lp_dyadic_rational_struct_0 in
    object
      method ctype = lp_dyadic_rational_struct_0
      method members =
        object
          method a = field_0
          method n = field_1
        end
    end

  let a x = Ctypes.(getf !@x s#members#a |> addr |> MPZ.to_z)
  let n x = Ctypes.(getf !@x s#members#n |> ULong.to_int)


  let to_string0 =
    Foreign.foreign "lp_dyadic_rational_to_string"
      (Ctypes.(@->)
         (Ctypes.ptr t)
         (Ctypes.returning (Ctypes.ptr Ctypes.char)))
  
  let to_string x = x |> to_string0 |> to_string

end


module DyadicInterval = struct
  include DyadicInterval
  type s = t
  type t = s Ctypes.abstract

  let a_open x = x |> a_open |> Size_t.(equal one)
  let b_open x = x |> b_open |> Size_t.(equal one)
  let is_point x = x |> is_point |> Size_t.(equal one)
end


module Ring = struct

  type t = [ `lp_int_ring_t ] Ctypes.structure

  let s : t Ctypes.typ = Ctypes.structure ""

  let lp_int_ring_struct =
    let field_0 = Ctypes.field s "ref_count" Ctypes.size_t in
    let field_1 = Ctypes.field s "is_prime" Ctypes.int in
    let field_2 = Ctypes.field s "M" MPZ.t in
    let field_3 = Ctypes.field s "lb" MPZ.t in
    let field_4 = Ctypes.field s "ub" MPZ.t in
    let () = Ctypes.seal s in
    object
      method ctype = s
      method members =
        object
          method ref_count = field_0
          method is_prime = field_1
          method _M = field_2
          method lb = field_3
          method ub = field_4
        end
    end

  let t = Ctypes.typedef s "lp_int_ring_t"

  let ref_count t = Ctypes.(getf !@t lp_int_ring_struct#members#ref_count) |> Size_t.to_int
  let is_prime t  = Ctypes.(getf !@t lp_int_ring_struct#members#is_prime) |> is1_int
  let modulus t   = Ctypes.(getf !@t lp_int_ring_struct#members#_M) |> Ctypes.addr |> MPZ.to_z
  let lb t = Ctypes.(getf !@t lp_int_ring_struct#members#lb) |> Ctypes.addr |> MPZ.to_z
  let ub t = Ctypes.(getf !@t lp_int_ring_struct#members#ub) |> Ctypes.addr |> MPZ.to_z

  let lp_Z = Foreign.foreign_value "lp_Z" t

end


module UPolynomial = struct

  (* Anonymous lp_upolynomial_t *)

  type t = [ `lp_upolynomial_struct ] Ctypes.structure

  let s : t Ctypes.typ = Ctypes.structure ""
  let t = Ctypes.typedef s "lp_upolynomial_t"

  let degree =
    Foreign.foreign "lp_upolynomial_degree"
      (Ctypes.(@->)
         (Ctypes.ptr t)
         (Ctypes.returning Ctypes.size_t))

  let degree p = degree p |> Unsigned.Size_t.to_int

  let unpack =
    Foreign.foreign "lp_upolynomial_unpack"
      (Ctypes.(@->)
         (Ctypes.ptr t)
         (Ctypes.(@->)
            (Ctypes.ptr MPZ.t)
            (Ctypes.returning Ctypes.void)))

  let construct = 
    Foreign.foreign "lp_upolynomial_construct"
      (Ctypes.(@->)
         (Ctypes.ptr Ring.t)
         (Ctypes.(@->)
            Ctypes.size_t
            (Ctypes.(@->)
               (Ctypes.ptr MPZ.t)
               (Ctypes.returning (Ctypes.ptr t)))))

  let construct ring degree coeffs = construct ring (Size_t.of_int degree) coeffs

  let construct_from_int =
    Foreign.foreign "lp_upolynomial_construct_from_int"
      (Ctypes.(@->)
         (Ctypes.ptr Ring.t)
         (Ctypes.(@->)
            Ctypes.size_t
            (Ctypes.(@->)
               (Ctypes.ptr Ctypes.int)
               (Ctypes.returning (Ctypes.ptr t)))))

  let construct_from_int ring degree coeffs =
    construct_from_int ring (Size_t.of_int degree) coeffs

  let construct_power =
    Foreign.foreign "lp_upolynomial_construct_power"
      (Ctypes.(@->)
         (Ctypes.ptr Ring.t)
         (Ctypes.(@->)
            Ctypes.size_t
            (Ctypes.(@->)
               Ctypes.long
               (Ctypes.returning (Ctypes.ptr t)))))

  let construct_power ring degree coeff =
    construct_power ring (Size_t.of_int degree) coeff

  let delete =
    Foreign.foreign "lp_upolynomial_delete"
      (Ctypes.(@->)
         (Ctypes.ptr t)
         (Ctypes.returning (Ctypes.void)))
    
  let to_string0 =
    Foreign.foreign "lp_upolynomial_to_string"
      (Ctypes.(@->)
         (Ctypes.ptr t)
         (Ctypes.returning (Ctypes.ptr Ctypes.char)))

  let to_string x = x |> to_string0 |> to_string

end

module AlgebraicNumber = struct

  type t = [ `lp_algebraic_number_struct ] Ctypes.structure

  let s : t Ctypes.typ = Ctypes.structure "lp_algebraic_number_struct"

  let lp_algebraic_number_struct =
    let field_0 = Ctypes.field s "f" (Ctypes.ptr UPolynomial.t) in
    let field_1 = Ctypes.field s "I" DyadicInterval.t in
    let field_2 = Ctypes.field s "sgn_at_a" int in
    let field_3 = Ctypes.field s "sgn_at_b" int in
    let () = Ctypes.seal s in
    object
      method ctype = s
      method members =
        object
          method f = field_0
          method _I = field_1
          method sgn_at_a = field_2
          method sgn_at_b = field_3
        end
    end
  
  let t = Ctypes.typedef s "lp_algebraic_number_t"

  let sgn_at_a t = Ctypes.(getf !@t lp_algebraic_number_struct#members#sgn_at_a |> is1_int)
  let sgn_at_b t = Ctypes.(getf !@t lp_algebraic_number_struct#members#sgn_at_b |> is1_int)
  let interval t = Ctypes.(getf !@t lp_algebraic_number_struct#members#_I |> addr)

  let to_string0 =
    Foreign.foreign "lp_algebraic_number_to_string"
      (Ctypes.(@->)
         (Ctypes.ptr t)
         (Ctypes.returning (Ctypes.ptr Ctypes.char)))

  let to_string x = x |> to_string0 |> to_string

  let construct_zero =
    Foreign.foreign "lp_algebraic_number_construct_zero"
      (Ctypes.(@->)
         (Ctypes.ptr t)
         (Ctypes.returning Ctypes.void))

end
