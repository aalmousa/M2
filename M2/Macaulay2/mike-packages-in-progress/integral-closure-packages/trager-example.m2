tragerTest = method()
tragerTest(Ring, Ideal, List) := (S,I,noetherVars) -> (
     depVars := sort toList( (set gens S) - set noetherVars);
     singI := I + minors(codim I, jacobian I);
     singIK = trim radical eliminate(singI, depVars);
     D = singIK_0;
     << "discriminant is " << D << endl;
     if numgens singIK > 1 then << "restricted singular locus is " << singIK << endl;
     A := S/I;
     R := noetherPosition (noetherVars / (v -> promote(v,A)));
     K := coefficientRing R;
     D = lift(sub(D,R),K);
     tragerOutput = time trager(R,D);
     << netList displayTrager tragerOutput << endl;
     tragerOutput
     )

tragerTest(Ring, Ideal, List) := (S,I,noetherVars) -> (
     depVars := sort toList( (set gens S) - set noetherVars);
     singI := I + minors(codim I, jacobian I);
     singIK = trim radical eliminate(singI, depVars);
     D = singIK_0;
     << "discriminant is " << D << endl;
     if numgens singIK > 1 then << "restricted singular locus is " << singIK << endl;
     A := S/I;
     R := noetherPosition (noetherVars / (v -> promote(v,A)));
     K := coefficientRing R;
     D = lift(sub(D,R),K);
     tragerOutput = time integralClosureDenominator(R,D);
     << netList fractions tragerOutput << endl;
     tragerOutput
     )

end
-- Examples done by hand of the algorithm
--   (will then be placed into code)

restart
needsPackage "TraceForm"
needsPackage "FractionalIdeals"
load "Trager.m2"
load "trager-example.m2"

-- Example 1: rational quartic

-- Example 2: non-normal surface singularity
  -- take a node x line, embed into P^5 via the Segre, take an affine part of the image
  --  which contains a singularity which is the node cross the line.
  --  the normalization should be a plane.
  -- start with the node V(y2z-x3-x2z) x P^1 (vars s,t)
  -- in P^5, take c=1 (i.e. z=1=s)
R1 = ZZ/32003[a..f]
M = genericMatrix(R1,a,3,2)
I1 = minors(2,M)
I2 = ideal"b2c-a3-a2c,b2f-a2d-a2f,bef-ad2-adf,e2f-d3-d2f"
I = I1 + I2
I = sub(I, {c=>1})
I = trim I
codim I
S = ZZ/32003[a,b,d,e,f]
I = sub(I,S)
I = ideal"bf-e,af-d,bd-ae,d3+d2f-e2f,ad2+d2-e2,a2d+ad-be,a3+a2-b2"
use S
tragerOutput = tragerTest(S,I,{a,f})

testIntegrality tragerOutput

R2 = S/I
time R2Fracs = icFractions R2
integralClosure R2
fractionalIdeal R2Fracs

ICring = fractionalIdealFromICFracs(R2Fracs, ring tragerOutput)
ICring == tragerOutput -- trager and icfractions agree on this example
-- the resulting ring is isomorphic to a polynomial ring in two variables,
-- namely w_(0,1) and f
-- this can be checked by successive eliminations
ringFromFractionalIdeal tragerOutput


--boehm3
restart
needsPackage "FractionalIdeals"
needsPackage "TraceForm"
load "Trager.m2"
load "trager-example.m2"
S = QQ[u,v,z]
F = v^5+2*u*v^2*z^2+2*u*v^3*z+u^2*v*z^2-4*u^3*v*z+2*u^5
time tragerOutput = tragerTest(S, ideal F, {u,z})
netList displayTrager tragerOutput
R = ring tragerOutput

A = S/F
time Afracs = icFractions A;
netList Afracs
Aideal = fractionalIdealFromICFracs(Afracs, R)
Aideal == tragerOutput -- trager and icfractions agree on this example
testIntegrality Aideal

--boehm4
restart
needsPackage "FractionalIdeals"
needsPackage "TraceForm"
load "Trager.m2"
load "trager-example.m2"
S = ZZ/32003[u,v,z]
F = 25*u^8+184*u^7*v+518*u^6*v^2+720*u^5*v^3+576*u^4*v^4+282*u^3*v^5+84*u^2*v^6+14*u*v^7+v^8+244*u^7*z+1326*u^6*v*z+2646*u^5*v^2*z+2706*u^4*v^3*z+1590*u^3*v^4*z+546*u^2*v^5*z+102*u*v^6*z+8*v^7*z+854*u^6*z^2+3252*u^5*v*z^2+4770*u^4*v^2*z^2+3582*u^3*v^3*z^2+1476*u^2*v^4*z^2+318*u*v^5*z^2+28*v^6*z^2+1338*u^5*z^3+3740*u^4*v*z^3+4030*u^3*v^2*z^3+2124*u^2*v^3*z^3+550*u*v^4*z^3+56*v^5*z^3+1101*u^4*z^4+2264*u^3*v*z^4+1716*u^2*v^2*z^4+570*u*v^3*z^4+70*v^4*z^4+508*u^3*z^5+738*u^2*v*z^5+354*u*v^2*z^5+56*v^3*z^5+132*u^2*z^6+122*u*v*z^6+28*v^2*z^6+18*u*z^7+8*v*z^7+z^8
time tragerOutput = tragerTest(S, ideal F, {u,z})
netList displayTrager tragerOutput
R = ring tragerOutput
testIntegrality tragerOutput

A = S/F
time Afracs = icFractions A
Aideal = fractionalIdealFromICFracs(Afracs, R)
Aideal == tragerOutput --trager and icFractions agree on this example

--boehm4 over QQ
restart
needsPackage "FractionalIdeals"
needsPackage "TraceForm"
load "Trager.m2"
load "trager-example.m2"
S = QQ[u,v,z]
F = 25*u^8+184*u^7*v+518*u^6*v^2+720*u^5*v^3+576*u^4*v^4+282*u^3*v^5+84*u^2*v^6+14*u*v^7+v^8+244*u^7*z+1326*u^6*v*z+2646*u^5*v^2*z+2706*u^4*v^3*z+1590*u^3*v^4*z+546*u^2*v^5*z+102*u*v^6*z+8*v^7*z+854*u^6*z^2+3252*u^5*v*z^2+4770*u^4*v^2*z^2+3582*u^3*v^3*z^2+1476*u^2*v^4*z^2+318*u*v^5*z^2+28*v^6*z^2+1338*u^5*z^3+3740*u^4*v*z^3+4030*u^3*v^2*z^3+2124*u^2*v^3*z^3+550*u*v^4*z^3+56*v^5*z^3+1101*u^4*z^4+2264*u^3*v*z^4+1716*u^2*v^2*z^4+570*u*v^3*z^4+70*v^4*z^4+508*u^3*z^5+738*u^2*v*z^5+354*u*v^2*z^5+56*v^3*z^5+132*u^2*z^6+122*u*v*z^6+28*v^2*z^6+18*u*z^7+8*v*z^7+z^8
time tragerOutput = tragerTest(S, ideal F, {u,z})
netList displayTrager tragerOutput
testIntegrality tragerOutput

A = S/F
R = ring tragerOutput
integralClosure(A, Verbosity=>1) --slow
time Afracs = icFractions A -- does not finish
Aideal = fractionalIdealFromICFracs(Afracs, R)
Aideal == tragerOutput

