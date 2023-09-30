# N-bit-integer-multiplier-and-divider-using-VHDL

__Task#1:__ 

As a promising digital design engineer, you are required to implement an N-bit integer multiplier and divider. The multiplier/divider should have an input to choose whether it will multiply or divide. It will also have 2 inputs (a,b) each has N-bits and two outputs (m,r) N-bits as well. In case of multiplication, the result of multiplication will be of size 2N where the most significant N-bits will be in ‘m’ and the least significant bits will be in ‘r’. On the other hand, the division a/b = ‘m’ and the reminder will be saved in ‘r’.

You are not allowed to use ‘*’ or ‘/’ operators as they will not synthesis, you should implement the hardware circuit yourself.  Both multiplier and divider should be sequential using shifting and adding/subtracting.  

Additionally, the arithmetic unit should have three additional outputs, error bit, busy bit and valid bit. Error bit indicates some error like division by zero, where busy bit indicates that the circuit is busy and can’t accept any input currently, finally, valid bit indicates that the result is ready.
Use a clock and reset signals to initialize your design.

__Task#2:__

Repeat the design above but make the multiplier and division pure combinational circuits. Make sure not to generate any un-necessary latches or flipflops. Use same entity but different architecture and ignore the clock and reset signals.

__Task#3:__

•	Create testbench using procedure to test the above two implementation. Take care that each implementation has its own corner cases with respect to timing. Testcases should be read from a file, you can add additional flag in the file to designate a testcase for the first or second implementation.  At the end you should report the total number of passed testcases as a ratio from the total testcases i.e., 15/15. Use configuration to choose which design 

•	Create testbench that compare both implementations to each other.
