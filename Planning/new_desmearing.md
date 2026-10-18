# Truncated-Abel desmearing for USAXS — implementation notes

Source: G.-R. Huang *et al.*, "Analytical desmearing of Bonse-Hart USANS data via
truncated Abel inversion", J. Appl. Cryst. preprint (ORNL / NTHU).
Igor sketch: `User Procedures/Indra 2/new_desmearing.ipf` (`IN3_DesmearDataAbel()`).
Status: experimental, for manual comparison with Lake (`IN3_DesmearData()`).

---

## 1. Summary

- The paper's method replaces Lake iterations with a **closed-form integral**:
  desmeared I(Q) = (an integral of the *derivative* of the smeared data from Q to
  √(Q²+σy²)) + (a boundary value of the desmeared intensity at higher Q).
- **The paper's Eq. 15 is not exact for a finite slit.** When it swaps the order of
  integration (Eq. 12 → 13) it treats the upper limit Qm = √(Qx²+σy²) as fixed, but it
  depends on Qx. For USANS (Q ≪ σy) the dropped term is negligible. For USAXS it is
  not: I checked numerically and got up to **5% error at Q ≈ slit length**. Section 4
  gives the exact formula, which has one extra term and also simplifies to a cleaner
  form. With it the inversion matches the true intensity to 10⁻⁶ when evaluated by
  direct quadrature.
- **USAXS suits this method better than USANS.** USANS needs separate SANS data
  because σy (~0.1 Å⁻¹) is far beyond Qmax. USAXS has Qmax ≈ 10·σy, so the
  inversion runs **from high Q down to low Q** using only our own data. The only
  extrapolation needed is a ~1% extension past Qmax, to √(Qmax²+2σy²).
  `IN3_ExtendData` already extends further than that, to √(Qmax²+(1.5σy)²).
- Python prototype on a typical 3-level USAXS model (σy = 0.03, 400 log-spaced points
  from 10⁻⁴ to 0.3 Å⁻¹):

  | input                                 | rms(Desmeared/true − 1) | notes |
  |---------------------------------------|-------------------------|-------|
  | noise-free                            | 0.3% (max 0.5%)          | no smoothing |
  | 1% noise, no smoothing                | 7%                       | derivative amplifies noise |
  | 1% noise, local-linear smoothing w=0.1 (χ²≈0.9) | 0.7%           | lowest-Q 1–2 points off ~5% |
  | 3% noise, w=0.1 (χ²≈1)                | 1.7%                     | lowest-Q points off ~10% |
  | 5% noise, w=0.2 (χ²≈1)                | 2.3%                     | lowest-Q points off ~17% |

  Smoothing is required. The paper says the same: it prescribes Gaussian-kernel
  derivatives and a χ²≈1 criterion.

---

## 2. Smearing model and how it maps to Irena

The paper's Eq. 1/9, written with Irena symbols (σy ≡ `SlitLength`):

```
Ismr(q) = (1/sl) ∫_0^sl  I( √(q² + y²) ) dy
```

This is exactly what `IN3_SmearData` computes: it integrates from 0 to `slitLength`
and then applies `Smeared_int *= 1/slitLength`. So the paper's σy is Irena's
`SlitLength` (the half-length), with the same normalization. A flat I gives a flat
Ismr with the same value. No conversion factors are needed.

---

## 3. What the paper derives (Eq. 9–15)

Substituting s = √(q²+y²) gives an Abel-type form:

```
sl · Ismr(q) = ∫_q^{Qm(q)}  s I(s) / √(s² − q²) ds ,     Qm(q) = √(q² + sl²)
```

The paper integrates by parts, differentiates with respect to q (the two boundary
terms in I′(Qm) cancel, so Eq. 11 is correct), multiplies by 1/√(q²−Q²), integrates
q from Q to Qm(Q), and swaps the order of integration. The result is the paper's
Eq. 15:

```
I(Q) ≈ I(Qm) − (2 sl/π) ∫_Q^{Qm} Ismr′(x) / √(x² − Q²) dx         (paper Eq. 15)
```

and, in the USANS limit Qm ≈ σy, Eq. 19.

---

## 4. The correction: exact finite-slit inversion

In Eq. 12 the inner integral over s runs from q to Qm(q) = √(q²+sl²), and this limit
grows with q. Swapping the order over the true region
`{Q ≤ q ≤ Qm(Q), q ≤ s ≤ √(q²+sl²)}` gives two parts:

1. s ∈ [Q, Qm(Q)]: q runs over [Q, s]. The inner integral is π/2, which is the paper's
   term.
2. s ∈ [Qm(Q), Qmm(Q)], with Qmm = √(Q²+2sl²): q runs over [√(s²−sl²), Qm(Q)].
   **The paper drops this part.** Its inner integral is analytic:

