open! Core
open! Hardcaml
open! Signal

let start_amnt = 50
let dial_size = 100

let input_width = 32
let accum_width = 64

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
    let dial_size_sig = Signal.of_int_trunc ~width:accum_width dial_size in

    let total_day1 = Signal.reg_fb spec ~width:accum_width ~f:(fun total -> 
        mux2 input.reset 
            (Signal.of_int_trunc ~width:accum_width start_amnt)
            (mux2 input.enable 
                (let nxt_full = total +: sresize input.turn_amnt ~width:accum_width in
                mux2 (nxt_full >=+ dial_size_sig)
                    (nxt_full -: dial_size_sig)
                    (mux2 (nxt_full <+ zero accum_width) 
                        (nxt_full +: dial_size_sig) nxt_full))
                total) 
    ) in

    let res_day1 = Signal.reg_fb spec ~width:input_width ~f:(fun res -> 
        mux2 (input.enable &: (total_day1 ==: zero accum_width)) (res +: Signal.of_int_trunc ~width:input_width 1) res
    ) in
    {
        res_day1
        ; total_day1_dbg = total_day1
    }