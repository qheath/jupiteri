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

let parse_args () =
  let longopts = GetArg.[
    ('v',"verbose"," increase verbosity"),
    GetArg.Lone JupiterI.Output.Verbosity.moreTalk ;

    ('q',"quiet"," decrease verbosity"),
    GetArg.Lone JupiterI.Output.Verbosity.lessTalk ;
  ] and usage =
    Printf.sprintf
      "usage: %s [<options>]"
      Sys.argv.(0)
  in

  GetArg.parse longopts ignore usage ;
  ()

let () =
  let () = parse_args () in
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
