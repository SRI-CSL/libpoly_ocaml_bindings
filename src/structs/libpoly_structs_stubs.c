
#include <ctypes_cstubs_internals.h>
#include <caml/callback.h>
#include <caml/fail.h>

#if !defined(__cplusplus)
#if defined(__clang__) && (__clang_major__ > 3 || ((__clang_major__ == 3) && (__clang_minor__ >= 3)))
#define DISABLE_CONST_WARNINGS_PUSH()                                   \
  _Pragma("clang diagnostic push")                                      \
  _Pragma("clang diagnostic ignored \"-Wincompatible-pointer-types-discards-qualifiers\"")
#define DISABLE_CONST_WARNINGS_POP()            \
  _Pragma("clang diagnostic pop")
#elif !defined(__clang__) && defined(__GNUC__) && ( __GNUC__ >= 5 )
#define DISABLE_CONST_WARNINGS_PUSH()                           \
  _Pragma("GCC diagnostic push")                                \
  _Pragma("GCC diagnostic ignored \"-Wdiscarded-qualifiers\"") \
  _Pragma("GCC diagnostic ignored \"-Wdiscarded-array-qualifiers\"")
#define DISABLE_CONST_WARNINGS_POP() \
    _Pragma("GCC diagnostic pop")
#endif
#endif

#ifndef DISABLE_CONST_WARNINGS_PUSH
#define DISABLE_CONST_WARNINGS_PUSH()
#endif

#ifndef DISABLE_CONST_WARNINGS_POP
#define DISABLE_CONST_WARNINGS_POP()
#endif

#ifndef CAMLdrop
#define CAMLdrop caml_local_roots = caml__frame
#endif

#ifdef __cplusplus
#define PPX_CSTUBS_ADDR_OF_FATPTR(typ,var)      \
  (typ)(CTYPES_ADDR_OF_FATPTR(var))
#else
#define PPX_CSTUBS_ADDR_OF_FATPTR(typ,var)      \
  CTYPES_ADDR_OF_FATPTR(var)
#endif

#ifndef CTYPES_PTR_OF_OCAML_BYTES
#ifdef Bytes_val
#define CTYPES_PTR_OF_OCAML_BYTES(s)   \
  (Bytes_val(Field(s, 1)) + Long_val(Field(s, 0)))
#else
#define CTYPES_PTR_OF_OCAML_BYTES(s) CTYPES_PTR_OF_OCAML_STRING(s)
#endif
#endif



                   #include <poly/dyadic_rational.h>
                   #include <poly/dyadic_interval.h>
                   

static lp_dyadic_rational_t* ppxc_libpoly_structs_f_1e3_ia(lp_dyadic_interval_t* ppxc__var0_interval_){

                    return &ppxc__var0_interval_->a;
                    
}


DISABLE_CONST_WARNINGS_PUSH();
#ifdef __cplusplus
extern "C" {
#endif
intnat ppxc_libpoly_structs_f_1e3_fa(value);
value bppxc_libpoly_structs_f_1e3_fa(value);
#ifdef __cplusplus
}
#endif

intnat ppxc_libpoly_structs_f_1e3_fa(value ppxc__0)  {
  CAMLparam1(ppxc__0);
  lp_dyadic_interval_t* ppxc__1 = PPX_CSTUBS_ADDR_OF_FATPTR(lp_dyadic_interval_t*,ppxc__0);
  intnat ppxc__2;
  lp_dyadic_rational_t* ppxc__3;
  ppxc__3 = ppxc_libpoly_structs_f_1e3_ia(ppxc__1);
  ppxc__2 = (intnat)(ppxc__3);
  CAMLreturnT(intnat,ppxc__2);
}
value bppxc_libpoly_structs_f_1e3_fa(value a0)  {
  return(CTYPES_FROM_PTR((ppxc_libpoly_structs_f_1e3_fa(a0))));
}
DISABLE_CONST_WARNINGS_POP();


static lp_dyadic_rational_t* ppxc_libpoly_structs_17_2b6_ib(lp_dyadic_interval_t* ppxc__var0_interval_){

                    return &ppxc__var0_interval_->b;
                    
}


