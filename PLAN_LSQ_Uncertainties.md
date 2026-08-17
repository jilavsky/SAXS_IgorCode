# Plan — Least-squares fit uncertainties (W_sigma) as user-visible error estimates

Branch: `add-least-square-errors`

Status:

- **Step 1 (global switch) — DONE, TESTED.** `IN2_GeneralProcedures.ipf` v2.35. Config checkboxes save
  on click via `IN2G_ConfigCheckProc` — `IN2G_ConfigMain` force-reads the preference file on every open,
  so a `noproc` checkbox silently reverted unless the user closed with OK. Also applied to
  `Igor8UseLongNames` and `UseUserNameString`; `DoNotRestorePanelSizes` deliberately left alone.
- **Step 2-5 (Modeling) — DONE, TESTED.** `IR2_ModelingMain.ipf` v1.37 / panel 1.26,
  `IR2_ModelingSupport.ipf` v1.57. Also fixed a long-standing tag-placement bug: the tag point number was
  looked up in `Q_setN`, but tags attach to `IntensityModel_setN`, which is plotted against the trimmed
  `Qmodel_setN` — so every tag was displaced toward low q by the number of points cut off below Qmin.
- **Section 6 (other tools) — DONE, NOT YET TESTED.**

### Correction to the survey table above

The table in §1 was wrong about three tools. **Unified fit, Fractals and Guinier-Porod already display
uncertainties in their graph tags** (Fractals `IR1_Fractals.ipf` 913/918/923/972/977/982/987/996;
Unified fit `IR1_UnifiedFitPanel.ipf` 3719-3770, both guarded by `if(<X>Error > 0)`). Per "if it exists,
we leave it", their behaviour is untouched — they are NOT gated by `IN2G_UseLSQFitErrors()`.

What the rollout pass actually changed:

| Tool | File (new version) | Change |
|---|---|---|
| **Simple fits** | `IR3_SimpleFits.ipf` v1.19, panel 1.17 | **Feature added.** `W_sigma` was referenced but never read — dead code. Added 11 `<Name>Error` globals, `IR3J_SetErrorsToZero()`, `IR3J_FmtValErr()`, population from `W_sigma` in all 5 fit routines (Guinier/Rod/Sheet, Porod, Power law, Sphere, Spheroid), and gated `+/-` in graph tags and results notebook. Guinier Sheet thickness carries `sqrt(12)*RgError`. |
| **System specific** | `IR3_SystemSpecificModels.ipf` v1.04 | `SASBackgroundError` was never zeroed — a stale value survived a fit that no longer fitted the background. `W_sigma` recording loop guarded with `WaveExists`. |
| **Ellipsoid/Cylinder** | `IR3_EllipsoidCylinderMain.ipf` v0.4 | Same two fixes. The guard matters here because this tool can fit with `gencurvefit`, which does not produce `W_sigma`. |
| **Ellipsoid/Cylinder** | `IR3_EllipsoidCylinderSupport.ipf` v0.4 | Notebook printed `Length = num2str(SLD)` in all 5 model branches — the wrong quantity — while `LengthErr` was computed and discarded. Now prints `Length +/- LengthErr`. |
| **Reflectivity** | `IR2_Reflectivity.ipf` v1.25 | `ScalingFactorError` was missing from `IR2R_SetErrorsToZero()`. `SolventPenetrationLayer*Error<n>` globals do not exist, so the reset loop assigned to null NVARs 8x per call — now `NVAR_Exists`-guarded. |
| **Analytical models** | `IR2_AnalyticalModels.ipf` v4.20 | `IR2H_ResetErrors()` zeroed only 7 of 16 error globals; the 9 missing ones (including `LowQRgError`/`LowQRgPrefactorError`, which ARE displayed) kept stale values across fits. Both `W_sigma` blocks guarded — the genetic-optimization branch read it with its `V_FitError` check commented out. |

### Still open

- **Simple fits result waves and result tables** (`IR3J_SaveResultsToWaves`, the 8 `*ResultsTableFnct`
  functions) have no Error columns. That needs new columns in each make/redimension list plus matching
  table columns — deliberately left out of this pass.
- `TSCorrLengthError`/`TSRepDistError` (Analytical models) and `TSPar[4..5][4]` (System specific) are
  uncertainties of *derived* quantities that are never fitted. They are now reliably 0 rather than
  stale, but a real number needs error propagation.
- Unified fit notebook prints `+/- 0` for fixed parameters (no `>0` guard) — left as-is.
- Reflectivity still surfaces uncertainties only via a history `print`; it has no graph tag and no
  notebook writer at all.

Decisions takenDecisions taken as implemented (see §8): `<Base>Error_popN` naming; raw `W_sigma`
with reduced Chi-squared reported alongside; uncertainties always stored, display gated;
output-wave Error columns always written; graph tags get the full set.

---

## 1. Summary of what the survey found

The important finding is that **this feature is already implemented, three different ways, in
three other Irena tools**. Modeling is the odd one out. So the job in Modeling is largely a port
of an existing, proven pattern rather than new design.

