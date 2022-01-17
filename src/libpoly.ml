open Libpoly_core

let to_string = Ctypes.(coerce (ptr char) string)

module DyadicRational = struct

  include DyadicRational

  let to_string0 =
    Foreign.foreign "lp_dyadic_rational_to_string"
      (Ctypes.(@->)
         (Ctypes.ptr t)
         (Ctypes.returning (Ctypes.ptr Ctypes.char)))
  
  let to_string x = x |> to_string0 |> to_string

end

module DyadicInterval = struct
  include DyadicInterval

  let a_open x = x |> a_open |> Unsigned.Size_t.(equal one)
  let b_open x = x |> b_open |> Unsigned.Size_t.(equal one)
  let is_point x = x |> is_point |> Unsigned.Size_t.(equal one)

end
                      
module AlgebraicNumber = struct

  include AlgebraicNumber  

  let to_string0 =
    Foreign.foreign "lp_algebraic_number_to_string"
      (Ctypes.(@->)
         (Ctypes.ptr t)
         (Ctypes.returning (Ctypes.ptr Ctypes.char)))

  let to_string x = x |> to_string0 |> to_string

  let construct_zero =
    Foreign.foreign "lp_algebraic_number_construct_zero"
      (Ctypes.(@->)
         (Ctypes.ptr t)
         (Ctypes.returning Ctypes.void))

end
