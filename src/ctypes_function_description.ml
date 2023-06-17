open Ctypes
open Ctypes_zarith

module Functions (F : FOREIGN) = struct
  open F

  module DyadicRational = struct

    open Ctypes_type_description.DyadicRational

    let to_string0 =
      foreign "lp_dyadic_rational_to_string"
        ((@->)
           (ptr (lift_typ t))
           (returning (ptr char)))
  end

  module Ring = struct

    open Ctypes_type_description.Ring
    let lp_Z = foreign_value "lp_Z" t

  end


  module UPolynomial = struct

    open Types_generated.UPolynomial

    let degree =
      foreign "lp_upolynomial_degree"
        ((@->)
           (ptr t)
           (returning size_t))


    let unpack =
      foreign "lp_upolynomial_unpack"
        ((@->)
           (ptr t)
           ((@->)
              (ptr MPZ.t)
              (returning void)))

    let construct =
      foreign "lp_upolynomial_construct"
        ((@->)
           (ptr Ctypes_type_description.Ring.t)
           ((@->)
              size_t
              ((@->)
                 (ptr MPZ.t)
                 (returning (ptr t)))))

    let construct_from_int =
      foreign "lp_upolynomial_construct_from_int"
        ((@->)
           (ptr Ctypes_type_description.Ring.t)
           ((@->)
              size_t
              ((@->)
                 (ptr int)
                 (returning (ptr t)))))

    let construct_power =
      foreign "lp_upolynomial_construct_power"
        ((@->)
           (ptr Ctypes_type_description.Ring.t)
           ((@->)
              size_t
              ((@->)
                 long
                 (returning (ptr t)))))

    let delete =
      foreign "lp_upolynomial_delete"
        ((@->)
           (ptr t)
           (returning (void)))
    
    let to_string0 =
      foreign "lp_upolynomial_to_string"
        ((@->)
           (ptr t)
           (returning (ptr char)))

  end

  module AlgebraicNumber = struct

    open Types_generated.AlgebraicNumber
    
    let to_string0 =
      foreign "lp_algebraic_number_to_string"
        ((@->)
           (ptr t)
           (returning (ptr char)))

    let construct_zero =
      foreign "lp_algebraic_number_construct_zero"
        ((@->)
           (ptr t)
           (returning void))

    let destruct =
      foreign "lp_algebraic_number_destruct"
        ((@->)
           (ptr t)
           (returning void))

  end

end
