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
  let waves, sim = Waveform.create sim in
  
  (* Test vectors *)
  let inputs = Cyclesim.inputs sim in

  let fin = open_in "testin.txt" in
  try
    while true do
        let line = input_line fin in
        let value = int_of_string (String.trim line) in
        inputs.input_signal := Bits.of_int_trunc ~width:10 value;
        Cyclesim.cycle sim;
    done
  with End_of_file -> 
    close_in fin;
  
  (* Show waveform *)
  Waveform.print ~display_height:10 ~display_width:200 waves;