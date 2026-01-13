open! Core
open! Hardcaml
open! Signal

let start_amnt = 50

let input_width = 32
let accum_width = 64

module I = struct 
    type 'a t = { 
        clock : 'a [@bits 1]
        ;reset : 'a [@bits 1]
        ;enable : 'a [@bits 1]
        ;turn_amnt_day1 : 'a [@bits 32]
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
    let dial_size_sig = Signal.of_int_trunc ~width:input_width 100 in
    let neg_dial_size_sig = Signal.of_int_trunc ~width:input_width (-100) in
    let one = Signal.of_int_trunc ~width:input_width 1 in

    let dial_size_sig_accum = sresize dial_size_sig ~width:accum_width in

    let fold_step (r,q) = 
        let greater_eq = r >=+ dial_size_sig in
        let less_than = r <+ neg_dial_size_sig in

        let rem_step = 
            mux2 greater_eq
                (r -: dial_size_sig)
                (mux2 less_than
                    (r +: dial_size_sig)
                    r)
        in

        let quo_step = 
            mux2 greater_eq
                (q +: one)
                (mux2 less_than 
                    (q -: one)
                    q)
        in

        (rem_step, quo_step)
    in

    let turn_divmod100 =
        let r0 = input.turn_amnt_day1 in
        let q0 = Signal.of_int_trunc ~width:input_width 0 in

        let r1, q1 = fold_step (r0, q0) in
        let r2,  q2  = fold_step (r1,  q1) in
        let r3,  q3  = fold_step (r2,  q2) in
        let r4,  q4  = fold_step (r3,  q3) in
        let r5,  q5  = fold_step (r4,  q4) in
        let r6,  q6  = fold_step (r5,  q5) in
        let r7,  q7  = fold_step (r6,  q6) in
        let r8,  q8  = fold_step (r7,  q7) in
        let r9,  q9  = fold_step (r8,  q8) in
        let r10, q10 = fold_step (r9,  q9) in

        (q10, r10)
    in

    let _quot100, rem100 = turn_divmod100 in

    let total_day1 = Signal.reg_fb spec ~width:accum_width ~f:(fun total -> 
        mux2 input.reset 
            (Signal.of_int_trunc ~width:accum_width start_amnt)
            (mux2 input.enable 
                (let nxt_full = total +: sresize rem100 ~width:accum_width in
                mux2 (nxt_full >=+ dial_size_sig_accum)
                    (nxt_full -: dial_size_sig_accum)
                    (mux2 (nxt_full <+ zero accum_width) 
                        (nxt_full +: dial_size_sig_accum) nxt_full))
                total) 
    ) in

    let res_day1 = Signal.reg_fb spec ~width:input_width ~f:(fun res -> 
        mux2 (input.enable &: (total_day1 ==: zero accum_width)) (res +: Signal.of_int_trunc ~width:input_width 1) res
    ) in

(*    let total_pt2 = Signal.reg_fb spec ~width:accum_width ~f:(fun total ->
        mux2 input.reset
            (Signal.of_int_trunc ~width:accum_width start_amnt)
            ()
    ) in
    
    let res_pt2 = Signal.reg_fb spec ~width:input_width ~f:() in *)

    {
        res_day1
        ; total_day1_dbg = total_day1
    }