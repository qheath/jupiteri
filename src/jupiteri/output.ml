(****************************************************************************)
(* Styled and conditional output                                            *)
(* Copyright (C) 2015-2018 Quentin Heath                                    *)
(*                                                                          *)
(* This program is free software; you can redistribute it and/or modify     *)
(* it under the terms of the GNU General Public License as published by     *)
(* the Free Software Foundation; either version 2 of the License, or        *)
(* (at your option) any later version.                                      *)
(*                                                                          *)
(* This program is distributed in the hope that it will be useful,          *)
(* but WITHOUT ANY WARRANTY; without even the implied warranty of           *)
(* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            *)
(* GNU General Public License for more details.                             *)
(*                                                                          *)
(* You should have received a copy of the GNU General Public License along  *)
(* with this program; if not, write to the Free Software Foundation, Inc.,  *)
(* 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.              *)
(****************************************************************************)

let src = Logs.Src.create "jupiteri.output" ~doc:"wrapper around Logs"
(*
module Log = (val Logs.src_log src : Logs.LOG)
 *)

(* Prefix and style *)

module Level : sig
  val pp : Format.formatter -> Logs.level -> unit
  val to_style : Logs.level -> Fmt.style
end = struct
  let to_string = function
    | Logs.App ->
      begin match Array.length Sys.argv with
        | 0 -> Filename.basename Sys.executable_name
        | _ -> Filename.basename Sys.argv.(0)
      end
    | Logs.Error -> "ERROR"
    | Logs.Warning -> "WARNING"
    | Logs.Info -> "INFO"
    | Logs.Debug -> "DEBUG"

  let pp fmt level =
    Format.pp_print_string fmt (to_string level)

  let to_style = function
    | Logs.App -> `Blue
    | Logs.Error -> `Red
    | Logs.Warning -> `Yellow
    | Logs.Info -> `Green
    | Logs.Debug -> `Magenta
end

module Header : sig
  val pp :
    Logs.level ->
    (Format.formatter -> 'a -> unit) ->
    Format.formatter -> 'a -> unit
end = struct
  let pp level pp_tag fmt tag =
    let style = Level.to_style level in
    Fmt.pf fmt "[%a]" Fmt.(styled style pp_tag) tag
end

(* Logging *)

let setup style_renderer level =
  Fmt_tty.setup_std_outputs ?style_renderer () ;
  Logs.Src.set_level src level ;

  let pp_header fmt (level,header) =
    let pp_h pp_tag =
      Header.pp level pp_tag
    in
    match header with
    | None -> pp_h Level.pp fmt level
    | Some header -> pp_h Fmt.string fmt header
  in
  let pp_pos fmt = function
    | None -> ()
    | Some pos ->
      let pp = Logs.Tag.printer Pos.tag_def in
      Format.fprintf fmt "@ %a:@ wrong input:" pp pos
  in

  let lwt_reporter =
    let buf_fmt ~like =
      let b = Buffer.create 512 in
      Fmt.with_buffer ~like b,
      fun () -> let m = Buffer.contents b in Buffer.reset b; m
    in
    let app, app_flush = buf_fmt ~like:Fmt.stdout in
    let dst, dst_flush = buf_fmt ~like:Fmt.stderr in

    let report _src level ~over k msgf =
      let fmt = if level = Logs.App then app else dst in
      let k _ =
        let write () = match level with
          | Logs.App -> Lwt_io.write Lwt_io.stdout (app_flush ())
          | _ -> Lwt_io.write Lwt_io.stderr (dst_flush ())
        in
        let unblock () = over (); Lwt.return_unit in
        Lwt.finalize write unblock |> Lwt.ignore_result;
        k ()
      in
      let format_with_prefix ?header ?tags f =
        let pos = match tags with
          | None -> None
          | Some tags -> Logs.Tag.find Pos.tag_def tags
        in
        Format.kfprintf k fmt ("@[<hov 2>%a%a@ @[" ^^ f ^^ "@]@]@.")
          pp_header (level,header)
          pp_pos pos
      in
      msgf format_with_prefix
    in
    { Logs.report }
  in

  Logs.set_reporter lwt_reporter

let setup_term =
  Cmdliner.Term.(
    const setup $
    Fmt_cli.style_renderer () $
    Logs_cli.level ())

(* Print text, provided the verbosity level is high enough. *)
let app   f = Logs_lwt.app   ~src f
let err   f = Logs_lwt.err   ~src f
let warn  f = Logs_lwt.warn  ~src f
let info  f = Logs_lwt.info  ~src f
let debug f = Logs_lwt.debug ~src f
