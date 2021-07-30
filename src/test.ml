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

let main verbosity unverbosity =
  List.iter (fun _ -> JupiterI.Output.Verbosity.moreTalk ()) verbosity ;
  List.iter (fun _ -> JupiterI.Output.Verbosity.lessTalk ()) unverbosity ;
  JupiterI.Output.eprintf "error" ;
  JupiterI.Output.wprintf "warning" ;
  JupiterI.Output.dprintf "debug" ;
  let f lexbuf =
    JupiterI.Output.wprintf "%a"
      JupiterI.Pos.pp (JupiterI.Pos.of_lexbuf lexbuf ()) ;
    assert false
  in
  begin match JupiterI.Input.apply_on_string f "" with
    | Some _ -> ()
    | None -> ()
  end ;
  ()

let () =
  let verbosity =
    let doc = "increase verbosity" in
    Cmdliner.Arg.(value & flag_all & info ["v";"verbose"] ~doc)
  and unverbosity =
    let doc = "decrease verbosity" in
    Cmdliner.Arg.(value & flag_all & info ["q";"quiet"] ~doc)
  in
  let term =
    Cmdliner.Term.(const main $ verbosity $ unverbosity)
  in
  Cmdliner.Term.(exit @@ eval (term,info "jupiteri"))
