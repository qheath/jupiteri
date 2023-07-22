(****************************************************************************)
(* Jupiter I (IO) utils                                                     *)
(* Copyright (C) 2018 Quentin Heath                                         *)
(*                                                                          *)
(* This program is free software: you can redistribute it and/or modify     *)
(* it under the terms of the GNU General Public License as published by     *)
(* the Free Software Foundation, either version 3 of the License, or        *)
(* (at your option) any later version.                                      *)
(*                                                                          *)
(* This program is distributed in the hope that it will be useful,          *)
(* but WITHOUT ANY WARRANTY; without even the implied warranty of           *)
(* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            *)
(* GNU General Public License for more details.                             *)
(*                                                                          *)
(* You should have received a copy of the GNU General Public License        *)
(* along with this program.  If not, see <http://www.gnu.org/licenses/>.    *)
(****************************************************************************)

open Lwt.Syntax

let main () =
  let aux =
    let* () = JupiterI.Output.app (fun m -> m "this is a message") in
    let* () = JupiterI.Output.err (fun m -> m "this is an error") in
    let* () = JupiterI.Output.warn (fun m -> m "this is an warning") in
    let* () = JupiterI.Output.info (fun m -> m "this is information") in
    let* () = JupiterI.Output.debug (fun m -> m "this is debugging") in
    begin match JupiterI.Input.apply_on_string (fun _ -> assert false) "" with
      | Some _ -> ()
      | None -> ()
    end ;
    let code =
      (*
      if Logs.err_count () > 0 then Cmdliner.Cmd.Exit.some_error else
       *)
      Cmdliner.Cmd.Exit.ok
    in
    Lwt.return code
  in
  Lwt_main.run aux

let () =
  let main_term =
    Cmdliner.Term.(const main $ JupiterI.Output.setup_term)
  in
  Stdlib.exit @@ Cmdliner.Cmd.(eval' (v (info "jupiteri") main_term))
