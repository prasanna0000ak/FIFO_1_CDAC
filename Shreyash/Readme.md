
-------------------------- FWFT (First Word Fall Through) ANALYSIS-------------------------- 

PURPOSE:

The FWFT module implements a First Word Fall Through mechanism for FIFO read 
operations. Data becomes available at the output before the user asserts REN 
(read enable), improving throughput by eliminating read latency.

-----------------------------------------------------------RTL-----------------------------------------------------------------------------------------

<img width="1615" height="376" alt="FWFT_RTL" src="https://github.com/user-attachments/assets/f2bb7354-b801-4551-8322-65e7c9042077" />

--------------------------------------------------------------------------------------------------------------------------------------------------------


-------------------------- FWFT READ INTERFACE-------------------------- 


PURPOSE:

Provides a synchronous read buffer that automatically fetches data from FIFO 
memory and presents it at output. When FWFT_enable=1, data is continuously 
available without explicit read requests.

INPUTS:

RCLK: Read clock domain clock

RST: Asynchronous active-high reset

REN: Read request from downstream user (data consumption signal)

REMPTY: Empty flag from FIFO (indicates no data available)

FWFT_enable: Enable signal to activate FWFT mode (1=enabled, 0=disabled)

mem_rdata: Raw data word read from FIFO memory

OUTPUTS:

rdata: Current data word available to user (updated via internal buffer)

valid: Flag indicating rdata contains valid data (1=valid, 0=invalid)

ren_fifo: Internal read enable pulse sent to FIFO memory controller

PARAMETERS:

read_datasize: Width of data words (8 bits typical)


-------------------------- INTERNAL REGISTERS:-------------------------- 

rdata_buf: Holds the latest fetched data word from FIFO

valid_reg: Flag indicating whether rdata_buf contains valid data

pending: Flag indicating FIFO read was requested but data not yet latched


-------------------------- LOGIC -------------------------- 


1. READ ENABLE SIGNAL (ren_fifo_fwft):
   ren_fifo_fwft asserts when:
   - (!valid_reg && !REMPTY && !pending): Buffer empty, FIFO has data, read it now
   - OR (valid_reg && REN && !REMPTY && !pending): Buffer full, user consuming, 
      fetch next word

   This creates a prefetch mechanism: always try to keep buffer full of next word.

2. OUTPUT MUX (ren_fifo):
   - If FWFT_enable=1: Use FWFT logic (ren_fifo_fwft)
   - If FWFT_enable=0: Use direct FIFO read (REN && !REMPTY)

3. STATE MACHINE (Sequential Logic on posedge RCLK):
   
   WHEN FWFT_enable=1:
   
   a) IF pending=1:
      - Load rdata_buf with fresh mem_rdata from FIFO
      - Set valid_reg=1 (data now available to user)
      - Clear pending=0 (latched the data)
   
   b) ELSE IF (REN && valid_reg):
      - User consumed current data
      - Set valid_reg=0 (buffer now empty, waiting for next)
   
   c) IF ren_fifo_fwft=1:
      - FIFO read initiated
      - Set pending=1 (data coming next cycle, mark as pending)

   WHEN FWFT_enable=0:
   - Clear all registers (passthrough mode, no buffering)

4. OUTPUT DATA (rdata):
   - If FWFT_enable=1: rdata = rdata_buf (buffered data)
   - If FWFT_enable=0: rdata = 0 (disabled)

5. OUTPUT VALID (valid):
   - If FWFT_enable=1: valid = valid_reg (valid flag from buffer)
   - If FWFT_enable=0: valid = (REN && !REMPTY) (direct FIFO condition)


--------------------------FWFT OPERATION --------------------------

CYCLE 1 (Initial):
  - valid_reg=0, pending=0
  - FIFO has data (REMPTY=0)
  - ren_fifo_fwft asserts (condition: !valid_reg && !REMPTY)
  - pending set to 1

CYCLE 2:
  - pending=1, so rdata_buf loaded with mem_rdata
  - valid_reg set to 1
  - pending cleared to 0
  - Data NOW AVAILABLE at rdata output
  - ren_fifo_fwft may assert again if FIFO not empty

CYCLE 3 (User reads, REN=1):
  - User asserts REN
  - valid_reg currently 1
  - Data consumed
  - valid_reg will be cleared next cycle
  - New read to FIFO initiated (ren_fifo_fwft asserts)

CYCLE 4:
  - pending=1 again, new data loaded into rdata_buf
  - valid_reg set to 1
  - New data available at output

KEY BENEFIT: Data is pre-fetched and available immediately when user wants it.
             No latency penalty for reading data from FIFO.

------------------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------TESTBENCH--------------------------

PURPOSE:

Behavioral test of FWFT module with stimulus patterns to verify correct operation.

TEST SETUP:
Clock period: 10 ns (5 ns high/low)
Data width: 8 bits
FWFT mode: Enabled throughout test

TEST SEQUENCE:

1. RESET PHASE (0-20 ns):
   - RST=1, REN=0, REMPTY=1 (FIFO empty)
   - FWFT_enable=1 (FWFT active)
   - mem_rdata=0x00

2. RELEASE RESET (20 ns):
   - RST=0
   - Wait 10 ns

3. DATA AVAILABLE (30 ns):
   - REMPTY=0 (FIFO now has data)
   - mem_rdata=0x1A (first data word)
   - Wait 30 ns for prefetch to complete
   - Expected: rdata shows 0x1A, valid=1

4. FIRST READ (60 ns):
   - REN=1 (user requests data)
   - Data 0x1A consumed
   - Wait 10 ns

5. SECOND READ (70 ns):
   - REN=0 (hold current state)
   - mem_rdata=0x5A (new data from FIFO)
   - Wait 30 ns
   - Expected: Next prefetch loads 0x5A into buffer

6. END TEST (100 ns):
   - Simulation finishes

EXPECTED BEHAVIOR:

- After first REMPTY deassertion, 0x1A appears at rdata with valid=1
- When REN asserts, new data prefetch begins
- 0x5A becomes available at rdata output after latency
- ren_fifo pulses show internal read requests to FIFO

------------------------------------------------------------------TESTBENCH--------------------------------------------------------------------------------

<img width="1281" height="403" alt="FWFT_TB" src="https://github.com/user-attachments/assets/9b13fce4-7528-4e6c-a566-ee3513931ab6" />

------------------------------------------------------------------------------------------------------------------------------------------------------------


--------------------------PARAMETER USAGE--------------------------

read_datasize:
  - Controls width of data path (rdata, rdata_buf, mem_rdata)
  - Testbench uses 8-bit width
  - Can be scaled for wider data (16, 32, 64 bits)

FWFT_enable:
  - Allows runtime selection between FWFT and standard read modes
  - When 0: Acts as simple pass-through (REN gated by REMPTY)
  - When 1: Enables prefetch buffering logic


------------------------------------------------------------------------------------------------------------------------------------------------------------
