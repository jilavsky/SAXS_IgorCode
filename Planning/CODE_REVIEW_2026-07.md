# Code Review — July 2026

Scope: current-generation code only — `IR2_*`, `IR3_*`, `IRB1_*` (Irena), `IN4_*` (Indra 2),
`NI1_*` (Nika), plus shared `IN2_GeneralProcedures.ipf`. Legacy `Indra/` and `IR1_*` files were
excluded by request. This document is a planning artifact: no code was changed. Each item lists
file, location, evidence, and suggested fix. Line numbers refer to the working tree as of
2026-07-09 (HEAD = 1944c29).

Note: this repo has had prior AI-assisted review passes (2026-05-04 deferred-TODO blocks in nine
file headers; Nika 2.79/2.80; IN4 0.9). This review consolidates what is still outstanding and
adds new findings — including one regression introduced *by* a prior cleanup pass (item 1.1).

---

## Priority 1 — Bugs (fix before next release)

> **STATUS 2026-07-09: All Priority 1 items fixed in the working tree (items 1.1–1.5; 1.5 partially,
> see its status note). Not yet compiled/tested in Igor — pending user verification. Version
> pragmas/changelog headers of edited files were intentionally NOT bumped; do that at release.**
> Edited files: `IN4_Calculations.ipf`, `IR2_DataMiner.ipf`, `IR3_MergingData.ipf`.

### 1.1 `SetDataFolder saveDF` vs `DFREF oldDf` mismatch in IN4_Calculations.ipf — REGRESSION — ✅ FIXED 2026-07-09

**File:** `User Procedures/Indra 2/IN4_Calculations.ipf`
**Introduced by:** commit `382ca47` ("AI cleanup and minor bug fixes"). That commit added missing
data-folder restores — a good intent — but wrote them as `SetDataFolder saveDF` while the saved
reference in each function is declared `DFREF oldDf`. It even replaced three previously *correct*
`setDataFolder oldDf` lines with `SetDataFolder saveDF`.

Since no local `saveDF` exists, Igor treats `saveDF` as a literal subfolder name at runtime.
With `#pragma rtFunctionErrors=1` (set in this file) every one of these lines throws a runtime
error, and the current data folder is never restored.

**Affected functions (14 sites, 10 functions; a 15th occurrence at line 1200 is inside the fully
commented-out `IN4_ReplaceNaNs` and was left alone):**

| Function | Restore line(s) |
|---|---|
| `IN4_CalculateRWaveIntensity` | 152 |
| `IN4_calculateR_Qvec` | 181, 197 |
| `IN4_FitModGaussTop` | 320 |
| `IN4_CopyBlankAndCorrectTransm` | 390 |
| `IN4_SubtractSampleAndBlank` | 480, 484 |
| `IN4_FindQminForUSAXS` | 585 |
| `IN4_DesmearData` | 609, 634, 652 |
| `IN4_RebinDataIfNeeded` | 1098 |
| `IN4_CopyUSAXSToFolder` | 1168 |
| `IN4_SmoothRData` | 1286 |

**Fix applied:** replaced `SetDataFolder saveDF` with `SetDataFolder oldDf` at all 14 sites. The
three functions that correctly declare `DFREF saveDF` (restore lines 725, 929, 1017) were verified
untouched. Post-fix scan of the whole current-gen tree found zero remaining mismatches.

**Process lesson:** bulk automated edits should be followed by a full recompile in Igor before
committing. Consider a pre-commit smoke test (open Igor, compile all procedure files).

### 1.2 `SetDataFolder oldDf` with no `oldDf` declared — IR2_DataMiner.ipf — ✅ FIXED 2026-07-09

**File:** `User Procedures/Irena/IR2_DataMiner.ipf`, `static Function/S IR3B_FindSpecificMetadata`
(~line 601–618). The error path does:

```igor
DoAlert/T="Incorrectly defined data type" 0, "..."
SetDataFolder oldDf     // oldDf never declared in this function
abort
```

The function never changes the data folder, so the `SetDataFolder` is both broken and unnecessary.
**Fix applied:** deleted the `SetDataFolder oldDf` line. (Note: the similar-looking block in
`IR3B_ExtrMtdtFromOneFolder` is correct — that function declares `DFREF OldDf` — and was not touched.)

