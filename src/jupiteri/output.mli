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

(* {6 Verbosity} *)

module Verbosity : sig

  (** Increase the verbosity level. *)
  val moreTalk : unit -> unit

  (** Decrease the verbosity level. *)
  val lessTalk : unit -> unit
end

(* {6 Prefix and style} *)

module Level : sig
  type t = Error | Warning | Debug
end

(* {6 Prefixed and styled output} *)

val kstyprintf : level:Level.t -> (LTerm_text.t -> 'a) ->
  ('b, Format.formatter, unit, 'a) format4 -> 'b

(* {6 Wrappers} *)

val eprintf : ('a, Format.formatter, unit, unit) format4 -> 'a
val wprintf : ('a, Format.formatter, unit, unit) format4 -> 'a
val dprintf : ('a, Format.formatter, unit, unit) format4 -> 'a