--boehm12-QQ
restart
needsPackage "FractionalIdeals"
needsPackage "TraceForm"
load "Trager.m2"
load "trager-example.m2"
S = QQ[u,v,z]
F = -24135/322*u^6-532037/6440*u^5*v+139459/560*u^4*v^2-1464887/12880*u^3*v^3+72187/25760*u^2*v^4+9/8*u*v^5+1/8*v^6-403511/3220*u^5*z-40817/920*u^4*v*z+10059/80*u^3*v^2*z-35445/1288*u^2*v^3*z+19/4*u*v^4*z+3/4*v^5*z-20743/805*u^4*z^2+126379/3220*u^3*v*z^2-423417/6440*u^2*v^2*z^2+11/2*u*v^3*z^2+3/2*v^4*z^2+3443/140*u^3*z^3+u^2*v*z^3+u*v^2*z^3+v^3*z^3
time tragerOutput = tragerTest(S,ideal F, {v,z})
netList displayTrager tragerOutput
factor lift(denominator simplify tragerOutput, coefficientRing ring tragerOutput)
trager(ring tragerOutput, 2*z-v)
R = ring tragerOutput
testIntegrality tragerOutput -- true

A = S/F
time Afracs = icFractions A --17.38s, absolutely horrendous output
Aideal = fractionalIdealFromICFracs(Afracs, R) --slow, but output OK
assert (Aideal == tragerOutput) -- true, trager and icFractions agree

--boehm14 
-- most interesting example so far; our code finds integral elements
--   which are not found by icFractions
S = QQ[u,v,z] -- error: a non unit was found in a ring declared to be a field
F = 1251*v^4*z^3+5184*u*v^3*z^3+5354*u^2*v^2*z^3+115*u^4*z^3-9552*u*v^4*z^2-22496*u^2*v^3*z^2-5424*u^3*v^2*z^2-32*115/23*u^4*v*z^2+192*115*u^2*v^4*z+17472*u^3*v^3*z-13824*u^3*v^4
G = sub(F, u => u+v)
tragerOutput = time tragerTest(S,ideal G, {u,z});
getIntegralEquation tragerOutput -- note all elements are integral
A = S/G
Afracs = icFractions A
R = ring tragerOutput
Aideal = fractionalIdealFromICFracs(Afracs,R);
isSubset(Aideal, tragerOutput) -- true
Aideal == tragerOutput -- false!  we're finding new integral elements

--leonard1
restart
needsPackage "FractionalIdeals"
needsPackage "TraceForm"
load "Trager.m2"
load "trager-example.m2"
S = QQ[x,y]
I = ideal((y^2-y-x/3)^3-y*x^4*(y^2-y-x/3)-x^11)
time tragerOutput = tragerTest(S,I, {x})
netList displayTrager tragerOutput
R = ring tragerOutput
testIntegrality tragerOutput -- true, fast

A = S/I
time Afracs = icFractions A
Aideal = fractionalIdealFromICFracs(Afracs, R)
assert(Aideal == tragerOutput) -- true

--vanHoeij4
restart
needsPackage "FractionalIdeals"
needsPackage "TraceForm"
load "Trager.m2"
load "trager-example.m2"
S = QQ[x,y]
I = ideal"y40+y13x+x4y5+x3(x+1)2"

time tragerOutput = tragerTest(S,I, {y})
netList displayTrager tragerOutput
R = ring tragerOutput
assert testIntegrality tragerOutput

A = S/I
time Afracs = icFractions A -- 3.3sec
Aideal = fractionalIdealFromICFracs(Afracs, R) --
assert (Aideal == tragerOutput) -- true

--singular-sakai5
restart
needsPackage "FractionalIdeals"
needsPackage "TraceForm"
load "Trager.m2"
load "trager-example.m2"
S = QQ[x,y]
I = ideal"55x8+66y2x9+837x2y6-75y4x2-70y6-97y7x2"
I = sub(I, x=>x+y)

time tragerOutput = tragerTest(S,I, {x}) -- 1.75sec
netList displayTrager tragerOutput
R = ring tragerOutput
testIntegrality tragerOutput -- NEED TO CHECK THIS, given that the answers are different!

A = S/I
time Afracs = icFractions A -- 6.77sec
Aideal = fractionalIdealFromICFracs(Afracs, R) --
Aideal == tragerOutput -- FALSE!!
isSubset(Aideal, tragerOutput)  -- true

---------------------------------------------------------------------
--singular-koelman
restart
needsPackage "FractionalIdeals"
needsPackage "TraceForm"
load "Trager.m2"
load "trager-example.m2"
kk = QQ
kk = ZZ/32003 -- for now
S = kk[x,y,z]; -- genus 10  with 26 cusps
I = ideal"761328152x6z4-5431439286x2y8+2494x2z8+228715574724x6y4+
 9127158539954x10-15052058268x6y2z2+3212722859346x8y2-
 134266087241x8z2-202172841y8z2-34263110700x4y6-6697080y6z4-
 2042158x4z6-201803238y10+12024807786x4y4z2-128361096x4y2z4+
 506101284x2z2y6+47970216x2z4y4+660492x2z6y2-
 z10-474z8y2-84366z6y4"
time tragerOutput = tragerTest(S,I, {y,z}) -- 
netList displayTrager tragerOutput
R = ring tragerOutput
assert all(testIntegrality tragerOutput, identity)

A = S/I
time Afracs = icFractions A -- 
Aideal = fractionalIdealFromICFracs(Afracs, R) --
assert(Aideal == tragerOutput) -- 

---------------------------------------------------------------------
--GLS1-char32003
restart
needsPackage "FractionalIdeals"
needsPackage "TraceForm"
load "Trager.m2"
load "trager-example.m2"

kk = ZZ/32003 -- from Greuel-Laplagne-Seelisch arXiv:0904.3561v1
S = kk[x,y]
I = ideal"(x-y)x(y+x2)3-y3(x3+xy-y2)"

time tragerOutput = tragerTest(S,I, {x}) -- .25 sec
netList displayTrager tragerOutput
R = ring tragerOutput
assert all(testIntegrality tragerOutput,identity)

A = S/I
time Afracs = icFractions A -- 1.22 sec 
Aideal = fractionalIdealFromICFracs(Afracs, R) --
assert(Aideal == tragerOutput)

---------------------------------------------------------------------
--GLS7-char32003
restart
needsPackage "FractionalIdeals"
needsPackage "TraceForm"
load "Trager.m2"
load "trager-example.m2"
kk = ZZ/11
kk = ZZ/32003 -- from Greuel-Laplagne-Seelisch arXiv:0904.3561v1
kk = QQ
S = kk[x,y,z,w,t]
I = ideal"x2+zw,
  y3+xwt,
  xw3+z3t+ywt2,
  y2w4-xy2z2t-w3t3"
I = sub(I, t=>t+z)

time tragerOutput = tragerTest(S,I, {w,t}) -- 1.37 sec
netList displayTrager tragerOutput
R = ring tragerOutput
--testIntegrality tragerOutput -- 

A = S/I
time Afracs = icFractions A -- 1.99
time integralClosure(A, Verbosity=>1)
Aideal = fractionalIdealFromICFracs(Afracs, R) --
netList displayTrager Aideal
assert(Aideal == tragerOutput) -- same

---------------------------------------------------------------------
--singular-huneke
restart
needsPackage "FractionalIdeals"
kk = ZZ/31991
S = kk[a..e]
I = ideal"
  5abcde-a5-b5-c5-d5-e5,
  ab3c+bc3d+a3be+cd3e+ade3,
  a2bc2+b2cd2+a2d2e+ab2e2+c2de2,
  abc5-b4c2d-2a2b2cde+ac3d2e-a4de2+bcd2e3+abe5,
  ab2c4-b5cd-a2b3de+2abc2d2e+ad4e2-a2bce3-cde5,
  a3b2cd-bc2d4+ab2c3e-b5de-d6e+3abcd2e2-a2be4-de6,
  a4b2c-abc2d3-ab5e-b3c2de-ad5e+2a2bcde2+cd2e4,
  b6c+bc6+a2b4e-3ab2c2de+c4d2e-a3cde2-abd3e2+bce5"
A = S/I

