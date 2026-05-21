newPackage(
	"RandomCurves",
    	Version => "0.6",
    	Date => "July 5, 2011",
    	Authors => {{Name => "Frank-Olaf Schreyer",
		     Email => "schreyer@math.uni-sb.de",
		     HomePage => "http://www.math.uni-sb.de/ag/schreyer/"},

	            {Name => "Hans-Christian Graf v. Bothmer",
	             Email => "bothmer@uni-math.gwdg.de",
		     HomePage => "http://www.crcg.de/wiki/User:Bothmer"},

	     	    {Name=> "Florian Geiss",
	             Email=> "fg@math.uni-sb.de",
	             HomePage=> "http://www.math.uni-sb.de/ag/schreyer/"}


                   },
    	Headline => "random curves",
	Keywords => {"Examples and Random Objects"},
	PackageExports => {"RandomObjects","RandomSpaceCurves","RandomPlaneCurves","RandomGenus14Curves","RandomCanonicalCurves"},
    	DebuggingMode => false
        )

beginDocumentation()


doc ///
Key
 RandomCurves
Headline
 random curves
Description
 Text
  Selecting a random curve of genus g means selecting a random point in the moduli space M_g of smooth curves of genus g.
  For g<=14, this space is known to be unirational, and construction methods to find a random point are known.
  In this package there are functions to create objects of type RandomObject that contain routines to choose
  a random curve in this sense, always for genus <= 14, and certain other construction.

  A RandomObject in this sense is a hashTable consisting of two functions, one that can construct a random point
  and the other that can certify that the thing constructed has the desired property, say being a smooth space
  curve of the desired genus and degree. This is employed through a call such as random spaceCurve, which
  returns the constructor function;
  thus to get a random curve of degree d and genus g one must do something like

  (random spaceCurve)(d,g,R)

  where R is the homogeneous coordinate ring of P^3.

  For a different approach, see the package @TO SpaceCurves@: there  special curves in P^3 of every  genus and degree that is
  allowed by Castelnuovo's theorem are constructed on surfaces of degree <=4, following the Theorem of Gruson and Peskine.
  
  This package loads the @TO RandomObjects@, @TO RandomSpaceCurves@,
  @TO RandomPlaneCurves@, @TO RandomGenus14Curves@, and
  @TO RandomCanonicalCurves@ packages.
///

end

restart;
uninstallPackage"RandomCurves"
uninstallPackage"RandomObjects"
uninstallPackage"RandomPlaneCurves"
uninstallPackage"RandomSpaceCurves"
uninstallPackage"RandomGenus14Curves"
uninstallPackage"RandomCanonicalCurves"
--installing all packages takes about 90 seconds:
installPackage("RandomObjects",RerunExamples=>true,RemakeAllDocumentation=>true);
installPackage("RandomPlaneCurves",RerunExamples=>true,RemakeAllDocumentation=>true);
installPackage("RandomSpaceCurves",RerunExamples=>true,RemakeAllDocumentation=>true);
installPackage("RandomGenus14Curves",RerunExamples=>true,RemakeAllDocumentation=>true);
installPackage("RandomCanonicalCurves",RerunExamples=>true,RemakeAllDocumentation=>true);
installPackage("RandomCurves",RerunExamples=>true,RemakeAllDocumentation=>true);
restart
loadPackage"RandomCurves"
viewHelp RandomPlaneCurves
viewHelp RandomSpaceCurves
viewHelp RandomGenus14Curves
viewHelp RandomCanonicalCurves
g=7;
kk=ZZ/101;
R=kk[x_0..x_(g-1)];
C=(random canonicalCurve)(g,R);
betti res C
(genus C, degree C)