```
K(s,Q) = ∫ q dq / (√(q²−Q²) √(s²−q²)) = arcsin A(s),   A(s) = (Q² + 2sl² − s²)/(s² − Q²)
```

(A goes from 1 at s = Qm to 0 at s = Qmm.) The exact relation is therefore

```
I(Q) = I(Qm) − (2sl/π) ∫_Q^{Qm} Ismr′(x)/√(x²−Q²) dx + (2/π) ∫_{Qm}^{Qmm} I′(s) arcsin A(s) ds
```

Integrating the last term by parts cancels I(Qm). Substituting arcsin A = u, i.e.
`s(u)² = Q² + 2sl²/(1+sin u)`, gives the form used in the code:

```
I(Q) = −(2sl/π) · T1(Q)  +  T2(Q)

T1(Q) = ∫_Q^{√(Q²+sl²)}  Ismr′(x) / √(x² − Q²) dx          (from the smeared data)
T2(Q) = (2/π) ∫_0^{π/2}  I( √(Q² + 2sl²/(1+sin u)) ) du      (mean of the DESMEARED I
                                                              over s ∈ [√(Q²+sl²), √(Q²+2sl²)])
```

Sanity checks:
- For a constant I = C: T1 = 0 and T2 = C. ✓
- For Q ≫ sl: T2 → I(Q) + O(sl²) and T1 is small, which recovers the paper's first-order
  Eq. 7.
- Numerical check with a two-level model and sl = 0.03, using adaptive quadrature and
  the exact Ismr′. The ratio to the true I was 1.000000 at every Q from 10⁻⁴ to 0.3. The
  paper's Eq. 15 alone gave 1.0004 at Q = 10⁻⁴, 1.0097 at 0.01, **1.053 at 0.03**,
  1.021 at 0.1 and 1.003 at 0.3.

**Key structural property.** T2 needs I only at s ≥ √(Q²+sl²) > Q. So I(Q) can be
computed **point by point from the highest Q downward**: every value T2 needs is
already known. No iteration and no global solve are required.

---

## 5. Discrete algorithm (what `IN3Abel_AbelInvert` does)

Inputs: `qe[0..n-1]` (increasing, > 0), `Ise` (smoothed smeared intensity on `qe`),
`sl`, and `nOrig` (the first `nOrig` points are measured, the rest are extension).

**Step 0 — extension.** Run `IN3_ExtendData` (same user-chosen function and
`DesmearBckgStart` as Lake) to extend Ismr to at least √(Qmax²+2sl²).
Lake's extension goes to √(Qmax²+(1.5 sl)²), which is enough.

**Step 1 — start values in the extension (Q > Qmax).** Here Q ≥ 10·sl, so the paper's
first-order Eq. 7 is accurate to about 0.01%:

```
I(Q) = Ismr(Q) − sl²/(6Q) · dIsmr/dQ
```

**Step 2 — march i = nOrig−1 … 0.** For each Q = qe[i]:

*T1, analytic per segment.* Ismr is taken as piecewise linear between points, so its
slope on segment j is constant, `slope_j = (Ise[j+1]−Ise[j])/(qe[j+1]−qe[j])`, and

```
∫_{x_lo}^{x_hi} dx/√(x²−Q²) = acosh(x_hi/Q) − acosh(x_lo/Q)
T1 = Σ_{j ≥ i, qe[j] < Qm}  slope_j · [acosh(min(qe[j+1],Qm)/Q) − acosh(qe[j]/Q)]
```

This handles the 1/√ singularity at x = Q exactly, with no special treatment needed.

*T2, midpoint rule in u.* Use NU = 64 nodes, u_k = (k+½)(π/2)/NU,
s_k = √(Q² + 2sl²/(1+sin u_k)), and T2 = mean_k I(s_k). Interpolate I linearly in q
between already-computed points. Linear interpolation is fine and handles negative
intensities. Log-log interpolation made no measurable difference.

*Implicit first bracket (important).* At high Q the whole s-range [Qm, Qmm] has width
≈ sl²/(2Q). At Q = 0.3 that is 0.0015, which can be **smaller than the point spacing**,
so some nodes fall between qe[i] and qe[i+1], where I(qe[i]) is still unknown. Clamping
those nodes to Id[i+1] caused a systematic drift of up to 7% in my first prototype.
The fix: in that bracket I(s) = a·Id[i] + (1−a)·Id[i+1] with a = (qe[i+1]−s)/Δq. T2 is
then linear in Id[i], T2 = α·Id[i] + β, so

```
Id[i] = ( −(2 sl/π) T1 + β ) / (1 − α)
```

