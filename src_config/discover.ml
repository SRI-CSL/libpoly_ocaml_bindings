(* Generate C/LD flags for libpoly + dependencies and write them to files
   consumed by dune. This tries pkg-config first, then falls back to
   platform-specific defaults or a vendored prefix. *)
module C = Configurator.V1

(* Case-insensitive substring match to interpret OCaml "system" strings. *)
let is_system op s =
  let re = Str.regexp_string_case_fold op in
  try
    ignore (Str.search_forward re s 0 : int);
    true
  with Not_found -> false

let () =
  (* Dune passes these arguments via the discover rule. *)
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
  (* Run in configurator context so we can query ocamlc and pkg-config. *)
  C.main ~args ~name:"gmp" @@
    fun c ->
    let open C.Pkg_config in
    let sys = !sys in
    (* Baseline flags are OS-specific and conservative. *)
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
    (* Optional opam prefix to prioritize switch-local pkg-config files. *)
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
      (* Ensure pkg-config sees switch-local .pc files first. *)
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
    (* Optional vendored prefix: explicit arg, opam prefix, or vendor/_install. *)
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
    (* Resolve to absolute path if needed so the linker can use it directly. *)
    let vendor_prefix =
      match vendor_prefix with
      | None -> None
      | Some p ->
          if Filename.is_relative p then
            Some (Filename.concat (Sys.getcwd ()) p)
          else
            Some p
    in
    (* If a vendored libpoly exists, inject it into the flag set. *)
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
    (* Resolve each dependency, with pkg-config taking precedence. *)
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
          (* No pkg-config available; use vendor or bare -l fallback. *)
          if linux_name = "poly" then
            match vendor_poly_flags sofar with
            | Some conf -> conf
            | None -> default ()
          else
            default ()
      | Some pc ->
         match C.Pkg_config.query pc ~package with
         | None ->
            (* pkg-config knows nothing about the package; fall back. *)
            if linux_name = "poly" then
              match vendor_poly_flags sofar with
              | Some conf -> conf
              | None -> default ()
            else
              default ()
         | Some deps ->
            (* Merge discovered flags into the running set. *)
            { libs   = sofar.libs @ deps.libs ;
              cflags = sofar.cflags @ deps.cflags }
    in
    let conf = List.fold_left aux base !pkg in
    let conf =
      let has_libpoly = List.exists ((=) "-lpoly") conf.libs in
      let has_libdir libdir =
        List.exists (fun flag -> flag = "-L" ^ libdir) conf.libs
      in
      let libpoly_candidates =
        [ "libpoly.dylib";
          "libpoly.0.dylib";
          "libpoly.so";
          "libpoly.so.0";
          "libpoly.so.0.0" ]
      in
      let libpoly_in_dir dir =
        List.exists
          (fun name -> Sys.file_exists (Filename.concat dir name))
          libpoly_candidates
      in
      let libpoly_in_flags libs =
        let add_path acc flag =
          if String.length flag >= 2 && String.sub flag 0 2 = "-L" then
            let path = String.sub flag 2 (String.length flag - 2) in
            path :: acc
          else
            acc
        in
        let libdirs = List.rev (List.fold_left add_path [] libs) in
        List.exists libpoly_in_dir libdirs
      in
      let has_substring haystack needle =
        let re = Str.regexp_string needle in
        try
          ignore (Str.search_forward re haystack 0 : int);
          true
        with Not_found -> false
      in
      let opam_libdir =
        match opam_prefix with
        | Some prefix -> Some (Filename.concat prefix "lib")
        | None -> None
      in
      let opam_has_libpoly =
        match opam_libdir with
        | Some dir -> libpoly_in_dir dir
        | None -> false
      in
      let vendor_libdir =
        match vendor_prefix with
        | Some prefix -> Some (Filename.concat prefix "lib")
        | None -> None
      in
      let vendor_has_libpoly =
        match vendor_libdir with
        | Some dir -> libpoly_in_dir dir
        | None -> false
      in
      let strip_build_vendor_libdirs conf =
        if not has_libpoly || not opam_has_libpoly then
          conf
        else
          let is_build_vendor flag =
            if String.length flag < 2 || String.sub flag 0 2 <> "-L" then
              false
            else
              let path = String.sub flag 2 (String.length flag - 2) in
              has_substring path "/_build/" && has_substring path "/vendor_install/"
          in
          { conf with libs = List.filter (fun flag -> not (is_build_vendor flag)) conf.libs }
      in
      let add_opam_libdir conf =
        match opam_libdir with
        | Some libdir ->
            if has_libpoly && opam_has_libpoly && not (has_libdir libdir) then
              (* Keep opam's libdir in the cmxa when opam libpoly exists. *)
              { conf with libs = ("-L" ^ libdir) :: conf.libs }
            else
              conf
        | None -> conf
      in
      let add_vendor_libdir conf =
        match vendor_libdir with
        | Some libdir ->
            if has_libpoly && vendor_has_libpoly && not opam_has_libpoly
               && not (has_libdir libdir) && not (libpoly_in_flags conf.libs) then
              (* Fall back to the vendored libpoly when no other libpoly is found. *)
              { conf with libs = ("-L" ^ libdir) :: conf.libs }
            else
              conf
        | None -> conf
      in
      let conf = add_opam_libdir conf in
      let conf = add_vendor_libdir conf in
      strip_build_vendor_libdirs conf
    in

    (* Emit the same flags in multiple formats for dune rules. *)
    C.Flags.write_sexp "c_flags.sexp" conf.cflags;

    C.Flags.write_sexp "c_library_flags.sexp" conf.libs;

    C.Flags.write_lines "c_flags.lines" conf.cflags;

    (* OCaml -cclib expects each linker flag separately. *)
    let ocaml_lib_flags =
      List.concat_map (fun flag -> [ "-cclib"; flag ]) conf.libs
    in
    C.Flags.write_sexp "c_library_flags.ocaml" ocaml_lib_flags
