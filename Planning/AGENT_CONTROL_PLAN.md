# Plan — Driving Indra / Irena / Nika from AI agents via the Igor Pro MCP Server

Status: planning + first steps (2026-11-26). Low urgency. Policy: **pyIrena / Matilda are the
primary agent-facing tools** (cross-platform, own MCP). The Igor path is a *last option* for
users who live in Igor experiments or need an Igor-only tool. Implement cheap things now; do the
expensive things only when someone asks.

## 1. Context

- Igor Pro 10.05+ ships an MCP server (`igor-mcp-server.exe`): execute commands, call
  functions, compile/open procedures, list/capture windows, report "busy / waiting for dialog",
  stop a running call, get help, start/quit Igor.
- **Windows only.** macOS is not expected. Works under CrossOver on macOS (tested from Aida):
  `wine --bottle IgorPro10 --cx-app C:\users\crossover\AppData\Local\Programs\WaveMetrics\Igor Pro MCP Server\igor-mcp-server.exe`.
- Generic Igor skill already exists: `IgorPro-skills/mcp skills/igor-pro` (syntax, graphs,
  manual mirror). Package-specific knowledge is the gap.
- Igor runs code from the **SVN working copy** (`~/Igor Pro SVN/trunk`), not from this repo.
  Edit and debug in SVN, sync to GitHub afterwards.

## 2. Why agents fail today

| Problem | Evidence | Effect on an agent |
|---|---|---|
| No discoverable entry points | Menu text "Load USAXS" is built at runtime by `IndraMacrosMenuItem()`; the function is `LoadUSAXS()` | Agent searches for "USAXS macros" and gives up |
| Modal dialogs | ~430 `DoAlert`, ~160 `DoPrompt`, some `PauseForUser` across Irena/Nika/Indra | MCP call blocks until a human clicks; agent stalls |
| `Abort` everywhere | ~1100 `Abort` calls | Probably comes back as an error string (needs verifying, T3 below); fine if so |
| Q range comes from graph cursors | ~330 `pcsr`/`csrInfo` uses in Irena | Agent must place cursors with `Cursor/P/W=...` |
| Inputs are panel globals | `root:Packages:<tool>:*` + symbolic paths | Agent must know global names; panel must exist so the globals exist |
| Control procs take STRUCTs | e.g. `IR2C_PanelPopupControl(STRUCT WMPopupAction &)` | Can't be called from the command line; set the SVARs directly instead |
| `Execute/P` loading | `LoadUSAXS()` queues INSERTINCLUDE + COMPILE | Returns before code exists; agent must wait/poll |

Existing assets that help:
- **IN4 (Indra 4)** reduction is a chain of folder-string functions (`IN4_ProcessSelectedData`,
  `IN4_ProcessOneUSAXSScan`, …) with **no DoAlert/DoPrompt** on the Igor-code branch. Close to
  agent-ready.
- **Scripting tool** has dialog-free button variants: Unified `DrawGraphsSkipDialogs`,
  `DoFittingSkipReset`, `CopyTFolderNoQuestions`; Sizes `GraphIfAllowedSkipRecover`,
  `DoFittingSkipReset`, `SaveDataNoQuestions`; Modeling `FitModelSkipDialogs`, …
- Precedent for "skip dialogs when automated": Unified checks `GetRTStackInfo` for the scripting
  tool before its limits-reached `DoAlert` (14 `GetRTStackInfo` uses in total).

## 3. Layers, cost, and what is done now

Effort = Jan's time with AI assistance, including testing in Igor through MCP.

### L0 — Agent skill (package knowledge)  · ~1–2 days · **started now**
Folder `IgorPro-skills/irena-mcp-skills/irena-igor/`. Covers: loading packages, folder and wave
naming, USAXS reduction recipe (IN4), import (ASCII / NXcanSAS), Unified fit and Size
distribution recipes via the SkipDialogs paths, where results land, and a list of known
dialog traps. No code changes. Works today for the happy path; fragile on error paths.

### L1 — Agent-mode dialog wrappers  · **revised after testing: the core task**

Testing (section 5) confirmed that dialogs are the blocker. Decision (Jan, 2026-11-26): all
DoAlert/DoPrompt/warnings get wrappers that do not trip in agent mode and give feedback instead.

Census of live code (comments excluded, SVN trunk, 2026-11-26):

| Package | DoAlert info (type 0) | DoAlert yes/no (1/2) | DoPrompt | PauseForUser | file opens* |
|---|---|---|---|---|---|
| Irena | 150 | 99 | 56 | 7 | 26 |
| Nika | 40 | 23 | 26 | 1 | 56 |
| Indra 2 | 23 | 21 | 44 | 3 | 27 |
| CanSAS | 1 | 3 | 0 | 0 | 5 |
| **Total** | **214** | **146** | **126** | **11** | **~114** |

*HDF5OpenFile / LoadWave / ImageLoad / Open/R. These show an Open-File dialog when the file is
missing (verified for HDF5OpenFile, even with /Z). Only sites where the name comes from user input
need a guard.