| Tool | File | Error variables exist? | Zeroed before fit? | Populated from `W_sigma`? | Displayed? |
|---|---|---|---|---|---|
| **Guinier-Porod** | `IR3_GuinierPorodModel.ipf` | Yes — `Level_GError`, `Level_Rg1Error`, … , `SASBackgroundError` | Yes — `IR3GP_SetErrorsToZero()` (l. 1636, 1683, 1832) | Yes — l. 1694–1707 | Yes — graph tag, guarded by `if(Par.GError > 0)` (l. 1930–1999) |
| **Unified fit** | `IR1_UnifiedFitPanel.ipf` / `IR1_UnifiedFitFncts.ipf` | Yes — `Level<N><Param>Error`, `SASBackgroundError` (panel l. 173–202) | Yes — `IR1A_SetErrorsToZero()` (panel l. 424) | Yes — `IR1A_RecordErrorsAfterFit()` (fncts l. 6668) | Notebook only, `"+/- "` (fncts l. 7504–7544, 7624–7664) |
| **Fractals** | `IR1_Fractals.ipf` | Yes — `<CoefName>Error` | Yes — `IR1V_SetErrorsToZero()` (l. 2331) | Yes — `IR1V_RecordErrorsAfterFit()` (l. 2772) | Not obviously surfaced |
| **System specific models** | `IR3_SystemSpecificModels.ipf` | Partly — `SASBackgroundError`, plus column 4 (`"FitError"`) of the per-model `TempParam` matrix | ? | Yes — l. 1831–1839 | Not obviously surfaced |
| **Ellipsoid/Cylinder** | `IR3_EllipsoidCylinderMain.ipf` | Yes, same `TempParam[..][4]` scheme | ? | Yes — l. 1551–1559 | ? |
| **Reflectivity** | `IR2_Reflectivity.ipf` | Yes — has `IR2R_SetErrorsToZero()` (l. 729) | Yes | probably | ? |
| **Analytical models (Gels)** | `IR2_AnalyticalModels.ipf` | Yes | ? | Yes — l. 2471–2510 | ? |
| **Simple fits** | `IR3_SimpleFits.ipf` | No named globals; `W_sigma` read locally per fit | n/a | Yes, locally | Partially, in tag text |
| **Modeling** | `IR2_Modeling*.ipf` | **No** — except an orphan `BackgErr_setN` | **No** | **No** | **No** |

**The orphan:** `BackgErr_setN` already exists in `ListOfDataVariables` in `IR2L_Initialize()`
(`IR2_ModelingSupport.ipf` l. ~2186) and is already *written out* by
`IR2L_SaveResInWavesIndivDtSet()` as the output wave `BackgroundError_setN`
(`IR2_ModelingMain.ipf` l. 2842–2848) and into the wave note (l. 2312). **Nothing ever assigns
it** — it is always 0. Step 3 below finally makes it real, and this also fixes an existing latent
bug.

**Naming convention already established by the other tools** is `<ParameterName>Error`. Note the
subtlety for Modeling (see §3.1).

**Interaction with "Analyze uncertainties" (confidence evaluation):** none. `IR2L_AnalyzeUncertainities()`
→ `IR2L_ConfEvaluationPanelF()` / `IR2L_ConfEvButtonProc()` do their own χ² scan
(`IR2_ModelingSupport.ipf` l. 3806–4600); they never call `IR2L_Fitting()` — grep confirms
`IR2L_Fitting(` is called only from `IR2L_InputPanelButtonProc` (l. 4987, 4990). Nothing in this
plan touches that code path. The one nuance worth a comment in the code: a ConfEv scan varies the
parameter globals afterwards, so the stored `…Error` values remain those of the *last real fit*.
That is the correct behaviour and matches Unified fit.

---

## 2. Global switch — `UseLSQFitErrors`

### 2.1 Where it lives

`root:Packages:IrenaConfigFolder:UseLSQFitErrors`, created in
**`IN2G_InitConfigMain()`** (`User Procedures/Indra 2/IN2_GeneralProcedures.ipf`, l. 1823).

Add to the existing list at l. ~1841:

```igor
ListOfVariables+="Igor8UseLongNames;UseUserNameString;UseLSQFitErrors;"
```

`IN2G_CreateItem("variable", …)` creates it as 0 if absent and leaves an existing value alone, so
default = 0 (off) is automatic. No extra defaulting code needed.

### 2.2 PackagePreferences — the part that needs care

The prefs struct is `IrenaPanelDefaults` (`IN2_GeneralProcedures.ipf` l. 1772–1793). It ends with:

```igor
    uint32 reserved[77]         // Reserved for future use
```

**Do not append a new field at the end.** `SavePackagePreferences`/`LoadPackagePreferences` key on
struct size; growing the struct invalidates every user's existing prefs file and would trip the
"Old version of GUI and Graph Fonts…" alert on every machine. Instead **consume one slot of the
reserved array**, which keeps `sizeof(IrenaPanelDefaults)` unchanged:

```igor
    uint32 UseLSQFitErrors      // 0 = do not use LSQ fit uncertainties (default)
    uint32 reserved[76]         // Reserved for future use
```

