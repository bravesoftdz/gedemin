(*******************************************************************)
(*                                                                 *)
(* The contents of this file are subject to the Interbase Public   *)
(* License Version 1.0 (the "License"); you may not use this file  *)
(* except in compliance with the License. You may obtain a copy    *)
(* of the License at http://www.Inprise.com/IPL.html                 *)
(*                                                                 *)
(* Software distributed under the License is distributed on an     *)
(* "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express     *)
(* or implied. See the License for the specific language governing *)
(* rights and limitations under the License.                       *)
(*                                                                 *)
(* The Original Code was created by Inprise Corporation *)
(* and its predecessors. Portions created by Inprise Corporation are     *)
(* Copyright (C) Inprise Corporation. *)
(*                                                                 *)
(* All Rights Reserved.                                            *)
(* Contributor(s): ______________________________________.         *)
(*******************************************************************)

{***********************************************************}
{                                                           }
{ 	PROGRAM:	UDF and Blob filter Utilities library         }
{ 	MODULE:		ib_util.h                                     }
{ 	DESCRIPTION:	Prototype header file for ib_util.c       }
{                                                           }
{***********************************************************}
unit ib_util;

interface

function ib_util_malloc(l: integer): pointer; cdecl; external 'ib_util.dll';

implementation

end.