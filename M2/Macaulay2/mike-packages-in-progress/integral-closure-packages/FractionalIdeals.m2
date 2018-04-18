newPackage(
        "FractionalIdeals",
        Version => "0.1", 
        Date => "6 June 2009",
        Authors => {
	     {Name => "Charley Crissman", 
		  Email => "charleyc@math.berkeley.edu", 
		  HomePage => "http://math.berkeley.edu/~charleyc/"},
	     {Name => "Mike Stillman", 
              	  Email => "mike@math.cornell.edu", 
                  HomePage => "http://www.math.cornell.edu/~mike"}},
        Headline => "fractional ideals given a domain in Noether normal position",
	PackageExports => {"TraceForm"},
        DebuggingMode => true
        )

-- Requires at least M2 version 1.4.0.1

export {
     "FractionalRing",
     "FractionalIdeal", 
     "fractionalIdeal",
     "fractionalRing",
     "fractions",
     "getIntegralEquation",
     "possibleDenominators",
     "newDenominator",
     "disc", -- this name will change!
     "simplify",
     -- the following two should be where??
     "integralClosureHypersurface",
     "integralClosureDenominator",
     "ringFromFractionalIdeal",
     "fractionalRingPresentation"
     }

exportMutable {
     "GLOBALEND"
     }

GLOBALEND = {}
TraceLevel = 2

FractionalIdeal = new Type of HashTable
FractionalRing = new Type of FractionalIdeal

  -- fields of a FractionIdeal:
  -- numerator: an ideal in a ring R
  -- denominator: an element of either R, or the coefficient ring of R (Noether normal case)
  -- 

inNoetherPosition = (R) -> R#?"NoetherField"

ring FractionalIdeal := (F) -> ring F.numerator
denominator FractionalIdeal := (F) -> F.denominator
numerator FractionalIdeal := (F) -> F.numerator

---------------------------------------------------
-- Creation of new fractional ideals and rings ----
---------------------------------------------------

makeFractionalIdeal = method()
makeFractionalIdeal(RingElement, Ideal) := (f,J) -> (
     -- Internal function: no checking is done!
     new FractionalIdeal from {symbol numerator => J, symbol denominator => f}
     )
makeFractionalRing = method()
makeFractionalRing(RingElement, Ideal) := (f,J) -> (
     -- Internal function: no checking is done!
     new FractionalRing from {symbol numerator => J, symbol denominator => f}
     )

fractionalIdeal = method()
fractionalIdeal(RingElement, Ideal) := (f, J) -> (
     if ring f =!= ring J and ring f =!= coefficientRing ring J then error "expected denominator in the same ring or coeff ring as ideal";
     F := makeFractionalIdeal(f,J);
     simplify F
     )
fractionalIdeal Ideal := (I) -> (
     R := ring I;
     new FractionalIdeal from {symbol denominator => 1_R, symbol numerator => I}
     )

fractionalIdeal List := (L) -> (
     -- L is a list of elements, either 'Divide's or RingElement's in a fraction field.
     if #L == 0 then error "expected non-empty list";
     R := ring numerator L#0;
     if inNoetherPosition R then (
         -- TODO
         )
     else (
	  -- find a common denominator
	  L1 := possibleDenominators L;
	  denom := L1_0;
	  fractionalIdeal(denom,trim ideal(L/(f -> lift(denom*f,R))))
	  )
     )
fractionalRing = method()
fractionalRing(RingElement, Ideal) := (f, J) -> (
     F := new FractionalRing from {symbol numerator => J, symbol denominator => f};
     F
     )
fractionalRing(Ring) := (R) -> new FractionalRing from fractionalIdeal ideal(1_R)

--- Simplifying fractional ideals ---------------------
-- If the ring is is Noether normal position, then the denominator will be chosen to be
--   in the subring.  If it is not in the subring, computation will be required.
noetherize = method()
noetherize FractionalIdeal := F -> (
     -- as simplifyFraction, but for a fractional ideal;
     -- name is not simplifyFractionalIdeal since simplify(FractionalIdeal) already exists
     g := denominator F;
     J := numerator F;
     Rdenoms := (ideal g) : J;
     denoms := first entries selectInSubring(1, gens gb Rdenoms);
     if #denoms > 1 then print "more than one potential denom!";
     denom := denoms_0;
     numers := (denom * generators J) // g; -- what if the rings of g and J don't match?
     fractionalIdeal(denom, ideal numers)
     )