### 1.3 Copy-paste bug in merge optimizer start value — IR3_MergingData.ipf — ✅ FIXED 2026-07-09

**File:** `User Procedures/Irena/IR3_MergingData.ipf`, line 2483, branch
`VaryQ1shift && !VaryQ2shift && Optim_Data1Background && !Optim_Data2IntMultiplier` (D1Q + Background):

```igor
Optimize/Q/X={highQDifference, Data2Qshift + 0.0001}/... IR3D_FindMergeValuesQ1Backg, ...
```

This branch optimizes **Data1**Qshift but seeds the optimizer with **Data2**Qshift. Should be
`Data1Qshift + 0.0001` (compare with the sibling D1Q branches at ~2444 and ~2472).
**Fix applied:** changed seed to `Data1Qshift + 0.0001`.

### 1.4 Malformed Optimize call in background-only branch — IR3_MergingData.ipf — ✅ FIXED 2026-07-09

**File:** same file, line 2526:

```igor
Optimize/Q/M={3, 0}/X={HighQBckgMin}/TSA={0, 0.2}/M={3, 0} IR3D_FindMergeValuesBackg, ...
```

Three problems: `/M={3,0}` appears twice; the start value is `HighQBckgMin` (always 0) instead of
the `highQDifference` estimate used by every sibling branch; and unlike siblings it has no
`/XSA` bounds and no `/Y=(ValueEst)`. Review whether this branch was ever exercised/tested.
**Fix applied:** rebuilt the call to mirror the one-parameter sibling branches: single `/M={3,0}`,
seed `/X={highQDifference}`, added `Make/O/N=(1,1) XLimitWave = {{HighQBckgMin}, {HighQBckgMax}}`
with `/XSA=XLimitWave`, `/Y=(ValueEst)`, and `/R={highQDifference}`. **Test this branch
specifically** (merge with only "background" optimization enabled) — it likely never worked before.

### 1.5 No error handling after `Optimize` calls — IR3_MergingData.ipf — ✅ FIXED (minimal) 2026-07-09

All `Optimize` calls in `IR3D_MergeDataOverlap` immediately did `WAVE W_Extremum` + indexing with
no success check. If Optimize fails, `W_Extremum` may be missing → opaque runtime abort. The
`KillWaves TempIntCombined` calls also lacked `/Z`.

**Fix applied (deliberately minimal, behavior-preserving on the success path):**

- After each multi-parameter `Optimize` (10 branches): `WAVE W_Extremum` → `WAVE/Z W_Extremum`
  followed by a `WaveExists` guard that restores `saveDF` and aborts with a clear user message.
- All `KillWaves TempIntCombined` → `KillWaves/Z TempIntCombined` (11 sites).
- The scale-only branch reads `V_minloc` (per its own comment, one-parameter optimize may run
  univariate and not create `W_Extremum`), so its unused `WAVE W_Extremum` line was removed
  instead of guarded — a guard there could false-abort a working path.

**Deferred (follow-up, not a bug):** consolidating the eleven nearly identical branches into a
shared helper (~120 duplicated lines) and checking `V_OptTermCode` for convergence quality.
Post-fix sanity checks: if/endif balanced (27/27), 10 guards present, 0 unguarded KillWaves.

---

## Priority 2 — Robustness / correctness risks

### 2.1 Precision loss: results stored with `num2str` (6 digits)

Fit results are persisted into wave notes via `num2str()`, which formats to ~6 significant
digits. Example — `IR3_GuinierPorodModel.ipf` lines 2149–2180 store every parameter, error, and
background this way; the same pattern exists across IR3 tools and Nika metadata. These notes are
the canonical record: they are re-read by the GUI ("recover parameters"), exported to NXcanSAS,
and consumed by pyIrena. Round-tripping loses precision (e.g., background `1.234567e-5` vs the
fitted double).

`IN2G_num2StrFull()` (IN2_GeneralProcedures.ipf, from Jon Tischler) already exists for exactly
this but is used only twice in the whole repo.

**Fix:** sweep result-persistence call sites (`IN2G_AppendorReplaceWaveNote(..., num2str(x))`) and
switch numeric *values* to `IN2G_num2StrFull` or `num2str(x, "%.15g")`-style formatting. Keep
`num2str` for display strings, tags, and folder/wave name construction (there it is correct).