DISABLE_CONST_WARNINGS_PUSH();
#ifdef __cplusplus
extern "C" {
#endif
intnat ppxc_libpoly_structs_17_2b6_fb(value);
value bppxc_libpoly_structs_17_2b6_fb(value);
#ifdef __cplusplus
}
#endif

intnat ppxc_libpoly_structs_17_2b6_fb(value ppxc__0)  {
  CAMLparam1(ppxc__0);
  lp_dyadic_interval_t* ppxc__1 = PPX_CSTUBS_ADDR_OF_FATPTR(lp_dyadic_interval_t*,ppxc__0);
  intnat ppxc__2;
  lp_dyadic_rational_t* ppxc__3;
  ppxc__3 = ppxc_libpoly_structs_17_2b6_ib(ppxc__1);
  ppxc__2 = (intnat)(ppxc__3);
  CAMLreturnT(intnat,ppxc__2);
}
value bppxc_libpoly_structs_17_2b6_fb(value a0)  {
  return(CTYPES_FROM_PTR((ppxc_libpoly_structs_17_2b6_fb(a0))));
}
DISABLE_CONST_WARNINGS_POP();


static size_t ppxc_libpoly_structs_1e_37e_ia_open(lp_dyadic_interval_t* ppxc__var0_interval_){

                    return ppxc__var0_interval_->a_open;
                    
}


DISABLE_CONST_WARNINGS_PUSH();
#ifdef __cplusplus
extern "C" {
#endif
value ppxc_libpoly_structs_1e_37e_fa_open(value);
#ifdef __cplusplus
}
#endif

value ppxc_libpoly_structs_1e_37e_fa_open(value ppxc__0)  {
  CAMLparam1(ppxc__0);
  lp_dyadic_interval_t* ppxc__1 = PPX_CSTUBS_ADDR_OF_FATPTR(lp_dyadic_interval_t*,ppxc__0);
  value ppxc__2;
  size_t ppxc__3;
  ppxc__3 = ppxc_libpoly_structs_1e_37e_ia_open(ppxc__1);
  ppxc__2 = ctypes_copy_size_t(ppxc__3);
  CAMLreturn(ppxc__2);
}
DISABLE_CONST_WARNINGS_POP();


static size_t ppxc_libpoly_structs_25_43d_ib_open(lp_dyadic_interval_t* ppxc__var0_interval_){

                    return ppxc__var0_interval_->b_open;
                    
}


DISABLE_CONST_WARNINGS_PUSH();
#ifdef __cplusplus
extern "C" {
#endif
value ppxc_libpoly_structs_25_43d_fb_open(value);
#ifdef __cplusplus
}
#endif

value ppxc_libpoly_structs_25_43d_fb_open(value ppxc__0)  {
  CAMLparam1(ppxc__0);
  lp_dyadic_interval_t* ppxc__1 = PPX_CSTUBS_ADDR_OF_FATPTR(lp_dyadic_interval_t*,ppxc__0);
  value ppxc__2;
  size_t ppxc__3;
  ppxc__3 = ppxc_libpoly_structs_25_43d_ib_open(ppxc__1);
  ppxc__2 = ctypes_copy_size_t(ppxc__3);
  CAMLreturn(ppxc__2);
}
DISABLE_CONST_WARNINGS_POP();


static size_t ppxc_libpoly_structs_2c_4fc_iis_point(lp_dyadic_interval_t* ppxc__var0_interval_){

                    return ppxc__var0_interval_->is_point;
                    
}


DISABLE_CONST_WARNINGS_PUSH();
#ifdef __cplusplus
extern "C" {
#endif
value ppxc_libpoly_structs_2c_4fc_fis_point(value);
#ifdef __cplusplus
}
#endif

value ppxc_libpoly_structs_2c_4fc_fis_point(value ppxc__0)  {
  CAMLparam1(ppxc__0);
  lp_dyadic_interval_t* ppxc__1 = PPX_CSTUBS_ADDR_OF_FATPTR(lp_dyadic_interval_t*,ppxc__0);
  value ppxc__2;
  size_t ppxc__3;
  ppxc__3 = ppxc_libpoly_structs_2c_4fc_iis_point(ppxc__1);
  ppxc__2 = ctypes_copy_size_t(ppxc__3);
  CAMLreturn(ppxc__2);
}
DISABLE_CONST_WARNINGS_POP();
