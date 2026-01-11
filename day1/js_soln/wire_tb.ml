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

  let fin = In_channel.create "test2.txt" in
  try
    while true do
        let line = In_channel.input_line_exn fin |> String.strip in

        let sign_ch = String.get line 0 in
        let num_str = String.sub line ~pos:1 ~len:(String.length line - 1) in
        let abs_num = Int.of_string num_str in
        let value = match sign_ch with
          | 'L' -> -abs_num
          | 'R' -> abs_num
          | _ -> failwith (sprintf "Invalid leading char %c" sign_ch)
        in

        (* let value = Int.of_string (String.strip line) in *)
        inputs.input_signal := Bits.of_int_trunc ~width:10 value;
        Cyclesim.cycle sim;

        let output_val = Bits.to_signed_int !(outputs.output_signal) in
        printf "Input: %d makes Output: %d\n" value output_val
    done
  with End_of_file -> 
    In_channel.close fin;
  
  (* Show waveform *)
  (*Waveform.print ~display_height:10 ~display_width:500 waves;*)