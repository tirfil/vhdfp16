# half precision floating point (FP16)
import struct
import random as rd

maxi = 65504

def fp16(num):
	s0 = ''
	for c in struct.pack('!e', num):
		s0 += '{:0>8b}'.format(c)
	return s0
	
for i in range(100):
	while True:
		a = rd.random()*maxi
		b = rd.random()*maxi
		if (rd.random() > .5):
			a = -a
		if (rd.random() > .5):
			b = -b
		c = a * b
		if (c < maxi and c > -maxi):
			break

	#print("%d %d %d"%(a,b,c))
	print("%s %s %s %f %f %f"%(fp16(a),fp16(b),fp16(c),a,b,c))
	
