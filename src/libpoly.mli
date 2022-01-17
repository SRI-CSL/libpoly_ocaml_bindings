open Ctypes

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

module AlgebraicNumber : sig
  type t = [ `lp_algebraic_number_struct ] structure
  val t : t typ
  val sgn_at_a : t ptr -> bool
  val sgn_at_b : t ptr -> bool
  val interval : t ptr -> DyadicInterval.t ptr
  val to_string : t ptr -> string
  val construct_zero : t ptr -> unit
end