-- This ring is R1 but not S2
singI = I + minors(codim I, jacobian I)
radsingI = radical singI
integralClosure A
icFractions A
--------------------------------------------------
--leonard1
S = QQ[x,y]
ideal((y^2-y-x/3)^3-y*x^4*(y^2-y-x/3)-x^11)
--------------------------------------------------
--vanHoeij1
S = QQ[x,y]
ideal"y10+(-2494x2+474)y8+(84366+2042158x4-660492x2)y6
           +(128361096x4-4790216x2+6697080-761328152x6)y4
	   +(-12024807786x4-506101284x2+15052058268x6+202172841+134266087241x8)y2
	   +34263110700x4-228715574724x6+5431439286x2+201803238-9127158539954x10-3212722859346x8"
--------------------------------------------------
--vanHoeij2
S = QQ[x,y]
ideal"y20+y13x+x4y5+x3(x+1)2"
--------------------------------------------------
--vanHoeij3
S = QQ[x,y]
ideal"y30+y13x+x4y5+x3(x+1)2"
--------------------------------------------------
--vanHoeij4
S = QQ[x,y]
ideal"y40+y13x+x4y5+x3(x+1)2"
--------------------------------------------------
--boehm1
S = QQ[u,v,z]
ideal(v^4-2*u^3*z+3*u^2*z^2-2*v^2*z^2)
--------------------------------------------------
--boehm2
S = QQ[u,v,z]
F = (v^2-u*z)^2-u^3*z
F = sub(F,{z=>1})
S = QQ[u,v]
ideal(sub(F,S))
--------------------------------------------------
--boehm3
S = QQ[u,v,z]
ideal(v^5+2*u*v^2*z^2+2*u*v^3*z+u^2*v*z^2-4*u^3*v*z+2*u^5)
--------------------------------------------------
--boehm4
S = ZZ/32003[u,v,z] -- QQ is currently out of range
F = 25*u^8+184*u^7*v+518*u^6*v^2+720*u^5*v^3+576*u^4*v^4+282*u^3*v^5+84*u^2*v^6+14*u*v^7+v^8+244*u^7*z+1326*u^6*v*z+2646*u^5*v^2*z+2706*u^4*v^3*z+1590*u^3*v^4*z+546*u^2*v^5*z+102*u*v^6*z+8*v^7*z+854*u^6*z^2+3252*u^5*v*z^2+4770*u^4*v^2*z^2+3582*u^3*v^3*z^2+1476*u^2*v^4*z^2+318*u*v^5*z^2+28*v^6*z^2+1338*u^5*z^3+3740*u^4*v*z^3+4030*u^3*v^2*z^3+2124*u^2*v^3*z^3+550*u*v^4*z^3+56*v^5*z^3+1101*u^4*z^4+2264*u^3*v*z^4+1716*u^2*v^2*z^4+570*u*v^3*z^4+70*v^4*z^4+508*u^3*z^5+738*u^2*v*z^5+354*u*v^2*z^5+56*v^3*z^5+132*u^2*z^6+122*u*v*z^6+28*v^2*z^6+18*u*z^7+8*v*z^7+z^8
ideal F
--------------------------------------------------
--boehm5
S = ZZ/32003[u,v] -- QQ is currently out of range, this one is just the dehomogenization of boehm4, and takes much longer!
F = 25*u^8+184*u^7*v+518*u^6*v^2+720*u^5*v^3+576*u^4*v^4+282*u^3*v^5+84*u^2*v^6+14*u*v^7+v^8+244*u^7+1326*u^6*v+2646*u^5*v^2+2706*u^4*v^3+1590*u^3*v^4+546*u^2*v^5+102*u*v^6+8*v^7+854*u^6+3252*u^5*v+4770*u^4*v^2+3582*u^3*v^3+1476*u^2*v^4+318*u*v^5+28*v^6+1338*u^5+3740*u^4*v+4030*u^3*v^2+2124*u^2*v^3+550*u*v^4+56*v^5+1101*u^4+2264*u^3*v+1716*u^2*v^2+570*u*v^3+70*v^4+508*u^3+738*u^2*v+354*u*v^2+56*v^3+132*u^2+122*u*v+28*v^2+18*u+8*v+1
ideal F
--------------------------------------------------
--boehm6
S = QQ[u,v,z]
F = u^6+3*u^4*v^2+3*u^2*v^4+v^6-4*u^4*z^2-34*u^3*v*z^2-7*u^2*v^2*z^2+12*u*v^3*z^2+6*v^4*z^2+36*u^2*z^4+36*u*v*z^4+9*v^2*z^4
ideal F
--------------------------------------------------
--boehm7
S = QQ[u,v,z]
F = v^9+4*u*v^7*z+4*v^8*z+6*u^2*v^5*z^2+12*u*v^6*z^2+6*v^7*z^2+4*u^3*v^3*z^3+12*u^2*v^4*z^3+12*u*v^5*z^3+3*v^6*z^3+u^4*v*z^4+4*u^3*v^2*z^4+6*u^2*v^3*z^4+3*u*v^4*z^4-2*v^5*z^4+u^2*v^2*z^5+u*v^3*z^5-2*v^4*z^5+u^3*z^6+3*u^2*v*z^6-u*v^2*z^6-6*v^3*z^6-2*u^2*z^7-5*u*v*z^7-4*v^2*z^7-v*z^8
ideal F
--------------------------------------------------
--boehm8
S = QQ[u,v,z]
F = 36*u^7+64*u^6*v+1440*u^5*v^2+216*u^4*v^3+120*u^3*v^4+1728*u^2*v^5+243*u*v^6+36*v^7-96*u^6*z+108*u^5*v*z+16*u^4*v^2*z+576*u^3*v^3*z+216*u^2*v^4*z-12*u*v^5*z+216*v^6*z+88*u^5*z^2+3456*u^4*v*z^2+243*u^3*v^2*z^2+124*u^2*v^3*z^2+3816*u*v^4*z^2+297*v^5*z^2+162*u^4*z^3-20*u^3*v*z^3+936*u^2*v^2*z^3+342*u*v^3*z^3-96*v^4*z^3+1944*u^3*z^4+81*u^2*v*z^4-32*u*v^2*z^4+1536*v^3*z^4
ideal F
--------------------------------------------------
--boehm9
S = QQ[u,v,z]
F = u^5*v^5+21*u^5*v^4*z-36*u^4*v^5*z-19*u^5*v^3*z^2+12*u^4*v^4*z^2+57*u^3*v^5*z^2+u^5*v^2*z^3+u^4*v^3*z^3-53*u^3*v^4*z^3-19*u^2*v^5*z^3+u^5*v*z^4+43*u^3*v^3*z^4+u*v^5*z^4+u^5*z^5-15*u^3*v^2*z^5+u^2*v^3*z^5+u*v^4*z^5+v^5*z^5
ideal F
--------------------------------------------------
--boehm10
S = QQ[u,v,z]
F = u^4-14*u^2*v^2+v^4+8*u^2*v*z+8*v^3*z
ideal F
--------------------------------------------------
--boehm11
S = QQ[u,v,z]
F = 14440*u^5-16227*u^4*v+10812*u^3*v^2-13533*u^2*v^3+3610*u*v^4+1805*v^5+14440*u^4*z-18032*u^3*v*z+16218*u^2*v^2*z-12626*u*v^3*z+3610*v^4*z+3610*u^3*z^2-4508*u^2*v*z^2+5406*u*v^2*z^2-2703*v^3*z^2
ideal F
--------------------------------------------------
--boehm12
S = ZZ/32003[u,v,z]  -- segment fault over QQ
F = -24135/322*u^6-532037/6440*u^5*v+139459/560*u^4*v^2-1464887/12880*u^3*v^3+72187/25760*u^2*v^4+9/8*u*v^5+1/8*v^6-403511/3220*u^5*z-40817/920*u^4*v*z+10059/80*u^3*v^2*z-35445/1288*u^2*v^3*z+19/4*u*v^4*z+3/4*v^5*z-20743/805*u^4*z^2+126379/3220*u^3*v*z^2-423417/6440*u^2*v^2*z^2+11/2*u*v^3*z^2+3/2*v^4*z^2+3443/140*u^3*z^3+u^2*v*z^3+u*v^2*z^3+v^3*z^3
ideal F
--------------------------------------------------
--boehm13
S = ZZ/32003[u,v,z] -- bad over QQ?
F = u^9+u^7*v^2-u^6*v^3-6*u^5*v^4+3*u^4*v^5+4*u^3*v^6-3*u^2*v^7-u*v^8+v^9+4*u^8*z-u^7*v*z+5*u^6*v^2*z+9*u^5*v^3*z-21*u^4*v^4*z-6*u^3*v^5*z+16*u^2*v^6*z+u*v^7*z-5*v^8*z+6*u^7*z^2-4*u^6*v*z^2+3*u^5*v^2*z^2+30*u^4*v^3*z^2-12*u^3*v^4*z^2-27*u^2*v^5*z^2+6*u*v^6*z^2+10*v^7*z^2+4*u^6*z^3-6*u^5*v*z^3-8*u^4*v^2*z^3+25*u^3*v^3*z^3+15*u^2*v^4*z^3-14*u*v^5*z^3-10*v^6*z^3+u^5*z^4-4*u^4*v*z^4-10*u^3*v^2*z^4+2*u^2*v^3*z^4+11*u*v^4*z^4+5*v^5*z^4-u^3*v*z^5-3*u^2*v^2*z^5-3*u*v^3*z^5-v^4*z^5
ideal F
--------------------------------------------------
--boehm14 
S = QQ[u,v,z] -- error: a non unit was found in a ring declared to be a field
F = 1251*v^4*z^3+5184*u*v^3*z^3+5354*u^2*v^2*z^3+115*u^4*z^3-9552*u*v^4*z^2-22496*u^2*v^3*z^2-5424*u^3*v^2*z^2-32*115/23*u^4*v*z^2+192*115*u^2*v^4*z+17472*u^3*v^3*z-13824*u^3*v^4
ideal F
--------------------------------------------------
--boehm15
S = ZZ/32003[u,v,z] -- over QQ, how long does it take?  actually, how long over ZZ/32003?
F = -2*u*v^4*z^4+u^4*v^5+12*u^4*v^3*z^2+12*u^2*v^4*z^3-u^3*v*z^5+11*u^3*v^2*z^4-21*u^3*v^3*z^3-4*u^4*v*z^4+2*u^4*v^2*z^3-6*u^4*v^4*z+u^5*z^4-3*u^5*v^2*z^2+u^5*v^3*z-3*u*v^5*z^3-2*u^2*v^3*z^4+u^3*v^4*z^2+v^5*z^4
ideal F
--------------------------------------------------
--boehm16
S = ZZ/32003[u,v,z]
F = u^10+6*u^9*v-30*u^7*v^3-15*u^6*v^4+u^5*v^5+u^4*v^6+6*u^3*v^7+u^2*v^8+7*u*v^9+v^10+5*u^9*z+24*u^8*v*z-30*u^7*v^2*z-120*u^6*v^3*z-43*u^5*v^4*z+5*u^4*v^5*z+20*u^3*v^6*z+10*u^2*v^7*z+29*u*v^8*z+5*v^9*z+10*u^8*z^2+36*u^7*v*z^2-105*u^6*v^2*z^2-179*u^5*v^3*z^2-38*u^4*v^4*z^2+25*u^3*v^5*z^2+25*u^2*v^6*z^2+46*u*v^7*z^2+10*v^8*z^2+10*u^7*z^3+24*u^6*v*z^3-135*u^5*v^2*z^3-117*u^4*v^3*z^3-u^3*v^4*z^3+25*u^2*v^5*z^3+34*u*v^6*z^3+10*v^7*z^3+5*u^6*z^4+6*u^5*v*z^4-75*u^4*v^2*z^4-27*u^3*v^3*z^4+10*u^2*v^4*z^4+11*u*v^5*z^4+5*v^6*z^4+u^5*z^5-15*u^3*v^2*z^5+u^2*v^3*z^5+u*v^4*z^5+v^5*z^5
ideal F
--------------------------------------------------
--boehm17
S = QQ[u,v,z]
F = 2*u^7+u^6*v+3*u^5*v^2+u^4*v^3+2*u^3*v^4+u^2*v^5+2*u*v^6+v^7-7780247/995328*u^6*z-78641/9216*u^5*v*z-10892131/995328*u^4*v^2*z-329821/31104*u^3*v^3*z-953807/331776*u^2*v^4*z-712429/248832*u*v^5*z+1537741/331776*v^6*z+2340431/248832*u^5*z^2+5154337/248832*u^4*v*z^2+658981/41472*u^3*v^2*z^2+1737757/124416*u^2*v^3*z^2-1234733/248832*u*v^4*z^2-1328329/82944*v^5*z^2-818747/248832*u^4*z^3-1822879/124416*u^3*v*z^3-415337/31104*u^2*v^2*z^3+1002655/124416*u*v^3*z^3+849025/82944*v^4*z^3
ideal F
--------------------------------------------------
--boehm18
S = QQ[u,v,z]
F = u^11+3*u^10*v+2*u^9*v^2+u^8*v^3+2*u^7*v^4+u^6*v^5+3*u^5*v^6+u^4*v^7+2*u^3*v^8+u^2*v^9+2*u*v^10+v^11-37646523511/5159780352*u^10*z-12735172937/644972544*u^9*v*z-92722810205/5159780352*u^8*v^2*z-6771611725/322486272*u^7*v^3*z-79705721155/2579890176*u^6*v^4*z-5691795857/161243136*u^5*v^5*z-52315373005/2579890176*u^4*v^6*z+2598387077/322486272*u^3*v^7*z+157674139405/5159780352*u^2*v^8*z+9450269981/644972544*u*v^9*z-1350789043/1719926784*v^10*z+12849479611/644972544*u^9*z^2+3879535279/71663616*u^8*v*z^2+11488988309/161243136*u^7*v^2*z^2+16022496731/161243136*u^6*v^3*z^2+14783031067/107495424*u^5*v^4*z^2+34074776537/322486272*u^4*v^5*z^2-2606453339/161243136*u^3*v^6*z^2-7551362827/53747712*u^2*v^7*z^2-71147279173/644972544*u*v^8*z^2-4491673835/214990848*v^9*z^2-5255202913/214990848*u^8*z^3-8675467489/107495424*u^7*v*z^3-1706519429/11943936*u^6*v^2*z^3-22409190037/107495424*u^5*v^3*z^3-11738664739/53747712*u^4*v^4*z^3-1469700833/35831808*u^3*v^5*z^3+23678835685/107495424*u^2*v^6*z^3+24664591385/107495424*u*v^7*z^3+4743235967/71663616*v^8*z^3+1955990257/161243136*u^7*z^4+10614149851/161243136*u^6*v*z^4+23866276253/161243136*u^5*v^2*z^4+10551670493/53747712*u^4*v^3*z^4+14951486563/161243136*u^3*v^4*z^4-22801627471/161243136*u^2*v^5*z^4-32691689713/161243136*u*v^6*z^4-3808427873/53747712*v^7*z^4-362334499/322486272*u^6*z^5-596548295/26873856*u^5*v*z^5-21950924039/322486272*u^4*v^2*z^5-1124117785/20155392*u^3*v^3*z^5+1234417927/35831808*u^2*v^4*z^5+5479236793/80621568*u*v^5*z^5+2660429561/107495424*v^6*z^5
ideal F
--------------------------------------------------
--boehm19
S = QQ[u,v,z]
F = 5*v^6+7*v^2*u^4+6*u^6+21*v^2*u^3+12*u^5+21*v^2*u^2+6*u^4+7*v^2*u
ideal F
--------------------------------------------------
--huneke1
-- Compute the integral closure of this ring
-- source: this is the second step of the integral closure of the Rees algebra
--  S = k[a,b,c][f1t,f2t,f3t], where the fi are the derivatives of
--  a^3 + random (homog) quartic in 3 variables.
-- In the first step, we computed Hom((a,b,c),(a,b,c)), in S, obtaining one new
-- fraction, here represented by x.
-- Original plan: compute the integral closure JJf of the ideal J(f), and see if 
-- J(f) is contained in mm*JJf, where
--   mm = (a,b,c).
--   J(f) = ideal jacobian f
--   f = a^3 + random quartic poly in a,b,c. (or other f which are not
--     quasi-homog).
-- To be quasi-homog: check that sub(JJf:f, all vars to 0) is 0.  If not, then
--     f is quasi-homogeneous.
kk = ZZ/32003
w = symbol w
S = kk[x, w_0, w_1, w_2, a..c, 
     Degrees => {{1, 5}, 3:{1, 2}, 3:{0, 1}}, 
     --Heft => {-1, 1}, 
     --DegreeRank => 2,
     MonomialOrder => {MonomialSize => 16,
	  GRevLex => {4}, 
	  GRevLex => {3:1}, 
	  GRevLex => {3:1}}
     ]