### 2.2 `rtFunctionErrors=1` only in 2 of ~50 current-gen files

Only `IR3_DataManipulationIII.ipf` and `IN4_Calculations.ipf` set `#pragma rtFunctionErrors=1`.
The rest silently continue past runtime errors, which hides bugs like 1.1–1.2 for years.
**Fix:** roll it out file by file (one file per release cycle), fixing what it flags. Suggested
order: IN4_* (instrument code, already 1/3 done) → IR3_* → NI1_* → IR2_*.

### 2.3 Bare WAVE/NVAR/SVAR declarations (known, deferred backlog)

The 2026-05-04 review deferred hardening of bare `Wave`/`NVAR`/`SVAR` references (crash with an
opaque error if a tool's init did not run, e.g. when driven from scripting). Representative
counts of bare NVAR/SVAR per file: IR3_SimpleFits 323, IR3_GuinierPorodModel 321, IR3_MergingData
259, IR3_ImportData 234, IR3_3DModels 213, IR3_MultiDataPlot 204. Files carrying explicit
deferred-TODO blocks in their headers:

- `IR3_SimpleFits.ipf` — bare Wave declarations in IR3J_CreateLinearizedData, IR3J_Fit* functions
- `IR3_SystemSpecificModels.ipf` — ~50 bare Wave declarations on package paths
- `IR2_StructureFactors.ipf` — abort paths in IR2S_MakeSFParamPanel skip DF restore (~293, ~300)
- `IR2_Reflectivity.ipf`, `IR2_ScriptingTool.ipf`, `IR2_SmallAngleDiffraction.ipf` — Proc/Window
  → Function conversions (see 3.1)
- plus IR1_Desmearing, IR1_DataManipulation, IR1_EvaluationGraph (legacy, out of scope here)

**Fix strategy:** don't do a blind /Z sweep (a bare declaration at least fails loudly; `/Z`
without a `WaveExists` check fails later and more confusingly). Instead: add `/Z` + explicit
existence check + user-facing abort message in functions reachable from scripting/menus before
init; leave hot inner loops alone.

### 2.4 Wave-existence assumptions in IN4_CalculateRWaveIntensity

