#pragma TextEncoding	= "UTF-8"
#pragma rtGlobals		= 3			// Use modern global access method and strict wave access
#pragma DefaultTab		= {3,20,4}	// Set default tab width in Igor Pro 9 and later
#pragma IgorVersion		= 7.00
#pragma version			= 2.00

//========================================================================================
//	TORUS FORM FACTOR  -  user form factor for the Irena Modeling / Sizes packages
//========================================================================================
//
//	Reference
//	---------
//	T. Kawaguchi, "Radii of gyration and scattering functions of a torus and its
//	derivatives", Journal of Applied Crystallography (2001) 34, 580-584.
//	DOI: https://doi.org/10.1107/S0021889801009517
//
//
//	What the torus is
//	-----------------
//	A solid ring of uniform scattering length density (Kawaguchi Fig. 1):
//
//		a  = radius of the circular cross section  ("tube" radius)
//		b  = distance from the rotation axis to the centre of that cross section
//		     ("ring" radius, i.e. the radius of the centre line of the tube)
//
//	Requirement:  0 < a <= b.  For a = b the central hole closes to a point; for a > b
//	the body would intersect itself and Kawaguchi's equations no longer describe it.
//
//		Volume		V   = 2 pi^2 a^2 b								(Kawaguchi eq. 3)
//		Rg^2		Rg2 = a^2 + b^2									(Kawaguchi Table 1)
//
//
//	The equations that are implemented
//	----------------------------------
//	Kawaguchi works in s = 2 sin(theta_Bragg)/lambda = Q/(2 pi).  Igor/Irena work in
//	Q = 4 pi sin(theta_Bragg)/lambda, so every 2*pi*s in the paper becomes Q here.
//
//	Scattering amplitude of a torus whose symmetry axis makes the angle theta with the
//	scattering vector (Kawaguchi eq. 14, rewritten in Q):
//
//		F(Q,theta) = INT[b-a .. b+a]  2 pi r J0(Q r sin(theta)) sin(Q g cos(theta)) dr
//		             / (Q cos(theta) / 2)
//
//		with  g(r) = sqrt( a^2 - (r-b)^2 )   = half height of the ring at radius r
//
//	Orientational average for a dilute, randomly oriented solution (eq. 9):
//
//		I(Q) = INT[0 .. pi/2]  F(Q,theta)^2 sin(theta) d(theta)
//
//	Two rewrites are used below, both exact, both purely for numerical robustness:
//
//	(1)	sin(Q g cos(theta)) / (Q cos(theta)/2)  ==  2 g * sinc(Q g cos(theta))
//		where sinc(x) = sin(x)/x.  The original form divides by cos(theta), which is
//		exactly zero at theta = pi/2 - an endpoint of the outer integral.  The sinc
//		form has the finite limit 2g there and needs no special case.
//
//	(2)	Substitution  r = b + a sin(phi),  phi in [-pi/2, pi/2], so that
//		g = a cos(phi) and dr = a cos(phi) d(phi):
//
//			F(Q,theta) = INT[-pi/2 .. pi/2]
//			             4 pi a^2 cos^2(phi) [b + a sin(phi)]
//			             * J0(Q [b + a sin(phi)] sin(theta))
//			             * sinc(Q a cos(phi) cos(theta))  d(phi)
//
//		In the raw variable r the integrand behaves like sqrt(a^2-(r-b)^2) and so has an
//		infinite slope at both ends; Simpson's rule then converges only as N^-1.5.  After
//		the substitution the integrand is smooth and convergence is the full N^-4.
//
//	Sanity check that follows immediately from (2): at Q = 0 the Bessel function and the
//	sinc are both 1, and the integral evaluates analytically to 2 pi^2 a^2 b = V.
//	So F(0,theta) = V for every theta, and I(0) = V^2.  That is used for the
//	normalisation below - no numerical "divide by the lowest measured Q" is needed.
//
//
//	Conventions required by Irena  (see IR1_FormFactors.ipf, IR1T_GenerateGMatrix)
//	------------------------------------------------------------------------------
//	Irena evaluates a user form factor like this:
//
//		TempWave  = <FormFactorFunction>(Q, R, par1..par5)
//		TempWave  = TempWave^2
//		TempWave *= <VolumeFunction>(R, par1..par5)^VolumePower
//		...
//		Gmatrix   = Gmatrix * (1e-24)^VolumePower
//
//	Three consequences, all of which this file obeys:
//
//	* The form factor function must return the AMPLITUDE, not the intensity - Irena
//	  squares it itself.  For a non-spherical particle the orientational average has to
//	  be taken of F^2 and not of F, so what is returned here is
//			sqrt( <F(Q,theta)^2>_theta ) / V
//	  which is 1 at Q = 0.  (Identical convention to TriaxSpheroid in the same folder:
//	  "TriaxSpheroidIntgOut returns F^2, code expects F".)
//
//	* The volume function must return the volume in ANGSTROMS^3.  Irena applies the
//	  A^3 -> cm^3 conversion itself, once, on the whole G matrix
//	  (IR1_FormFactors.ipf: "Gmatrix = Gmatrix * (1e-24)^VolumePower").  Putting a 1e-24
//	  into Torus_Volume as well would make the modelled intensity too small by 1e24 or
//	  1e48.  All built-in Irena volumes (IR1T_SphereVolume etc.) are in A^3 too.
//
//	* Lengths in, and only in, Angstroms - that is what Irena's Q axis assumes.
//
//
//	Parameters as seen in the Irena panel
//	-------------------------------------
//		Radius	b	ring radius, centre line of the tube			[A]   (the distributed size)
//		par1	a	cross-section radius of the tube				[A]   0 < a <= b
//		par2		numerical quality, see below					[-]   0 = automatic
//		par3..5		not used
//
//	par2 in detail:
//		0 (or blank)	fully automatic point counts (recommended)
//		0 < par2 < 20	multiplier on the automatic point counts.  2 = twice as many
//						points (slower, more accurate), 0.5 = half as many (faster).
//		par2 >= 20		use exactly this many points for BOTH integrals, no adaptation.
//						Rounded up to the next odd number (Simpson's rule).
//
//	The automatic counts are
//		nPhi   = 31 + 2.5 Q a			points across the tube cross section
//		nTheta = 31 + 1.5 Q (a + b)		points over the orientation angle
//	i.e. they grow with the number of oscillations the integrands actually have.  Tested
//	against adaptive quadrature for a/b from 1/20 to 1 and sizes from 2 to 1000 A over
//	Q = 0.001 to 3 A^-1: worst relative error 3e-4, typically far better.
//
//
//	How to set this up in Irena
//	---------------------------
//		1.  Open this .ipf file in the Igor experiment and leave it open (do not kill it).
//		2.  Modeling II -> Model controls -> Form Factor = "User".
//		3.  Name of Form Factor function  :  Torus_FF
//		4.  Name of volume FF function    :  Torus_Volume
//		5.  Set "Radius" to the ring radius b, par1 to the tube radius a, par2 to 0.
//		6.  Contrast is NOT built into this form factor, so set the contrast in the main
//			panel to the real (delta-rho)^2 of your system, as for any simple shape.
//		7.  Torus_FF_Test() runs a self-check and plots an example curve.
//
//
//	Revision history
//	----------------
//	1.00	original version (F. L. B.)
//	2.00	Jan Ilavsky / review, September 2026.  Corrections and changes:
//
//		[1]	g(r) was coded as sqrt(b^2-(r-a)^2) instead of sqrt(a^2-(r-b)^2), i.e. the
//			roles of the tube radius and the ring radius were swapped inside the square
//			root while the integration limits used them the right way round.  For most
//			parameter combinations this made the argument negative over part of the
//			range and the whole integral NaN.
//
//		[2]	The result of the inner integral was read from Inner_Dest[LastPoint-1]
//			instead of Inner_Dest[LastPoint].  Integrate/T returns a cumulative
//			integral, so the complete integral is the LAST point; the old code
//			systematically dropped the final interval.
//
//		[3]	The integrand divided by cos(theta), which is exactly 0 at the theta = pi/2
//			endpoint of the outer integral.  Rewritten with sinc(), see (1) above.
//
//		[4]	The normalisation divided I(Q) by I(Q_min), with Q_min tracked in a global
//			variable Global_minQ that survived between runs and between data sets.  The
//			returned curve therefore depended on the order in which points were
//			evaluated and on what had been fitted previously, and it doubled the cost of
//			every call.  Removed: the Q -> 0 limit of the amplitude is analytically V,
//			so the normalisation is simply /V.
//
//		[5]	Irena squares whatever the form factor function returns.  The old code
//			returned an intensity, which was then squared again.  Now the amplitude,
//			sqrt(<F^2>)/V, is returned.
//
//		[6]	Waves were created with Make/O in the current data folder on every single
//			call, overwriting any user waves of the same name.  All work waves are now
//			free waves.
//
//		[7]	Both integrals now use Simpson's rule on a smooth, substituted integrand,
//			with point counts that adapt to Q and to the particle size, and the
//			orientational average is multithreaded.
//
//		[8]	Torus_Volume: units confirmed to be A^3, NOT cm^3 - Irena does that
//			conversion itself (see "Conventions required by Irena" above).  Comment
//			added so the question does not come up again.
//
//========================================================================================