P = ideal(w_1*a^3+14207*w_1*a^2*b-10581*w_1*a*b^2-2057*w_1*b^3-1979*w_1*a^2*c+12475*w_1*a*b*c-2052*w_1*b^2*c-15832*w_1*a*c^2+14966*w_1*b*c^2+12153*w_1*c^3-14407*w_2*a^3-5956*w_2*a^2*b-4087*w_2*a*b^2+14935*w_2*b^3-14207*w_2*a^2*c-10841*w_2*a*b*c+6171*w_2*b^2*c+9764*w_2*a*c^2+2052*w_2*b*c^2+5679*w_2*c^3,
    w_0*a^2*b+8648*w_0*a*b^2+7004*w_0*b^3+6746*w_0*a^2*c+1160*w_0*a*b*c-8737*w_0*b^2*c+14144*w_0*a*c^2-11118*w_0*b*c^2+9772*w_0*c^3-1614*w_1*a^2*b+3638*w_1*a*b^2-7580*w_1*b^3-1840*w_1*a^2*c-4227*w_1*a*b*c-15236*w_1*b^2*c-534*w_1*a*c^2-3839*w_1*b*c^2-5811*w_1*c^3-11398*w_1*a^2-10362*w_2*a^2*b-13314*w_2*a*b^2-12412*w_2*b^3+1614*w_2*a^2*c-7278*w_2*a*b*c+14092*w_2*b^2*c+11369*w_2*a*c^2+14656*w_2*b*c^2-3435*w_2*c^3+3593*w_2*a^2,
    w_0*a^3-13200*w_0*a*b^2-10558*w_0*b^3+6584*w_0*a^2*c+13900*w_0*a*b*c-15130*w_0*b^2*c-12803*w_0*a*c^2+1584*w_0*b*c^2+10363*w_0*c^3+15950*w_1*a^2*b-221*w_1*a*b^2-1035*w_1*b^3-5571*w_1*a^2*c+15361*w_1*a*b*c-10440*w_1*b^2*c+1827*w_1*a*c^2+7561*w_1*b*c^2-10863*w_1*c^3-3794*w_1*a^2+2921*w_2*a^3-12084*w_2*a^2*b+8312*w_2*a*b^2-11276*w_2*b^3-15953*w_2*a^2*c+442*w_2*a*b*c-15698*w_2*b^2*c+1737*w_2*a*c^2+3490*w_2*b*c^2+12415*w_2*c^3-8125*w_2*a^2,
    x*c+8283*w_0*b^4+13415*w_0*a*b^2*c+15929*w_0*b^3*c+14791*w_0*a^2*c^2-10280*w_0*a*b*c^2+14886*w_0*b^2*c^2+1439*w_0*a*c^3-4175*w_0*b*c^3+15249*w_0*c^4-2282*w_1*a^2*b^2-9576*w_1*a*b^3-9726*w_1*b^4-3179*w_1*a^2*b*c+13861*w_1*a*b^2*c+12885*w_1*b^3*c-14005*w_1*a^2*c^2-11058*w_1*a*b*c^2-11922*w_1*b^2*c^2+2190*w_1*a*c^3+4207*w_1*b*c^3+3883*w_1*c^4-15097*w_1*a^2*b+5432*w_1*a*b^2-11827*w_1*b^3-4440*w_1*a^2*c+9826*w_1*a*b*c+13577*w_1*b^2*c-5941*w_1*a*c^2+12926*w_1*b*c^2-12427*w_1*c^3+9693*w_2*a^2*b^2-12726*w_2*a*b^3+6044*w_2*b^4+3560*w_2*a^2*b*c+6989*w_2*a*b^2*c+15573*w_2*b^3*c-8419*w_2*a^2*c^2+10604*w_2*a*b*c^2-8048*w_2*b^2*c^2-11073*w_2*a*c^3+8490*w_2*b*c^3-13597*w_2*c^4+10091*w_2*a^2*b-11584*w_2*a*b^2+2635*w_2*b^3-6917*w_2*a^2*c-15955*w_2*a*b*c+3478*w_2*b^2*c+2828*w_2*a*c^2-13577*w_2*b*c^2+6359*w_2*c^3,
    x*b+1193*w_0*b^4+904*w_0*a*b^2*c+6294*w_0*b^3*c+8260*w_0*a^2*c^2-5011*w_0*a*b*c^2+7315*w_0*b^2*c^2+653*w_0*a*c^3-3095*w_0*b*c^3-8268*w_0*c^4-6499*w_1*a^2*b^2-1159*w_1*a*b^3-6130*w_1*b^4-6268*w_1*a^2*b*c-8673*w_1*a*b^2*c-11981*w_1*b^3*c+13725*w_1*a^2*c^2+612*w_1*a*b*c^2-11647*w_1*b^2*c^2+6447*w_1*a*c^3-12658*w_1*b*c^3+5390*w_1*c^4+7253*w_1*a^2*b+14881*w_1*a*b^2+410*w_1*b^3+80*w_1*a^2*c+7158*w_1*a*b*c-6421*w_1*b^2*c+8338*w_1*a*c^2-15834*w_1*b*c^2+12529*w_1*c^3-9685*w_2*a^2*b^2-9541*w_2*a*b^3-14762*w_2*b^4-9390*w_2*a^2*b*c+2287*w_2*a*b^2*c+7441*w_2*b^3*c+7660*w_2*a^2*c^2-5806*w_2*a*b*c^2-14634*w_2*b^2*c^2+10158*w_2*a*c^3-2866*w_2*b*c^3-11023*w_2*c^4-4176*w_2*a^2*b-2418*w_2*a*b^2+13717*w_2*b^3-452*w_2*a^2*c+11648*w_2*a*b*c-1230*w_2*b^2*c+7021*w_2*a*c^2+6421*w_2*b*c^2+5278*w_2*c^3,
    x*a-w_0*c^4-15556*w_1*b^2*c^2-4222*w_1*b*c^3-15630*w_1*c^4+15334*w_2*b^2*c^2-11331*w_2*b*c^3-11658*w_2*c^4,
    x^2+8554*w_0^2*b^4*c^2-12442*w_0^2*a*b^2*c^3-6908*w_0^2*b^3*c^3-143*w_0^2*a^2*c^4-13084*w_0^2*a*b*c^4+10513*w_0^2*b^2*c^4+10056*w_0^2*a*c^5+14509*w_0^2*b*c^5-15384*w_0^2*c^6+961*w_0*w_1*b^4*c^2+13443*w_0*w_1*a*b^2*c^3-8521*w_0*w_1*b^3*c^3-8203*w_0*w_1*a^2*c^4+7854*w_0*w_1*a*b*c^4-2099*w_0*w_1*b^2*c^4-11965*w_0*w_1*a*c^5+61*w_0*w_1*b*c^5+13504*w_0*w_1*c^6+11427*w_0*w_1*a*b^2*c^2-447*w_0*w_1*b^3*c^2+14715*w_0*w_1*a^2*c^3-1034*w_0*w_1*a*b*c^3+9352*w_0*w_1*b^2*c^3-12642*w_0*w_1*a*c^4-5262*w_0*w_1*b*c^4-2083*w_0*w_1*c^5-15000*w_1^2*a^2*b^2*c^2+14840*w_1^2*a*b^3*c^2+4845*w_1^2*b^4*c^2+3243*w_1^2*a^2*b*c^3-7715*w_1^2*a*b^2*c^3+4895*w_1^2*b^3*c^3-12055*w_1^2*a^2*c^4+2903*w_1^2*a*b*c^4+12560*w_1^2*b^2*c^4-12775*w_1^2*a*c^5+386*w_1^2*b*c^5+1048*w_1^2*c^6+2343*w_1^2*a^2*b*c^2+8081*w_1^2*a*b^2*c^2+2162*w_1^2*b^3*c^2-13723*w_1^2*a^2*c^3+9743*w_1^2*a*b*c^3-581*w_1^2*b^2*c^3+6989*w_1^2*a*c^4+13019*w_1^2*b*c^4-10297*w_1^2*c^5+4561*w_1^2*a^2*c^2-12874*w_0*w_2*b^4*c^2-11596*w_0*w_2*a*b^2*c^3-15929*w_0*w_2*b^3*c^3+11249*w_0*w_2*a^2*c^4+5143*w_0*w_2*a*b*c^4+2869*w_0*w_2*b^2*c^4-2863*w_0*w_2*a*c^5-2009*w_0*w_2*b*c^5+8893*w_0*w_2*c^6+4378*w_0*w_2*a*b^2*c^2+10855*w_0*w_2*b^3*c^2-11133*w_0*w_2*a^2*c^3+9130*w_0*w_2*a*b*c^3+10927*w_0*w_2*b^2*c^3+10835*w_0*w_2*a*c^4+7091*w_0*w_2*b*c^4+8624*w_0*w_2*c^5-12084*w_1*w_2*a^2*b^2*c^2+7537*w_1*w_2*a*b^3*c^2-8526*w_1*w_2*b^4*c^2-13066*w_1*w_2*a^2*b*c^3-12465*w_1*w_2*a*b^2*c^3-914*w_1*w_2*b^3*c^3-217*w_1*w_2*a^2*c^4-11152*w_1*w_2*a*b*c^4-10769*w_1*w_2*b^2*c^4-3147*w_1*w_2*a*c^5-2251*w_1*w_2*b*c^5-8570*w_1*w_2*c^6+15209*w_1*w_2*a^2*b*c^2+2586*w_1*w_2*a*b^2*c^2+13917*w_1*w_2*b^3*c^2-15551*w_1*w_2*a^2*c^3-7424*w_1*w_2*a*b*c^3-4065*w_1*w_2*b^2*c^3-1397*w_1*w_2*a*c^4-10737*w_1*w_2*b*c^4+13845*w_1*w_2*c^5+15667*w_1*w_2*a^2*c^2+12662*w_2^2*a^2*b^2*c^2+6630*w_2^2*a*b^3*c^2+3422*w_2^2*b^4*c^2-179*w_2^2*a^2*b*c^3+7761*w_2^2*a*b^2*c^3+11797*w_2^2*b^3*c^3-4998*w_2^2*a^2*c^4-9789*w_2^2*a*b*c^4+15782*w_2^2*b^2*c^4-14414*w_2^2*a*c^5+4596*w_2^2*b*c^5-12643*w_2^2*c^6+12811*w_2^2*a^2*b*c^2+14993*w_2^2*a*b^2*c^2+11955*w_2^2*b^3*c^2-14035*w_2^2*a^2*c^3+10179*w_2^2*a*b*c^3-6282*w_2^2*b^2*c^3-8378*w_2^2*a*c^4+15021*w_2^2*b*c^4+4946*w_2^2*c^5+1345*w_2^2*a^2*c^2);
