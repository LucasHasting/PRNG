#Name: Lucas Hasting
#Class: CS 490
#Date: 12/3/2025
#Instructor: Dr. Jerkins
#Description: Script to generate a table for a LCG
#Source: https://en.wikipedia.org/wiki/Linear_congruential_generator

from collections.abc import Generator

def lcg(modulus: int, a: int, c: int, seed: int) -> Generator[int, None, None]:
    """Linear congruential generator."""
    while True:
        seed = (a * seed + c) % modulus
        yield seed
        
# Parameters for the generator
modulus = 2**31 - 1
a = 110351524
c = 12345
seed = 59

# Create generator object
gen = lcg(modulus, a, c, seed)

# Generate the table
for i in range(32):
    val = str(hex(next(gen)))
    print(f".BYTE ${val[2:4]:0>2},${val[4:6]:0>2},${val[6:8]:0>2},${val[8:10]:0>2}")