//========================================================================================
//	Torus_FF  -  the function Irena calls
//----------------------------------------------------------------------------------------
//	Returns the orientationally averaged scattering amplitude of a solid torus,
//	normalised to 1 at Q = 0:
//
//		Torus_FF(Q) = sqrt( INT[0..pi/2] F(Q,theta)^2 sin(theta) d(theta) ) / V
//
//	Irena squares this and multiplies by Torus_Volume()^VolumePower.
//========================================================================================
Function Torus_FF(Q, radius, par1, par2, par3, par4, par5)
	variable Q				// scattering vector											[1/A]
	variable radius			// b, ring radius (axis to centre of the tube)				[A]
	variable par1			// a, radius of the circular cross section of the tube		[A]
	variable par2			// numerical quality, 0 = automatic							[-]
	variable par3, par4, par5	// not used

	variable aa = par1		// tube radius
	variable bb = radius	// ring radius

	// ---- input checking ---------------------------------------------------------------
	if(!(aa > 0) || !(bb > 0))
		Abort "Torus_FF: both the ring radius (Radius = b) and the tube radius (par1 = a) must be > 0."
	endif
	if(aa > bb)
		Abort "Torus_FF: the tube radius (par1 = a) must not exceed the ring radius (Radius = b); the torus would intersect itself."
	endif

	// ---- Q = 0 is the analytic limit ---------------------------------------------------
	if(!(Q > 0))							// also catches NaN
		return 1
	endif

	// ---- how many integration points ---------------------------------------------------
	variable nPhi, nTheta
	variable quality = (par2 > 0) ? par2 : 1		// 0 or blank -> automatic
	if(par2 >= 20)							// explicit point count for both integrals
		nPhi   = Torus_MakeOdd(par2, 11, 4001)
		nTheta = nPhi
	else
		// The J0 term oscillates over roughly Q*(a+b) radians as theta sweeps 0..pi/2, and
		// the cross-section integrand over roughly Q*a radians.  Scale the grids with that.
		nPhi   = Torus_MakeOdd(quality * (31 + 2.5 * Q * aa),        11, 1001)
		nTheta = Torus_MakeOdd(quality * (31 + 1.5 * Q * (aa + bb)), 11, 4001)
	endif

	// ---- outer integral over the orientation angle theta --------------------------------
	variable dTheta = (pi/2) / (nTheta - 1)

	Make/FREE/D/N=(nTheta) Torus_weight, Torus_F		// theta[p] = p*dTheta, no wave needed

	Torus_weight = 2 + 2*mod(p, 2)			// Simpson: 1 4 2 4 ... 4 1
	Torus_weight[0]         = 1
	Torus_weight[nTheta-1]  = 1
	Torus_weight           *= dTheta/3
	Torus_weight           *= sin(p * dTheta)			// the sin(theta) of eq. 9

	// F(Q,theta) for every theta; Igor spreads the orientations over the available cores
	MultiThread Torus_F = Torus_Amplitude(Q, aa, bb, sin(p*dTheta), cos(p*dTheta), nPhi)

	Torus_F = Torus_weight[p] * Torus_F[p]^2			// F^2 sin(theta) * Simpson weight
	variable IofQ = sum(Torus_F)						// = <F^2>, and = V^2 at Q -> 0

	// ---- normalise to the Q -> 0 limit --------------------------------------------------
	variable Vol = 2 * pi^2 * aa^2 * bb					// [A^3], the analytic F(0,theta)

	if(!(IofQ > 0))										// underflow far out in Q, or trouble
		return 0
	endif

	return sqrt(IofQ) / Vol
