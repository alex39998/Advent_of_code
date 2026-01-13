open! Core
open! Hardcaml
open! Hardcaml_waveterm
open! Hardcaml_test_harness

let () =
  let module Sim = Cyclesim.With_interface(Wire.I)(Wire.O) in

  (* let waves_config = 
    Waves_config.to_directory "."
    |> Waves_config.as_wavefile_format ~format:Vcd
  in *)
  
  let sim = Sim.create Wire.create in
  let _waves, sim = Waveform.create sim in
  
  (* Test vectors *)
  let inputs = Cyclesim.inputs sim in
  let outputs = Cyclesim.outputs sim in

  inputs.clock := Bits.vdd;
  inputs.reset := Bits.vdd;
  inputs.enable := Bits.gnd;
  inputs.turn_amnt_day1 := Bits.zero 32;
  
  Cyclesim.cycle sim;

  inputs.reset := Bits.gnd; 
  Cyclesim.cycle sim;

  inputs.enable := Bits.vdd;
  let fin = In_channel.create "in.txt" in
  (try
    while true do
        let line = In_channel.input_line_exn fin |> String.strip in

        let sign_ch = String.get line 0 in
        let num_str = String.sub line ~pos:1 ~len:(String.length line - 1) in
        let abs_num = Int.of_string num_str in
        let value = match sign_ch with
          | 'L' -> -(abs_num)
          | 'R' -> (abs_num)
          | _ -> failwith (sprintf "Invalid leading char %c" sign_ch)
        in

        inputs.turn_amnt_day1 := Bits.of_int_trunc ~width:32 value;
        Cyclesim.cycle sim;

        let output_val = Bits.to_signed_int !(outputs.res_day1) in
        let total_reg = Bits.to_signed_int !(outputs.total_day1_dbg) in
        printf "Input: %d makes Output: %d\n Reg: %d\n" value output_val total_reg
    done
  with End_of_file -> 
    In_channel.close fin);

  inputs.enable := Bits.gnd;
  printf "\n -- Final cycles (enable disabled) -- \n";
  for _ = 1 to 10 do
    Cyclesim.cycle sim;
  done;
  printf "Day1pt1 result: %d \n" (Bits.to_signed_int !(outputs.res_day1))
  
  (* Show waveform *)
  (*Waveform.print ~display_height:10 ~display_width:500 waves;*)