Design (IN2_GeneralProcedures.ipf, shared by all three packages):
- `IN2G_SetAgentMode(on)` / `IN2G_AgentMode()`: flag `root:Packages:AgentMode`. The agent sets it
  first (the skill says so). Igor cannot tell whether a call came through MCP, so an explicit flag is needed.
- `IN2G_Alert(type, msg [, title, agentAnswer])` returns 1/2/3 like V_flag. Normal mode: DoAlert/T.
  Agent mode: no dialog. Print `AGENT_ALERT <title>: <msg> -> <answer>` and append the message to a
  text wave `root:Packages:AgentMode:Messages`. Return `agentAnswer` (default 1 = OK/Yes; each
  yes/no site chooses the *safe* answer, e.g. "overwrite? → No").
- `IN2G_AgentMessages(clear)` returns the collected messages: the agent's feedback channel.
- DoPrompt sites: `if(IN2G_AgentMode())` keep current values and log; `else Prompt…; DoPrompt…`.
  Per-site edits; each site decides whether the current values are an acceptable default or whether
  it must Abort with "set <global> first".
- PauseForUser: skip in agent mode.
- Folder pickers (`NewPath` without a path): in agent mode Abort "set path <name> first".
- File opens: `IN2G_FileExists(pathName, fileName)` guard, then Abort with a clear message.
- `Abort` stays as it is. It comes back to the agent as an error with history (verified).

Effort (with AI assistance + review):
| Work | Est. |
|---|---|
| Wrapper functions + agent-mode flag + message log | 0.5 d |
| 214 info DoAlerts (mostly mechanical replace) | 1 d |
| 146 yes/no DoAlerts (choose the safe default per site) | 2–3 d |
| 126 DoPrompts (per-site logic) | 2–3 d |
| PauseForUser, folder pickers, file-open guards | 1–2 d |
| MCP regression run (T1–T6 per package) + fixes | 2–3 d |
| **Total** | **~2–2.5 weeks**, phased: Indra → Irena (import, Unified, Sizes first) → rest of Irena → Nika |

Each phase is useful on its own: the agent-mode flag is harmless when off.

#### Original L1 notes (kept for reference)
1. Global agent-mode flag, e.g. `root:Packages:AgentMode` (variable 1/0) plus
   `IN2G_AgentMode()` returning it.
2. `IN2G_Alert(msg)` / `IN2G_AskYesNo(msg, default)` wrappers: in agent mode they print to
   history (prefix `AGENT:`) and return the default; otherwise they behave as DoAlert.
3. Replace only the dialogs on the priority paths (IN4 main, IR3I import, Unified, Sizes):
   roughly 15–25 call sites. Extend the existing `GetRTStackInfo` checks to also honor agent mode.
4. Make PauseForUser sites (Unified fit-control dialog) honor agent mode
   (equivalent to `SkipFitControlDialog=1`).
5. `IN2G_LoadPackages(list)` that loads synchronously enough for an agent, or documents the
   poll (`exists("IN4_Main")==6`).

Converting *all* ~600 dialogs is weeks of work. **Not planned.**

### L2 — Thin agent API (`IRA_AgentAPI.ipf`)  · ~0.5–1 day per wrapper
Functions with explicit parameters returning a JSON or key=value string (`status`, `message`,
output folders/waves, key results). Discovery mirrors the pyIrena MCP: `IRA_ListTools()`,
`IRA_DescribeTool(name)`.

| Wrapper | Builds on | Est. |
|---|---|---|
| `IRA_ReduceUSAXS(dataPath, sampleList, blank, inclSAXS, inclWAXS)` | IN4_Init + globals + IN4_ProcessSelectedData | 0.5 d |
| `IRA_ImportNXcanSAS(path, files)` / `IRA_ImportASCII(...)` | NEXUS_NXcanSASDataReader / IR3I_* | 0.5–1 d |
| `IRA_DescribeData(folder)` (Q range, points, units, type) | wave notes | 0.5 d |
| `IRA_UnifiedFit(folder, qmin, qmax, nLevels, params…)` | Unified SkipDialogs path, cursors set from qmin/qmax | 1 d |
| `IRA_SizeDistribution(folder, qmin, qmax, method, shape, rmin, rmax, …)` | Sizes SkipDialogs path | 0.5–1 d |
| `IRA_PlotData(folders, graphName)` | Display/AppendToGraph | 0.5 d |
| Each further Irena tool | varies; Modeling II is the hard one (3–5 d) | — |

### L3 — Docs and regression  · ~1–2 days
"Using Igor packages from AI agents" page in the restructured RTD manuals (pointing to pyIrena
first). Small test experiment plus a checklist an agent runs through MCP (T1–T6 below).

**Revised totals:** L0 (done, tested) + L1 phase Indra+Irena priority tools (~1 week) gives usable
reduction/import/Unified/Sizes. All L1 phases: ~2–2.5 weeks. L2 is then optional: with
wrappers in place, the skill recipes may be enough, and thin API functions only add convenience.

