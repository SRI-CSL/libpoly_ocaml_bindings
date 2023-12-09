open Libpoly

let v  = AlgebraicNumber.make()
let () = AlgebraicNumber.construct_zero v
let () = print_endline(AlgebraicNumber.to_string v)

let p = UPolynomial.construct_power Ring.lp_Z 10 (Signed.Long.of_int 0)
let () = print_endline(UPolynomial.to_string p)

(* The following fails *)
(* let () = UPolynomial.delete p *)
(* let p = UPolynomial.construct_power Ring.lp_Z 10 (Signed.Long.of_int 1)
 * let () = print_endline(UPolynomial.to_string p) *)

(* let coeffs = List.init 5 (fun i -> i)
 * let coeffs = Ctypes.CArray.(of_list Ctypes.int coeffs |> start)
 * let p = UPolynomial.construct_from_int Ring.lp_Z 2 coeffs *)
