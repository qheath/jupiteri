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

(* Verbosity *)

module Verbosity : sig
  val moreTalk : unit -> unit
  val lessTalk : unit -> unit
  val iprintf : int -> LTerm_text.t -> unit
end = struct
  let verbosity = ref 0

  let moreTalk () = incr verbosity

  let lessTalk () = decr verbosity

  (* Print text, provided the verbosity level is high enough. *)
  let iprintf min_verbosity lterm_text =
    if !verbosity>=min_verbosity
    then Lwt_main.run @@ LTerm.eprintls lterm_text
end

(* Prefix and style *)

module ColorCube : sig
  type t = int * int * int

  (*
  val to_256 : t -> t
  val of_256 : t -> t
  val to_index : t -> int
   *)
  val to_color : t -> LTerm_style.color
end = struct
  type t = int * int * int

  let to_256 (r,g,b) =
    r*51,g*51,b*51

  let of_256 (r,g,b) =
    (r+25)/51,(g+25)/51,(b+25)/51

  let to_index (r,g,b) =
    ((r * 6 + g) * 6 + b) + 16

  let to_color (r,g,b) =
    let r,g,b = to_256 (r,g,b) in
    LTerm_style.rgb r g b
end

module Level : sig
  type t = Error | Warning | Debug

  val of_tag : string -> t option
  val to_tag : t -> string
  val to_verbosity : t -> int
  val to_prefix : t -> string
  val to_color_cube : t -> ColorCube.t
  val pp : Format.formatter -> t -> unit
end = struct
  type t = Error | Warning | Debug

  let of_tag = function
    | "error" -> Some Error
    | "warning" -> Some Warning
    | "debug" -> Some Debug
    | _ -> None

  let to_tag = function
    | Error -> "error"
    | Warning -> "warning"
    | Debug -> "debug"

  let to_verbosity = function
    | Error -> 0
    | Warning -> 1
    | Debug -> 2

  let to_prefix = function
    | Error -> "[Error]"
    | Warning -> "[Warning]"
    | Debug -> "[Debug]"

  let to_color_cube = function
    | Error -> 5,1,1
    | Warning -> 4,3,0
    | Debug -> 4,1,5

  let pp fmt level =
    Format.pp_open_tag fmt (to_tag level) ;
    Format.pp_print_string fmt (to_prefix level) ;
    Format.pp_print_space fmt () ;
    Format.pp_close_tag fmt ()
end

(* Prefixed and styled output *)

let read_color tag =
  match Level.of_tag tag with
    | Some level ->
        let fg = level |> Level.to_color_cube |> ColorCube.to_color in
        LTerm_style.{ none with foreground = Some fg ; bold = Some false }
    | None -> LTerm_style.none

let kstyprintf ~level k f =
  LTerm_text.kstyprintf ~read_color k
    ("@[<hov 2>%a@," ^^ f ^^ "@]")
    Level.pp level

(* Wrappers *)

let level_printf ~level f =
  kstyprintf ~level (Verbosity.iprintf @@ Level.to_verbosity level) f

let eprintf f =
  level_printf ~level:Level.Error f

let wprintf f =
  level_printf ~level:Level.Warning f

let dprintf f =
  level_printf ~level:Level.Debug f
