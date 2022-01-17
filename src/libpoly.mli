open Ctypes
open Ctypes_zarith

module DyadicRational : sig
  type s
  type t = s structure
  val t : t typ
  val a : t ptr -> Z.t
  val n : t ptr -> int
  val to_string : t ptr -> string
end

module DyadicInterval : sig
  type s
  type t = s abstract
  val t : t typ
  val a : t ptr -> DyadicRational.t ptr
  val b : t ptr -> DyadicRational.t ptr
  val a_open : t ptr -> bool
  val b_open : t ptr -> bool
  val is_point : t ptr -> bool
end

module Ring : sig
  type t = [ `lp_int_ring_t ] Ctypes.structure
  val t : t typ
  val ref_count : t ptr -> int
  val is_prime  : t ptr -> bool
  val modulus   : t ptr -> Z.t
  val lb        : t ptr -> Z.t
  val ub        : t ptr -> Z.t
  val lp_Z      : t ptr
end

module UPolynomial : sig
  type t = [ `lp_upolynomial_struct ] Ctypes.structure
  val t : t typ
  val degree : t ptr -> int
  val unpack : t ptr -> MPZ.ptr -> unit
  val construct          : Ring.t ptr -> int -> MPZ.t abstract ptr -> t ptr
  val construct_from_int : Ring.t ptr -> int -> int ptr -> t ptr
  val construct_power    : Ring.t ptr -> int -> Signed.Long.t -> t ptr
  val delete    : t ptr -> unit
  val to_string : t ptr -> string
end
   
module AlgebraicNumber : sig
  type t = [ `lp_algebraic_number_struct ] structure
  val t : t typ
  val sgn_at_a : t ptr -> bool
  val sgn_at_b : t ptr -> bool
  val interval : t ptr -> DyadicInterval.t ptr
  val f        : t ptr -> UPolynomial.t ptr
  val to_string : t ptr -> string
  val construct_zero : t ptr -> unit
end