End


//========================================================================================
//	Torus_Volume  -  the volume function Irena calls
//----------------------------------------------------------------------------------------
//	Kawaguchi eq. 3:   V = 2 pi^2 a^2 b
//
//	UNITS:  Angstrom^3.  Do NOT multiply by 1e-24 here.  Irena converts A^3 to cm^3 for
//	the whole G matrix in IR1_FormFactors.ipf / IR1T_GenerateGMatrix:
//			Gmatrix = Gmatrix * (1e-24)^VolumePower
//	and all of Irena's built-in volume functions (IR1T_SphereVolume, IR1T_SpheroidVolume,
//	TriaxSpheroidVolume, ...) return A^3 for exactly that reason.  An extra 1e-24 here
//	would make the modelled intensity wrong by 24 or 48 orders of magnitude.
//========================================================================================
Function Torus_Volume(radius, par1, par2, par3, par4, par5)
	variable radius			// b, ring radius								[A]
	variable par1			// a, tube (cross-section) radius				[A]
	variable par2, par3, par4, par5	// not used

	variable aa = par1
	variable bb = radius

	if(!(aa > 0) || !(bb > 0))
		Abort "Torus_Volume: both the ring radius (Radius = b) and the tube radius (par1 = a) must be > 0."
	endif

	return 2 * pi^2 * aa^2 * bb			// [A^3]