Q = eliminate(P, {x,w_0})
Q = sub(Q, w_1 => w_1 + a)
A = S/Q

---------------------------------------------------------------------
--huneke2
kk = ZZ/32003
S = kk[a,b,c]
F = a^2*b^2*c+a^4+b^4+c^4
J = ideal jacobian ideal F
substitute(J:F, kk) -- check local quasi-homogeneity!
I = ideal (flattenRing reesAlgebra J)_0

A = (ring I)/I
time integralClosure A  -- 13.6 sec
icFractions A

singI = I + minors(codim I, jacobian I);
radsingI = radical singI
---------------------------------------------------------------------
--singular-huneke
kk = ZZ/31991
R = kk[a..e]
ideal"
  5abcde-a5-b5-c5-d5-e5,
  ab3c+bc3d+a3be+cd3e+ade3,
  a2bc2+b2cd2+a2d2e+ab2e2+c2de2,
  abc5-b4c2d-2a2b2cde+ac3d2e-a4de2+bcd2e3+abe5,
  ab2c4-b5cd-a2b3de+2abc2d2e+ad4e2-a2bce3-cde5,
  a3b2cd-bc2d4+ab2c3e-b5de-d6e+3abcd2e2-a2be4-de6,
  a4b2c-abc2d3-ab5e-b3c2de-ad5e+2a2bcde2+cd2e4,
  b6c+bc6+a2b4e-3ab2c2de+c4d2e-a3cde2-abd3e2+bce5"
