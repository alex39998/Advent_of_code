open! Core
open! Hardcaml
open! Signal

(*Note: PROBLEM is need to implement circular addition, mod is expensive as hell so need another way*)

module I = struct 
    type 'a t = { 
        clock : 'a [@bits 1]
        ;reset : 'a [@bits 1]
        ;enable : 'a [@bits 1]
        ;turn_amnt : 'a [@bits 32]
        }
    [@@deriving sexp_of, hardcaml, compare]
end

module O = struct
    type 'a t = { 
        res_day1 : 'a [@bits 32]
        ; total_day1_dbg : 'a [@bits 64]
    }
    [@@deriving sexp_of, hardcaml, compare]
end

let create (input : Signal.t I.t) : Signal.t O.t =
    let spec = Reg_spec.create ~clock:input.clock ~reset:input.reset () in

    let total_day1 = Signal.reg_fb spec ~width:64 ~f:(fun total -> 
        mux2 input.reset 
        (Signal.of_int_trunc ~width:64 50)
        (mux2 input.enable (total +: sresize input.turn_amnt ~width:64) total) 
    ) in

    let res_day1 = Signal.reg_fb spec ~width:32 ~f:(fun res -> 
        mux2 (input.enable &: (total_day1 ==: zero 64)) (res +: Signal.of_int_trunc ~width:32 1) res
    ) in
    {
        res_day1
        ; total_day1_dbg = total_day1
    }