## 4. Phase 1 (now)

- [x] Code survey and this plan.
- [x] Bug fix (SVN `trunk/Igor Procedures/Boot Indra2.ipf`): `LoadUSAXSAndIrena()` and
      `LoadUSAXSIrenaandNika()` called the non-existent `LoadUSAXSMacros()`; now call `LoadUSAXS()`.
      Not yet synced to GitHub. (Both Procs are obsolete anyway: `IN2_Load Indra 2.ipf` already
      `#include`s NI1_Loader and IR1_Loader.)
- [x] Draft skill `IgorPro-skills/irena-mcp-skills/irena-igor/`.
- [x] Igor MCP connected (Claude desktop local MCP via CrossOver); T1–T5 run, results in section 5.
- [x] Test results folded into the skill. L1 is needed (decided).
- [ ] T6 Sizes; L1 phase 1 (wrappers in IN2G + Indra sites).

## 5. Test plan and results (through MCP, CrossOver Igor; run 2026-11-26)

Results:
- **T1 Load: PASS.** `LoadUSAXS()` → everything compiled by the next call.
- **T2 USAXS: PARTIAL.** Import mode (`RecalcNexusData=0`) works: 2 samples in ~0.07 s, full set of
  R/BL/SMR/DSM waves, graphs fine. Recalculation from raw **fails on FX4 data** (Larry, 2026-10):
  the IN4 Igor reader knows only the DDPCA300/mca 12-ID-E layout ("Loading /entry/flyScan/mca1
  failed", then "expected wave name"). The FX4 port to Indra is not in SVN trunk.
- **T3 Errors: MIXED.** Runtime errors come back cleanly with history. A missing blank file opened
  the "Open HDF5 File" dialog → blocked until Jan closed it.
- **T4 Import: PASS.** NXcanSAS direct reader works. ASCII works once `DataPathName` and
  `FoundNWaves` are set. Without `FoundNWaves`: "Import waves problem" DoAlert (blocked).
- **T5 Unified: RUNS, NOT AGENT-SAFE.** Three fits, three blocking alerts (twice limits-reached,
  once "B limits set incorrectly"). Fit values were sensible (G = 3977 ± 17, Rg = 875 ± 2 Å).
- **T6 Sizes: not run** (stopped to avoid more dialogs while Jan was away).
- Cosmetic: the IN4 USAXS_DSM_data legend colors do not match the traces.
- MCP transport: two calls timed out in transport (140 s) without reaching Igor. Never send
  dependent calls in parallel.

Original checklist:

- T1 Load: `LoadUSAXS()` → poll until `exists("IN4_Main")==6`; check `WinList` / menus.
- T2 USAXS reduction: one sample + blank via IN4 globals + `IN4_ProcessSelectedData`; check
  `root:USAXS:<sample>:DSM_Int` etc.; capture `USAXS_DSM_data`.
- T3 Error path: a bad file name → confirm that an `Abort` comes back as an MCP error (does not hang).
- T4 Import: one NXcanSAS and one ASCII file → `root:ImportedData:SAXS:<name>`.
- T5 Unified 1-level fit on reduced data with qmin/qmax → results saved (`UnifiedFitIntensity_N`).
  Watch for the limits-reached DoAlert (blocks when called from the command line).
- T6 Size distribution (spheroid, MaxEnt or TNNLS) → `SizesVolumeDistribution_N`.

## 6. Other findings (not fixed)

- `IR1_UnifiedFitPanel.ipf` ~line 209–210: `ListOfStrings = "DataFolderName;…"` is
  immediately overwritten by `ListOfStrings = "ConfEv…"` (should be `+=`). Probably harmless
  because the data-selection controls create those strings, but it is a bug.
- `IN4_ProcessSelectedData` declares `SVAR extensionStr = root:Packages:Indra4:DataSelListBoxExtString`,
  which is created by the panel controls. Headless use without opening `IN4_Main()` may fail.
  Recipe: always open the panel first.
- Unified `DoAlert` "limits may have been reached" fires unless the caller stack contains
  `IR2S_ButtonProc` / `IR1A_ConEvEvaluateParameter`. Agent calls will block → L1 item 3.
- Unified `PauseForUser IR1A_CheckFittingParams` unless `SkipFitControlDialog=1`.

## 7. Open decisions

- ~~FX4 raw-data reduction in Igor IN4~~ → **Resolved 2026-11-26:** the port was overlooked and is
  pending. Jan is adding it to the issues as high priority (it affects all users with new data, not
  only agents). Update `usaxs-reduction.md` in the skill once the port is done.

- Distribute the skill with the Igor installer once it is proven? (Later.)
- Agent-mode flag name and location (`root:Packages:AgentMode` proposed).
- Whether L2 returns JSON (better for agents) or Igor keyword=value lists (simpler in Igor).
