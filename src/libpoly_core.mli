open Unsigned

module DyadicRational : sig
  type s
  type t = s Ctypes.structure
  val t : t Ctypes.typ
  val a : t Ctypes.ptr -> Z.t
  val n : t Ctypes.ptr -> int
end

module DyadicInterval : sig
  type s
  type t = s Ctypes.abstract
  val t : t Ctypes_static.typ
  val a : t Ctypes.ptr -> DyadicRational.t Ctypes.ptr
  val b : t Ctypes.ptr -> DyadicRational.t Ctypes.ptr
  val a_open : t Ctypes.ptr -> size_t
  val b_open : t Ctypes.ptr -> size_t
  val is_point : t Ctypes.ptr -> size_t
end

module AlgebraicNumber : sig
  type t = [ `lp_algebraic_number_struct ] Ctypes.structure
  val t : t Ctypes_static.typ
  val sgn_at_a : t Ctypes.ptr -> bool
  val sgn_at_b : t Ctypes.ptr -> bool
  val interval : t Ctypes.ptr -> DyadicInterval.t Ctypes.ptr
end