Igor zero-initialises structs, so prefs files written by older versions have zeros in the reserved
area and will read back `UseLSQFitErrors = 0`. **`Defs.Version` stays 3** — no version bump, no
migration branch. This is the whole reason the `reserved` array is there.

Then:

- **`IN2G_SaveIrenaGUIPackagePrefs()`** (l. 1917): add
  `NVAR UseLSQFitErrors = root:Packages:IrenaConfigFolder:UseLSQFitErrors` and
  `Defs.UseLSQFitErrors = UseLSQFitErrors`.
- **`IN2G_ReadIrenaGUIPackagePrefs()`** (l. 1976): inside the `elseif(Defs.Version==3)` branch, add
  the same guarded pattern already used for `Igor8UseLongNames`:

```igor
    if(numtype(Defs.UseLSQFitErrors)==0)
        UseLSQFitErrors = Defs.UseLSQFitErrors
    else
        UseLSQFitErrors = 0
    endif
```

### 2.3 The checkbox

`Proc IN2G_MainConfigPanelProc()` (l. 2172) is legacy hardcoded-coordinate code — panel
`NewPanel /K=1/W=(282,48,707,500)`, i.e. 425 × 452, with `OKButton` at y=420. It does not follow
the `yPos` accumulator convention in `CLAUDE.md`; **do not rewrite it as part of this change** —
that is a separate refactor and would risk breaking Nika/Indra users.

Minimal, low-risk edit:

1. Grow the panel: `NewPanel /K=1/W=(282,48,707,560)`.
2. Add a section header after the Nika one:
   `SetDrawEnv fsize=14, fstyle=3, textrgb=(63500,4369,4369)` / `DrawText 30,455,"Fitting uncertainties (all Irena fitting tools)"`
3. Add the checkbox:

```igor
    CheckBox UseLSQFitErrors,pos={10,470},size={80,16},noproc,title="Use least-squares fit uncertainties?"
    CheckBox UseLSQFitErrors,variable= root:Packages:IrenaConfigFolder:UseLSQFitErrors
    CheckBox UseLSQFitErrors,help={"Report the least-squares parameter uncertainties (Igor W_sigma) with fitted parameters. These are only meaningful if your data uncertainties are correct. Off by default."}
```

4. Move `OKButton` from `pos={290,420}` to `pos={290,520}`.
5. Consider widening the window title from "…default fonts and names" — the panel already covers
   Nika uncertainty choice and long names, so the title is stale. Optional; touches
   `IN2G_ConfigMain()` comment only.

`noproc` is enough — `variable=` writes the global directly. The prefs are saved on OK
(`IN2G_KillPrefsButtonProc` → `IN2G_SaveIrenaGUIPackagePrefs(0)`), same as `DoNotRestorePanelSizes`
and `Igor8UseLongNames` behave today.

### 2.4 The accessor — protect against a missing global

Old experiments will not have `UseLSQFitErrors`. Every consumer must be defensive. Rather than
scatter `NVAR/Z` + `NVAR_Exists` across five packages, add **one** helper next to
`IN2G_LkUpDfltVar()` in `IN2_GeneralProcedures.ipf`:

```igor
//***********************************************************
// Returns 1 if the user asked for least-squares fit uncertainties to be
// reported, 0 otherwise. Safe to call from any Irena tool at any time -
// creates the configuration folder/variable if it is missing.
Function IN2G_UseLSQFitErrors()

    NVAR/Z UseLSQFitErrors = root:Packages:IrenaConfigFolder:UseLSQFitErrors
    if(!NVAR_Exists(UseLSQFitErrors))
        IN2G_InitConfigMain()
        NVAR/Z UseLSQFitErrors = root:Packages:IrenaConfigFolder:UseLSQFitErrors
        if(!NVAR_Exists(UseLSQFitErrors))
            return 0
        endif
    endif
    return (numtype(UseLSQFitErrors)==0) ? (UseLSQFitErrors != 0) : 0
End
```

This is the *only* API the tools use. Note `IN2G_InitConfigMain()` is already called from
`IR2L_Main()` (`IR2_ModelingMain.ipf` l. 74), so in practice the variable will exist; the guard is
for scripting/headless entry points.

---

## 3. Modeling — the wiring

### 3.1 Decide the name pattern first

Other tools use `CoefNames[i] + "Error"`. In Modeling the coefficient globals carry a `_popN` /
`_setN` suffix, and every sibling attribute is spelled `<Base>Fit_popN`, `<Base>Min_popN`,
`<Base>Max_popN`. So a literal `CoefNames[i]+"Error"` would give `Volume_pop1Error` —
inconsistent with everything around it, and it would break the `StringFromList(i,List)+"…_pop"+j`
idiom that the entire package is built on.

**Recommendation: `<Base>Error_popN` and `<Base>Error_setN`.**

- consistent with `VolumeFit_pop1` / `VolumeMin_pop1` / `VolumeMax_pop1`
- consistent with the output wave name `BackgroundError_setN` that
  `IR2L_SaveResInWavesIndivDtSet()` already writes
