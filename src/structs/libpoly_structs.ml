external to_voidp_nativeint : nativeint -> Cstubs_internals.voidp = "%identity"

open
  struct
    module Ppxc__libpoly_structs =
      struct
        open! Ctypes[@@ocaml.warning "-33-66"]
        type lp_dyadic_rational_struct_0
        let lp_dyadic_rational_struct_0 :
          lp_dyadic_rational_struct_0 Ctypes.structure Ctypes.typ =
          Ctypes.structure ""
        let lp_dyadic_rational_t : _ Ctypes.typ =
          typedef lp_dyadic_rational_struct_0 "lp_dyadic_rational_t"
        module DyadicInterval =
          struct
            type t
            let t : t Ctypes.abstract Ctypes.typ =
              Ctypes_static.Abstract
                {
                  Ctypes_static.aname = "lp_dyadic_interval_t";
                  Ctypes_static.asize = 56;
                  Ctypes_static.aalignment = 8
                }
            external a :
              _ Cstubs_internals.fatptr -> ((nativeint)[@unboxed ]) =
                "bppxc_libpoly_structs_f_1e3_fa"
                "ppxc_libpoly_structs_f_1e3_fa"
            let a : 'ppxc__t_0 -> 'ppxc__t_1 =
              fun ppxc__0_libpoly_structs_10 ->
                let Ctypes_static.CPointer ppxc__1_libpoly_structs_10 =
                  ppxc__0_libpoly_structs_10 in
                Cstubs_internals.make_ptr lp_dyadic_rational_t
                  (to_voidp_nativeint
                     (a ppxc__1_libpoly_structs_10))
            and _ =
              if false
              then
                Stdlib.ignore
                  ((Ctypes.ptr t : _ Ctypes.abstract Ctypes.ptr Ctypes.typ) : 
                  'ppxc__t_0 Ctypes.typ)
            external b :
              _ Cstubs_internals.fatptr -> ((nativeint)[@unboxed ]) =
                "bppxc_libpoly_structs_17_2b6_fb"
                "ppxc_libpoly_structs_17_2b6_fb"
            let b : 'ppxc__t_0 -> 'ppxc__t_1 =
              fun ppxc__0_libpoly_structs_18 ->
                let Ctypes_static.CPointer ppxc__1_libpoly_structs_18 =
                  ppxc__0_libpoly_structs_18 in
                Cstubs_internals.make_ptr lp_dyadic_rational_t
                  (to_voidp_nativeint
                     (b ppxc__1_libpoly_structs_18))
            and _ =
              if false
              then
                Stdlib.ignore
                  ((Ctypes.ptr t : _ Ctypes.abstract Ctypes.ptr Ctypes.typ) : 
                  'ppxc__t_0 Ctypes.typ)
            external a_open :
              _ Cstubs_internals.fatptr -> Unsigned.size_t =
                "ppxc_libpoly_structs_1e_37e_fa_open"
            let a_open : 'ppxc__t_0 -> 'ppxc__t_1 =
              fun ppxc__0_libpoly_structs_1f ->
                let Ctypes_static.CPointer ppxc__1_libpoly_structs_1f =
                  ppxc__0_libpoly_structs_1f in
                a_open ppxc__1_libpoly_structs_1f
            and _ =
              if false
              then
                Stdlib.ignore
                  ((Ctypes.ptr t : _ Ctypes.abstract Ctypes.ptr Ctypes.typ) : 
                  'ppxc__t_0 Ctypes.typ)
            external b_open :
              _ Cstubs_internals.fatptr -> Unsigned.size_t =
                "ppxc_libpoly_structs_25_43d_fb_open"
            let b_open : 'ppxc__t_0 -> 'ppxc__t_1 =
              fun ppxc__0_libpoly_structs_26 ->
                let Ctypes_static.CPointer ppxc__1_libpoly_structs_26 =
                  ppxc__0_libpoly_structs_26 in
                b_open ppxc__1_libpoly_structs_26
            and _ =
              if false
              then
                Stdlib.ignore
                  ((Ctypes.ptr t : _ Ctypes.abstract Ctypes.ptr Ctypes.typ) : 
                  'ppxc__t_0 Ctypes.typ)
            external is_point :
              _ Cstubs_internals.fatptr -> Unsigned.size_t =
                "ppxc_libpoly_structs_2c_4fc_fis_point"
            let is_point : 'ppxc__t_0 -> 'ppxc__t_1 =
              fun ppxc__0_libpoly_structs_2d ->
                let Ctypes_static.CPointer ppxc__1_libpoly_structs_2d =
                  ppxc__0_libpoly_structs_2d in
                is_point ppxc__1_libpoly_structs_2d
            and _ =
              if false
              then
                Stdlib.ignore
                  ((Ctypes.ptr t : _ Ctypes.abstract Ctypes.ptr Ctypes.typ) : 
                  'ppxc__t_0 Ctypes.typ)
          end
      end
    module type __ppxc_libpoly_structs  =
      sig include module type of Ppxc__libpoly_structs end
  end
type lp_dyadic_rational_struct_0 =
  Ppxc__libpoly_structs.lp_dyadic_rational_struct_0
open!
  struct
    module type __ppxc_libpoly_structs  =
      sig
        include
          __ppxc_libpoly_structs with type  lp_dyadic_rational_struct_0 = 
            lp_dyadic_rational_struct_0
      end
  end[@@ocaml.warning "-33-66"]
let lp_dyadic_rational_struct_0 :
  lp_dyadic_rational_struct_0 Ctypes.structure Ctypes.typ =
  Ppxc__libpoly_structs.lp_dyadic_rational_struct_0[@@ocaml.warning "-32"]
let lp_dyadic_rational_t =
  if false
  then
    let module Ppxc__libpoly_structs =
      (Ppxc__libpoly_structs : __ppxc_libpoly_structs) in
      Ppxc__libpoly_structs.lp_dyadic_rational_t
  else Ppxc__libpoly_structs.lp_dyadic_rational_t[@@ocaml.warning "-32"]
module DyadicInterval =
  struct
    type t = Ppxc__libpoly_structs.DyadicInterval.t
    open!
      struct
        module type __ppxc_libpoly_structs  =
          sig include __ppxc_libpoly_structs with type  DyadicInterval.t =  t
          end
      end[@@ocaml.warning "-33-66"]
    let t : t Ctypes.abstract Ctypes.typ =
      Ppxc__libpoly_structs.DyadicInterval.t[@@ocaml.warning "-32"]
    let a =
      if false
      then
        let module Ppxc__libpoly_structs =
          (Ppxc__libpoly_structs : __ppxc_libpoly_structs) in
          Ppxc__libpoly_structs.DyadicInterval.a
      else Ppxc__libpoly_structs.DyadicInterval.a
    let b =
      if false
      then
        let module Ppxc__libpoly_structs =
          (Ppxc__libpoly_structs : __ppxc_libpoly_structs) in
          Ppxc__libpoly_structs.DyadicInterval.b
      else Ppxc__libpoly_structs.DyadicInterval.b
    let a_open =
      if false
      then
        let module Ppxc__libpoly_structs =
          (Ppxc__libpoly_structs : __ppxc_libpoly_structs) in
          Ppxc__libpoly_structs.DyadicInterval.a_open
      else Ppxc__libpoly_structs.DyadicInterval.a_open
    let b_open =
      if false
      then
        let module Ppxc__libpoly_structs =
          (Ppxc__libpoly_structs : __ppxc_libpoly_structs) in
          Ppxc__libpoly_structs.DyadicInterval.b_open
      else Ppxc__libpoly_structs.DyadicInterval.b_open
    let is_point =
      if false
      then
        let module Ppxc__libpoly_structs =
          (Ppxc__libpoly_structs : __ppxc_libpoly_structs) in
          Ppxc__libpoly_structs.DyadicInterval.is_point
      else Ppxc__libpoly_structs.DyadicInterval.is_point
  end
