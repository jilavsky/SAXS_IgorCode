# SAXS_IgorCode — Project Instructions

This is the only Igor Pro package still maintained. All Igor Pro conventions
live here; `~/.claude/CLAUDE.md` is loaded automatically and is not imported.

## Igor Pro environment

- Igor Pro 10, 64-bit only. Never suggest 32-bit XOP patterns.
- Target `#pragma IgorVersion=9.04` or higher unless told otherwise.
- Header block for every new `.ipf` file, plus a version history block:
  ```igor
  #pragma TextEncoding = "UTF-8"
  #pragma rtGlobals=3
  #pragma DefaultTab={3,20,4}
  #pragma IgorVersion=9.04
  ```

### Waves and data folders — critical

- NEVER use a wave name inside a function without a `WAVE` declaration.
- ALWAYS use `WAVE/Z` when a wave may not exist, then check `WaveExists()`.
- ALWAYS save and restore the current data folder:
  `DFREF saveDF = GetDataFolderDFR()` … `SetDataFolder saveDF`.
- NEVER build a path mid-expression — build the string first, apply `$` once.
  - WRONG: `WAVE w = root:myData:$name`
  - CORRECT: `WAVE w = $("root:myData:" + name)` or `WAVE w = dfr:$name`
- Prefer `DFREF` parameters over string paths in function signatures.
- Use `Make/FREE` for temporary waves inside functions.

### Igor 10 compiler breaking changes

- Unreachable code before a `case` label in `switch`/`strswitch` is a compile ERROR.
- `#pragma independentModule=ProcGlobal` is a compile ERROR.
- `ExperimentModified` is NOT triggered by same-value assignments.

### Panel geometry — critical

- ALWAYS call `PauseUpdate` as the first line of any panel-building function.
- ALWAYS use a running `yPos` accumulator — never hardcode y coordinates.
- ALWAYS compute panel height before `NewPanel` by summing control heights + gaps.
  - Title area ~45px; control row 22–25px; section subtitle ~28px; bottom margin ~30px.
  - Add 10% headroom — a slightly tall panel beats clipped controls.
- Control heights: Button 20–22px, CheckBox 14px, SetVariable 18–23px, PopupMenu 21px.
- Gaps: 5px between controls, 12px between sections. Left margin 5px.
- Panel width: 430px single-column, 640px two-column. Never exceed 650px.
- Title style: `font="Times New Roman"`, `fstyle=3`, `fColor=(0,0,52224)`, `frame=0`.
- Decorative line: `TitleBox FakeLine1, title=" ", labelBack=(0,0,52224), size={width,3}`.
- GetHelp button: red `fColor=(65535,32768,32768)`, 80×15, top-right.
- Primary action button: green `fColor=(32768,65535,49386)`, ~200×22.
- Add `help={"..."}` to every control.
- See `/igor-panel` for the full geometry reference and a worked example.

### Command lookup