---------------------------------------------------------------------
--singular-vasconcelos
kk = ZZ/32003
w = symbol w
t = symbol t
R = kk[x,y,z,w,t]
ideal"
  x2+zw,
  y3+xwt,
  xw3+z3t+ywt2,
  y2w4-xy2z2t-w3t3"
---------------------------------------------------------------------
--singular-theo1
kk = ZZ/32003
R = kk[x,y,z, Degrees=>{2,3,6}]
ideal"zy2-zx3-x6"
---------------------------------------------------------------------
--singular-theo1a
kk = ZZ/32003  -- CM and regular in codim 2
R = kk[x,y,z,u, Degrees=>{2,3,6,6}]
ideal"zy2-zx3-x6+u2"
---------------------------------------------------------------------
--singular-theo2
kk = ZZ/32003
R = kk[x,y,z,Degrees=>{3,4,12}]
ideal"z(y3-x4)+x8"
---------------------------------------------------------------------
--singular-theo2a
T = symbol T
R = ZZ/32003[T_1..T_4, Degrees=>{3,4,12,17}]
ideal(
     T_1^8-T_1^4*T_3+T_2^3*T_3,
     T_1^4*T_2^2-T_2^2*T_3+T_1*T_4,
     T_1^7+T_1^3*T_2^3-T_1^3*T_3+T_2*T_4,
     T_1^6*T_2*T_3+T_1^2*T_2^4*T_3+T_1^3*T_2^2*T_4-T_1^2*T_2*T_3^2+T_4^2)
---------------------------------------------------------------------
--singular-theo3
R = ZZ/32003[x,y,z, Degrees => {3,5,15}]
ideal"z(y3-x5)+x10"
---------------------------------------------------------------------
--singular-theo5
R = ZZ/32003[x,y,z, Degrees=>{2,1,2}]
ideal"z3-xy4"
---------------------------------------------------------------------
--singular-theo6
R = ZZ/32003[x,y,z]
ideal"x2y2+x2z2+y2z2"
---------------------------------------------------------------------
--singular-sakai1
R = QQ[x,y] -- genus 0 4 nodes and 6 cusps
ideal"(x2+y2-1)3 +27x2y2"
---------------------------------------------------------------------
--singular-sakai2
R = QQ[x,y] -- genus 0
ideal"(x-y2)2 - yx3"
---------------------------------------------------------------------
--singular-sakai3
R = QQ[x,y] -- genus 4
ideal"y3-x6+1"
---------------------------------------------------------------------
--singular-sakai4
(m,p,q) := (9,2,9); -- q =2..9 -- modifying these gives other good examples
R = QQ[x,y]
ideal(y^m - x^p*(x - 1)^q)
---------------------------------------------------------------------
--singular-sakai5
R = QQ[x,y]
ideal"55x8+66y2x9+837x2y6-75y4x2-70y6-97y7x2"
---------------------------------------------------------------------
--singular-sakai6
R = QQ[x,y] -- genus 34
ideal"y10+(-2494x2+474)y8+(84366+2042158x4-660492)y6
        +(128361096x4-47970216x2+6697080-761328152x6)y4
        +(-12024807786x4-506101284x2+15052058268x6+202172841-3212x8)y2
        +34263110700x4-228715574724x6+5431439286x2+201803238
        -9127158539954x10-3212722859346x8"
