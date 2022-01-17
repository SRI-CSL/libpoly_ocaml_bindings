open Ctypes_zarith
open Unsigned
open Libpoly_ext

let int    = Ctypes.typedef Ctypes.int "int"

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

end

module DyadicInterval = struct
  include DyadicInterval
  type s = t
  type t = s Ctypes.abstract
end

(* Anonymous lp_upolynomial_t *)

let lp_upolynomial_struct_0 : [ `lp_algebraic_number_struct ] Ctypes.structure Ctypes.typ =
  Ctypes.structure "lp_algebraic_number_struct"

let lp_upolynomial_t = Ctypes.typedef lp_upolynomial_struct_0 "lp_upolynomial_t"


module AlgebraicNumber = struct

  type t = [ `lp_algebraic_number_struct ] Ctypes.structure

  let s : t Ctypes.typ =
    Ctypes.structure "lp_algebraic_number_struct"

  let lp_algebraic_number_struct =
    let field_0 = Ctypes.field s "f" (Ctypes.ptr lp_upolynomial_t) in
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

  let is1_int    = Int.(equal one)

  let sgn_at_a t = Ctypes.(getf !@t lp_algebraic_number_struct#members#sgn_at_a |> is1_int)
  let sgn_at_b t = Ctypes.(getf !@t lp_algebraic_number_struct#members#sgn_at_b |> is1_int)
  let interval t = Ctypes.(getf !@t lp_algebraic_number_struct#members#_I |> addr)

end


