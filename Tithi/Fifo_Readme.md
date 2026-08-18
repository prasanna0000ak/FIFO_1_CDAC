----------------------SYNC FIFO WRITE POINTER----------------------

Purpose:
Manages the write pointer and full-flag logic for a synchronous FIFO (single-clock domain). Tracks the current write position and detects when the FIFO reaches capacity.

Inputs:
* clk, rst: Write domain clock and asynchronous active-high reset.
* winc: Write increment signal (asserts when valid data is presented for writing).
* rbin_sync: Read pointer from the read side, used to calculate FIFO occupancy and detect the full condition.
Outputs:
* wfull: Asserts when write pointer reaches the synchronized read pointer (FIFO completely full, no more writes allowed).
* wbin: Current write pointer in binary format (incremented on every valid write).
* almost_full: Asserts when free space remaining ≤ 2 locations.
* prog_full: Programmable full flag; asserts when free space ≤ `prog_full_thresh` (configurable threshold).

Key Logic:
* wbinnext calculation: Increments `wbin` by 1 when `winc=1` and `wfull=0`, otherwise holds current value.
* Full detection: Compares the next write pointer with the read pointer after MSB inversion. Full is asserted when the lower pointer bits match and the MSBs indicate one complete buffer wrap.
* Free space calculation: `free_space = 2^addressize - (wbin - rbin_sync)`.

Parameters:
* `addressize`: Width of pointer (4 bits → 16-entry FIFO).
* `prog_full_thresh`: Threshold for programmable full (default: 3).


----------------------SYNC FIFO READ POINTER----------------------

Purpose:
Manages the read pointer and empty-flag logic for a synchronous FIFO. Tracks the current read position and detects when the FIFO is empty.

Inputs:
* clk, rst: Read domain clock and asynchronous active-high reset.
* rinc: Read increment signal (asserts when downstream requests data).
* wbin_sync:Write pointer from the write side, used to calculate FIFO occupancy and detect the empty condition.

Outputs:
* rempty: Asserts when read pointer equals the synchronized write pointer (FIFO is empty).
* rbin: Current read pointer in binary format (incremented on every valid read).
* almost_empty: Asserts when available data ≤ 2 locations.
* prog_empty: Programmable empty flag; asserts when available data ≤ `prog_empty_thresh` (configurable threshold).

Key Logic:
* rbinnext calculation: Increments `rbin` by 1 when `rinc=1` and `rempty=0`, otherwise holds current value.
* Empty detection: Compares next read pointer against synchronized write pointer; empty when pointers are equal.
* Read level calculation: `read_level = wbin_sync - rbin`.

Parameters:
* `addressize`: Width of pointer (4 bits → 16-entry FIFO).
* `prog_empty_thresh`: Threshold for programmable empty (default: 3).
* 
-------------------------------------RTL SYNC AND HIERARCHY WHEN SYNC MODE -------------------------------------------------------------------------------

<img width="1248" height="592" alt="SYNC_RTL" src="https://github.com/user-attachments/assets/2818cc27-6c7c-44bc-b193-0c4cf9a86bdf" />


<img width="841" height="669" alt="SYNC_Verilog" src="https://github.com/user-attachments/assets/125d0661-a147-460f-873b-94ad353f1812" />


------------------------------------------------------------------------------------------------------------------------------------------


----------------------ASYNC FIFO WRITE POINTER----------------------

Purpose:
Manages the write pointer and full-flag logic for an asynchronous FIFO (dual-clock domain). Operates in the write clock domain and compares against the synchronized read pointer for full detection.

Inputs:
* wclk, rst: Write domain clock and asynchronous active-high reset.
* winc: Write increment signal (write request from upstream).
* w_rptr2: Synchronized (metastability-safe) read pointer in Gray code format, synchronized to write clock domain.

Outputs:
* wbin: Current write pointer in binary format.
* wgray: Current write pointer in Gray code format (used for clock-domain crossing).
* wfull: Asserts when the next write pointer (in Gray code) matches the synchronized read pointer with the required MSB inversion for the full condition.
* almost_full: Asserts when free space ≤ 2.
* prog_full: Programmable full flag; asserts when free space ≤ `prog_full_thresh`.

