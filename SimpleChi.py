import numpy as np

#From Claude Opus 5 High:
def chi(A):
    """A: (5, 5, 64) array of dtype bool, indexed [x, y, z]."""
    return np.bitwise_xor(
        A,
        np.bitwise_and(np.bitwise_not(np.roll(A, -1, axis=1)),
                       np.roll(A, -2, axis=1)),
    ).flatten()

rng = np.random.default_rng()
aHex = "24aca848817a9103906b2121c66a0f8db0de9d60b199fb62a621434d484aec9180c7cf00b0b3eb606e8fc4dcbcb3b178b7ea2b6e31efb4629f97bf3e6324ecc7a321ef47554bc8aba7eff54eee4e4bdd486b4c91f1db37e24f960c9e73696ee7175e002fa37253473a921a74bd14717bb41ad569a664e54dc646f78d50e1cea00144dc030484260855a21eaab9333373697c04d3c81dc191b01c3d61ca6be595d6bbf9acab5465574052e881757c6aebb897ff70f34ea3e7c492218850a690a05350cea73c328c79"
#From google search AI:
binaryString = f"{int(aHex, 16):0{len(aHex) * 4}b}"
bitArray = [int(bit) for bit in binaryString]
a = np.array(bitArray).reshape(5, 5, 64)

print("Input shape: " + str(a.shape))
print("Input: " + str(a))

#print output
output = str(np.packbits(chi(a)).tobytes().hex())
print("Output: " + output)

expectedOutput = "04383408b0eb6161964a632c8e280b1cb01811600128f802820963054902fc921084ce21f6b3e5ec669a50ccfeb3f9fd97ca6b2f25a4b44a9b59af36c920ef93eb21efd745fa788b368fde6cef024fdf58234cb071c926e2671616ce6f6d4edf9356c526a112d74372f312e4ec8f63d9b38ed567a444ad4892e4f525e9d2dfd32918dc524488e688c5a2278abb5117772f3ec65fd89dcbb1b11c3563ce6fc59d6e3eeedc2956e4530452e80975dc7aebabd73157df5eafbe40391080d3e2f1a65310cea6681a86d1"
if output == expectedOutput:
    print("Output and expected outputs are equal!")
else:
    print("Output and expected outputs are different!!!!!!!!!!!")