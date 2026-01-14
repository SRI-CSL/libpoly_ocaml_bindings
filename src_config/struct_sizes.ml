module C = Configurator.V1

let is_system op s =
  let re = Str.regexp_string_case_fold op in
  try
    ignore (Str.search_forward re s 0 : int);
    true
  with Not_found -> false

let () =
  let out_path = ref "" in
  let args =
    [("-o", Arg.Set_string out_path, "output file")]
  in
  C.main ~args ~name:"libpoly_struct_sizes" @@ fun c ->
    if !out_path = "" then
      C.die "Missing -o <output file>";

    let sys =
      match C.ocaml_config_var c "system" with
      | Some v -> v
      | None -> ""
    in
    let fallback_cflags =
      if is_system "freebsd" sys || is_system "openbsd" sys then
        [ "-I/usr/local/include" ]
      else if is_system "macosx" sys then
        [ "-I/opt/homebrew/include"; "-I/opt/local/include"; "-I/usr/local/include" ]
      else
        [ "-I/usr/local/include"; "-I/usr/include" ]
    in
    let cflags =
      match C.Pkg_config.get c with
      | None -> fallback_cflags
      | Some pc ->
          (match C.Pkg_config.query pc ~package:"poly.0" with
           | Some p -> p.C.Pkg_config.cflags
           | None -> fallback_cflags)
    in
    let cc =
      match C.ocaml_config_var c "c_compiler" with
      | Some v -> v
      | None -> C.ocaml_config_var_exn c "cc"
    in
    let c_file = Filename.temp_file "libpoly_sizes" ".c" in
    let exe_file = Filename.temp_file "libpoly_sizes" ".exe" in
    let oc = open_out c_file in
    output_string oc
      "#include <stdio.h>\n\
       #include <stddef.h>\n\
       #include <poly/dyadic_interval.h>\n\
       int main(void) {\n\
         printf(\"%zu\\n%zu\\n\", sizeof(lp_dyadic_interval_t), __alignof__(lp_dyadic_interval_t));\n\
         return 0;\n\
       }\n";
    close_out oc;

    let compile =
      C.Process.run c cc (cflags @ [ c_file; "-o"; exe_file ])
    in
    if compile.exit_code <> 0 then
      C.die "Failed to compile size probe";

    let run = C.Process.run c exe_file [] in
    if run.exit_code <> 0 then
      C.die "Failed to run size probe";

    let lines =
      run.stdout
      |> String.split_on_char '\n'
      |> List.filter (fun s -> s <> "")
    in
    match lines with
    | [ size_str; align_str ] ->
        let generated =
          Printf.sprintf
            "open Ctypes\n\ntype t\n\nlet dyadic_interval_t : t abstract typ =\n  abstract ~size:%s ~alignment:%s ~name:\"lp_dyadic_interval_t\"\n"
            size_str align_str
        in
        let oc = open_out !out_path in
        output_string oc generated;
        close_out oc
    | _ ->
        C.die "Unexpected output from size probe"
