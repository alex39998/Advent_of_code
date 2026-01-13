Contains hardware solutions for Advent of Code 2025.

Day 1 is prototyped in Python and the final solution is written in Hardcaml. I opted to slightly pre-process the text file inputs 
in the testbench (from L10 to -10). Implementing that in hardware would be relatively trivial, so instead I just handled it simulation side. 
Design works as follows: there's a total_day1 accumulator register that keeps a running sum, and part 1 and part 2 each have their own result registers.
The accumulator register takes in a bounded value from [-99, 99]. This is done via repeated conditional addition/subtraction; this is possible as inputs
are bounded to +/-999 and dial size is 100, allowing a much more resource-efficient implementation vs a hardware modulo/divider.

To build and run the testbench, from the `day1` directory run `dune exec ./wire_tb.exe`. Results will be printed to terminal. Note, this assumes setup instructions under
https://github.com/janestreet/hardcaml_template_project were followed and the core Hardcaml libraries are installed. 