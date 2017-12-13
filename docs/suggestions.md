I suspect hash2integer() could be rewritten as one or two lines of code, but I don't fully understand what is supposed to do, or why the loop is short by one. It wouldn't kill you to write some comments...

From a performance perspective, there is a lot of duplicated work here — buffers that are reinitialized to the same value for every hash attempt, etc. If you were serious about this, you would inline the sha256 implementation and strip it down to the bare minimum you need, removing all loops and conditionals. You can prefill a 128-byte buffer with the data, difficulty, length and padding and only change the nonce. Even better, you can place the data in the first half and the nonce and difficulty in the second and save the sha256 state after the first half instead of re-hashing the same data every time, and you can integrate the logic of hash2integer() into sha256_final().

Hash2int could be written in about three lines of code, especially if you use a lookup table.




f(h[i]) {
  int j = 7;
    for(; h[i] >> j; --j);
      x += j;
        y[1] = (h[i] * 1 << j) + (h[i+1] >> j);
        } else {
          x += 8;
            y[1] = h[i+1];
            }



For hahs2integer you should be able to drastically simplify the long chain of ifs. Basically all you're doing is checking what the highest set bit in h[i] is, and then doing some shifts on h[i] based on that value. So you should write a function that returns the position of the highest set bit (Which would be a value between 0 and 7, along with an error value like -1 to indicate the value has no set bits), and then do all your math based on that value.


https://docs.oracle.com/cd/E19455-01/806-3773/instructionset-89/index.html

https://docs.oracle.com/cd/E19455-01/806-3773/instructionset-90/index.html



I haven't read you code, but sounds like you're doing something like bitscan. Check out the x86 bsf and bsr assembly instructions.

If those don't apply, maybe also look at using a De Bruin sequences for a potential speedup. 

>Great suggestions, thanks a lot.

De Bruin is a great idea for mining because I would only have to change 1 bit between nonces instead of adding 1 to a 32-byte value.

I had never heard of bsf and bsr instructions, but it looks like they might be doing exactly what I need.

https://en.wikipedia.org/wiki/De_Bruijn_sequence

Report back with performance difference. I'm curious.

The only time I've ever used the instruction was in C#. To call it I allocated unmanaged memory and assigned x86 OP Codes to it, then assigned that memory to a delegate.

The overhead of calling a delegate plus the transition from unmanaged to managed code ended up causing it to be 3x slower than a C# De Bruijn function but only 20 percent slower than using a naive for loop
