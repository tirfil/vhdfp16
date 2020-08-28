import struct
import numpy as np

maxi = 65536.0

tmp1 = 2.0 * maxi * np.random.rand(1000) - maxi
in1 = tmp1.astype(np.float16)
#print(in1)
tmp2 = 2.0 * maxi * np.random.rand(1000) - maxi
in2 = tmp2.astype(np.float16)
#print(in2)
out0 = in1 + in2
#print(out0)

queue = [0] * 5

for val in zip(in1,in2,out0):
	v0 = int.from_bytes(np.float16(val[0]).tobytes(),"little")
	v1 = int.from_bytes(np.float16(val[1]).tobytes(),"little")
	v2 = int.from_bytes(np.float16(val[2]).tobytes(),"little")
	queue.append(v2)
	v2 = queue.pop(0)
	print(format(v0,'016b'),format(v1,'016b'),format(v2,'016b'))