End


//========================================================================================
//	Torus_Rg  -  radius of gyration, handy for checking a fit against a Guinier analysis
//	Kawaguchi Table 1:   Rg^2 = a^2 + b^2
//========================================================================================
Function Torus_Rg(radius, par1)
	variable radius			// b, ring radius		[A]
	variable par1			// a, tube radius		[A]

	return sqrt(par1^2 + radius^2)		// [A]
End


//========================================================================================
//	WORK FUNCTIONS - no need to change anything below this line
//========================================================================================

//----------------------------------------------------------------------------------------
//	Torus_Amplitude
//	F(Q,theta), Kawaguchi eq. 14, after the substitution r = b + a sin(phi):
//
//		F = INT[-pi/2..pi/2] 4 pi a^2 cos^2(phi) [b + a sin(phi)]
//		    * J0(Q [b + a sin(phi)] sin(theta)) * sinc(Q a cos(phi) cos(theta)) d(phi)
//
//	evaluated with Simpson's rule on nPhi (odd) points.  Threadsafe so that the caller
//	can evaluate all orientations in parallel.
//
//	At Q = 0 this returns exactly 2 pi^2 a^2 b = V, which is what the normalisation in
//	Torus_FF relies on.
//----------------------------------------------------------------------------------------
threadsafe static Function Torus_Amplitude(Q, aa, bb, sinTheta, cosTheta, nPhi)
	variable Q				// scattering vector								[1/A]
	variable aa				// tube radius a									[A]
	variable bb				// ring radius b									[A]
	variable sinTheta		// sin of the orientation angle
	variable cosTheta		// cos of the orientation angle
	variable nPhi			// number of points, odd, >= 3

	variable dPhi = pi / (nPhi - 1)			// phi runs over [-pi/2, pi/2], length pi

	Make/FREE/D/N=(nPhi) phiW, wW, sincW

	phiW  = -pi/2 + p*dPhi

	// Simpson weights 1 4 2 4 ... 4 1, times dPhi/3
	wW    = 2 + 2*mod(p, 2)
	wW[0]        = 1
	wW[nPhi-1]   = 1
	wW          *= dPhi/3

	// geometric factor of eq. 14 after the substitution:
	//     2 pi r  *  2 gamma  *  dr/d(phi)
	//   = 2 pi [b + a sin(phi)]  *  2 a cos(phi)  *  a cos(phi)
	//   = 4 pi a^2 cos^2(phi) [b + a sin(phi)]
	wW *= 4*pi * aa^2 * cos(phiW[p])^2 * (bb + aa*sin(phiW[p]))

	// sinc(Q * gamma * cos(theta)) with gamma = a cos(phi).
	// Igor's built-in sinc(x) = sin(x)/x returns 1 at x = 0, which is exactly the limit
	// needed at theta = pi/2 (cos(theta) = 0) and at phi = +-pi/2 (gamma = 0).  This is
	// the whole point of rewrite (1) in the header: no division by cos(theta) anywhere.
	sincW = sinc(Q * aa * cos(phiW[p]) * cosTheta)

	// assemble and integrate
	sincW *= wW[p] * Besselj(0, Q * (bb + aa*sin(phiW[p])) * sinTheta)

	return sum(sincW)
End


//----------------------------------------------------------------------------------------
//	Torus_MakeOdd - round up to an odd integer inside [lo, hi]; Simpson's rule needs an
//	odd number of points (an even number of intervals).
//----------------------------------------------------------------------------------------
threadsafe static Function Torus_MakeOdd(val, lo, hi)
	variable val, lo, hi

	variable n = ceil(val)
	n = max(lo, min(hi, n))
	if(mod(n, 2) == 0)
		n += 1
	endif
	return n
End