Key Logic:
* Gray code conversion: `wgraynext = wbinnext ^ (wbinnext >> 1)` ensures only 1 bit changes between consecutive pointer values, reducing ambiguity during clock-domain crossing.
* Full detection: Compares the next write Gray pointer with the synchronized read Gray pointer after inversion of the two MSBs. Full is asserted when the remaining Gray-code bits match.
* Binary-to-Gray conversion: `rbin_async` reconstructs binary value from synchronized Gray pointer using XOR chain.
* Free space tracking: `free_space = 2^addressize - (wbin - rbin_async)`.

Parameters:
* `addressize`: Width of pointer.
* `prog_full_thresh`: Programmable full threshold.


----------------------ASYNC FIFO READ POINTER----------------------

Purpose:
Manages the read pointer and empty-flag logic for an asynchronous FIFO in the read clock domain. Compares against the synchronized write pointer for empty detection.

Inputs:
* rclk, rst: Read domain clock and asynchronous active-high reset.
* rinc: Read increment signal (read request from downstream).
* r_wptr2: Synchronized (metastability-safe) write pointer in Gray code format, synchronized to read clock domain.

Outputs:
* rbin: Current read pointer in binary format.
* rgray: Current read pointer in Gray code format (used for clock-domain crossing).
* rempty: Asserts when read pointer equals the synchronized write pointer (FIFO empty condition).
* almost_empty: Asserts when available data ≤ 2.
* prog_empty: Programmable empty flag; asserts when available data ≤ `prog_empty_thresh`.

Key Logic:
* Gray code conversion: `rgraynext = rbinnext ^ (rbinnext >> 1)` ensures only 1 bit changes between consecutive pointer values, reducing ambiguity during clock-domain crossing.
* Empty detection: Compares Gray-coded read pointer directly against synchronized write pointer; empty when equal.
* Binary-to-Gray conversion: `wbin_sync` reconstructs binary value from synchronized Gray pointer.
* Read level calculation: `read_level = wbin_sync - rbin`.

Parameters:
* `addressize`: Width of pointer.
* `prog_empty_thresh`: Programmable empty threshold.
* 

-------------------------------------RTL ASYNC AND HIERARCHY WHEN ASYNC MODE-------------------------------------------------------------------------------

<img width="1248" height="592" alt="ASYNC_RTL" src="https://github.com/user-attachments/assets/c65ddfa6-ed2a-486c-891d-8525cdce980d" />


<img width="689" height="675" alt="ASYNC_Verilog" src="https://github.com/user-attachments/assets/61cf256a-967a-4c6c-a8c3-edb495b67a45" />


------------------------------------------------------------------------------------------------------------------------------------------


----------------------ASYNC READ POINTER SYNC TO WRITE DOMAIN----------------------

Purpose:
Implements a 2-stage synchronizer to safely transfer the read pointer from the read clock domain to the write clock domain, eliminating metastability issues.

Inputs:
* wclk: Write domain clock.
* rst: Asynchronous active-high reset.
* rgray: Read pointer in Gray code format from read domain (asynchronously crossing clock boundary).

Outputs:
* w_rptr2: Synchronized read pointer (stable in write clock domain after 2 wclk cycles).

Key Logic:
* Stage 1: `w_rptr1` captures `rgray` on the first rising edge of `wclk`.
* Stage 2: `w_rptr2` captures `w_rptr1` on the second rising edge of `wclk`.

This 2-stage pipeline ensures that any metastable state in `w_rptr1` settles before `w_rptr2` is used by full-detection logic.
Gray code input ensures only 1 bit changes per clock transition, minimizing metastability risk.

Parameters:
* `addressize`: Width of pointer (determines register width).


----------------------ASYNC WRITE POINTER SYNC TO READ DOMAIN----------------------

Purpose:
Implements a 2-stage synchronizer to safely transfer the write pointer from the write clock domain to the read clock domain, eliminating metastability issues.

Inputs:
* rclk: Read domain clock.
* rst: Asynchronous active-high reset.
* wgray: Write pointer in Gray code format from write domain (asynchronously crossing clock boundary).

