# Assemble program for W65C02SXB board
AS=C:\Users\rebel\Documents\sxb\vasm6502\vasm6502_oldstyle\win\win10\vasm6502_oldstyle.exe
ASFLAGS= -chklabels -dotdir -wdc02
SRC=PRNG.asm
ROM==PRNG.bin
SREC=PRNG.srec

.PHONY: all listing view clean

all: $(SREC)

$(SREC): $(SRC)
	$(AS) $(ASFLAGS) -Fsrec -s19 -crlf -o $@ $(SRC)

$(ROM): $(SRC)
	$(AS) $(ASFLAGS) -Fbin -o $@ $(SRC)

listing: $(SRC)
	$(AS) $(ASFLAGS) -Fbin -o $(ROM) -L listing.out $(SRC)

view: $(ROM)
	/usr/bin/hexdump -C $(ROM)

clean:
	@rm -f $(ROM) $(SREC) listing.out

