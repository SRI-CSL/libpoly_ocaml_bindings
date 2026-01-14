open Ctypes

type lp_dyadic_rational_struct_0

let lp_dyadic_rational_struct_0 : lp_dyadic_rational_struct_0 structure typ =
  structure "lp_dyadic_rational_struct"

let lp_dyadic_rational_t =
  typedef lp_dyadic_rational_struct_0 "lp_dyadic_rational_t"

module DyadicInterval = struct
  type t = Libpoly_structs_sizes.t

  let t : t abstract typ =
    Libpoly_structs_sizes.dyadic_interval_t
end