---------------------------------------------------------------------
--singular-koelman
R = QQ[x,y,z]; -- genus 10  with 26 cusps
ideal"761328152x6z4-5431439286x2y8+2494x2z8+228715574724x6y4+
 9127158539954x10-15052058268x6y2z2+3212722859346x8y2-
 134266087241x8z2-202172841y8z2-34263110700x4y6-6697080y6z4-
 2042158x4z6-201803238y10+12024807786x4y4z2-128361096x4y2z4+
 506101284x2z2y6+47970216x2z4y4+660492x2z6y2-
 z10-474z8y2-84366z6y4"
---------------------------------------------------------------------
--singular-koelman2
R = QQ[x,y]; -- genus 10  with 26 cusps
ideal"9127158539954x10+3212722859346x8y2+228715574724x6y4-34263110700x4y6
-5431439286x2y8-201803238y10-134266087241x8-15052058268x6y2+12024807786x4y4
+506101284x2y6-202172841y8+761328152x6-128361096x4y2+47970216x2y4-6697080y6
-2042158x4+660492x2y2-84366y4+2494x2-474y2-1"
---------------------------------------------------------------------
--singular-unnamed1
R = QQ[x,y]; -- genus 1 with 5 cusps
ideal"57y5+516x4y-320x4+66y4-340x2y3+73y3+128x2-84x2y2-96x2y"
---------------------------------------------------------------------
--singular-unnamed2
R = QQ[y,z,w,u] -- genus 9
ideal"y2+z2+w2+u2,z4+w4+u4"
---------------------------------------------------------------------
--singular-unnamed3
R = QQ[x,y,t]
ideal "25x8+200x7y+720x6y2+1520x5y3+2064x4y4+1856x3y5+1088x2y6+384xy7+64y8-12x6t2-72x5yt2-184x4y2t2-256x3y3t2-192x2y4t2-64xy5t2-2x4t4-8x3yt4+16xy3t4+16y4t4+4x2t6+8xyt6+8y2t6+t8"
---------------------------------------------------------------------
--singular-unnamed4
R = QQ[x,y,t]
ideal"32761x8+786264x7y+8314416x6y2+50590224x5y3+193727376x4y4+478146240x3y5+742996800x2y6+664848000xy7+262440000y8+524176x7t+11007696x6yt+99772992x5y2t+505902240x4y3t+1549819008x3y4t+2868877440x2y5t+2971987200xy6t+1329696000y7t+3674308x6t2+66137544x5yt2+499561128x4y2t2+2026480896x3y3t2+4656222144x2y4t2+5746386240xy5t2+2976652800y6t2+14737840x5t3+221067600x4yt3+1335875904x3y2t3+4064449536x2y3t3+6226336512xy4t3+3842432640y5t3+36997422x4t4+443969064x3yt4+2012198112x2y2t4+4081745520xy3t4+3126751632y4t4+59524208x3t5+535717872x2yt5+1618766208xy2t5+1641991392y3t5+59938996x2t6+359633976xyt6+543382632y2t6+34539344xt7+103618032yt7+8720497t8"
---------------------------------------------------------------------
--singular-unnamed5
R = ZZ/32003[x,y,z,w,u]
ideal"x2+y2+z2+w2+u2,x3+y3+z3,z4+w4+u4"
---------------------------------------------------------------------
--magma-curve
R = QQ[x,y]
ideal((x-y)*x*(y+x^2)^3-y^3*(x^3+x*y-y^2))
---------------------------------------------------------------------
--2charPairs
kk = ZZ/32003
S = kk[x,y]
ideal"y4-2x3y2-4x5y+x6-x7"
---------------------------------------------------------------------
--2charPairsJacIdeal
kk = ZZ/32003
S = kk[x,y]
F = ideal"y4-2x3y2-4x5y+x6-x7"
J = ideal jacobian F
substitute(J:F, kk) -- check local quasi-homogeneity!
ideal (flattenRing reesAlgebra J)_0
---------------------------------------------------------------------
--ReesAlgOf 3 cubes
kk = ZZ/32003
S=kk[a,b,c]
I=ideal"a3,b3,c3"
R=reesAlgebra I
ideal (flattenRing R)_0
---------------------------------------------------------------------
--ReesAlgOf 3 powers
kk = ZZ/32003
S=kk[a,b,c]
I=ideal"a2,b3,c4"
time R=reesAlgebra I
ideal (flattenRing R)_0
---------------------------------------------------------------------
--rees1-32003
kk = ZZ/32003 -- time for int closure of ideal on 3/5/09 (DE big machine): 16000 sec
S = kk[a,b,c]
I=ideal"a4+b4+c4+a2b2c+a2bc2"  
time R=reesAlgebra ideal jacobian I
ideal (flattenRing R)_0
---------------------------------------------------------------------
--rees2-32003
kk = ZZ/32003 -- -- time for int closure of ideal on 3/5/09 (DE big machine): 4500 sec
S = kk[a,b,c]
I=ideal(a^2*b^2*c+a^4+b^4+c^4)
time R=reesAlgebra ideal jacobian I
ideal (flattenRing R)_0
---------------------------------------------------------------------
--rees3-32003
kk = ZZ/32003 -- -- time for int closure of ideal on 3/5/09 (DE big machine): 750 sec
S = kk[a,b,c]
I=ideal(a^4+b^4+c^4+a^3+a^2*b+a^2*c)
time R=reesAlgebra ideal jacobian I
ideal (flattenRing R)_0
---------------------------------------------------------------------
--GLS1-char0
kk = QQ -- from Greuel-Laplagne-Seelisch arXiv:0904.3561v1
S = kk[x,y]
I = ideal"(x-y)x(y+x2)3-y3(x3+xy-y2)"
---------------------------------------------------------------------
--GLS1-char2
kk = ZZ/2  -- from Greuel-Laplagne-Seelisch arXiv:0904.3561v1
S = kk[x,y]
I = ideal"(x-y)x(y+x2)3-y3(x3+xy-y2)"
---------------------------------------------------------------------
--GLS1-char5
kk = ZZ/5  -- from Greuel-Laplagne-Seelisch arXiv:0904.3561v1
S = kk[x,y]
I = ideal"(x-y)x(y+x2)3-y3(x3+xy-y2)"
---------------------------------------------------------------------
--GLS1-char11
kk = ZZ/11  -- from Greuel-Laplagne-Seelisch arXiv:0904.3561v1
S = kk[x,y]
I = ideal"(x-y)x(y+x2)3-y3(x3+xy-y2)"
---------------------------------------------------------------------
--GLS1-char32003
kk = ZZ/32003 -- from Greuel-Laplagne-Seelisch arXiv:0904.3561v1
S = kk[x,y]
I = ideal"(x-y)x(y+x2)3-y3(x3+xy-y2)"
-------------------------------------------------------------------
--GLS2-char0
kk = QQ -- from Greuel-Laplagne-Seelisch arXiv:0904.3561v1
S = kk[x,y]
I = ideal"55x8+66y2x9+837x2y6-75y4x2-70y6-97y7x2"
---------------------------------------------------------------------
--GLS2-char3
kk = ZZ/2  -- from Greuel-Laplagne-Seelisch arXiv:0904.3561v1
S = kk[x,y]
I = ideal"55x8+66y2x9+837x2y6-75y4x2-70y6-97y7x2"
---------------------------------------------------------------------
--GLS2-char13
kk = ZZ/11  -- from Greuel-Laplagne-Seelisch arXiv:0904.3561v1
S = kk[x,y]
I = ideal"55x8+66y2x9+837x2y6-75y4x2-70y6-97y7x2"
---------------------------------------------------------------------
--GLS2-char32003
kk = ZZ/32003 -- from Greuel-Laplagne-Seelisch arXiv:0904.3561v1
S = kk[x,y]
I = ideal"55x8+66y2x9+837x2y6-75y4x2-70y6-97y7x2"
-------------------------------------------------------------------
--GLS3-char0
kk = QQ -- from Greuel-Laplagne-Seelisch arXiv:0904.3561v1
S = kk[x,y]
I = ideal"y9+y8x+y8+y5+y4x+y3x2+y2x3+yx8+x9"
---------------------------------------------------------------------
--GLS3-char2
kk = ZZ/2  -- from Greuel-Laplagne-Seelisch arXiv:0904.3561v1
S = kk[x,y]
I = ideal"y9+y8x+y8+y5+y4x+y3x2+y2x3+yx8+x9"
---------------------------------------------------------------------
--GLS3-char5
kk = ZZ/5  -- from Greuel-Laplagne-Seelisch arXiv:0904.3561v1
S = kk[x,y]
I = ideal"y9+y8x+y8+y5+y4x+y3x2+y2x3+yx8+x9"
---------------------------------------------------------------------
--GLS3-char11
kk = ZZ/11  -- from Greuel-Laplagne-Seelisch arXiv:0904.3561v1
S = kk[x,y]
I = ideal"y9+y8x+y8+y5+y4x+y3x2+y2x3+yx8+x9"
---------------------------------------------------------------------
--GLS3-char32003
kk = ZZ/32003 -- from Greuel-Laplagne-Seelisch arXiv:0904.3561v1
S = kk[x,y]
I = ideal"y9+y8x+y8+y5+y4x+y3x2+y2x3+yx8+x9"
-------------------------------------------------------------------
--GLS4-char0
kk = QQ -- from Greuel-Laplagne-Seelisch arXiv:0904.3561v1
S = kk[x,y]
I = ideal"(x2+y2-1)3+27x2y2"
---------------------------------------------------------------------
--GLS4-char5
kk = ZZ/5  -- from Greuel-Laplagne-Seelisch arXiv:0904.3561v1
S = kk[x,y]
I = ideal"(x2+y2-1)3+27x2y2"
---------------------------------------------------------------------
--GLS4-char11
kk = ZZ/11  -- from Greuel-Laplagne-Seelisch arXiv:0904.3561v1
S = kk[x,y]
I = ideal"(x2+y2-1)3+27x2y2"
---------------------------------------------------------------------
--GLS4-char32003
kk = ZZ/32003 -- from Greuel-Laplagne-Seelisch arXiv:0904.3561v1
S = kk[x,y]
I = ideal"(x2+y2-1)3+27x2y2"
-------------------------------------------------------------------
--GLS5-char0
kk = QQ -- from Greuel-Laplagne-Seelisch arXiv:0904.3561v1
S = kk[x,y]
I = ideal"-x10+x8y2-x6y4-x2y8+2y10-x8+2x6y2+x4y4
           -x2y6-y8+2x6-x4y2+x2y4+2x4+2x2y2-y4-x2+y2-1"
