#include <poly/dyadic_interval.h>

const lp_dyadic_rational_t* lpocaml_dyadic_interval_a(const lp_dyadic_interval_t* i) {
  return &i->a;
}

const lp_dyadic_rational_t* lpocaml_dyadic_interval_b(const lp_dyadic_interval_t* i) {
  return &i->b;
}

size_t lpocaml_dyadic_interval_a_open(const lp_dyadic_interval_t* i) {
  return i->a_open;
}

size_t lpocaml_dyadic_interval_b_open(const lp_dyadic_interval_t* i) {
  return i->b_open;
}

size_t lpocaml_dyadic_interval_is_point(const lp_dyadic_interval_t* i) {
  return i->is_point;
}