- the existing orphan global is `BackgErr_setN` — keep that name for the global (it is already in
  the wave note and would break round-tripping if renamed) and simply assign to it; add
  `<Base>Error_popN` only for the population parameters.

Name-length check (Igor short-name limit is 31 chars): longest is
`LogNormalSdeviationError_pop10` = 30, `FormFactor_Param1Error_pop10` = 28. Fits, with no room to
spare — worth re-checking if any new parameter is added later.

### 3.2 `IR2L_Initialize()` — create the variables
`IR2_ModelingSupport.ipf`, l. 2154

The function builds `ListOfPopulationVariablesSD / DP / UF / FR` and then loops
`for(j=1;j<=10;j+=1)` calling `IN2G_CreateItem("variable", name+"_pop"+num2str(j))`.

Add an `Error` entry for **every parameter that can appear in `W_coef`**, i.e. exactly those
enumerated by `IR2L_Fitting()`:

- SD list: `VolumeError;` `LNMinSizeError;LNMeanSizeError;LNSdeviationError;`
  `GMeanSizeError;GWidthError;LSWLocationError;` `SZMeanSizeError;SZWidthError;`
  `ArdLocationError;ArdParameterError;`
  `FormFactor_Param1Error;`…`FormFactor_Param9Error;`
  `StructureParam1Error;`…`StructureParam6Error;`
- UF list: `UF_GError;UF_RgError;UF_BError;UF_PError;UF_RGCOError;`
- DP list: `DiffPeakPar1Error;`…`DiffPeakPar5Error;`
- FR list: `MassFrPhiError;MassFrRadiusError;MassFrDvError;MassFrKsiError;`
  `SurfFrSurfError;SurfFrKsiError;SurfFrDSError;`
- Data list: `BackgErr` already exists — nothing to add.

No new loop needed; just extend the existing list strings. This is the bulk of the mechanical work
and is where a typo will silently produce a variable that is never written — see the test in §5.

**Do not** add Error entries for derived quantities (`Mean`, `Mode`, `Median`, `FWHM`, `Rg`,
`DiffPeakDPos`, `DiffPeakQPos`, `DiffPeakQFWHM`, `DiffPeakIntgInt`, `MassFrBeta`, `MassFrEta`,
`SurfFrQc`, `SurfFrQcWidth`, `UF_K`). Those are computed from the fitted parameters, not fitted;
giving them an uncertainty would require error propagation through the distribution integrals.
Explicitly out of scope — mention it in the notebook output so users are not misled.

### 3.3 `IR2L_Fitting()` — build a parallel name wave
`IR2_ModelingMain.ipf`, l. 1339

At l. 1363–1370 the function makes `CoefNames`, `LowLimCoefName`, `HighLimCoefNames`,
`ParamNamesK`, `ParamNames`. Add one more, **not** free (it needs to survive for step 3.4/3.5;
`LowLimCoefName`/`HighLimCoefNames` are `/FREE`, but `ErrorCoefNames` is only needed inside the same
function, so `/FREE` is fine and is the cleaner choice):

```igor
    Make/T/FREE/N=0 ErrorCoefName
```

Then, in **each of the eight parameter-collection blocks** (Volume, distribution shape, structure
factor, form factor, unified level, diffraction peak, mass fractal, surface fractal, background),
alongside the existing

```igor
    LowLimCoefName[numpnts(CoefNames) - 1]   = stringfromList(i, ListOfPopulationVariables) + "Min_pop" + num2str(j)
```

add

```igor
    Redimension/N=(numpnts(W_coef)) ErrorCoefName      // add to the existing Redimension line
    ...
    ErrorCoefName[numpnts(CoefNames) - 1]    = stringfromList(i, ListOfPopulationVariables) + "Error_pop" + num2str(j)
```

(and `…+"Error_set"+num2str(j)` in the background block — but for background emit the literal
`"BackgErr_set"+num2str(j)`, per §3.1).

> **Refactoring note.** Those eight blocks are ~35 identical lines each, copy-pasted. This change
> touches all eight. It is tempting to extract a helper
> `IR2L_AddOneFitParameter(baseName, suffix, prettyName)` first. That would be the right thing
> long-term but it is a much larger, riskier diff. **Recommendation: do the mechanical edit now,
> open a separate issue for the refactor.** If the refactor is done later, the `ErrorCoefName`
> line comes along for free.

### 3.4 Zero the errors before the fit

Add a small function in `IR2_ModelingSupport.ipf`, modelled on `IR3GP_SetErrorsToZero()`:

```igor
Function IR2L_SetErrorsToZero()
    DFREF oldDf = GetDataFolderDFR()
    setDataFolder root:Packages:IR2L_NLSQF
    // walks the same ListOfPopulationVariables* strings, zeroing every *Error_popN
    // and every BackgErr_setN
    ...
    setDataFolder oldDf
End
```

Implementation detail: rather than re-listing the names, derive them by grepping the stored
`ListOfPopulationVariablesSD` etc. globals for items ending in `"Error"` — the lists are already
saved as globals in `IR2L_Initialize()`, so `IR2L_SetErrorsToZero()` stays correct automatically
when a parameter is added.