---------------------------------------------------------------------
--GLS5-char5
kk = ZZ/5  -- from Greuel-Laplagne-Seelisch arXiv:0904.3561v1
S = kk[x,y]
I = ideal"-x10+x8y2-x6y4-x2y8+2y10-x8+2x6y2+x4y4
           -x2y6-y8+2x6-x4y2+x2y4+2x4+2x2y2-y4-x2+y2-1"
---------------------------------------------------------------------
--GLS5-char11
kk = ZZ/11  -- from Greuel-Laplagne-Seelisch arXiv:0904.3561v1
S = kk[x,y]
I = ideal"-x10+x8y2-x6y4-x2y8+2y10-x8+2x6y2+x4y4
           -x2y6-y8+2x6-x4y2+x2y4+2x4+2x2y2-y4-x2+y2-1"
---------------------------------------------------------------------
--GLS5-char32003
kk = ZZ/32003 -- from Greuel-Laplagne-Seelisch arXiv:0904.3561v1
S = kk[x,y]
I = ideal"-x10+x8y2-x6y4-x2y8+2y10-x8+2x6y2+x4y4
           -x2y6-y8+2x6-x4y2+x2y4+2x4+2x2y2-y4-x2+y2-1"
-------------------------------------------------------------------
--GLS6-char0
kk = QQ -- from Greuel-Laplagne-Seelisch arXiv:0904.3561v1
S = kk[x,y,z,u,v]
I = ideal"z3+zyx+y3x2+y2x3,
  uyx+z2,
  uz+z+y2x+yx2,
  u2+u+zy+zx,
  v3+vux+vz2+vzyx+vzx+uz3+uz2y+z3+z2yx2"
---------------------------------------------------------------------
--GLS6-char2
kk = ZZ/2  -- from Greuel-Laplagne-Seelisch arXiv:0904.3561v1
S = kk[x,y,z,u,v]
I = ideal"z3+zyx+y3x2+y2x3,
  uyx+z2,
  uz+z+y2x+yx2,
  u2+u+zy+zx,
  v3+vux+vz2+vzyx+vzx+uz3+uz2y+z3+z2yx2"
-------------------------------------------------------------------
--GLS7-char0
kk = QQ -- from Greuel-Laplagne-Seelisch arXiv:0904.3561v1
S = kk[x,y,z,w,t]
I = ideal"x2+zw,
  y3+xwt,
  xw3+z3t+ywt2,
  y2w4-xy2z2t-w3t3"
---------------------------------------------------------------------
--GLS7-char2
kk = ZZ/2  -- from Greuel-Laplagne-Seelisch arXiv:0904.3561v1
S = kk[x,y,z,w,t]
I = ideal"x2+zw,
  y3+xwt,
  xw3+z3t+ywt2,
  y2w4-xy2z2t-w3t3"
---------------------------------------------------------------------
--GLS7-char5
kk = ZZ/5  -- from Greuel-Laplagne-Seelisch arXiv:0904.3561v1
S = kk[x,y,z,w,t]
I = ideal"x2+zw,
  y3+xwt,
  xw3+z3t+ywt2,
  y2w4-xy2z2t-w3t3"
---------------------------------------------------------------------
--GLS7-char11
kk = ZZ/11  -- from Greuel-Laplagne-Seelisch arXiv:0904.3561v1
S = kk[x,y,z,w,t]
I = ideal"x2+zw,
  y3+xwt,
  xw3+z3t+ywt2,
  y2w4-xy2z2t-w3t3"
---------------------------------------------------------------------
--GLS7-char32003
kk = ZZ/32003 -- from Greuel-Laplagne-Seelisch arXiv:0904.3561v1
S = kk[x,y,z,w,t]
I = ideal"x2+zw,
  y3+xwt,
  xw3+z3t+ywt2,
  y2w4-xy2z2t-w3t3"
--------------------------------------------------------------------
--triple-points
kk = ZZ/32003 -- one used for debugging early on in M2
R = kk[x,y]
I1 = ideal"x,y"
I2 = ideal"x,y-1"
I3 = ideal"x-1,y"
I4 = ideal"x-2,y-3"
I5 = ideal"x-7,y-13"
J = trim intersect(I1^3,I2^3,I3^3,I4^3,I5^3)
I = ideal sum flatten entries gens J
