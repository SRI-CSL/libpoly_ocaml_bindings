open Containers

let args = ref []
let description = "Create flags for linking";;

Arg.parse [] (fun a->args := a::!args) description;;

match !args |> List.rev with
| [os] ->
   if String.equal os "macosx"
   then
     print_endline "(:standard -cclib -lpoly.0 -ccopt \"$LDFLAGS\")"
   else
     print_endline "(:standard -cclib -lpoly -ccopt \"$LDFLAGS\")"
| _ -> failwith "Wrong number of arguments in the command.";;
