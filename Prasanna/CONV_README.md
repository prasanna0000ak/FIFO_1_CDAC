
---------------------Write Width Converter----------------------

Inputs: 

- wclk, rst: Write domain clock and asynchronous active-high reset. 

- wen: Write request from the user/upstream interface (winc && !wfull).  

- wdata : Incoming smaller or equal-sized user data.  


Outputs:

- mem_wen: Write enable pulse forwarded to the memory core (asserts only when a complete memory word is packed).  

- mem_wdata : Fully assembled wide data word written into the FIFO RAM. 

-----------------------------$$$$----------------------------------

---------------------Read Width Converter--------------------------

Inputs:

- rclk, rst: Read domain clock and asynchronous active-high reset. 

- ren: Read request from the user/downstream interface (rinc && !rempty).  

- mem_rdata : Wide data word read from the FIFO RAM.  


Outputs:

- mem_ren: Read enable pulse sent to the memory core (asserts only when all sub-words are consumed and the next memory word is needed). 

- rdata : Current sliced sub-word delivered to the user.  

--------------------------$$$$--------------------------



------------------------------------------------ RTL WRITE WIDTH CONVERSION ----------------------------------------------------

<img width="1894" height="367" alt="W_CONV" src="https://github.com/user-attachments/assets/250baa96-e66a-486b-9775-7cbad76312f1" />

------------------------------------------------ RTL READ WIDTH CONVERSION -----------------------------------------------------

<img width="1622" height="420" alt="R_CONV" src="https://github.com/user-attachments/assets/415c3376-110b-4ae0-8c57-ec7965d35064" />


------------------------------------------------ DATA CONVERSION TEST-BENECH ---------------------------------------------------

<img width="1907" height="517" alt="D_CONV_TB" src="https://github.com/user-attachments/assets/82b60ed2-92a7-44a3-9787-ed759b534663" />