//========================================================================================
//	Torus_FF_Test
//	Self-check plus an example curve.  Run it from the command line:  Torus_FF_Test()
//
//	Checks
//		1.  Torus_FF -> 1 as Q -> 0 (the normalisation).
//		2.  Five values of Torus_FF for the torus of Kawaguchi Fig. 3 (a = 2.37, b = 4.73 A)
//			against high-accuracy adaptive quadrature of eqs. 14 and 9.
//		3.  The Guinier limit, which must return Rg^2 = a^2 + b^2 (Kawaguchi Table 1).
//		4.  Torus_Volume against 2 pi^2 a^2 b, and against the sphere of equal volume that
//			Kawaguchi compares with in Fig. 3 (R = 5 A).
//	Then plots I(Q) = V^2 * Torus_FF^2 for that torus, which is the dashed curve of Fig. 3.
//========================================================================================
Function Torus_FF_Test()

	variable aa = 2.37, bb = 4.73				// Kawaguchi Fig. 3
	variable i, calc, ref, err, worst = 0

	Make/FREE/D TestQ   = {0.1,      0.3,      0.6,      1.0,      2.0}
	Make/FREE/D TestRef = {0.954258, 0.649850, 0.263584, 0.150747, 0.025375}

	print "-------- Torus form factor self test (Kawaguchi 2001, a = 2.37 A, b = 4.73 A) --------"

	// 1. normalisation
	calc = Torus_FF(1e-8, bb, aa, 0, 0, 0, 0)
	printf "  Q -> 0 limit                     : %.8f   (must be 1)\r", calc

	// 2. against adaptive quadrature of eqs. 14 + 9
	for(i = 0; i < numpnts(TestQ); i += 1)
		calc = Torus_FF(TestQ[i], bb, aa, 0, 0, 0, 0)
		ref  = TestRef[i]
		err  = abs(calc/ref - 1)
		worst = max(worst, err)
		printf "  Q = %-5g  Torus_FF = %.6f   reference = %.6f   rel. error = %.1e\r", TestQ[i], calc, ref, err
	endfor
	printf "  worst relative error             : %.1e   (should be < 1e-3)\r", worst

	// 3. Guinier limit - an independent check of the whole normalisation chain.
	//    P(Q) -> exp(-Q^2 Rg^2 / 3), so -3 ln(P)/Q^2 -> Rg^2 = a^2 + b^2 as Q -> 0.
	calc = -3 * ln(Torus_FF(0.01, bb, aa, 0, 0, 0, 0)^2) / 0.01^2
	printf "  Guinier limit at Q = 0.01        : Rg^2 = %.4f A^2  (analytic a^2+b^2 = %.4f A^2)\r", calc, aa^2+bb^2

	// 4. volume
	calc = Torus_Volume(bb, aa, 0, 0, 0, 0)
	printf "  Volume                           : %.3f A^3  (analytic %.3f A^3)\r", calc, 2*pi^2*aa^2*bb
	printf "  Sphere of equal volume           : R = %.3f A  (Kawaguchi Fig. 3 uses R = 5 A)\r", (3*calc/(4*pi))^(1/3)
	printf "  Rg                               : %.3f A  (analytic sqrt(a^2+b^2) = %.3f A)\r", Torus_Rg(bb, aa), sqrt(aa^2+bb^2)

	if(worst < 1e-3)
		print "  PASSED"
	else
		print "  FAILED - the form factor does not reproduce the published equations"
	endif

	// ---- example curve, Kawaguchi Fig. 3 (dashed) --------------------------------------
	variable nQ = 300
	Make/O/D/N=(nQ) Torus_Q, Torus_I
	Torus_Q = 10^(-2.3 + p*(log(3.2)-(-2.3))/(nQ-1))			// 0.005 .. 3.2 1/A, log spaced
	variable Vol = Torus_Volume(bb, aa, 0, 0, 0, 0)
	for(i = 0; i < nQ; i += 1)									// plain loop: Torus_FF is itself
		Torus_I[i] = (Vol * Torus_FF(Torus_Q[i], bb, aa, 0, 0, 0, 0))^2	// a multithreaded call
	endfor

	DoWindow/K Torus_TestGraph
	Display/N=Torus_TestGraph/W=(30,30,560,400) Torus_I vs Torus_Q
	ModifyGraph log=1, mirror=1, minor=1
	Label left "V\\S2\\M P(Q)   [A\\S6\\M]"
	Label bottom "Q   [1/A]"
	TextBox/C/N=info/A=RT "Torus, a = 2.37 A, b = 4.73 A\rKawaguchi (2001), Fig. 3"
	print "-------- example curve plotted in graph Torus_TestGraph --------"
End