Call it from **`IR2L_Fitting()`, immediately before the fit** — the natural spot is right after
`Duplicate/O W_Coef, E_wave, CoefficientInput` (l. 1894), i.e. before the `FuncFit`/`gencurvefit`
branch at l. 1940.

Also call it from **`IR2L_ResetParamsAfterBadFit()`** (l. 2115) — if the user reverses a fit, the
uncertainties must not survive alongside the restored pre-fit values. `IR3GP` does exactly this
(l. 1683).

### 3.5 Populate from `W_sigma` after a successful fit

New function next to `IR2L_ResetParamsAfterBadFit()` in `IR2_ModelingMain.ipf`:

```igor
Function IR2L_RecordErrorsAfterFit()

    DFREF oldDf = GetDataFolderDFR()
    setDataFolder root:Packages:IR2L_NLSQF

    WAVE/Z   W_sigma       = root:Packages:IR2L_NLSQF:W_sigma
    WAVE/Z/T ErrorCoefName = root:Packages:IR2L_NLSQF:ErrorCoefName
    if(!WaveExists(W_sigma) || !WaveExists(ErrorCoefName))
        setDataFolder oldDf
        return 0                    // genetic optimization produces no W_sigma
    endif
    variable i
    for(i = 0; i < numpnts(ErrorCoefName); i += 1)
        NVAR/Z InsertErrorHere = $(ErrorCoefName[i])
        if(NVAR_Exists(InsertErrorHere))
            InsertErrorHere = W_sigma[i]
        endif
    endfor
    setDataFolder oldDf
End
```

(If `ErrorCoefName` is made `/FREE` in §3.3 then this logic lives inline at the end of
`IR2L_Fitting()` instead of in its own function. Either is fine; a separate non-`/FREE` wave
matches how `CoefNames` is already handled and is easier to debug — **recommend non-`/FREE`**, i.e.
`Make/O/T/N=0 ErrorCoefName` alongside `CoefNames`.)

Call site: in `IR2L_Fitting()`, inside the `else` branch of `if(V_FitError != 0)` (l. 1969+),
**after** the loop that copies `W_Coef` back into the parameter globals and **before**
`IR2L_RecordResults("after")` (l. 2004).

**Genetic optimization:** `gencurvefit` (l. 1954) does not produce `W_sigma`. The `WaveExists`
guard above handles it, but it should be explicit: if `UseGeneticOptimization` is set, leave the
errors at zero and print one line to the history —
`"Note: genetic optimization does not produce least-squares parameter uncertainties."`
Everything downstream is guarded on `Error > 0`, so zeros simply mean "not reported".

**Gate on the global switch?** Two options:

- (a) always compute and store, gate only the *display*.
- (b) gate the computation too.

**Recommend (a).** Storing a number costs nothing, keeps `W_sigma` and the globals in sync
regardless of when the user flips the switch, and means the values are already there if the user
turns the option on after a fit. All the *reporting* sites in §3.6 test
`IN2G_UseLSQFitErrors()` **and** `…Error > 0`.

### 3.6 Reporting — three sites

All three follow the Guinier-Porod precedent: emit the `+/-` only when the value is non-zero, so
fixed (non-fitted) parameters never grow a meaningless `+/- 0`.

**a) `IR2L_SaveResultsInWaves` → `IR2L_SaveResInWavesIndivDtSet()`**
`IR2_ModelingMain.ipf` l. 2803–3164

This builds `ListOfParameters` as `name=value;` pairs which
`IR2L_SaveResInWavesIndivDtSet2/3()` turn into one output wave per key. The `BackgroundError_setN`
precedent at l. 2842–2848 is exactly the shape to copy — including the `else` branch that writes
`=0` so the output waves stay the same length across rows.

For each model branch (Size dist. l. 2857+, Unified level l. 2973+, SurfaceFractal l. 2991+,
MassFractal l. 3005+, Diffraction peak), add a matching
`ListOfParameters += "<Name>Error_pop"+num2str(i)+"="+num2str(<err>)+";"` line for every fittable
parameter — **unconditionally**, using the stored `…Error_popN` value (which is 0 when not fitted
or when the fit was genetic). Do *not* gate these on `IN2G_UseLSQFitErrors()`: the column count
must not depend on a preference, or a user toggling the switch mid-session gets ragged output
waves. The zeros are self-explanatory.

Two things to fix while in here:
- l. 2842: `BackgErr_setN` finally has a real value (§3.2/3.5).
- the `Mean/Mode/Median/FWHM` block at l. 2858 gets **no** Error columns (§3.2).

Also check `IR2_DataMiner.ipf` l. 1838 — it rewrites `"Error"` → `"Err"` in some generated names,
presumably a 31-char guard. Confirm the new `…Error_popN` wave names survive Data Miner's
round-trip before declaring this done.

**b) `IR2L_AddRemoveTagsToGraph()`**
`IR2_ModelingSupport.ipf` l. 2859–3120

This is the display-space-constrained one and the reason the global switch exists. The tags are
already long. Recommendation:

