
-------------------------------------------------------------------------------------------------------------------------------

<img width="1608" height="515" alt="7" src="https://github.com/user-attachments/assets/331a105c-7fcd-424d-8a9a-1fda43e8cfc7" />

7. Concurrent / Simultaneous Streaming Read & Write (fifo_tb8.v)
Concurrent Read Write Waveform

- Full-Duplex Streaming Throughput: 
Both winc and rinc are asserted simultaneously, enabling active writing and reading on every single clock cycle.

- Pipeline Flow (55 ns−140 ns): 
Input stream (01, 02, 03, 04, 05, 06, 07, 08) is written to memory and immediately read out on rdata[7:0] without pipeline stalls.

- Flag Stability: 
wfull and rempty remain stably at 0 during steady-state simultaneous read/write operations.

-------------------------------------------------------------------------------------------------------------------------------

<img width="1321" height="538" alt="6" src="https://github.com/user-attachments/assets/54fb3ad6-87ab-4cb5-b07d-533ee435c7ac" />

6. Full Threshold & Status Flag Lifecycle (fifo_tb7.v)
Threshold Flags Waveform

- Continuous Fill Burst (30 ns−110 ns): 
winc writes a continuous burst (10, 20, 30, 40, 50, 60, 70, 80).

- Dynamic Flag Transitions (Filling):
        rempty drops to 0 (∼50 ns).
        almost_empty and prog_empty clear to 0 (∼65 ns).
        prog_full asserts to 1 (∼80 ns) as depth reaches the programmable threshold.
        almost_full asserts to 1 (∼95 ns) as remaining free memory drops to ≤2 words.
        
- Continuous Drain Burst (130 ns−190 ns):
rinc reads out 10 through 60. Flags de-assert in reverse sequence as memory drains.

-------------------------------------------------------------------------------------------------------------------------------

<img width="1101" height="518" alt="5" src="https://github.com/user-attachments/assets/911d1182-0368-4749-99a4-7a0973efe2be" />

5. Asynchronous Dual-Clock Domain CDC Operation (fifo_tb6.v)
Asynchronous CDC Waveform

- Independent Asynchronous Clocks: 
Demonstrates cross-domain operation between independent wclk (Write Clock) and rclk (Read Clock) domains.

- Write Phase (40 ns−70 ns):
Data bytes d4 and e5 are written in the wclk domain (winc = 1).

- CDC Synchronizer Latency: 
Gray-coded write pointers cross into the rclk domain through 2-stage Flip-Flop synchronizers. rempty safely drops to 0 in rclk after 2 clock cycles of CDC settling time.

- Read Phase (140 ns−170 ns): 
rinc is asserted in the rclk domain, reading d4 and e5 cleanly without metastability or data loss.

-------------------------------------------------------------------------------------------------------------------------------

<img width="1101" height="518" alt="4" src="https://github.com/user-attachments/assets/00e75f37-aa7a-417c-b4e1-dfebd1cc1154" />

4. Data Width Converter: 8-bit to 32-bit Packing (fifo_tb5.v)
Width Converter Waveform

- Word Packing (40 ns−80 ns):
Producer writes four 8-bit bytes (11, 22, 33, 44) sequentially into wdata[7:0].

- Wide Word Readout (105 ns−115 ns): 
The internal converter automatically packs the 4 narrow bytes into a single 32-bit output word 32'h44332211 on rdata[31:0].

- Key Takeaway: 
Proves dynamic bus sizing between different IP component widths without extra clock latency.

-------------------------------------------------------------------------------------------------------------------------------

<img width="1101" height="518" alt="3" src="https://github.com/user-attachments/assets/e29be4d8-43af-4007-a1ef-cca4cc04e913" />

3. SECDED ECC Protection & Error Monitoring (fifo_tb4.v)
ECC Waveform

- Hamming (13,8) Encoded Write (40 ns−70 ns):
Data bytes a5, 3c, and f0 are automatically encoded into 13-bit protected RAM words (8 data bits + 5 parity bits).

- Decoded Data Output (85 ns−115 ns): 
Data is decoded and verified on rdata[7:0].

- Error Flags (ecc_single_err & ecc_double_err): 
Evaluates real-time parity checks to guarantee memory integrity against Soft Errors (SEUs).

-------------------------------------------------------------------------------------------------------------------------------

<img width="1422" height="530" alt="2" src="https://github.com/user-attachments/assets/254527af-b370-4743-9c9e-7b0dc9e84d24" />

2. First-Word Fall-Through (FWFT) Show-Ahead Mode (fifo_tb3.v)
FWFT Waveform

- Zero-Latency Show-Ahead:
  Unlike standard read mode, when winc writes a1 into an empty FIFO (40 ns−60 ns),
  a1 immediately falls through to rdata[7:0] with valid = 1 BEFORE rinc is asserted.
  
- Consumer Handshake (85 ns−95 ns):
  Pulsing rinc pops a1 and automatically pre-fetches the next word b2 onto rdata on the very next cycle.
  
- Key Takeaway:
  Demonstrates 0-clock-cycle read latency for high-speed packet processing pipelines.

-------------------------------------------------------------------------------------------------------------------------------

<img width="1066" height="564" alt="1" src="https://github.com/user-attachments/assets/8a76c45d-a08f-4d69-86de-695ecbb811b2" />

1. Standard Synchronous Operation & Flag Generation (fifo_tb1.v)
Synchronous FIFO Waveform

- Reset & Initialization (0 ns−20 ns):
  rst initializes the FIFO. rempty, almost_empty, and prog_empty are asserted (1).
  
- Sequential Writes (40 ns−70 ns):
  winc is pulsed to write three consecutive data bytes (11, 22, 33). rempty drops to 0, and empty flags clear as depth increases.
  
- Sequential Reads (85 ns−115 ns):
   Asserting rinc reads out 11, 22, and 33 in exact FIFO order. valid stays high during active data output.
  
- Empty Recovery:
  Once all data is read, rempty, almost_empty, and prog_empty return to 1.
  
-------------------------------------------------------------------------------------------------------------------------------
