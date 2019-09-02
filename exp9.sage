def short_pad_attack(c1, c2, e, n):
    PRxy.<x,y> = PolynomialRing(Zmod(n))
    PRx.<xn> = PolynomialRing(Zmod(n))
    PRZZ.<xz,yz> = PolynomialRing(Zmod(n))

    g1 = x^e - c1
    g2 = (x+y)^e - c2

    q1 = g1.change_ring(PRZZ)
    q2 = g2.change_ring(PRZZ)

    h = q2.resultant(q1)
    h = h.univariate_polynomial()
    h = h.change_ring(PRx).subs(y=xn)
    h = h.monic()

    kbits = n.nbits()//(2*e*e)
    diff = h.small_roots(X=2^kbits, beta=0.5)[0]  # find root < 2^kbits with factor >= n^0.5

    return diff

def related_message_attack(c1, c2, diff, e, n):
    PRx.<x> = PolynomialRing(Zmod(n))
    g1 = x^e - c1
    g2 = (x+diff)^e - c2

    def gcd(g1, g2):
        while g2:
            g1, g2 = g2, g1 % g2
        return g1.monic()

    return -gcd(g1, g2)[0]


if __name__ == '__main__':
    n = 0x2030ca024a23fb978752ccc2897947fd9c82b682915771e447fc1eefa6be8cbcc00df7cc2dfc401516b88b06a044b6fa595ce67f7b02f4a441a2a4495fb05463da88b059f4c1a924b3f6bc1e2a4938be37f5a44dd7a495c6bb264fdae9eda265f5a4c2a5147d84566d8122e25954b94575ec97f4d979fff756f95cbfcc49fcc9
    e = 3

    #nbits = n.nbits()
    #kbits = nbits//(2*e*e)
    #print "upper %d bits (of %d bits) is same" % (nbits-kbits, nbits)

    # ^^ = bit-wise XOR
    # http://doc.sagemath.org/html/en/faq/faq-usage.html#how-do-i-use-the-bitwise-xor-operator-in-sage
    #m1 = randrange(2^nbits)
    #m2 = m1 ^^ randrange(2^kbits)
    #c1 = pow(m1, e, n)
    #c2 = pow(m2, e, n)
    c1=0x45204e3e2d780d6fded3ed4c53ca2a0300a78bd7f9b30afb5e3267bcb7074756ab386a165cf0678e3af272151b0635c784df30117f89d92afe83156d55fc8d45f0d9db0b868737cad674e2407fc83e234498542162f86132f2edaed3580b8da605a3d2df4ccd49150aed3686401790e5d0742ef5288d756fd9a011666c4018d
    c2=0x1c17423e4aa0ee916c513f9f6f7f7f6efda060974ad06282bd846a50571c2b26465aba50a48eda745b0bb5b410d0b89a199256d5034cb2932a03b0b9dffa065a01c856ff967addc8834e9e09d8d51c020f2a115144e20ac17dd23bb645db39f71eb22aa9175f92bc822c102270f183b1cf60cd6460d6cc28624a9cedbd17484c


    diff = short_pad_attack(c1, c2, e, n)
    print "difference of two messages is %d" % diff

    #print m1
    m1 = related_message_attack(c1, c2, diff, e, n)
    print 'm1 =',m1
    #print m2
    print 'm2 =',m1 + diff
    print 'diff =',diff