- gate the whole thing: `variable useErr = IN2G_UseLSQFitErrors()`
- for each parameter line, `TagText += "G = " + num2str(G) + SelectString(useErr && UF_GError>0, "", " +/- " + num2str(UF_GError)) + "  \r"`
  — a tiny local helper is worth it here, e.g.

```igor
static Function/S IR2L_FmtValErr(val, err, useErr)
    variable val, err, useErr
    if(useErr && err > 0)
        return num2str(val) + " +/- " + num2str(err)
    endif
    return num2str(val)
End
```

  used everywhere a `num2str(<fitted param>)` currently appears in the tag builder.
- **Only** for genuinely fitted parameters. Derived values (`Mean`, `FWHM`, `DiffPeakQFWHM`,
  `DiffPeakIntgInt`, `DiffPeakDPos`) print unchanged.
- Watch tag height. With uncertainties on, a Size dist. tag with a structure factor can reach
  ~15 lines. If this becomes a problem, an acceptable fallback is to append uncertainties only
  for the primary parameters (Volume/`UF_G`/`UF_Rg`/`UF_P`/`UF_B` and distribution shape
  parameters) and leave form/structure factor parameters bare — decide after seeing it on screen.

**c) `IR2L_SaveResultsInNotebook()` → `IR2L_SvNbk_ModelInf()`**
`IR2_ModelingSupport.ipf` l. 3123–3470

No space constraint here, so this is where the full record belongs. Same
`IR2L_FmtValErr()` helper on every `IR2L_AppendAnyText(name+"\t=\t"+num2str(testVar),0)` line for
a fittable parameter. Also add, once per fit record, when `IN2G_UseLSQFitErrors()` is on:

- a header line naming what the numbers are: `"Uncertainties are least-squares standard errors (Igor W_sigma) from the last fit."`
- the reduced χ² — see §4 — so the user can rescale if they want to
- a note that derived quantities (Mean/Mode/Median/FWHM/Rg) carry no propagated uncertainty

`IR2L_RecordResults()` (`IR2_ModelingMain.ipf` l. 2191) writes the *other* logbook via
`IR2L_WriteOneFitVar()` (l. 3386) and `Ir2L_WriteOneFitVarPop()` (l. 3231). Those two tiny
functions already print `Fitted / Value= / Min= / Max=`; adding `\tError=` there is a two-line
change and gives a full audit trail almost for free. **Recommend doing it** — cheapest reporting
win in the whole plan.

### 3.7 Wave note round-trip — check, then decide

`IR2L_SaveResultsInDataFolder()` (l. 2258) builds a `name=value;` wave note that
`IR2L_RecoverOldParameters()` (l. 842) reads back to restore a session. `BackgErr` is already in
that note (l. 2312).

Adding the `…Error_popN` values to the note is **optional and recommended for a later step**, not
step 1. It makes the note longer, and the recovery path must be verified to be tolerant of keys it
does not recognise before anything is added. Verify `IR2L_RecoverOldParameters()` first.

### 3.8 Panel version bump

`IR2_ModelingMain.ipf` l. 4: `Constant IR2LversionNumber = 1.25` → **`1.26`**.

`IR2L_MainCheckVersion()` (l. 98) will then prompt users with an old panel to restart the tool,
which re-runs `IR2L_Initialize()` and creates the new globals. This is what makes it safe to use
plain `NVAR` (not `NVAR/Z`) for the `…Error_popN` variables inside Modeling — **but note the
"No" branch** at l. 106: if the user declines the restart, the code calls `IR2L_Initialize()` and
`IR2S_InitStructureFactors()` anyway, so the globals are created either way. Good.

`UseLSQFitErrors` is the one that must stay defensive (§2.4), because it lives outside the
Modeling package and is not covered by the panel version.

Also update the version-history comment block at the top of `IR2_ModelingMain.ipf` and
`User Procedures/Irena/Modification history.txt`.

---

## 4. One statistical decision to make explicitly

Igor's `W_sigma` from a **weighted** fit (`/W=EWvForFit /I=1`, which is what
`IR2L_Fitting()` uses at l. 1949/1959) is **not** scaled by the reduced χ². WaveMetrics' own
guidance is that the user rescales manually:

```igor
reducedChiSquare = V_chisq/(V_npnts - numpnts(W_coef))
reducedSigma = W_sigma*sqrt(reducedChiSquare)
```

This matters directly to the disagreement described in the request:

- **Raw `W_sigma`** is the correct estimator *if and only if* the data uncertainties are
  trustworthy. That is precisely the claim the requesting users are making, so raw `W_sigma`
  is the honest thing to give them.
- **`W_sigma * sqrt(χ²_red)`** is what most people implicitly expect, and is more forgiving of
  mis-scaled uncertainties — but it silently launders a bad uncertainty estimate into a
  plausible-looking error bar, which is the failure mode worth avoiding.

