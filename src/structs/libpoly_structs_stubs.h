#ifndef LIBPOLY_STRUCTS_STUBS_H
#define LIBPOLY_STRUCTS_STUBS_H

#include <poly/dyadic_interval.h>

#ifdef __cplusplus
extern "C" {
#endif

const lp_dyadic_rational_t* lpocaml_dyadic_interval_a(const lp_dyadic_interval_t* i);
const lp_dyadic_rational_t* lpocaml_dyadic_interval_b(const lp_dyadic_interval_t* i);
size_t lpocaml_dyadic_interval_a_open(const lp_dyadic_interval_t* i);
size_t lpocaml_dyadic_interval_b_open(const lp_dyadic_interval_t* i);
size_t lpocaml_dyadic_interval_is_point(const lp_dyadic_interval_t* i);

#ifdef __cplusplus
}
#endif

#endif
