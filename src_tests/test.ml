open Libpoly

let v  = Ctypes.make AlgebraicNumber.t |> Ctypes.addr
let () = AlgebraicNumber.construct_zero v
let () = print_endline(AlgebraicNumber.to_string v)
