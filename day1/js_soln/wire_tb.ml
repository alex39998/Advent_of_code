open Hardcaml
open Hardcaml_waveterm

let () =
  let module Sim = Cyclesim.With_interface(Wire.I)(Wire.O) in
  
  let sim = Sim.create Wire.create in
  let waves, sim = Waveform.create sim in
  
  (* Test vectors *)
  let inputs = Cyclesim.inputs sim in
  
  (* Cycle 1: input = 0 *)
  inputs.input_signal := Bits.vdd;
  Cyclesim.cycle sim;
  
  (* Cycle 2: input = 1 *)
  inputs.input_signal := Bits.gnd;
  Cyclesim.cycle sim;
  
  (* Cycle 3: input = 0 *)
  inputs.input_signal := Bits.vdd;
  Cyclesim.cycle sim;
  
  (* Display waveform *)
  Waveform.print ~display_height:10 ~display_width:70 waves