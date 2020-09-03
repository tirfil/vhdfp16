import numpy as np

maxi = 65536.0

rint = np.trunc(maxi * np.random.rand(1000))
dot = np.random.randint(10,size=1000)
#print(rint,dot)
rint2 = rint * (2.0**(-1*dot))
#print(rint,dot,rint2)
rf16 = rint2.astype(np.float16)

for val in zip(rint,dot,rf16):
	v0 = int.from_bytes(np.uint(val[0]).tobytes(),"little")
	v2 = int.from_bytes(np.uint(val[1]).tobytes(),"little")
	v1 = int.from_bytes(np.float16(val[2]).tobytes(),"little")
	print(format(v0,'016b'),format(v2,'04b'),format(v1,'016b'))
