open Ctypes
open Ctypes_zarith

open Structs.Libpoly_structs


module DyadicRational = struct

  type s = lp_dyadic_rational_struct_0
  type t = s structure
  let t : t typ  = lift_typ lp_dyadic_rational_struct_0

  let s =
    let field_0 = field (lift_typ lp_dyadic_rational_struct_0) "a" (lift_typ MPZ.t) in
    let field_1 = field (lift_typ lp_dyadic_rational_struct_0) "n" ulong in
    let () = seal (lift_typ lp_dyadic_rational_struct_0) in
    object
      method ctype = lp_dyadic_rational_struct_0
      method members =
        object
          method a = field_0
          method n = field_1
        end
    end

end

module Ring = struct

  type t = [ `lp_int_ring_t ] structure

  let s : t typ = structure ""

  let lp_int_ring_struct =
    let field_0 = field s "ref_count" size_t in
    let field_1 = field s "is_prime" int in
    let field_2 = field s "M" (lift_typ MPZ.t) in
    let field_3 = field s "lb" (lift_typ MPZ.t) in
    let field_4 = field s "ub" (lift_typ MPZ.t) in
    let () = seal s in
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

  let t = typedef s "lp_int_ring_t"

end

module Types (F : TYPE) = struct
  open F

  module DyadicInterval = struct
    include DyadicInterval
    type s = t
    type t = s abstract
  end


  module UPolynomial = struct

    (* Anonymous lp_upolynomial_t *)

    type t = [ `lp_upolynomial_struct ] structure

    let s : t typ = structure ""
    let t = typedef s "lp_upolynomial_t"


  end

  module AlgebraicNumber = struct

    type t = [ `lp_algebraic_number_struct ] structure

    let s : t typ = structure "lp_algebraic_number_struct"

    let lp_algebraic_number_struct =
      let field_0 = field s "f" (ptr UPolynomial.t) in
      let field_1 = field s "I" (lift_typ DyadicInterval.t) in
      let field_2 = field s "sgn_at_a" int in
      let field_3 = field s "sgn_at_b" int in
      let () = seal s in
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
    
    let t = typedef s "lp_algebraic_number_t"

  end

end
