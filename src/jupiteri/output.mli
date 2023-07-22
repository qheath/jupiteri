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

(* {6 Logging} *)

(* Setup logging facilities, using [--color], [-v], [--verbose],
 * and [-q] *)
val setup_term : unit Cmdliner.Term.t

val app   : ('a,unit Lwt.t) Logs.msgf -> unit Lwt.t
val err   : ('a,unit Lwt.t) Logs.msgf -> unit Lwt.t
val warn  : ('a,unit Lwt.t) Logs.msgf -> unit Lwt.t
val info  : ('a,unit Lwt.t) Logs.msgf -> unit Lwt.t
val debug : ('a,unit Lwt.t) Logs.msgf -> unit Lwt.t
