open! Core
open! Hardcaml
open! Signal

module I = struct 
    type 'a t = { input_signal : 'a [@bits 10]}
    [@@deriving sexp_of, hardcaml, compare]
end

module O = struct
    type 'a t = { output_signal : 'a [@bits 10]}
    [@@deriving sexp_of, hardcaml, compare]
end

let create (input : Signal.t I.t) : Signal.t O.t =
    {output_signal = input.input_signal}