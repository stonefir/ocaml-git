(*
 * Copyright (c) 2013-2015 Thomas Gazagnaire <thomas@gazagnaire.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *)

(** Mirage implementation of the Git file-system backend and
    protocol. *)

module type FS = sig

  include V1_LWT.FS with type page_aligned_buffer = Cstruct.t

  val connect: unit -> [`Error of error | `Ok of t ] Lwt.t
  (** Every [S] define how to connect to a peticular [t]. *)

  val string_of_error: error -> string
  (** Pretty-print errors. *)

end

module FS (FS: FS): Git.FS.S
(** Create a Irmin store from raw block devices hanlder. *)

module Sync (Conduit: Conduit_mirage.S): sig
  module IO: Git.Sync.IO with type ctx = Resolver_lwt.t * Conduit.ctx
  module Result: (module type of
                   Git.Sync.Result with type fetch = Git.Sync.Result.fetch
                                    and type push  = Git.Sync.Result.push)
  module Make (S: Git.Store.S): Git.Sync.S
    with type t = S.t and type ctx = IO.ctx
end