**Recommendation: store and report raw `W_sigma`**, matching what Unified fit, Fractals and
Guinier-Porod already do (consistency across Irena matters more than the choice itself), **and
always print reduced χ² next to the uncertainties in the notebook**, with a one-line note that
the uncertainties are only meaningful if χ²_red ≈ 1 and that the user can scale by
`sqrt(χ²_red)` if their uncertainties are known to be mis-scaled.

`AchievedChisq` is already stored (l. 2002) as raw `V_chisq`; the reduced value needs
`numpnts(IntWvForFit) - numpnts(W_coef)` degrees of freedom, both available at that point.
Consider storing `AchievedChisqReduced` as a new global — useful independently of this feature.

Second-order caveat worth one sentence in the help text: fitting *near a constraint boundary*
(which Modeling does routinely — see the "limits may have been reached" warning at l. 1990)
invalidates the linear error estimate. The existing `LimitsReached` warning already fires in that
case; when `UseLSQFitErrors` is on, the warning should also say the reported uncertainties for
those parameters are unreliable.

---

## 5. Verification for step 1 (Modeling)

Do these before calling it done. There is no unit-test harness in the repo, so these are manual.

1. **Compile clean.** All of Irena, not just Modeling.
2. **Variable-creation audit.** With the tool open, run a scratch function that walks
   `ListOfPopulationVariablesSD/DP/UF/FR`, and for every non-`Fit`/`Min`/`Max`/`Error` entry
   asserts a matching `…Error_popN` exists. Catches typos in §3.2. Also assert the reverse: every
   `ErrorCoefName[i]` produced by a real fit resolves to an existing global.
3. **Switch off (default).** Fit a two-population model. Confirm graph tags, notebook and output
   waves are **byte-identical** to `main` except for the new `…Error_popN` output-wave columns.
   This is the "do not break existing users" check.
4. **Switch on.** Same fit. Confirm `+/-` appears only on fitted parameters, that fixed
   parameters show no `+/-`, and that the numbers match `W_sigma` printed by hand.
5. **Cross-check against Unified fit.** Set up a single Unified level in Modeling and the same
   level in the Unified fit tool on the same data with the same Q range and fitted parameters.
   The uncertainties should agree closely. This is the strongest correctness check available and
   it is cheap.
6. **Reverse fit.** Fit, then "Reverse fit" → confirm all `…Error_popN` are back to 0 and no
   `+/-` shows.
7. **Failed fit.** Force a fit error → confirm errors are zero, no stale values.
8. **Genetic optimization.** Confirm it does not crash, errors stay 0, and the history note prints.
9. **Multiple data sets.** `MultipleInputData` with 3 sets → confirm `BackgErr_setN` is populated
   per set and the output waves have consistent lengths.
10. **Old experiment.** Open a pre-change saved experiment → confirm the version prompt fires and
    the tool works after restart, and also that declining the restart does not crash.
11. **Prefs compatibility.** With an existing `IrenaNikaDefaultPanelControls.bin` from `main`,
    confirm no "Old version of GUI and Graph Fonts" alert and that `UseLSQFitErrors` reads 0.
    Then toggle, quit Igor, relaunch, confirm it persisted.
12. **Analyze uncertainties.** Run a ConfEv scan before and after the change → identical results.

---

## 6. Rollout to the other tools

Ordered by value/effort. Each is a separate commit after Modeling ships and is validated.

### 6.1 Unified fit — `IR1_UnifiedFitPanel.ipf`, `IR1_UnifiedFitFncts.ipf`
**Already fully implemented; needs gating and a display upgrade, not new plumbing.**

- Error variables: exist (panel l. 173–202). Zeroing: exists (`IR1A_SetErrorsToZero()`, panel
  l. 424, called at fncts l. 390, 492, 6499). Population: exists
  (`IR1A_RecordErrorsAfterFit()`, fncts l. 6668). Notebook: exists (l. 7504–7544, 7624–7664),
  currently **ungated** — it prints `+/-` whether or not the user wants it.
- **Work:** (a) gate the notebook `+/-` on `IN2G_UseLSQFitErrors()`; (b) add `+/-` to the
  **graph tag** (currently absent), gated the same way; (c) print reduced χ² alongside.
- **Risk:** low. **Caution:** gating the notebook changes existing output for users who like it.
  Consider gating as `IN2G_UseLSQFitErrors() || <already-present>` — or simply leave the notebook
  ungated and gate only the new tag output. Decide with users.
- Do **not** touch `IR1A_ConfidenceEvaluation()` / `IR1A_ConfEv*` (fncts l. 4701–5602).

### 6.2 Guinier-Porod — `IR3_GuinierPorodModel.ipf`
**Complete. This is the reference implementation.**

- **Work:** only add the `IN2G_UseLSQFitErrors()` gate to the tag builder (l. 1930–1999) if
  consistency is wanted. Arguably leave alone entirely — it already does the right thing and
  guards on `Error > 0`.
- **Risk:** near zero. Lowest priority.

### 6.3 Fractals — `IR1_Fractals.ipf`
**Storage complete, display missing.**

- Error variables and `IR1V_SetErrorsToZero()` (l. 2331) / `IR1V_RecordErrorsAfterFit()` (l. 2772)
  all exist. Nothing surfaces them.
