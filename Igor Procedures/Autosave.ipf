#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma Version=1.1        
//#pragma independentModule = HOBIAutoSave


// 2019-08-13, JIL, changed to use File menu on WIndows also, seems to work. 
// 2011-3-30 DRD
//#pragma rtGlobals=1     // Use modern global access method.

//--------------------------------------------------------------------------
// Implements automatic background saving or copying of the current experiment file.
// Places a dynamic auto-save item in the file menu.  When auto-save is not already active,
// the auto-save command opens a dialog for selecting the period and mode.  When it is active,
// the text of the menu item shows how much time remains before the next save.
// 
// Mode is either overwrite, meaning each save replaces the existing experiment file, or copy,
// meaning a new copy is created each time, or reminder, which just puts up an alert box.
//  Note that in copy mode, files that are not included in the packed experiment file will NOT be backed up. 
//  In copy mode, each copy of the file has a sequence number appended to its name.
//
// This creates a data folder that holds just two settings, the mode and the count value used to auto-name
// files in backup mode.  The period and status of the background task are stored by Igor's background
// scheduler.
//
// David Dana, 2011/3/30
// modified by JIL 2019/08/13
//--------------------------------------------------------------------------
//#ifdef WINDOWS
//    Menu "Data", dynamic
//        "-"
//        ASMenuItem(), /Q, ASMenuAction()
//    End Menu
//#else
Menu "File", dynamic
     "-"
     ASMenuItem(), /Q, ASMenuAction()
End Menu
//#endif

Constant kOverwriteMode = 1
Constant kBackupMode = 2
Constant kRemindMode = 3
StrConstant ASSettingsFolder = "root:Packages:HOBIAutoSave"

//--------------------------------------------------------------------------
//  Returns a string for the Auto-save menu item.  The text of the menu item depends on the status of the
//  background task.
//--------------------------------------------------------------------------
Function/S ASMenuItem()
    if (ASIsActive())   // If it's active, display the amount of time remaining before the next save
        variable remaining = ASSecondsRemaining()
        string remainingStr
        if (remaining > 60)
            remaining = round(remaining/60)
            remainingStr = "in " + num2str(remaining) + " min"
        else
            remainingStr = "in " + num2str(round(remaining)) + " sec"
        endif
        string menuStr
        if (ASMode() == kBackupMode)
            menuStr = CheckMark() + "Auto-Backup "
        elseif (ASMode() == kRemindMode)
            menuStr = CheckMark() + "Auto-Remind "
        else
            menuStr =  CheckMark() + "Auto-Save "
        endif
        return menuStr + remainingStr
    else
        return "Auto-Save..."
    endif
End Menu
//--------------------------------------------------------------------------

//--------------------------------------------------------------------------
//  This is called when the menu item is selected.  Depending on whether the background task is running,
//  either stops it or asks the user to set it up
//--------------------------------------------------------------------------
Function ASMenuAction()
    GetLastUserMenuInfo
    if (ASIsActive())
        ASStop()
    else
        ASSetup()
    endif
End Function
//--------------------------------------------------------------------------

//--------------------------------------------------------------------------
//  Stops the background task
//--------------------------------------------------------------------------
Function ASStop()
    CtrlNamedBackground AutoSave, stop
End Function
//--------------------------------------------------------------------------

//--------------------------------------------------------------------------
//  Starts the background task, with the given period in minutes
//--------------------------------------------------------------------------
Function ASStart(minutes)
variable minutes

    if (minutes < 1)
        minutes = 1
    endif
    CtrlNamedBackground AutoSave, proc=ASTask, dialogsOK = 0, burst = 0
    CtrlNamedBackground AutoSave, period=minutes*3600
    CtrlNamedBackground AutoSave, start=ticks+minutes*3600
End Function
//--------------------------------------------------------------------------

//--------------------------------------------------------------------------
//  Background task that does the actual work.  Taks a WMBackgroundStruct, as required for any named
//  background task, but doesn't use it.  This routine must also return 0; nonzero tells Igor to halt the
//  taks.
//--------------------------------------------------------------------------
Function ASTask(s)
STRUCT WMBackgroundStruct &s        // required by Igor but unused

        // First check whether a save is even necessary
    ExperimentModified      // this only works in overwrite mode; saving a copy doesn't change the "modified" status
    if (v_flag == 0)        // the experiment is unmodified; no need to save
        return 0
    endif

    if (ASMode() == kOverwriteMode)
        print "Auto-saving " + time()   // print in history
        SaveExperiment
    elseif (ASMode() == kBackupMode)
        ASSetBackupCount(ASBackupCount() + 1)
        string newName = IgorInfo(1) + "_" + Num2Str(ASBackupCount())
        print "Auto-saving \"" + newName + "\",", time()    // print in history
        SaveExperiment/C/P=home as newName
    else
        ASRemind()
    endif
    return 0
End Function
//--------------------------------------------------------------------------

