module C = Configurator.V1

let is_system op s =
  let re = Str.regexp_string_case_fold op in
  try
    ignore (Str.search_forward re s 0 : int);
    true
  with Not_found -> false

let () =
  let sys = ref "" in
  let pkg = ref [] in
  let first = ref "" in
  let vendor_root = ref "" in
  let vendor_prefix_arg = ref "" in
  let args =
    Arg.(
    [ ("-system", Set_string sys, "set system");
      ("-vendor-root", Set_string vendor_root, "path to project root for vendored deps");
      ("-vendor-prefix", Set_string vendor_prefix_arg, "prefix for vendored deps");
      ("-pkg", Tuple[Set_string first; String(fun s -> pkg := (!first,s)::!pkg)], "package dependency")
    ])
  in
  C.main ~args ~name:"gmp" @@
    fun c ->
    let open C.Pkg_config in
    let sys = !sys in
    let base =
      if is_system "freebsd" sys || is_system "openbsd" sys then
        { libs   = [ "-L/usr/local/lib";    ];
          cflags = [ "-I/usr/local/include"; "-fPIC"; "-w" ] }
      else if is_system "macosx" sys then
        { libs   = [ "-L/opt/local/lib";     "-L/usr/local/lib";    ];
          cflags = [ "-I/opt/local/include"; "-I/usr/local/include"; "-w" ] }
      else
        { libs   = []; cflags = ["-fPIC"; "-w"] }
    in
    let opam_prefix =
      match Sys.getenv_opt "OPAM_SWITCH_PREFIX" with
      | Some p when p <> "" -> Some p
      | _ ->
          begin match C.which c "opam" with
          | None -> None
          | Some opam ->
              let res = C.Process.run c opam [ "var"; "prefix" ] in
              if res.exit_code = 0 then
                let p = String.trim res.stdout in
                if p = "" then None else Some p
              else
                None
          end
    in
    begin
      match opam_prefix with
      | None -> ()
      | Some p ->
          let pc_dir = Filename.concat p "lib/pkgconfig" in
          let new_value =
            match Sys.getenv_opt "PKG_CONFIG_PATH" with
            | None | Some "" -> pc_dir
            | Some v -> pc_dir ^ ":" ^ v
          in
          Unix.putenv "PKG_CONFIG_PATH" new_value
    end;
    let vendor_prefix =
      let provided = !vendor_prefix_arg in
      if provided <> "" then
        Some provided
      else
        match opam_prefix with
        | Some p -> Some p
        | None ->
            let root = !vendor_root in
            if root = "" then None else Some (Filename.concat root "vendor/_install")
    in
    let vendor_prefix =
      match vendor_prefix with
      | None -> None
      | Some p ->
          if Filename.is_relative p then
            Some (Filename.concat (Sys.getcwd ()) p)
          else
            Some p
    in
    let vendor_poly_flags sofar =
      match vendor_prefix with
      | None -> None
      | Some prefix ->
          let libdir = Filename.concat prefix "lib" in
          let incdir = Filename.concat prefix "include" in
          let candidates =
            [ Filename.concat libdir "libpoly.a";
              Filename.concat libdir "libpoly.so";
              Filename.concat libdir "libpoly.dylib";
              Filename.concat libdir "libpoly.so.0";
              Filename.concat libdir "libpoly.0.dylib" ]
          in
          let has_poly = List.exists Sys.file_exists candidates in
          let has_headers = Sys.file_exists (Filename.concat incdir "poly/version.h") in
          if not has_poly && not has_headers then None
          else
            Some
              { libs = sofar.libs @ [ "-L" ^ libdir; "-lpoly" ];
                cflags = sofar.cflags @ [ "-I" ^ incdir ] }
    in
    let aux sofar (linux_name, macos_name) =
      let package =
        if is_system "macosx" sys then macos_name else linux_name
      in
      let default () =
        { libs   = sofar.libs @ ["-l" ^ package];
          cflags = sofar.cflags }
      in
      match C.Pkg_config.get c with
      | None ->
          if linux_name = "poly" then
            match vendor_poly_flags sofar with
            | Some conf -> conf
            | None -> default ()
          else
            default ()
      | Some pc ->
         match C.Pkg_config.query pc ~package with
         | None ->
            if linux_name = "poly" then
              match vendor_poly_flags sofar with
              | Some conf -> conf
              | None -> default ()
            else
              default ()
         | Some deps ->
            { libs   = sofar.libs @ deps.libs ;
              cflags = sofar.cflags @ deps.cflags }
    in
    let conf = List.fold_left aux base !pkg in

    C.Flags.write_sexp "c_flags.sexp" conf.cflags;

    C.Flags.write_sexp "c_library_flags.sexp" conf.libs;

    C.Flags.write_lines "c_flags.lines" conf.cflags;

    let ocaml_lib_flags =
      List.concat_map (fun flag -> [ "-cclib"; flag ]) conf.libs
    in
    C.Flags.write_sexp "c_library_flags.ocaml" ocaml_lib_flags