simplify = method()
simplify FractionalIdeal := (F) -> (
     if not inNoetherPosition ring F 
     then simplifyNonNoether F
     else (
     	  -- return the FractionalIdeal equal to F, but
     	  -- whose representation is minimal: there is no nontrivial common factor 
     	  -- between the denominator and all of "y"-coefficients of the numerator.
     	  -- Assumption: the ring R of F is in Noether position and the denominator
     	  -- of F is liftable to the coefficient ring of R
     	  R := ring F;
     	  K := coefficientRing R;
     	  B := getBasis R;
     	  denom := denominator F;
     	  if liftable(denom,K) then denom = lift(denom,K) else (
	       F = noetherize F;
	       denom = denominator F
	       );
     	  cfs := last coefficients(gens numerator F, Monomials=>B);
     	  cfs = lift(cfs, K);
     	  denom = lift(denom, K);
     	  G := gcd prepend(denom, flatten entries cfs);
     	  makeFractionalIdeal(promote(denom//G, R), trim ideal(matrix{B} * (cfs//G)))
     	  ))

simplify FractionalRing := (F) -> new FractionalRing from F

simplifyNonNoether = method()
simplifyNonNoether FractionalIdeal := (F) -> (
     S := ambient ring F; -- should be a polynomial ring.
     f1 := lift(generators numerator F, S);
     f0 := lift(denominator F, S);
     g := gcd prepend(f0, first entries f1);
     if g == 1 
     then F 
     else makeFractionalIdeal(promote(f0 // g, ring F), trim promote(ideal (f1 // g), ring F))
     )

----------------------------------------------------------
-- Display of fractional ideals --------------------------
----------------------------------------------------------

-- This returns expressions, with factored denominators

fractions = method()
fractions FractionalIdeal := I -> (
     R := ring I;
     if inNoetherPosition R 
     then (
       L := noetherField R;
       nums := apply(flatten entries gens numerator I, i-> sub(i,L));
       denom := sub(denominator I, coefficientRing L);
       --apply(nums, p -> 1/denom * p)
       for p in nums list (
	     g := 1/denom * p;
	     gdenom := (terms g)/leadCoefficient/denominator//lcm;
	     resultDenom := if gdenom == 1 then 1_R else factor gdenom;
	     (hold sub(gdenom * g, noetherRing ring g)) / resultDenom
	    )
       )
     else (
	  S := ambient ring I;
	  denom = denominator I;
     	  denomS := lift(denom, S);
          for f in flatten entries gens numerator I list (
	       fS := lift(f,S);
	       g := gcd(denomS, fS);
	       if g == 1 then (hold f)/denom
	       else (
		    fS = fS//g;
		    den := denomS//g;
		    f = promote(fS,R);
		    den = promote(den,R);
		    (hold f)/den
		    )
	  )
     ))

----------------------------------------------------------

-- major assumption/restriction: the ring of a FractionalIdeal F
-- should be of the form R = S/I, where S is a polynomial ring with a product order
-- and such that if A is the polynomial ring generated by the variables not occuring in
-- the first block, then A --> S/I should be a Noether normalization.

-- A fractional ideal of R is repesented by a  list {f,I}
-- representing 1/f I contained in K(R), and f is in the subpolynomial ring A
-- (see above).
--
-- If this is a ring (or known to be one), then I_0 will be f

makeVariable = opts -> (
     s := opts.Variable;
     if instance(s,Symbol) then s else
     if instance(s,String) then getSymbol s else
     error "expected Variable option to provide a string or a symbol"
     )

findSmallGen = (J) -> (
     a := toList((numgens ring J):1);
     L := sort apply(J_*, f -> ((weightRange(a,f))_1, size f, f));
     --<< "first choices are " << netList take(L,3) << endl;
     L#0#2
     )

chooseNZD = method()
chooseNZD FractionalIdeal := (F) -> (
     -- find an element of the subpolynomial ring which is in the
     -- ideal L of F = 1/f L.  Although this element is in A, its
     -- ring is R = ring F.
     -- we compute the intersection with the subring, and then take a
     -- reasonable element there (reasonable: small degree, or small size, ...)
     L := ideal selectInSubring(1, gens gb numerator F);
     if L == 0 then error "no non-zero element in the subpolynomial ring found";
     findSmallGen L
     )

ends := (F) -> (
     -- returns the FractionalIdeal Hom_R(F,F)
     I := numerator F;
     f := chooseNZD F;
     GLOBALEND = append(GLOBALEND, {I,f});
     timing(H1 := (f*I):I);
     H := compress ((gens H1) % f);
     fractionalRing(f,ideal(matrix{{f}} | H))
     )

-- FIX THIS ONE:
Hom(FractionalIdeal, FractionalIdeal) := (F,G) -> (
     if F === G 
       then ends F
       else error "not implemented yet"
     )

endomorphisms = method()
endomorphisms(FractionalIdeal, RingElement) := (F,Q) -> (
     -- ASSUMPTION: Q is a non-zerodivisor in the fractional ideal 'F'
     f := Q * (denominator F); -- this is our NZD
     J := numerator F;
     timing(H1 := (f*J):J);
     H := compress ((gens H1) % f);
     fractionalRing(f,ideal(matrix{{f}} | H))
     )


debug Core

----------------------------------------------------------
-- TO BE REMOVED -----------------------------------------
-- below this line to next note: -------------------------
ringFromFractionalIdeal = method(Options=>{
	  Variable => "w", 
	  Index => 0,
	  Verbosity => 0})
ringFromFractionalIdeal (Matrix, RingElement) := o -> (H, f) ->  (
     -- f is a nonzero divisor in R
     -- H is a (row) matrix of numerators, elements of R
     -- Forms the ring R1 = R[H_0/f, H_1/f, ..].
     -- returns a sequence (F,G), where 
     --   F : R --> R1 is the natural inclusion
     --   G : frac R1 --> frac R, 
     -- optional arguments:
     --   o.Variable: base name for new variables added, defaults to w
     --   o.Index: the first subscript to use for such variables, defaults to 0
     --   so in the default case, the new variables produced are w_{0,0}, w_{0,1}...
          R := ring H;
          Hf := H | matrix{{f}};
     	  -- Make the new polynomial ring.
     	  n := numgens source H;
     	  newdegs := degrees source H - toList(n:degree f);
     	  degs := join(newdegs, (monoid R).Options.Degrees);
     	  MO := prepend(GRevLex => n, (monoid R).Options.MonomialOrder);
          kk := coefficientRing R;
	  var := makeVariable o;
     	  A := kk(monoid [var_(o.Index,0)..var_(o.Index,n-1), R.generatorSymbols,
		    MonomialOrder=>MO, Degrees => degs]);
     	  I := ideal presentation R;
     	  IA := ideal ((map(A,ring I,(vars A)_{n..numgens R + n-1})) (generators I));
     	  B := A/IA; -- this is sometimes a slow op

     	  -- Make the linear and quadratic relations
     	  varsB := (vars B)_{0..n-1};
     	  RtoB := map(B, R, (vars B)_{n..numgens R + n - 1});
     	  XX := varsB | matrix{{1_B}};
     	  -- Linear relations in the new variables
     	  lins := XX * RtoB syz Hf; 
     	  -- linear equations(in new variables) in the ideal
     	  -- Quadratic relations in the new variables
     	  tails := (symmetricPower(2,H) // f) // Hf;
     	  tails = RtoB tails;
     	  quads := matrix(B, entries (symmetricPower(2,varsB) - XX * tails));
	  both := ideal lins + ideal quads;
	  gb both; -- sometimes slow
	  Bflat := flattenRing (B/both); --sometimes very slow
	  R1 := trim Bflat_0; -- sometimes slow
	  R1
     )

ringFromFractionalIdeal FractionalIdeal := opts -> (F) -> (
     -- assuming that F is a subring of K(R), this computes the quotient ring presenting F
     -- if it is not a ring, then what kind of error will it return?
     -- ASSUMPTION (possibly a bad one): (denominator F) is the first element of (numerator F)
     f := (denominator F);
     I := (numerator F);
     H := submatrix(gens I, 1..numgens I - 1);
     ringFromFractionalIdeal(H,f,opts)
     )

-- TO BE REMOVED: above this line
------------------------------------------------------------
fractionalRingPresentation = method(Options=>{
	  Variable => "w", 
	  Index => 0,
	  Verbosity => 0})
fractionalRingPresentation FractionalIdeal := o ->  (F) -> (
     -- Create a polynomial ring which is isomorphic to F
     -- Choices:
     --   1. is it over R, or over kk, or over a Noether normalization?
     --   2. do we remove variables taht are not necessary?
     -- ASSUMPTIONS:
     --   F = 1/f J, and J_0 == f.
     R := ring F;
     J := numerator F;
     f := denominator F;
     Hf := gens J;
     H := submatrix(Hf, {1..numColumns Hf-1});
     -- Make the new polynomial ring.
     n := numgens source H;
     newdegs := degrees source H - toList(n:degree f);
     degs := join(newdegs, (monoid R).Options.Degrees);
     MO := prepend(GRevLex => n, (monoid R).Options.MonomialOrder);
     kk := coefficientRing R;
     var := makeVariable o;
     A := kk(monoid [var_(o.Index)..var_(o.Index+n-1), R.generatorSymbols,
	       MonomialOrder=>MO, Degrees => degs]);
     I := ideal presentation R;
     IA := ideal ((map(A,ring I,(vars A)_{n..numgens R + n-1})) (generators I));
     B := A/IA; -- this is sometimes a slow op MES: can be a forceGB?
     
     -- Make the linear and quadratic relations
     varsB := (vars B)_{0..n-1};
     RtoB := map(B, R, (vars B)_{n..numgens R + n - 1});
     XX := matrix{{1_B}} | varsB;
     -- Linear relations in the new variables
     lins := XX * RtoB syz Hf; 
     -- linear equations(in new variables) in the ideal
     -- Quadratic relations in the new variables
     tails := (symmetricPower(2,H) // f) // Hf;
     tails = RtoB tails;
     quads := matrix(B, entries (symmetricPower(2,varsB) - XX * tails));
     both := ideal lins + ideal quads;
     both
     )

-- FIX THIS ONE: (what is the problem here?)
isIdeal(FractionalIdeal,FractionalRing) := (F,R1) -> (
     -- is F an ideal in R1?
     -- R1 = 1/f L, F = 1/g J
     -- F will be an ideal if 
     --  (1) it is contained in R1
     --  (2) R1*F is contained in F  1/fg * LJ \subset 1/g J
     --       i.e.: L*J \subset (f)J
     -- MES: not yet correct
     << "isIdeal: not correct" << endl;
     (gens ((numerator R1) * (numerator F))) % ((denominator R1) * (numerator F)) == 0
     )

isSubset(FractionalIdeal,FractionalIdeal) := (F,G) -> (
     (gens ((denominator F) * (numerator G))) % ((denominator G) * (numerator F)) == 0
     )

FractionalIdeal * FractionalIdeal := (F,G) -> (
     fractionalIdeal((denominator F) * (denominator G), trim((numerator F)*(numerator G)))
     )

FractionalIdeal == FractionalIdeal := (F,G) -> (denominator F) * (numerator G) == (denominator G) * (numerator F)

--------------------------------------------------
-- Radicals --------------------------------------
-- In the Noether normal position case, if the
--   characteristic is large enough, we can use the trace radical.
-- Otherwise, we need to do something else.
--   e.g. compute the radical in an extension ring.
--   pass pack to the fractional ring.
--------------------------------------------------

traceRadical = method()
traceRadical(RingElement, FractionalIdeal) := (Q, J) -> (
     --first check that Q is in the coefficient ring of the ring of J
     R := ring J;
     K := coefficientRing R;
     if not ring Q === K then error "expected first argument to be an element of the coefficientRing of the second.";
     traceR := traceForm R;
     B := getBasis R;
     if char K > 0 and char K <= #B then 
       << "warning: characteristic is too small, this algorithm may not produce the entire integral closure" << endl;
     G := matrix{B} ** gens numerator J;
     print "--------------------";
     print "--  computing M   --";
     time M := last coefficients(G, Monomials => B);
     << "fast version has size M = " << numColumns M << endl;     
     M = gens trim image lift(M,K);
     print "--  matrix mult   --";
     time newTrace := transpose(M) * traceR * M;
     denom := denominator J;
     try denom = lift(denom, K) else error "expected denominator of ideal to be liftable to the coefficient ring"; 
     Qdiag := Q * (denom^2) * id_(target newTrace);
     print "--   modulo       --";
     time radGens := modulo(newTrace,Qdiag);
     print "-- make frac ideal--";
     time rad := fractionalIdeal(denom, trim ideal(((matrix {B})*M)*radGens));
     rad
     )

debug PrimaryDecomposition

radical(FractionalIdeal, FractionalIdeal) := opts -> (F,R1) -> (
     -- Assumption: R1 is a ring
     -- F is an ideal of R1
     -- compute a presentation A of R1
     -- MES MES TODO TODO !!!! Not functional if R1' == R (8-16-09)
     time if (denominator R1) == 1 and (numerator R1) == 1 
       then (
	    J0 := first flattenRing (numerator F);  -- assumes (denominator F) is 1 ??
	    radJ0 := rad J0;
	    return (radJ0, fractionalIdeal trim promote(radJ0,ring F))
	    );
     time R1' := ringFromFractionalIdeal(R1, Variable=>getSymbol "w"); -- the generators correspond to elements of (numerator R1) (except the first, which 
          -- corresponds to the unit).
     -- map F into A.  We need to know how to represent elements of F as elements in R1
     -- we assume: F = 1/g J \subset R1 = 1/f L
     --   i.e. J \subset g/f L
     S' := ring ideal R1';
     R := ring (denominator R1);
     M := gens ((denominator R1) * (numerator F)) // (gens ((denominator F) * (numerator R1)));
     newvars := (vars S')_{0..numgens R1'-numgens R-1};
     v := matrix{{1_R1'}} | promote(newvars,R1');
     vS' := matrix{{1_S'}} | newvars;
     J := ideal(v * sub(M, R1'));
     -- New computation of radical:
     J0 = first flattenRing J;
     << " computing radical of " << endl;
     << toString J0 << endl;
     << toExternalString ring J0 << endl;
     time Jrad := rad J0;
     --time Jrad := intersect decompose J0;
{*
     -- do the radical
     J0 := first flattenRing J;
     << "R0 = " << toExternalString ring J0 << endl;
     << "J0 = " << toString J0 << endl;
     time Jcomps := decompose J;
     << " rad components codims " << (Jcomps/codim) << endl;
     << " rad components " << netList Jcomps << endl;
     time Jrad := trim radical J; -- note: these are all linear in the new vars
     Jrad = lift(gens Jrad, S');
*}
     wt := splice{numgens source newvars : 1, numgens S' - numgens source newvars : 0};
     Jrad1 := matrix{select(flatten entries gens gb Jrad, f -> ((lo,hi) := weightRange(wt,leadTerm f); hi <= 1))};
     (mn,cf) := coefficients(Jrad1, Monomials => vS', Variables=>flatten entries newvars);
     Jid := (gens (numerator R1)) * sub(cf,R);
     (Jrad, R1 * fractionalIdeal((denominator R1), ideal Jid))
     )

--------------------------------------------------------------------------------------
-- Choice of element of the conductor, or element in the radical of the conductor ----
--------------------------------------------------------------------------------------
disc = method()
disc QuotientRing := (R) -> (
     I := ideal R;
     if numgens I > 1 then error "disc expected a quotient by a single monic polynomial";
     F := I_0;
     S := ring F;
     x := S_0; -- F should be monic in this variable MES: put in a test for this!!
     d := degree_x F;
     if first degree contract(x^d, F) > 0 then error "expected monic polynomial";
     ds := factor discriminant(F, x);
     dfactors := select((toList ds)/toList, m -> m#1 > 1);
     dfactors/(f -> {f#0, f#1//2})
     )
disc(RingElement,RingElement) := (F,x) -> (
     if ring F =!= ring x then error "expected variable and polynomial to be in the same ring";
     if index x === null then error "expected indeterminate in ring";
     d := degree_x F;
     if first degree contract(x^d, F) > 0 then error "expected monic polynomial";
     ds := factor discriminant(F, x);
     dfactors := select((toList ds)/toList, m -> m#1 > 1);
     dfactors/(f -> {f#0, f#1//2})
     )

------------------------------------------------------------
-- Translation of icFractions output to fractional ideals --
------------------------------------------------------------
simplifyFraction = method()
simplifyFraction(RingElement,RingElement) := (f,g) -> (
     -- given f/g an element of the fraction field of a Noether ring R
     -- re-express as a fraction with denominator in the coefficient ring of R
     I := (ideal g):f;
     denoms := first entries selectInSubring(1, gens gb I);
     if #denoms > 1 then print "more than one potential denom!";
     denom := denoms_0;
     numer := denom*f // g;
     K := coefficientRing ring denom;
     denom = lift(denom,K);
     (numer,denom)
     )

fractionalIdealFromICFracs = method() 
fractionalIdealFromICFracs(List, Ring) := (icFracs, R) -> (
     -- icFracs: output of icFractions
     -- R: Noether normalization of ring of icFracs
     numdenompairs := icFracs / (p -> (sub(numerator p, R), sub(denominator p,R)));
     numdenompairs = numdenompairs / simplifyFraction;
     denom := lcm (numdenompairs / last);
     I := ideal for P in numdenompairs list (
	  P#0 * (denom // P#1)
	  );
     I = I + ideal denom;
     J := fractionalIdeal(promote(denom,R), I);
     previous := J;
     output := J*J;
     while output != previous do (
	  print "got here";
	  previous = output;
	  output = output * J;
	  );
     output
     )


---------------------------------------------------
-- Integral closure with a specific denominator ---
---------------------------------------------------
integralClosureHypersurface = method()
integralClosureHypersurface Ring := (R) -> (
     -- assumption: R is in Noether normal position
     -- as required above.
     D := (disc R)/first//product;
     integralClosureDenominator(R, D)
     )

integralClosureDenominator = method()

trager = method()
trager(FractionalRing, RingElement) := (F, Q) -> (
     --R: ring generated via noetherPosition in TraceForm.m2
     --Q: element of the coefficient field of R in the conductor of R
     R := ring F;
     K := coefficientRing R;
     if not ring Q === K then error "expected first argument to be an element of the coefficientRing of the second.";
     print "--  trace form   --";
     time traceR := traceForm R;
     oldRing := F;
     radQ := traceRadical(Q, oldRing);
     print "-- endomorphisms --";
     time currentRing := Hom(radQ, radQ);
     while oldRing != currentRing do (
	  oldRing = currentRing;	  
	  --radQOld = traceRadicalOld(Q, currentRing);
	  radQ = traceRadical(Q, currentRing);
	  --if not radQOld == radQ then error "outputs do not agree for old and new";
          print "-- endomorphisms --";	  
	  time currentRing = Hom(radQ, radQ);
	  );
     oldRing
     )

integralClosureNonNoether = method()
integralClosureNonNoether(FractionalRing,RingElement) := (R,Q) -> (
     -- assumption: R is in Noether normal position
     -- Q is an element of the conductor (in the coefficient ring of R or the ring of R
     local k;
     e := R;
     j := fractionalIdeal ideal Q;
     while (
	  e1 := e;
     	  if TraceLevel > 1 then << "radical:" << endl;
	  time (k,j) = radical(j,e1);
     	  if TraceLevel > 1 then << "end:" << endl;
	  time e = ends(j);
	  e1 != e) do (
	  );
     simplify e)

integralClosureDenominator(Ring,RingElement) := (R,Q) -> (
     if inNoetherPosition R 
     then trager(fractionalRing R,Q) 
     else integralClosureNonNoether(fractionalRing R, Q)
     )

integralClosureDenominator(Ring,List) := (R,Qs) -> (
     F := fractionalRing R;
     if inNoetherPosition R 
     then for Q in Qs do F = trager(F,Q)
     else for Q in Qs do F = integralClosureNonNoether(F,Q);
     F
     )

-----------------------------------------------------
-- monic minimal polynomials for integral elements --
-----------------------------------------------------
getIntegralEquationNoether = method()
getIntegralEquationNoether(RingElement, RingElement, Ring) := (num, denom, Kt) -> (
     -- num, denom: elements of a noetherRing R
     -- denom should be liftable to the coefficient ring
     -- returns true iff num/denom is an integral element of frac R over R
     R := ring num;
     if not inNoetherPosition R then error "currently, can only find integral equation over a ring in Noether position";
     K := coefficientRing R;
     denom = lift(denom,K);     
     if not K === coefficientRing Kt then error "expected third argument to be polynomial ring over coefficient ring of ring of first argument";
     B := getBasis R;
     n := #B;
     M := matrix ({{1_K}}|toList (n-1:{0}));
     i := 1;
     while ker M == 0 do (
	  nextPower := num^i;
	  newCol := lift(last coefficients(nextPower, Monomials => B), K);
	  M = newCol | M;
	  i = i + 1;
	  );
     intEqn := flatten entries gens ker M;
     if not all(#intEqn, (i -> (intEqn#i) % (denom^i) == 0)) then return null;
     t := Kt_0;
     m := #intEqn - 1;
     result := sum for i from 0 to m list (
	  ((intEqn#i) // (denom^i)) * t^(m-i)
	  );
     result
     )

isMonic = (f, x) -> (
     -- input: f a polynomial
     --        x a variable of the ring of f
     -- output:
     --   either:  null
     --       or:  d:ZZ
     --   if f is monic of degree d in x, then return d.  Else, return null.
     d := degree(x,f);
     if d == 0 then return null;
     P := select(terms f, m -> support m === {x});
     d1 := max(P/(g -> degree(x,g)));
     if d1 == d then d else null
     )

-- Another way to get an integral equation:
getIntegralEquationNonNoether = method()
getIntegralEquationNonNoether(RingElement,RingElement,Ring) := (num, denom, Rt) -> (
     -- idea: num and denom are in a domain R
     --  this ring can be a quotient of a poly ring (over kk say)
     --  or: it can be a Noether ring R = A[x]/I (inNoetherPosition R === true)
     -- num should be in R
     -- denom should be in either A or R
     -- Rt should either be R[T]   (name of the var is not relevant)
     --   or A[T].
     -- The result wil be either null, if there is no integral equation over
     --   the selected ring, or, a polynomial in Rt, monic, which has num/denom
     --   as a root (over frac R)
     -- Action:
     --  If R is a poly ring over kk, then 
     R := ring num;
     if ring denom =!= R then
       try promote(denom, R) else error "different rings";
     if coefficientRing Rt === coefficientRing R and inNoetherPosition R
       then getIntegralEquation(num,denom,Rt)
       else (
	    -- 2 options for the ring Rt: it should be R[T], or K[T], where
	    -- K consists of some of the variables of R
	    -- case 1: coefficientRing Rt === R
	    if coefficientRing Rt === R then (
		 -- steps:
		 --  1. lift ideal of R to a ring with generators = gens of R and T.
		 --  2. compute the saturation
		 --  3. find the element, if any.
		 --  4. move it to Rt
		 J := ideal R;
		 kk := coefficientRing R;
		 S := ring J;
		 S1 := kk (monoid [gens Rt, gens S]);
		 StoS1 := map(S1,S,drop(gens S1, 1));
		 S1toRt := map(Rt,S1,generators(Rt, CoefficientRing => kk));
		 denomS1 := StoS1 lift(denom,S);
		 numS1 := StoS1 lift(num,S);
		 J = (StoS1 J) + ideal(S1_0 * denomS1 - numS1);
		 time Jsat := ideal gens gb saturate(J, denomS1);
		 findMinimalEquation := (Jsat, x) -> (
		      L := Jsat_*;
		      P := for i from 0 to #L-1 list (
		      	   d := isMonic(L#i,S1_0);
			   if d === null then continue else {d,i});
		      result := if P === {} 
		      then null 
		      else L#((min P)#1);
		      result
		      );
		 time F := findMinimalEquation(Jsat, S1_0);
		 if F === null then null else (
		      G := S1toRt F;
		      c := lift(leadCoefficient G, kk);
		      if c != 1 then G = 1/c * G;
		      G)
     	    )
       ))

integralEqnNonNoether = (num, denom, Rt, maxN) -> (
     -- Find a smallest degree monic equation for num/denom over R
     -- assumption: num/denom IS integral!
     -- num, denom in a domain R
     -- Rt = R[T], (name T is not relevant)
     -- maxN is the largest degree to consider (infinity allowed)
     -- return: null, if no equation found within the given bound, or
     --  an element of Rt, if one is found.
     M := ideal(denom);
     numI := num;
     i := 1;
     while i <= maxN do (
	  if numI % M == 0 then (
	       cfs := flatten entries(numI // gens M);
	       T := Rt_0;
	       F := T^i - sum(i, j -> cfs#j * T^(i-j-1));
	       return F;
	       );
	  M = denom * ((ideal numI) + M);
	  numI = num * numI;
	  i = i+1;
	  );
     null)

getIntegralEquation = method(Options => {DegreeLimit => infinity})
getIntegralEquation(RingElement,RingElement,Ring) := opts -> (num, denom, Rt) -> (
     R := ring num;
     denomR := denom;
     if ring denomR =!= R then
       try denomR = promote(denom, R) else error "different rings";
     if coefficientRing Rt === coefficientRing R and inNoetherPosition R
       then getIntegralEquationNoether(num,denomR,Rt)
       else if coefficientRing Rt === R
         then 
	   integralEqnNonNoether(num,denomR,Rt,opts.DegreeLimit)
	   --getIntegralEquationNonNoether(num,denomR,Rt)  -- this one is usually too slow
	 else error "cannot understand what ring the monic equation should be over"
     )

getIntegralEquation(RingElement,Ring) :=
getIntegralEquation(Divide,Ring) := opts -> (fr, Rt) -> 
     getIntegralEquation(numerator fr, value denominator fr, Rt, opts)
getIntegralEquation(Holder,Ring) := opts -> (fr,Rt) -> (
     -- this should only get here if the denominator was 1.
     v := value fr;
     R := coefficientRing Rt;
     if instance(v,ZZ) 
     then Rt_0 - v 
     else getIntegralEquation(v, 1_(ring v), Rt))

getIntegralEquation FractionalIdeal := opts -> I -> (
     denom := denominator I;
     K := coefficientRing ring numerator I;
     t := getSymbol "t";
     Kt := K monoid [t];
     apply(flatten entries gens numerator I, num -> getIntegralEquation(num,denom,Kt,opts))
     )

checkMonicEquation = (num, denom, F) -> (
     -- num and denom should be elements in a domain R
     -- F should be a polynomial in R[T] (variable name is not relevant)
     sub(F, {(ring F)_0 => num/denom})
     )

possibleDenominators = method()
possibleDenominators(RingElement, RingElement) := (num,denom) -> trim((ideal denom) : num)
possibleDenominators(RingElement) := (f) -> possibleDenominators(numerator f, value denominator f)
possibleDenominators(List) := (L) -> (
     L1 := for f in L list possibleDenominators f;
     trim intersect L1
     )

newDenominator = method()
newDenominator(FractionalIdeal, RingElement) := (F,g) -> (
     if ring g =!= ring F then try g = promote(g,ring F) else error "denominator cannot be promoted to ring of ideal";
     J := g * gens numerator F;
     if J % denominator F != 0 then error "denominator cannot be used";
     fractionalIdeal(g, ideal(J // denominator F))
     )
------------------------------------------------------

beginDocumentation()

doc ///
Key
  FractionalIdeals
Headline
  manipulation of fractional ideals in a domain in Noether normal position
Description
  Text
  Example
Caveat
SeeAlso
///

TEST ///
-- of simplification of fractional ideals, in Noether position
restart
needsPackage "FractionalIdeals"
S = QQ[a..d]
I = monomialCurveIdeal(S, {1,3,4})
A = S/I
R = noetherPosition {a,d}
F = fractionalIdeal(a^3, ideal(a^2*c, a*(a+1)^4*b))
fractions F
G = fractionalIdeal(b^4, ideal(a^2*c, a*(a+1)^4*b))
fractions G
///

TEST ///
-- of simplification of fractional ideals, NOT in Noether position
restart
needsPackage "FractionalIdeals"
S = QQ[a..d]
I = monomialCurveIdeal(S, {1,3,4})
R = S/I
F = fractionalIdeal(a^3, ideal(a^2*c, a*(a+1)^4*b))
G = fractionalIdeal(b^4, ideal(a^2*c, a*(a+1)^4*b))
fractions F
fractions G
oo/value
///

TEST ///

///


TEST ///  -- test of getIntegralEquation
restart
needsPackage "FractionalIdeals"
--taken from: singular-vasconcelos
kk = ZZ/32003
w = symbol w
t = symbol t
S = kk[x,y,z,w,t]
I = ideal"
  x2+zw,
  y3+xwt,
  xw3+z3t+ywt2,
  y2w4-xy2z2t-w3t3"
I = sub(I, {t => t+z})
A = S/I
R = noetherPosition{w,t}
kx = coefficientRing R
time F = getIntegralEquation(x, 1_kx, kx[T])
assert(degree(T,F) == 23)
  -- assert(leadCoefficient F == 1)  FAILS: has -1 lead coeff...
assert(isUnit leadCoefficient F)

use A
time F = getIntegralEquation(x, 1_A, A[T])
assert(F == T - x)

use R; use coefficientRing R
time integralClosureDenominator(R, w*t)
FR = fractions oo

time for f in FR list getIntegralEquation(f, R[T])
time for f in FR list getIntegralEquation(f, (coefficientRing R)[T])

use A
getIntegralEquation(y*z, w, A[T])
getIntegralEquation(y^2, w, A[T])
getIntegralEquation(x*y, w, A[T])
getIntegralEquation(y^2*z^2, w^2, A[T])
time getIntegralEquation(x*y^2*z^2, w^3, A[T])
time getIntegralEquation(x*y*z^3+w*x*y^2*z-w^4*y, t*w^2, A[T])

time FR = icFractions A
FR = prepend(1_(frac A), FR)
use A
possibleDenominators FR
F = fractionalIdeal FR
newDenominator(F, y*w^2)
FR1 = fractions oo
fractionalIdeal FR1

use R; use coefficientRing R
time integralClosureDenominator(R, t)

FR = fractions oo
getIntegralEquation(FR#1, R[T])

///

TEST ///
--boehm5-QQ
restart
needsPackage "FractionalIdeals"
kk = QQ
kk = ZZ/32003
S = kk[u,v] -- QQ is currently out of range, this one is just the dehomogenization of boehm4, and takes much longer!
F = 25*u^8+184*u^7*v+518*u^6*v^2+720*u^5*v^3+576*u^4*v^4+282*u^3*v^5+84*u^2*v^6+14*u*v^7+v^8+244*u^7+1326*u^6*v+2646*u^5*v^2+2706*u^4*v^3+1590*u^3*v^4+546*u^2*v^5+102*u*v^6+8*v^7+854*u^6+3252*u^5*v+4770*u^4*v^2+3582*u^3*v^3+1476*u^2*v^4+318*u*v^5+28*v^6+1338*u^5+3740*u^4*v+4030*u^3*v^2+2124*u^2*v^3+550*u*v^4+56*v^5+1101*u^4+2264*u^3*v+1716*u^2*v^2+570*u*v^3+70*v^4+508*u^3+738*u^2*v+354*u*v^2+56*v^3+132*u^2+122*u*v+28*v^2+18*u+8*v+1
A = S/F
singF = intersect decompose(ideal F + ideal jacobian ideal F)
see trim oo
use A
R = noetherPosition {v}
singF = decompose(ideal F + ideal jacobian ideal F)
singF = sub(intersect singF, R)
Q = (ideal selectInSubring(1,gens gb singF))_0
IR = time integralClosureDenominator(R,lift(Q,coefficientRing R))
FR = fractions oo  -- very complicatd.  Is this the way they should be?
FR = FR/value
time U = fractionalRingPresentation IR
minimalPresentation U

-- non Noether position variant


///
end

doc ///
Key
Headline
Inputs
Outputs
Consequences
Description
  Text
  Example
Caveat
SeeAlso
///

TEST ///
-- test code and assertions here
-- may have as many TEST sections as needed
///

---- examples from IntegralClosure/examples.m2
restart
needsPackage "FractionalIdeals"
--S = QQ[y,x,MonomialOrder=>{1,1}]
S = QQ[x,y]
I = ideal((y^2-y-x/3)^3-y*x^4*(y^2-y-x/3)-x^11)
R = S/I
--time R' = integralClosureHypersurface R

integralClosureDenominator(R, x)

S = QQ[x,y,MonomialOrder=>{1,1}]
integralClosureDenominator(R, y)
integralClosureDenominator(R, y-1)
integralClosureDenominator(R, y*(y-1))

singularLocus R
ringFromFractions(oo, Variable => getSymbol "w")
fractionalRingPresentation R'
minimalPresentation oo

A = noetherPosition {x}
debug FractionalIdeals
inNoetherPosition A

netList factorize det traceForm A
F = integralClosureDenominator(A, x)
fractions F
oo/value

use R
A = noetherPosition {y}
inNoetherPosition A

use coefficientRing A
F1 = time integralClosureDenominator(A, y^2-y)
fractions F1

use coefficientRing A
F2 = time integralClosureDenominator(A, {y,y-1})
fractions F2

use coefficientRing A
F3 = time integralClosureDenominator(A, {y-1,y})
fractions F3

F11 = F1*F1
F11 == F1
F1 == F2
F2 == F3
F1 == F3

F22 = F2*F2
F22 == F2
F11 == F22
use A
time F = integralClosureDenominator(A, y)
time integralClosureDenominator(F, y-1)
fractions oo

view oo
use A
use coefficientRing A
integralClosureDenominator(A, y)
view oo
integralClosureDenominator(A, y-1)
view oo
--------------------------------------------------
--vanHoeij1
S = QQ[y,x,MonomialOrder=>{1,1}]
I = ideal"y10+(-2494x2+474)y8+(84366+2042158x4-660492x2)y6
           +(128361096x4-4790216x2+6697080-761328152x6)y4
	   +(-12024807786x4-506101284x2+15052058268x6+202172841+134266087241x8)y2
	   +34263110700x4-228715574724x6+5431439286x2+201803238-9127158539954x10-3212722859346x8"
R = S/I
R' = integralClosureHypersurface R
time R' = integralClosureDenominator(R,x)  -- NEED also: allow R to be a fractional ring
time R' = integralClosureDenominator(R,x*(29*x^2+3))  -- NEED also: allow R to be a fractional ring
ringFromFractions oo
fractionalRingPresentation R'
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

----------------------------------------------------------
--boehm19
restart
loadPackage "FractionalIdeals"
S = QQ[u,v, MonomialOrder=>{1,1}]
F = 5*v^6+7*v^2*u^4+6*u^6+21*v^2*u^3+12*u^5+21*v^2*u^2+6*u^4+7*v^2*u
R = S/F

time integralClosureHypersurface R
fractionalRingPresentation oo
-- working on this bug:
rj3 = fractionalIdeal(v^3, ideal(v^4,u^2*v^3+u*v^3,u^3*v^2+u^2*v^2,u^5*v+u^4*v))
r3 = fractionalIdeal(v^3, ideal(v^3,u^3*v^2+u^2*v^2,u^4*v+u^3*v,6*u^5+6*u^4+7*u^2*v^2+7*u*v^2))
rj3/ring
r3/ring
r3*r3 == r3 -- true 
isSubset(rj3,r3) -- true
rj3*r3 == rj3 -- true
(k4,j4) = radical(rj3,r3)
isSubset(rj3,j4) -- true

A = ringFromFractionalIdeal(r3)
see ideal A
gens A
J = ideal(v, u^2+u, w_(0,0), u*w_(0,1))
Jrad = trim radical  J
isSubset(J, Jrad)


D = first first disc R
r1 = fractionalIdeal ideal(1_R)
j1 = fractionalIdeal trim radical ideal sub(D,R)
e1 = End j1
(k2,j2) = radical(j1, e1)
r2 = End j2
isSubset(r1,r2)
(k3,j3) = radical(j2,r2)
r3 = End j3
isSubset(r2,r3)
isSubset(j3,r3)
r3*j3 == j3
rj3 = newDenominator(j3, denominator r3)
(k4,j4) = radical(rj3,r3)

isSubset(rj3,j4) -- true
isSubset(j3,j4) -- true

r4 = End j4
isSubset(j1,j2)
isSubset(j2,j3)
isSubset(j3,j4)
isSubset(j3,r3)
isSubset(r3,r4)
(k5,j5) = radical(newDenominator(j4, denominator r4), r4)
r5 = End j5
r4 == r5 -- true
A = ringFromFractions r4
see ideal gens gb ideal A
u
fractionalIdeal

-- example of Doug Leonard
-- NOT WORKING YET: I have to remember how this code works! (6/27/09)
R=ZZ/2[x,y,z, MonomialOrder=>{1,2}]
I=ideal(x^6+x^3*z-y^3*z^2)
S=R/I
time integralClosureHypersurface S
F = I_0

D = disc(S)
D = D/first//product
j1 = fractionalIdeal trim radical ideal sub(D,S)
e1 = End j1
(k2,j2) = radical(j1,e1)
e2 = End j2
(k3,j3) = radical(j2,e2)
e3 = End j3
(k4,j4) = radical(j3,e3)
e4 = End j4 -- this is the answer
A = ringFromFractionalIdeal e4
prune A
e4

fractionalRingPresentation e4


A
gens gb ideal oo
transpose oo
time P=presentation(integralClosure(S))
icFractions S

-------------------------
restart
load "runexamples.m2"
loadPackage "PrimaryDecomposition"
loadPackage "FractionalIdeals"
I = value H#10#1
R = (ring I)/I
S = (coefficientRing ring I)[u,v,MonomialOrder=>{1,1}]
R = S/sub(I,S)
F = sub(I_0,S)
use ring F
disc(F,u)
disc(F,v)
use R
integralClosureDenominator(R, v-1)
integralClosureDenominator(R, v+3)
time integralClosureDenominator(R, v+1)

restart
load "runexamples.m2"
loadPackage "PrimaryDecomposition"
loadPackage "FractionalIdeals"
I = value H#3#1
R = (ring I)/I
S = (coefficientRing ring I)[x,y,MonomialOrder=>{1,1}]
R = S/sub(I,S)
F = sub(I_0,S)
use ring F
disc(F,x)
disc(F,y)
use R
time integralClosureDenominator(R, y)
errorDepth=0

I = value H#12#1
R = (ring I)/I
S = (coefficientRing ring I)[v,u,z,MonomialOrder=>{1,2}]
R = S/sub(I,S)
F = sub(I_0,S)
use ring F
disc(F,v)

use R
time integralClosureDenominator(R, z)
time integralClosureHypersurface(R)

---------------------------------------------------------------------
--singular-theo3 -- playing with finding Rees valuations
restart
R = ZZ/32003[x,y,z, Degrees => {3,5,15}, MonomialOrder=>{1,2}]
I = ideal"z(y3-x5)+x10"
A = R/I
singF = ideal singularLocus A
use ring singF
eliminate(singF, {y,z})
eliminate(singF, {x,z})
eliminate(singF, {x})
loadPackage "FractionalIdeals"
B = integralClosureDenominator(A, y)
values o6
oo/class
o7/ring
C = fractionalRingPresentation B
J = ideal gens gb C
J = trim lift(J, ambient ring J)
see J
use ring J
yJ = trim(J + ideal(y))
decompose yJ
ideal oo

use ring J
ideal J
ambient J
J

use ring J
eliminate(J, w_0)
see ideal oo

D = (ring J)/J
P = ideal(x,y,w_0,w_1)
P/P^2
prune oo
E = D/P
prune(P/P^2) ** E
see J