//--------------------------------------------------------------------------
//  Handles the setup and user input necessary to start auto-save.
//--------------------------------------------------------------------------
Function ASSetup()
    
    PathInfo home       // First check whether the experiment has previously been saved
    if (v_flag == 0)    // the home path doesn't exist; the experiment has never been saved
        DoAlert 1, "To use auto-save, you must first give the experiment a name and location.  Save it now?"
        if (v_flag != 1)        // 1 = yes clicked
            return 0
        endif
        SaveExperiment      // will prompt user for name and location
        PathInfo home
        if (v_flag == 0)    // still not saved; user must have cancelled
            DoAlert 0, "Auto-save cancelled."
            return 0
        endif
    endif
    
    // Prepare to get user input
    CtrlNamedBackground AutoSave, status        // Find the current period setting of the task
    variable period = NumberByKey ("PERIOD", s_info) / 3600
    if (period < 1) // not yet initialized
        period = 10 
    endif
    // put the period into a user-readable string, with units.  This string should match one of the choices in the popup
    // menu below, so that the popup will appear with the current setting selected
    string perStr
    if (period > 1)
        perStr = num2str(period) + " minutes"
    else
        perStr = num2str(period) + " minute"
    endif
    // Make and display a simple dialog with popup menus display the period and mode choices
    Prompt perStr, "Auto-save Interval", popup "1 minute;2 minutes;5 minutes;10 minutes;30 minutes;60 minutes;120 minutes"
    variable mode = ASMode()
    Prompt mode, "Replace,  copy, or show reminders?", popup "Replace original with each save;Make new backup copy with each save;Do not save, only show reminders"
    DoPrompt/HELP="Note that in copy mode, notebooks, procedures and other files that are separate from the experiment file will not be backed up." "Auto-save Settings", perStr, mode
    if (v_flag == 1)    // cancel was clicked; never mind
        ASStop()
        return 0
    endif
    ASSetMode(mode)
    period = str2num(perStr)
    ASStart(period)     // start the task
    return period
End Function
//--------------------------------------------------------------------------

//--------------------------------------------------------------------------
//  Returns a reference to the data folder containing the auto-save settings.  If it doesn't yet exist, creates
//  it.  The actual name of the folder is contained in a string constant defined at the top of the file
//--------------------------------------------------------------------------
Function/DF ASSettingsFolder()
    DFREF dfr = $ASSettingsFolder
    if (DataFolderRefStatus (dfr) == 0)
        NewDataFolder/O root:Packages
        NewDataFolder/O $ASSettingsFolder
        dfr = $ASSettingsFolder
        Variable/G dfr:SaveMode = kOverwriteMode
        Variable/G dfr:BackupCount      // Igor will initialize to zero, or leave alone if it already exists
    endif
    dfr = $ASSettingsFolder
    return dfr
End Function
//--------------------------------------------------------------------------


//--------------------------------------------------------------------------
// Returns the two-character prefix for a checked menu item
//--------------------------------------------------------------------------
Function/S Checkmark()
    return "!" + Num2Char(18)
End Function
//--------------------------------------------------------------------------

//--------------------------------------------------------------------------
//  Returns 1 if the background task is running, 0 if not
//--------------------------------------------------------------------------
Function ASIsActive()
    CtrlNamedBackground AutoSave, status
    if (stringmatch(s_info, "*RUN:1*"))
        return 1
    else
        return 0
    endif
End Function
//--------------------------------------------------------------------------


//--------------------------------------------------------------------------
//  Returns number of seconds remaining before the background task next runs.  Answer is meaningless if
//  task isn't running (most likely negative)
//--------------------------------------------------------------------------
Function ASSecondsRemaining()
    variable remaining
    CtrlNamedBackground AutoSave, status
    remaining = NumberByKey ("NEXT", s_info) - ticks
    remaining /= 60
    return remaining
End Function
//--------------------------------------------------------------------------

//--------------------------------------------------------------------------
//  Returns value of the mode variable stored in the auto-save folder
//--------------------------------------------------------------------------
Function ASMode()
    DFREF dfr = ASSettingsFolder()
    NVAR mode = dfr:SaveMode
    return mode
End Function
//--------------------------------------------------------------------------


//--------------------------------------------------------------------------
//  Sets the value of the mode variable stored in the auto-save folder, and returns its new value
//--------------------------------------------------------------------------
Function ASSetMode(newmode)
variable newMode

    DFREF dfr = ASSettingsFolder()
    NVAR mode = dfr:SaveMode
    mode = newmode
    return mode
End Function
//--------------------------------------------------------------------------


//--------------------------------------------------------------------------
//  Returns the value of the backup count variable stored in the auto-save folder.  This is used for naming
//  multiple backup files.
//--------------------------------------------------------------------------
Function ASBackupCount()
    DFREF dfr = ASSettingsFolder()
    NVAR count = dfr:BackupCount
    return count
End Function
//--------------------------------------------------------------------------


//--------------------------------------------------------------------------
//  Sets the value of the backup count variable stored in the auto-save folder, and returns its new value
//--------------------------------------------------------------------------
Function ASSetBackupCount(newCount)
variable newcount

    DFREF dfr = ASSettingsFolder()
    NVAR count = dfr:BackupCount
    count = newCount
    return count
End Function
//--------------------------------------------------------------------------


//--------------------------------------------------------------------------
//  Display a small non-modal reminder window.  User can dismiss it and also turn off future reminders
//--------------------------------------------------------------------------
Function ASRemind()
    if (WinType("ASReminderPanel") == 7)
        DoWindow/F ASReminderPanel
    else
        NewPanel /k=1/W=(84,77,366,174)/N=ASReminderPanel  as "Reminder" 
        ModifyPanel fixedSize=1
        TitleBox title0,pos={47,15},size={184,16},title="Remember to save your work"
        TitleBox title0,font="Lucida Grande",fSize=13,frame=0
        Button OKButton,pos={21,52},size={70,22},title="OK"
        Button StopButton,pos={109,52},size={150,22},title="Stop Reminders" 
        Button OKButton, proc=ASRemind_OKProc
        Button StopButton,proc=ASRemind_StopProc
    endif
    beep
    return 0
End Function


Function ASRemind_OKProc(ctrlName) : ButtonControl
    String ctrlName
    DoWindow/K ASReminderPanel 
End

Function ASRemind_StopProc(ctrlName) : ButtonControl
    String ctrlName
    ASStop()
    DoWindow/K ASReminderPanel 
End
//--------------------------------------------------------------------------