α < 1 always holds, because every node satisfies s > Q.

**Cost.** For each point, T1 loops over the points in [Q, √(Q²+sl²)] (hundreds at
low Q) and T2 does 64 node look-ups (BinarySearch). For 400–500 points this is a few
×10⁵ operations, so well under a second in Igor. For un-rebinned fly scans with
several thousand points it scales as N², so rebin first or vectorize T1.

---

## 6. Noise and smoothing

The inversion differentiates the data, and the kernel 1/√(x²−Q²) weights the
neighbourhood of Q heavily. Without smoothing, 1% noise turns into ~7% scatter.

What I implemented (`IN3Abel_SmoothLocalLinear`):
- **Gaussian-weighted local-linear regression vs ln Q**, on ln I (or on I if any
  value ≤ 0, which can happen at high Q after blank subtraction). Width `w` is in
  ln Q units, so w = 0.1 means about ±10% in Q.
- I chose local-linear rather than plain Gaussian averaging (the paper's kernel)
  because a plain average is biased at the ends of the data and on steep power laws.
  In the prototype it cut the lowest-Q error roughly in half.
- **Automatic width** (`IN3Abel_FindSmoothWidth`), following the paper's Step 4: the
  largest w for which the reduced χ² of (smoothed − measured)/SMR_Error over measured
  points is ≤ 1. It bisects in ln w over [0.002, 0.5].
  - This relies on `SMR_Error` being realistic. If our errors are inflated, it
    over-smooths; if they are underestimated, it under-smooths. Watch the printed χ²
    and width, and fall back to a manual width (`DesmearAbelAutoSmooth=0`,
    `DesmearAbelSmoothW=…`) if needed.
- The lowest 1–3 points are always the weakest, because the smoothing window is one-sided
  and T1 there integrates over the most points. On USAXS these points are next to the
  beam anyway.

Paper's limitation (Sec. 3.1.3), which applies equally here: data with sharp features
(form-factor minima, structure peaks) whose width is comparable to the slit length
cannot be desmeared reliably by *any* method. Noise is amplified at the minima. For
those samples, fit SMR data with a smeared model. That matches the Irena advice we
already give.

---

## 7. Uncertainties

The inversion is **linear** in Ismr (T1 is linear, and T2 is a linear combination of
previously computed values), so error propagation is well defined, unlike Lake.

Implemented: **Monte Carlo** (`IN3Abel_MonteCarloErrors`, `DesmearAbelNumMC`, default 20):
1. Add `gnoise(SMR_Error)` to the measured points (the extension stays fixed).
2. Smooth with the same width, invert, and repeat.
3. DSM_Error = standard deviation over the realizations.

This is simple and honest, and includes the smoothing. Setting `DesmearAbelNumMC < 2`
falls back to the old Lake-style `IN3_GetErrors`, for comparison.

Alternatives, if MC proves slow:
- Analytic propagation of the T1 term (the paper's Eq. 23 analogue). With
  `dT1/dIsmr[k] = W[i,k−1]/Δq[k−1] − W[i,k]/Δq[k]`, where W are the acosh segment
  weights, `σ²(Id[i]) ≈ (2sl/π)² Σ_k (dT1/dIsmr[k])² σ_k²`. This ignores the
  (correlated) T2 contribution and the smoothing, so it overestimates the error
  without smoothing and underestimates it with smoothing. MC is preferred.
- Build the full linear operator M by inverting unit vectors (N inversions), then
  `Cov = M Σ Mᵀ`. This is exact, including correlations, but costs N inversions.

---

## 8. Sensitivity to the high-Q extension

An error δ in the desmeared start values propagates **down the whole curve as an additive
constant**, because T2 is an average with weights that sum to 1 and a constant passes
through unchanged. Its size is set by I(Qmax), which is the smallest intensity of the
curve. In the prototype, changing the extension by **+20%** shifted Id by a constant
equal to **−0.8% of I(Qmax)**. That had no visible effect below Q ≈ 0.1 and was below
1% near Qmax. This is the same kind of sensitivity as a background error. The method is
far less sensitive to the extrapolation than the USANS case, because σy/Qmax is about
0.1 here instead of about 100.

---

## 9. Suggested test plan in Igor

1. **Synthetic, noise-free:** `IN3Abel_SyntheticTest(0.03, 0, 0)`. This smears the
   3-level test model with the production `IN3_SmearData` and desmears it. Expect the
   ratio to be within ±0.5%; the graph shows desmeared/true on the right axis.
   Note that this also tests `IN3_SmearData`'s own accuracy (it uses a 2×slit grid and
   a linear tail).
2. **Synthetic with noise:** `IN3Abel_SyntheticTest(0.03, 0.01, -1)` (auto width) and
   `(0.03, 0.03, -1)`. Compare against the table in section 1.
3. **Vary the slit length:** 0.01, 0.03 and 0.06, to check robustness when sl/Qmax
   changes.
4. **Real data, side by side:** reduce a sample as usual, then run
   `IN3Abel_CompareWithLake()`. It keeps `DSM_Int_Lake` and `DSM_Int_Abel` and plots
   Abel/Lake.
   Good test samples:
   - glassy carbon (calibration, smooth)
   - a Porod-dominated powder (Q⁻⁴ over decades)
   - a sample with a weak broad peak
   - a sample with a sharp form-factor minimum (expect both methods to struggle)
   - a noisy, weak scatterer
5. **Closure check:** `DesmNormalizedError` is now (SMR − resmear(DSM))/SMR_Error, a
   direct consistency check of the result. It should scatter about ±1 with no trend.
   The existing graph code already displays it.
6. **Downstream:** fit the same sample with Unified / Size distribution using (a) SMR
   data with a slit-smeared model, (b) Lake DSM, and (c) Abel DSM. Abel parameters
   should be closer to (a). That is the real criterion for adopting it.
7. **Timing:** the printed time per sample, with NumMC = 20, for step-scan (≈150–300
   points) and fly-scan (≈500–1000 points) data.

Ways to run it in Indra, without touching production code:
- Command line: `IN3_DesmearDataAbel()` after a normal recalculation (it overwrites the
  `DSM_*` waves in `root:Packages:Indra3`).
- For a whole session: temporarily make the body of `IN3_DesmearData()` (in
  `IN3_Calculations.ipf`) a single call to `IN3_DesmearDataAbel()`.
  `IN3_DesmearDataAbel` never calls `IN3_DesmearData`, so this creates no recursion.
  Igor also has an `Override Function` mechanism, but I could not reach the
  WaveMetrics page that documents it to confirm where the override must live. Check it
  before relying on it.

New globals in `root:Packages:Indra3:` are created on first use: `DesmearAbelAutoSmooth`
(1), `DesmearAbelSmoothW` (0.05), `DesmearAbelNumMC` (20). The DSM_Int wave note gets
`DesmearMethod=TruncatedAbel;SlitLength=…;AbelSmoothW=…;AbelSmoothChi2=…;AbelNumMC=…`.

---

## 10. If it wins: integration notes

- **Igor:** add a "Desmear method" popup (Lake / Abel) and a smoothing-width SetVariable
  with an Auto checkbox to the Indra panel. Keep Lake as default until real data
  comparisons are done. Record the method in the wave note and in the saved NXcanSAS
  metadata. This adds a field, so `from_dict()` needs a default ("Lake").
- **Matilda (Python):** the algorithm vectorizes well. T1 is a sparse banded matrix of
  acosh weights times the slope vector. T2 is a fixed interpolation matrix, except for
  the implicit bracket. The reference prototype below is the place to start. Core
  numpy only; no new dependencies.

### Reference prototype (numpy)

```python
import numpy as np

def abel_desmear(qe, Is, sl, n_orig, nu=64):
    """Truncated-Abel desmearing with the finite-slit correction (see sections 4-5).

    qe, Is: extended Q (increasing, >0) and smoothed slit-smeared intensity.
    sl: slit length (Irena SlitLength). n_orig: number of measured points.
    """
    n = len(qe)
    Id = np.full(n, np.nan)
    slope = np.diff(Is) / np.diff(qe)
    dI = np.gradient(Is, qe)
    Id[n_orig:] = Is[n_orig:] - sl**2 / (6 * qe[n_orig:]) * dI[n_orig:]   # Eq. 7, Q >> sl
    sinu = np.sin((np.arange(nu) + 0.5) * (np.pi / 2) / nu)
    for i in range(n_orig - 1, -1, -1):
        Q = qe[i]
        Qm = np.hypot(Q, sl)
        T1, j = 0.0, i
        while j < n - 1 and qe[j] < Qm:
            hi = min(qe[j + 1], Qm)
            T1 += slope[j] * (np.arccosh(hi / Q) - np.arccosh(qe[j] / Q))
            j += 1
        s = np.sqrt(Q * Q + 2 * sl * sl / (1 + sinu))
        inb = s < qe[i + 1]
        a = np.where(inb, (qe[i + 1] - s) / (qe[i + 1] - qe[i]), 0.0)
        known = np.where(inb, (1 - a) * Id[i + 1], np.interp(s, qe[i + 1:], Id[i + 1:]))
        Id[i] = (-2 * sl / np.pi * T1 + known.mean()) / (1 - a.mean())
    return Id
```