Never guess a command's flags, syntax or output variables. Fetch
`https://docs.wavemetrics.com/igorpro/commands/<commandname-lowercase>`
(index: https://docs.wavemetrics.com/igorpro/commands).

### General Igor style

- `Function` not `Macro` for all new code; `Static Function` for internal helpers.
- Package globals go in `root:Packages:<PackageName>:`.
- Use `#pragma moduleName` to namespace modules.
- Use `Printf` not `Print` for formatted output.

## Igor ↔ Python bridge

The `igorpro` module (Igor 10 only) drives Igor from Python:
`igorpro.fn.<functionname>()` to call an Igor function, `wave.asarray()` to
convert an Igor wave to a numpy array. See `/igor-python`.

## Repository overview

This is the Irena/Indra suite of Igor Pro packages for SAXS/USAXS/WAXS data
reduction and analysis, developed at the APS beamline 12-ID, Argonne National
Laboratory.

**Key packages:**
- `Irena/` — Main SAXS analysis suite (IR3_* files are current generation)
- `Indra 2/` — USAXS instrument data reduction (IN4_* files are current)
- `Nika/` — 2D detector data reduction
- `Indra/` — Legacy USAXS reduction (do not add new features here)

**File naming conventions:**
- `IR3_*.ipf` — Current Irena tools (generation 3)
- `IR2_*.ipf` — Irena shared infrastructure (controls, data handling)
- `IR1_*.ipf` — Irena legacy tools (still maintained)
- `IN4_*.ipf` — Current Indra4 tools
- `ING2_*.ipf` — Shared Indra/Irena utilities

**Global data folder structure:**
- `root:Packages:<PackageName>:` — all package globals
- `root:SAS:` — imported SAXS data
- `root:WAXS:` — imported WAXS data
- Irena packages use `root:Packages:Irena<ToolName>:` pattern

## Key shared infrastructure — use these, don't reinvent

| Function | Purpose |
|---|---|
| `IR3C_AddDataControls(...)` | Standard file list + data selection controls |
| `IR1_UpdatePanelVersionNumber(panelName, version, 1)` | Panel version tracking |
| `IR1_CheckPanelVersionNumber(panelName, version)` | Version check on open |
| `ING2_AddScrollControl()` | Add scroll to tall panels |
| `IN2G_CheckScreenSize("height", 900)` | Screen size guard |

Always call `IR1_UpdatePanelVersionNumber` at the end of panel creation.
Always call `ING2_AddScrollControl()` after panel creation for tall panels.

## Panel and window naming conventions

- Panel names: `<Prefix>_<ToolName>Panel` or `<Prefix>_<ToolName>Data`
  - e.g. `IN4_DataReductionPanel`, `IR3I_ImportData`
- Button proc names: `<Prefix>_ButtonProc`
- CheckBox proc names: `<Prefix>_CheckProc`
- PopupMenu proc names: `<Prefix>_PopMenuProc`
- Always check `DoWindow <PanelName>` before creating; bring to front if exists.

Standard panel entry point pattern:
```igor
Function MyTool_Main()
    KillWindow/Z MyTool_Panel
    DoWindow MyTool_Panel
    if(V_Flag)
        DoWindow/F MyTool_Panel
    else
        MyTool_Init()
        MyTool_PanelFnct()
        ING2_AddScrollControl()
        IR1_UpdatePanelVersionNumber("MyTool_Panel", MyToolVersion, 1)
    endif
End
```

## Control visibility pattern

Use a dedicated `_DisplayCorrectControls()` function — never kill/recreate controls.
Call it from CheckBox and PopupMenu procs when state changes.

```igor
Function MyTool_DisplayCorrectControls()
    NVAR someFlag = root:Packages:MyPkg:someFlag
    SetVariable MyControl win=MyTool_Panel, disable=(!someFlag)
    // disable=0: visible; disable=1: hidden+space; disable=2: grayed
End
```

## Constant declarations

Panel version numbers are always `Constant`, not `Variable`:
```igor
Constant MyTool_PanelVersion = 1.0
```

## Skills available

For detailed reference, invoke these skills in Claude Code:

- `/igor-commands` — full list of 1060+ built-in Igor commands with doc links
- `/igor-panel` — panel geometry reference, control sizes, yPos pattern, full example
- `/igor-wave-dfref` — WAVE/DFREF/NVAR/SVAR reference syntax, patterns, pitfalls
- `/igor-10` — Igor Pro 10 new features and breaking changes

## What NOT to do in this repo

- Do NOT use `Macro` — use `Function` for all new code.
- Do NOT add features to `Indra/` (legacy) — use `Indra 2/` (IN4_*).
- Do NOT store package globals outside `root:Packages:`.
- Do NOT use `Execute` to run commands if a direct function call is possible.
- Do NOT hardcode y-coordinates in panels — use the yPos accumulator pattern.
- Do NOT create panels wider than 650px (fits standard screen layouts).
