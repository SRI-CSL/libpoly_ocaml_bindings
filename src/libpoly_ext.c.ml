let%c () = header {|
                   #include <poly/dyadic_rational.h>
                   #include <poly/dyadic_interval.h>
                   |}

(* type lp_dyadic_rational_t  = [ `lp_dyadic_rational_struct ]  Ctypes.structure *)
let%c lp_dyadic_rational_struct_0 = structure ""
let%c lp_dyadic_rational_t = typedef lp_dyadic_rational_struct_0 "lp_dyadic_rational_t"

module DyadicInterval = struct

  let%c t = abstract "lp_dyadic_interval_t"

              [%%c
               external a :
                 interval_ : t ptr -> lp_dyadic_rational_t ptr
                 = {|
                    return &$interval_->a;
                    |}]

          
              [%%c
               external b :
                 interval_ : t ptr -> lp_dyadic_rational_t ptr
                 = {|
                    return &$interval_->b;
                    |}]

              [%%c
               external a_open :
                 interval_ : t ptr -> size_t
                 = {|
                    return $interval_->a_open;
                    |}]

              [%%c
               external b_open :
                 interval_ : t ptr -> size_t
                 = {|
                    return $interval_->b_open;
                    |}]

              [%%c
               external is_point :
                 interval_ : t ptr -> size_t
                 = {|
                    return $interval_->is_point;
                    |}]


end