Outputs:
* r_wptr2: Synchronized write pointer (stable in read clock domain after 2 rclk cycles).

Key Logic:
* Stage 1: `r_wptr1` captures `wgray` on the first rising edge of `rclk`.
* Stage 2: `r_wptr2` captures `r_wptr1` on the second rising edge of `rclk`.

Same 2-stage pipeline architecture as write-domain synchronizer.
Gray code input ensures safety during cross-domain transfer.

Parameters:
* `addressize`: Width of pointer.


----------------------FIFO MEMORY (Dual-Port RAM)----------------------

Purpose:
Implements the actual data storage as a dual-port RAM, allowing simultaneous reads (in read clock domain) and writes (in write clock domain) without conflicts.

Inputs:
* wclk: Write clock domain.
* rclk: Read clock domain.
* wen: Write enable pulse (asserts when write is valid and FIFO not full).
* ren: Read enable pulse (asserts when read is valid and FIFO not empty).
* wdata: Data to be written (width = `datasize` bits).
* waddr: Write address (lower bits of write pointer; width = `addressize` bits).
* raddr: Read address (lower bits of read pointer; width = `addressize` bits).

Outputs:
* rdata: Data read from memory at `raddr` (width = `datasize` bits).

Key Logic:
* Memory array: `mem[0:(2^addressize)-1]` holds all FIFO entries.
* Write operation: On `posedge wclk`, if `wen=1`, write `wdata` to `mem[waddr]`.
* Read operation: On `posedge rclk`, if `ren=1`, read `mem[raddr]` into output register `rdata`.
* Independent clocks: The memory provides separate write and read clock domains, allowing read and write operations to occur independently.

Parameters:
* `datasize`: Width of data word (8 bits typical).
* `addressize`: Address width (4 bits → 16 locations).


-------------------------------------RTL SYNC AND HIERARCHY-------------------------------------------------------------------------------


<img width="1909" height="1001" alt="ALL_TB" src="https://github.com/user-attachments/assets/02cd22db-e8fa-4565-924b-41d51807cd1c" />



------------------------------------------------------------------------------------------------------------------------------------------


----------------------TOP-LEVEL FIFO WRAPPER----------------------

Purpose:
Integrates all FIFO components (pointers, synchronizers, memory) into a single parameterizable FIFO with mode selection for synchronous or asynchronous operation via generate block.

Inputs:
* wclk: Write clock.
* rclk: Read clock.
* rst: Asynchronous active-high reset.
* winc: Write increment (write request).
* rinc: Read increment (read request).
* wdata: Write data input.

Outputs:
* rdata: Read data output.
* wfull: Write-domain full flag.
* rempty: Read-domain empty flag.
* almost_full: Write-domain almost-full flag.
* almost_empty: Read-domain almost-empty flag.
* prog_full: Write-domain programmable full flag.
* prog_empty: Read-domain programmable empty flag.

Internal Signals:
* wen, ren: Gated write/read enable pulses (only assert when not full/empty).
* wbin, rbin: Binary write and read pointers.
* wgray, rgray: Gray-coded write and read pointers.
* w_rptr2, r_wptr2: Synchronized cross-domain pointers.


----------------------Mode Selection----------------------

* FIFO_mode=0 (SYNC_MODE): Uses synchronous pointer modules (`sync_fifo_write_pointer`, `sync_fifo_read_pointer`). Both read and write clocks are the same.
* FIFO_mode=1 (ASYNC_MODE): Uses asynchronous pointer modules and synchronizers. Allows independent read/write clocks with metastability protection.

Key Instantiations:
1. Conditional instantiation of sync or async pointer control logic via `generate/if`.
2. Shared dual-port RAM (`fifi_memory`) used in both modes.
3. Address mapping: Lower `addressize` bits of the binary pointers feed memory addressing, while the additional pointer bit(s) provide wrap/full information.

Parameters:
* `datasize`: Width of data word (default: 8).
* `addressize`: Pointer width (default: 4 → 16-entry FIFO).
* `prog_full_thresh`: Programmable full threshold (default: 3).
* `prog_empty_thresh`: Programmable empty threshold (default: 3).
* `FIFO_mode`: 0=synchronous, 1=asynchronous (default: 0).