- **Work:** add gated `+/-` to the graph tag and results notebook. Mirrors §3.6 b/c exactly.
- **Risk:** low.

### 6.4 Simple fits — `IR3_SimpleFits.ipf`
**No named globals; `W_sigma` is read locally in each of ~6 fit routines
(l. 1292, 1349, 1604, 1630, 1678, 1709, 1845, 1879, 1946, 1986).**

- The fits are small (2–3 coefficients each: Guinier I0/Rg, Porod, etc.) and the results already
  go into a tag built right there (`TagText` at l. 1355+).
- **Work:** append `+/- W_sigma[n]` to the existing tag strings, gated. No new globals needed —
  `W_sigma` is in scope at each site. This makes Simple fits arguably the **easiest** of all and a
  good candidate to do *second*, right after Modeling, as a quick win.
- Note the deliberate `/W=OriginalDataErrorWave /I=1` weighting — same §4 caveat applies.
- **Risk:** low, but there are many near-duplicate call sites; a shared formatting helper is worth
  writing here.

### 6.5 System specific models — `IR3_SystemSpecificModels.ipf`
**Partially implemented via a matrix rather than globals.**

- Errors go into `TempParam[…][4]`, labelled `"FitError"` in `WaveParamsValues` (l. 1304), and
  are populated at l. 1831–1839. `SASBackgroundError` exists (l. 1268). A pile of commented-out
  `…Error` list entries (l. 1272–1292) suggests an abandoned earlier attempt — read those before
  writing anything.
- **Work:** find where the panel/notebook renders `TempParam` and add a gated `+/-` column or
  suffix. Verify the zeroing path exists (not confirmed in this survey).
- **Risk:** medium — the matrix layout is less obvious than the globals pattern and the
  commented-out code hints at a reason it was left unfinished. Budget investigation time.

### 6.6 Ellipsoid/Cylinder — `IR3_EllipsoidCylinderMain.ipf`
Same `TempParam[…][4]` scheme as 6.5 (l. 1551–1559), including `BackgroundError`. Do it together
with 6.5 or right after, sharing whatever helper 6.5 needs.

### 6.7 Reflectivity — `IR2_Reflectivity.ipf`
Has `IR2R_SetErrorsToZero()` (l. 729, called l. 718). Not surveyed further. Check whether
population and display exist; likely a small gap.

### 6.8 Analytical models (Gels) — `IR2_AnalyticalModels.ipf`
Populates errors from `W_sigma` at l. 2471–2510. Not surveyed further. Likely display-only work.

### 6.9 Explicitly untouched

- `IR2L_AnalyzeUncertainities()` / `IR2L_ConfEv*` (Modeling) and
  `IR1A_ConfidenceEvaluation()` / `IR1A_ConfEv*` (Unified fit) — the χ²-surface confidence
  evaluation. Better method, unrelated code path, no interaction. **Do not modify.**
- `IR1_Sizes.ipf` (size distribution / MaxEnt) — different uncertainty treatment entirely.
- `IR3_WAXSDiffraction.ipf` — uses MultiPeakFit2's own `W_sigma_N` waves; already handled by that
  package.
- `IR1_Desmearing.ipf` — already prints `+/-` from `W_sigma` (l. 1370) in its own context.

---

## 7. Suggested commit sequence

1. `IN2_GeneralProcedures.ipf`: global, prefs struct slot, save/read, checkbox,
   `IN2G_UseLSQFitErrors()`. Verify §5.11 in isolation — prefs compatibility is the one thing that
   affects every Irena/Nika/Indra user, so it should land and bake on its own.
2. Modeling: `IR2L_Initialize()` variables + `IR2L_SetErrorsToZero()`. No behaviour change yet.
3. Modeling: `ErrorCoefName` in `IR2L_Fitting()` + `IR2L_RecordErrorsAfterFit()` + reset-on-bad-fit.
   Values now populated, still nothing displayed. Verify §5.2/5.5 here.
4. Modeling: reporting — output waves, notebook, logbook, graph tags. Version bump to 1.26.
5. Reduced χ² storage + notebook note (§4).
6. Simple fits (§6.4) — quick win, validates that the global switch generalises.
7. Everything else in §6, one commit each.

---

## 8. Open questions for Jan

1. **Naming:** `VolumeError_pop1` (consistent with Modeling's own `VolumeFit_pop1`) vs
   `Volume_pop1Error` (literal match to how Unified fit/Fractals build the name). Plan assumes the
   former — confirm.
2. **Raw `W_sigma` vs `W_sigma * sqrt(χ²_red)`** (§4). Plan assumes raw + report χ²_red.
3. **Gate storage or only display?** Plan assumes always store, gate display only.
4. **Unified fit already prints `+/-` in the notebook, ungated** (§6.1). Should the new switch turn
   that *off* when unchecked — changing behaviour users have today — or should the switch only ever
   *add* output?
5. **Output-wave columns** for `…Error_popN` — always written (plan's assumption, keeps wave lengths
   stable) or only when the switch is on?
6. Graph tags with uncertainties get long (§3.6b). Full set, or primary parameters only?