`IN4_Calculations.ipf` lines 33–46: `WAVE/Z AmpGain … UPD_array` are declared with `/Z` but then
used unconditionally (`Duplicate/O UPD_array, USAXS_PD`). If the HDF5 import layout changes (this
already differs between DDPCA300 setups — the code comments "assume we are using DDPCA300 for
now"), the failure is an unhelpful runtime error mid-function. Add a guard that names the missing
wave and the folder. Same function: the 15 repeated `NumberByKey("DDPCA300_gainN"...)` blocks
(self-described in a comment as "this is stupid...") should be a 5-iteration loop, and each
`NumberByKey` result should be NaN-checked — a missing metadata key currently propagates NaN
silently into PD_Intensity.

### 2.5 Ad-hoc uncertainty scaling in IN4

`IN4_Calculations.ipf` line ~147: `PD_error = SigmaRwave / 5  // 2025-04 these values are simply
too large on new APS-U USAXS instrument`. A hard-coded ÷5 on reported uncertainties is a
scientific-results issue, not just style: it changes chi-squared of every downstream fit and is
invisible to users. Recommend: promote to a named constant with documentation, record the factor
in the wave note / NXcanSAS metadata so processed files are self-describing, and revisit the
error model (the comment itself says the instrument side needs work; see also the dark-current
TODO at line 118).

---

## Priority 3 — Modernization (aligns with existing deferred TODOs)

### 3.1 Retire `Execute()` — 149 call sites in current-gen Irena/Nika

Top offenders: `IR2_PanelCntrlProcs.ipf` (40), `IR2_ModelingMain.ipf` (20), `NI1_ConvProc.ipf`
(11), `IR2_SmallAngleDiffraction.ipf` (11), `IR2_Reflectivity.ipf` (10). Three recurring patterns,
all mechanically replaceable:

1. `Execute("SetVariable X disable=0, win=" + TopPanel)` → `SetVariable X, win=$TopPanel, disable=0`
   (direct `win=$str` has been supported for many Igor versions).
2. `Execute("PopupMenu X mode=1, value=\"...\"+Fnct(...), win=" + Panel)` → direct PopupMenu with
   `value=#stringExpr` or a rebuilt string — removes fragile quote escaping.
3. `Execute("ModifyGraph ... rgb(trace)=" + rgbString)` (IR2_ModelingMain 1209–1216) → parse the
   stored rgb string once and call ModifyGraph directly.

The remaining hard cases are `Execute("SomeWindowMacro()")` where the target is still a
`Window`/`Proc` declaration — those are the conversions already queued in the 2026-05-04 TODO
blocks (IR2R_*, IR2S_ScriptingToolPnl, IR2D_*). Converting them to `Function : Panel` unlocks
DFREF use and removes the Execute. `Macro`/`Proc` counts remaining in current-gen: IR2_AnalyticalModels 4,
IR2_Reflectivity 3, IR2_PDDF 1, IR2_PlotingToolII 1, IR2_SmallAngleDiffraction 1,
IR3_WAXSDiffraction 1, NI1_SaveRecallConfig 1 (repo rule: no Macro in new code).

### 3.2 String-based DF save/restore → DFREF

`GetDataFolder(1)` save/restore survives mainly in IR2_ and Nika: IR2_PDDF (21), IR2_DataMiner
(19), NI1_ConvProc (16), IR2_ModelingSupport (10), NI1_InstrumentSupport (9). IR3_ files are
already mostly converted (IR3_HDF5Browser has 57 DFREF uses). Mechanical modernization; do it
opportunistically when touching these files. Caution after item 1.1: convert one function at a
time and recompile.

### 3.3 Missing `IgorVersion` pragma in 14 IR3 files

The suite requires Igor 9.04 (loaders and IN4/NI1 declare it), but most IR3_ files don't:
3DModels, 3DSupportFunctions, 3DTwoPhaseSolid, AnalyzeResults2, Anisotropy, EllipsoidCylinderMain,
EllipsoidCylinderSupport, GuinierPorodModel, MergingData, MultiDataPlot, SimpleFits,
SystemSpecificModels, WAXSDiffraction, and DataManipulationIII (which has rtFunctionErrors but no
IgorVersion). Users on Igor 8 get confusing compile errors instead of a clear version message.
One-line fix per file: `#pragma IgorVersion = 9.04`. Also standardize `TextEncoding` (2 IR3 files
lack it) and `DefaultTab`.

### 3.4 Threading opportunities

`IN4_SmearDataFastFunc` is already `threadsafe` + MultiThread — good template. Candidates worth
profiling before investing: NI1_ConvProc main conversion loop (0 threadsafe functions in 8372
lines; per-pixel corrections are embarrassingly parallel where MatrixOP isn't already used) and
IR3_3DModels voxel calculations. Only pursue if profiling shows they matter; Igor built-ins are
already internally threaded for much of this.

---

## Priority 4 — Hygiene and documentation

### 4.1 Ten "fix me!!" help-link placeholders

`IN2G_OpenWebManual` calls marked `//fix me!!` point at wrong or placeholder anchors — e.g.,
`IR3_DataManipulationIII.ipf:323` opens `bioSAXS.html#basic-fits` from the Data Manipulation
tool, `IN4_MainCode.ipf:768` opens `Indra/ImportData.html`. Full list (10 sites):
IRB1_EvaluationTools:408, IRB1_bioSAXS:308/755/2021, IR3_DataManipulationIII:323,
IR3_SimpleFits:976, IR3_EllipsoidCylinderMain:772 (commented out), IR3_AnalyzeResults2:263,
IR3_SystemSpecificModels:841, IN4_MainCode:768. Quick pass against the current online manual;
half are probably correct already and just need the marker removed.

### 4.2 Inline TODO backlog worth triaging into issues

- `IN4_SupportCode.ipf:217, 730` — sample-name sanitization ("TODO: sanitize properly sample name
  here to make it Igor friendly"). Real failure mode with user-named samples containing Igor
  liberal-name characters; recommend a shared `IN2G_SanitizeSampleName()` used at both sites.
- `IN4_SupportCode.ipf:166, 188` — commented-out `IN4_SaveSWAXSDataInNexus` calls (feature stub).
- `IN4_Calculations.ipf:118` — I0 dark current per gain not recorded (instrument-side work).
- `IN4_Calculations.ipf:465` — meaningful-range selection heuristic.
- `IR3_3DModels.ipf:953` — verify VoxelSize/NumRSteps are set correctly.
- `IR3_EllipsoidCylinderSupport.ipf:358` — smearing of Unified fit model not implemented.
- `IR3_MultiDataPlot.ipf:1816–1817` — `//fixme` on Graph3D checkbox wiring.
- `NI1_InstrumentSupport.ipf:2506, 2992` — missing error handling; PE detector branch aborts with
  "Fix me".
- `IRB1_EvaluationTools.ipf:670` — record processing steps in wave note.

### 4.3 Repository hygiene

- `.DS_Store` files are tracked in git (`Igor Procedures/`, `User Procedures/CanSAS/`,
  `User Procedures/Nika/`). Add to `.gitignore` and `git rm --cached`.
- Duplicate/legacy files shipped inside current package folders: `Nika/mar345.ipf` vs
  `Nika/NI1_mar345.ipf`; `Indra 2/IonChamber3.1.ipf` and `IonChamber3.3.ipf` (two versions);
  `Indra 2/spec.ipf`; `Irena/DWS_GeneralGraph.ipf(+Controls)` duplicated in `Old unused/`.
  Decide which are dead and move them to `Old unused/` (or delete — git history preserves them).
- `User Procedures/Old unused/` (38 ipf files) ships with the installer folder tree — confirm the
  installer excludes it; if not, exclude.
- Test/data files mixed with code: `Indra 2/IN2_Test file.dat`, `Indra 2 test.pxp`. Consider a
  `tests/` or `ExampleIgorExperiments/` home.

### 4.4 Version-number consistency

`#pragma version` and the panel-version `Constant` drift apart (e.g., IR3_SimpleFits pragma 1.18
vs `IR3JversionNumber = 1.16`; IN4_MainCode pragma 0.9 "placeholder" vs `IN4_mainPanelVersion =
0.7`). If intentional (file version vs panel version), a one-line comment at each constant would
prevent future confusion; if not, sync them when releasing.

---

## Process recommendations

1. **Compile gate after bulk edits.** Item 1.1 shipped in a release-adjacent commit and would have
   been caught by a single compile. A minimal checklist before committing sweeping edits: open a
   fresh Igor instance, load each package (Irena, Indra2, Nika), confirm compile, open main panels.
2. **Adopt the existing conventions doc.** CLAUDE.md rules (no Macro, no Execute where avoidable,
   globals under `root:Packages:`, ≤650 px panels) are already largely followed in IR3/IN4 —
   current-gen scan found no oversized panels and no duplicate non-static function names. The
   remaining violations are concentrated in IR2_ files; fold 3.1/3.2 into any planned IR2 work.
3. **Unit tests for pure numeric functions.** Functions like `IN4_SmearDataFastFunc`,
   `IN4_GetErrors`, rebinnning, and the `IR3D_FindMergeValues*` family are pure and testable with
   the igortest framework — a small suite would have caught 1.3/1.4.
4. **Track this document.** Suggest converting Priority 1 items into individual commits with the
   item number in the message (e.g., "Fix 1.1: restore oldDf in IN4_Calculations"), then checking
   items off here.

---

## Verification notes

- Item 1.1 verified against git history: `git diff 382ca47^ 382ca47` shows the `saveDF` lines
  being added/substituted; parent commit had `setDataFolder oldDf` (correct) in 3 places and no
  restore in the others.
- Items 1.2–1.4 verified by reading the functions in full.
- Repo-wide scan for the item-1.1 pattern (SetDataFolder with an undeclared bare name) found only
  the sites listed in 1.1/1.2; other hits (IR2P_ReturnListQRSFolders, IR2D_DWSFixAxesInGraph,
  ZapNonLetterNumStart, etc.) are false positives — variables declared in comma-separated lists.
- Counts (Execute sites, NVAR/SVAR, DFREF usage, missing pragmas) are from ripgrep over the
  working tree and are approximate where noted.
