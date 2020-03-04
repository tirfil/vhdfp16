import struct
# half precision floating point (FP16)

def fp16(num):
	s0 = ''
	for c in struct.pack('!e', num):
		s0 += '{:0>8b}'.format(c)
	return s0
	
table = [(15,2),(-52,86),(13,75),(-500,500),(52,-86)]
for pair in table:
	add = pair[0] + pair[1]
	#print("%d+%d=%d"%(pair[0],pair[1],add))
	print("%s %s %s"%(fp16(pair[0]),fp16(pair[1]),fp16(add)))


