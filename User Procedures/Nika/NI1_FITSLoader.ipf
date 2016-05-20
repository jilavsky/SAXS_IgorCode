#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=2.17
#include <Autosize Images>

//2.17 fixed bug when data in Extension 2 of some FITS files with long and complicated bintable (Extension 1) were not read. 
// version 2.16 JIL - modified for Nika needs
// FITS Loader Version 2.15; For use with Igor Pro 4.0 or later
//	Larry Hutchinson, WaveMetrics inc., 1-19-02
// Version 2.15  151029
//		Added capability to import multiple HDUs from FITS file.
//			Dave Schlossberg, Univ. of Wisconsin, schlossberg@wisc.edu
// Version 2.14, 100316
//		Added MyCleanupFitsFolderName routine.
// Version 2.13, 081127
//		Fix endian problem on Intel Mac
//	Version 2.12
//		Fix for boolean variables.
//	Version 2.11:
//		Fix wave name conflict in BINTABLE load
//		Added support for ascii in BINTABLE.  
//	Version 2.1:
//		Support for multi-row BINTABLE extension.
//	Version 2.0:
//		Support for BINTABLE extension (but only kind where all data is packed into 1 row).
//		Eliminated keyword list in favor of reading ALL keywords into variables.
//	Version 2.0 (beta prior to 8-3):
//		Can now use the fits load routine as a subroutine in a user written procedure. See LoadOneFITS below.
//		Can now specify a list of keywords to suck out of the header. (removed 000807)
//		See FITS Loader Demo example experiment for examples of use including making movies.
//		This version does not create a menu item because the standard WMMenus.ipf file includes one in the
//			Data->Load Waves->Packages menu.  If you would like to have a menu that brings up the
//			panel, copy the commented-out Menu definition below into your procedure window and
//			remove the comment chars.
//	Version 1.02 differs from 1.01 in the use of the /K flag with NewPanel
//		This flag causes the need for 3.11B01.
//		Other changes made include changing of function names to avoid conflict with user names
//	Version 1.01 differs from 1.0 only in the use of FBinRead/B=2 to force bigendian
//		under Windows. This flag causes the need for 3.1.
//
//	This code is intended to be a starting point for a user supported astro package.
//	Documentation is provided in an example experiment named 'FITS Loader Demo'


Function/S NI1_ReadFITSFIleFormat3(PathName, FileName)
	string PathName, FileName
	//using modified and fixe Wavemetrics load
	//extended by community to be able to read primary data and multiple HUD, 
	//some of the instrument store data in HUD 'IMAGE' so we need to find the right data... 
	String OldDf=getDataFOlder(1)	
	KillDataFolder/Z root:Packages:Nika_FITS_Import
	NewDataFolder/O/S root:Packages:Nika_FITS_Import
	variable i, RefNum
	open /R/P=$(PathName) RefNum as FileName
	FStatus refnum
	//print "FITS Load from",S_fileName
	NI1_LoadOneFITS(refnum,S_fileName,1,1,1,0,0,1e12)
	close RefNum
	SVAR LatestImportedData			//contains string with name of recently imported FITS data.
	//next deal with the header information and convert it to more useful Igor form
	SVAR AllHeaderInfoAsString = $("root:Packages:Nika_FITS_Import:"+possiblyquotename(LatestImportedData)+":AllHeaderInfoAsString")
	AllHeaderInfoAsString = ReplaceString("  ", AllHeaderInfoAsString, "")
	//done - this is next wave note... 
	//print AllHeaderInfoAsString
	//Next find the data. Data should be in Primary location, but in some cases may be in Extension location. 
	//assume we are looking for sufficiently lareg image, so let's check what we have
	setDataFolder $(LatestImportedData)
	string ListOfFolders = DataFolderDir(1)
	ListOfFolders = IN2G_ConvertDataDirToList(ListOfFolders)
	string DataFoundPath=""
	string CurrentFldr=GetDataFolder(1)
	variable DataFound=0
	For(i=0;i<ItemsInList(ListOfFolders);i+=1)
		//print CurrentFldr+stringFromList(i,ListOfFolders)+":data"
		Wave/Z data = $(CurrentFldr+stringFromList(i, ListOfFolders)+":data")
		if(WaveExists(data))
			if(dimsize(data,0)>20 && dimsize(data,1)>20 && dimsize(data,2)<1 && dimsize(data,3)<1 )
				print "Found 2D data ("+num2str(dimsize(data,0))+","+num2str(dimsize(data,1))+") in file "+LatestImportedData+" in location "+stringFromList(i, ListOfFolders)+":data"
				DataFound = 1
				DataFoundPath = CurrentFldr+stringFromList(i, ListOfFolders)+":data"
			endif
		endif
	endfor
	if(!DataFound)
		DoAlert /T="Data not located" 0, "2D data were not located on this FITS file, please send example to ilavsky@aps.anl.gov so I can fit the loader"
		abort 
	endif
	Wave DataWv = $(DataFoundPath)
	Note /NOCR DataWv ,AllHeaderInfoAsString 
	setDataFolder OldDf
	return DataFoundPath
end

//Menu "Macros"
//	"FITS Loader Panel",CreateFITSLoader()
//End


//Function NI1_CreateFITSLoader()
//	DoWindow/F NI1_FITSPanel
//	if( V_Flag != 0 )
//		return 0
//	endif
//	
//
//	NI1_DoFITSPanel()
//end
//	


//Static Function NI1_LoadFITS()
//	Variable doHeader= NumVarOrDefault("root:Packages:Nika_FITS:wantHeader",1)			// set true to put header(s) in a notebook
//	Variable doHistory= NumVarOrDefault("root:Packages:Nika_FITS:wantHistory",0)			// set true to put HISTORY in the notebook
//	Variable doComment= NumVarOrDefault("root:Packages:Nika_FITS:wantComments",0)		// ditto for COMMENT
//	Variable doAutoDisp= NumVarOrDefault("root:Packages:Nika_FITS:wantAutoDisplay",0)	// true to display data
//	Variable doInt2Float= NumVarOrDefault("root:Packages:Nika_FITS:promoteInts",1)		// true convert ints to floats
//	Variable bigBytes= NumVarOrDefault("root:Packages:Nika_FITS:askifSize",0)				// if data exceeds this size, ask permission to load  
//	
//	Variable refnum
//	String path= StrVarOrDefault("root:Packages:Nika_FITS:thePath","")
//	if( CmpStr(path,"_current_")==0 )
//		Open/R/T="????" refnum
//	else
//		Open/R/P=$path/T="????" refnum
//	endif
//	if( refnum==0 )
//		return 0
//	endif
//	
//	FStatus refnum
//	print "FITS Load from",S_fileName
//	NI1_LoadOneFITS(refnum,S_fileName,doHeader,doHistory,doComment,doAutoDisp,doInt2Float,bigBytes)
//	Close refnum
//end

// LH100316: added this to fix file names that are too large to be used as a datafolder name.
// You can create your own algorithm (perhaps putting up a dialog for the user) by creating an Override function
// in your main procedure window. Execute DisplayHelpTopic "Function Overrides" for more info.
//Static Function/S NI1_MyCleanupFitsFolderName(nameIn)
//	String nameIn
//	
//	return CleanupName(nameIn,1)
//End
//


// LH991101: rewrote to make this routine independent of the panel so it can be called as a
// subroutine from a user written procedure.
//
static Function NI1_LoadOneFITS(refnum,dfName,doHeader,doHistory,doComment,doAutoDisp,doInt2Float,bigBytes)
	Variable refnum
	String dfName				// data folder name for results -- may be file name if desired
	Variable doHeader			// set true to put header(s) in a notebook
	Variable doHistory			// set true to put HISTORY in the notebook
	Variable doComment			// ditto for COMMENT
	Variable doAutoDisp			// true to display data
	Variable doInt2Float			// true convert ints to floats
	Variable bigBytes			// if data exceeds this size, ask permission to load 
	
	Variable doLogNotebook= doHeader | doHistory | doComment

	FStatus refnum

	String s
	s= PadString("",80,0)
	FBinRead refnum,s
	Variable err= 0
	String errstr=""
	do
		if( CmpStr("SIMPLE  =                    T ",s[0,30]) != 0 )
			errstr="doesn't begin with 'SIMPLE'"
			print s
			err= 1
			break
		endif
		if( mod(V_logEOF,2880) != 0 )
			errstr= "file size is not a multiple of 2880 bytes"
			DoAlert 1,"WARNING: "+errstr+"; Continue anyway?"
			if( V_Flag==2 )
				err= 2
			endif
			break;
		endif
	while(0)
	if( err )
		if( err==1 )
			Abort "Not a FITS file: "+errstr
		endif
		return err
	endif
	
	String nb = ""
//	if( doLogNotebook )
//		nb = CleanupName(dfName,0)
//		NewNotebook/N=$nb/F=1/V=1/W=(5,40,623,337) 
//		Notebook $nb defaultTab=36, statusWidth=238, pageMargins={72,72,72,72}
//		Notebook $nb showRuler=0, rulerUnits=1, updating={1, 60}
//		Notebook $nb newRuler=Normal, justification=0, margins={0,0,576}, spacing={0,0,0}, tabs={}, rulerDefaults={"Monaco",10,0,(0,0,0)}
//		Notebook $nb ruler=Normal
//	endif
	
	String dfSav= GetDataFolder(1)	
	dfName= CleanupName(dfName,1)
	string/G LatestImportedData = dfName
	NewDataFolder/O/S $dfName
	
	String/G AllHeaderInfoAsString=""
	
	String/G NotebookName= nb			// save name for later kill
	String/G GraphName= ""			// place for graph name(s) for later kill
	
	NewDataFolder/O/S Primary
	
	//
	//	Load the primary data
	//
	do
		err= NI1_GetRequired(refnum,nb,doHeader,bigBytes,0)
		if( err )
			errstr= StrVarOrDefault("errorstr","problem reading required parameters")
			break
		endif
		
		err= NI1_GetOptional(refnum,nb, doHeader,doHistory,doComment)
		if( err )
			errstr= StrVarOrDefault("errorstr","problem reading optional parameters")
			break
		endif
		err= NI1_SetFPosToNextRecord(refnum)
		if( err )
			errstr= StrVarOrDefault("errorstr","unexpected end of file")
			break
		endif

		NVAR gSkipData= gSkipData
		NVAR gDataBytes= gDataBytes
		if( gDataBytes != 0 )
			if( gSkipData )
				FStatus refnum
				FSetPos refnum,min(V_filePos+gDataBytes,V_logEOF)
			else
				FBinRead/B=2 refnum,data
				WAVE data
				if(doInt2Float)
					NI1_SetDataProperties(data,doInt2Float)
				else
					NVAR/Z BZERO
					NVAR/Z BSCALE
					if(NVAR_Exists(BZERO)&&NVAR_EXISTS(BSCALE))
						data = BZERO + BSCALE*data[p][q]
					endif
				endif
//				if( doAutoDisp )
//					NI1_AutoDisplayData(data)
//					GraphName= WinName(0, 1)		// for later kill
//				endif
			endif
			NI1_SetFPosToNextRecord(refnum)		// ignore error
		endif
	while(0)
	
	NI1_FITSAppendNB(nb,"*************")
	Variable extension= 0
	if( !err )
		do
			extension += 1
			FStatus refnum
			Variable exStart= V_filePos				// remember this so we can skip extensions we don't understand
			
			if( V_filePos ==  V_logEOF )
				break
			endif
			if( V_logEOF < (V_filePos+2880) )
				NI1_FITSAppendNB(nb,num2str(V_logEOF-V_filePos)+" bytes unread")		// LH991101: used to print to history but that is too much clutter
				break
			endif
			
			NewDataFolder/O/S ::$"Extension"+num2str(extension)
			FBinRead refnum,s
			NI1_FITSAppendNB(nb,s)

			if( CmpStr(s[0,8],"XTENSION=") != 0 )		// ok for extra records to exist after primary and extensions
				break
			endif
		
			String/G XTENSION= NI1_GetFitsString(s)
			if( strlen(XTENSION) == 0 )
				errstr= "XTENSION char string missing"
				err= 1
				break
			endif
			Variable isBinTable= CmpStr("BINTABLE",XTENSION) == 0
			
			if( isBinTable )
				err= NI1_GetRequiredBinTable(refnum,nb,doHeader)	
			else
				err= NI1_GetRequired(refnum,nb,doHeader,bigBytes,0)	// 1 means we don't create a wave	// Change to 0 to create wave DJS 10/29/15
			endif
			if( err  )
				break
			endif

			err= NI1_GetOptional(refnum,nb, doHeader,doHistory,doComment)
			if( err )
				errstr= StrVarOrDefault("errorstr","problem reading optional extension parameters")
				break
			endif
			NI1_SetFPosToNextRecord(refnum)		// ignore error

			if( Exists("PCOUNT") != 2 )
				errstr= "PCOUNT extension param missing"
				err= 1
				break
			endif
			if( Exists("GCOUNT") != 2 )
				errstr= "GCOUNT extension param missing"
				err= 1
				break
			endif
			NVAR PCOUNT,GCOUNT,BITPIX
			NVAR gDataBytes					// doesn't include p or g count
			
			gDataBytes= gDataBytes*8/abs(BITPIX)
			gDataBytes= abs(BITPIX)*GCOUNT*(PCOUNT+gDataBytes)/8	

			FStatus refnum
			Variable exDataStart= V_filePos
			 
			if( isBinTable )
				err= NI1_ReadDataBinTable(refnum,errstr)
				if( err )
					NI1_FITSAppendNB(nb,"***BINTABLE ERROR (did not load data): "+errstr)
					err= 0			// continue with the rest of the file
				endif
			endif

			if( CmpStr("TABLE   ",XTENSION) == 0 )
				NI1_FITSAppendNB(nb,"***Start TABLE data***")
				NVAR NAXIS1,NAXIS2
				String ss= PadString("",NAXIS1,0x20)
				Variable j=1
				do
					if( j>NAXIS2)
						break
					endif
					FBinRead refnum,ss
					NI1_FITSAppendNB(nb,ss)
					j+=1
				while(1)
				NI1_FITSAppendNB(nb,"***End TABLE data***")
			endif
			
			// Read the binary data from the file	!	//DJS 10/29/15
			NVAR/Z gSkipData
			if(!NVAR_Exists(gSkipData))
				variable/g gSkipData
				gSkipData = 1
			endif
			if( gDataBytes != 0 )
				if( gSkipData )
					FStatus refnum
					//FSetPos refnum,min(V_filePos+gDataBytes,V_logEOF)
					if(!isBinTable)				//seems like if we read binatble, we can already moved in the file reading and do not need to skip the gbytes
						FSetPos refnum,min(V_filePos+gDataBytes,V_logEOF)
					endif
				else
					Wave data
					FBinRead/B=2 refnum,data
					//fix the data per standard
					if(doInt2Float)
						NI1_SetDataProperties(data,doInt2Float)
					else
						NVAR/Z BZERO
						NVAR/Z BSCALE
						if(NVAR_Exists(BZERO)&&NVAR_EXISTS(BSCALE))
							data = BZERO + BSCALE*data[p][q]
						endif
					endif
					//
//					if( doAutoDisp )
//						NI1_AutoDisplayData(data)
//						GraphName= WinName(0, 1)		// for later kill
//					endif
				endif
				NI1_SetFPosToNextRecord(refnum)		// ignore error
			endif

			NI1_FITSAppendNB(nb,"*************")
			
			// Stop reading data, move to next record DJS 10/29/15
			
//			Comment this out since do NOT want to skip data DJS 10/29/15
//			FSetPos refnum,min(exDataStart+gDataBytes,V_logEOF)		// skip the data; do something with it later
			NI1_SetFPosToNextRecord(refnum)		// ignore error

		while(1)
	endif
	
	if( err )
		DoAlert 0, errstr
	endif
	
	
	SetDataFolder dfSav
	return err
end


Static Function NI1_ScaleIntData(d,bscale,bzero,blank,blankvalid)
	Variable d,bscale,bzero,blank,blankvalid
	
	if( blankvalid )
		if( d==blank )
			return NaN
		endif
	endif
	return d*bscale+bzero
end


Static Function NI1_SetDataProperties(data,doInt2Float)
	Wave data
	Variable doInt2Float
	
	Variable ndims= WaveDims(data)
	Variable i=1
	do
		if( i>ndims )
			break
		endif
		String ctype= StrVarOrDefault("CTYPE"+num2istr(i),"")
		Variable cref= NumVarOrDefault("CRPIX"+num2istr(i),1)-1
		Variable crval= NumVarOrDefault("CRVAL"+num2istr(i),0)
		Variable cdelt= NumVarOrDefault("CDELT"+num2istr(i),1)
		Variable d0= crval-cref*cdelt
		if( i==1 )
			SetScale/P x,d0,cdelt,ctype,data
		endif
		if( i==2 )
			SetScale/P y,d0,cdelt,ctype,data
		endif
		if( i==3 )
			SetScale/P z,d0,cdelt,ctype,data
		endif
		if( i==4 )
			SetScale/P t,d0,cdelt,ctype,data
		endif
		i+=1
	while(1)
	
	if( Exists("BUNIT")==2 )
		SetScale d,0,0,StrVarOrDefault("BUNIT",""),data
	endif
	
	NVAR BITPIX= BITPIX
	if( (BITPIX > 0) &&  doInt2Float )
		Variable bscale= NumVarOrDefault("BSCALE",1)
		Variable bzero= NumVarOrDefault("BZERO",0)
		Variable blank= NumVarOrDefault("BLANK",0)
		Variable blankvalid= Exists("BLANK")==2
		
		if( BITPIX==32 )
			Redimension/D $"data"		// need double precision to maintian all 32 bits
		else
			Redimension/S $"data"
		endif
		if( (bscale!=1) | (bzero!=0) | blankvalid )
			data=NI1_ScaleIntData(data,bscale,bzero,blank,blankvalid)
		endif
	endif
			
end

//Static Function NI1_AutoDisplayData(data)
//	Wave data
//	
//	Variable ndims= WaveDims(data)
//	if( ndims > 1 )
//		Display;AppendImage data
//		if( DimSize(data, 2) > 3 )
//			Variable/G curPlane
//			ControlBar 22
//			SetVariable setvarPlane,pos={9,2},size={90,17},proc=NI1_FITSSetVarProcPlane,title="plane"
//			SetVariable setvarPlane,format="%d"
//			SetVariable setvarPlane,limits={0,DimSize(data, 2)-1,1},value= curPlane
//		endif
//		DoAutoSizeImage(0,1)
//	else
//		Display data
//	endif
//end
//


Static Function NI1_SetFPosToNextRecord(refnum)
	Variable refnum

	FStatus refnum
	Variable nextRec= ceil(V_filePos/2880)*2880
	if( nextRec != V_filePos )
		if( nextRec >= V_logEOF )
			String/G errorstr= "hit end of file"
			return 1
		endif
		FSetPos refnum,nextRec
	endif
	//print nextRec
	return 0
end	

Function NI1_FITSAppendNB(nb,s)
	String nb
	String s
	
	if( strlen(nb) != 0 )
	//	Notebook $nb,text=s+"\r"
		SVAR/Z AllHeaderInfoAsString= ::AllHeaderInfoAsString
		if(SVAR_Exists(AllHeaderInfoAsString))
			AllHeaderInfoAsString+=s+";"
		endif
	endif
end

Static Function/S NI1_GetFitsString(s)
	String s

	String strVal
	Variable strValValid=0,sp1
	if( char2num(s[10]) == char2num("'") )
		strValValid= 1
		strVal= s[11,79]
		sp1= StrSearch(strVal,"'",0)
		if( sp1<0 )
			strValValid= 0
		else
			strVal= strVal[0,sp1-1]
		endif
	endif
	if( strValValid )
		return strVal
	else
		return ""
	endif
end
	


	
Static Function NI1_GetRequired(refnum,nb,doHeader,bigBytes,noWave)
	Variable refnum
	String nb
	Variable doHeader,bigBytes,noWave
	
	if( !doHeader )
		nb= ""
	endif
	
	String s= PadString("",80,0)
	FBinRead refnum,s
	NI1_FITSAppendNB(nb,s)

	Variable/G BITPIX
	if( CmpStr("BITPIX  = ",s[0,9]) != 0 )
		String/G errorstr= "BITPIX missing"
		return 1
	endif
	BITPIX= str2num(s[10,29])
	Variable numberType
	if( BITPIX== 8 )
		numberType= 8+0x40
	elseif( BITPIX== 16 )
		numberType= 0x10
	elseif( BITPIX== 32 )
		numberType= 0x20
	elseif( BITPIX== -32 )
		numberType= 2
	elseif( BITPIX== -64 )
		numberType= 1
	else
		String/G errorstr= "BITPIX bad value"
		return 1
	endif

	FBinRead refnum,s
	NI1_FITSAppendNB(nb,s)
	Variable/G NAXIS
	if( CmpStr("NAXIS   = ",s[0,9]) != 0 )
		String/G errorstr= "NAXIS missing"
		return 1
	endif
	NAXIS= str2num(s[10,29])
	Variable i=0
	Make/O/N=200 dims=0			// 199 is max possible NAXIS

	Variable/G gDataBytes= abs(BITPIX)/8
	Variable/G gSkipData=0
	if( NAXIS==0 )
		gSkipData= 1				// no primary data
		gDataBytes= 0
	endif

	do
		if( i>=NAXIS )
			break
		endif
		FBinRead refnum,s
		NI1_FITSAppendNB(nb,s)
		String naname= "NAXIS"+num2istr(i+1)
		Variable/G $naname
		NVAR na= $naname
		if( CmpStr(PadString(naname,8,0x20)+"= ",s[0,9]) != 0 )
			String/G errorstr= naname+" missing"
			return 1
		endif
		na= str2num(s[10,29])
		dims[i]= na
		gDataBytes *= na
		i+=1
	while(1)
	Variable trueNDims= NAXIS
	if( (NAXIS > 0)  && (noWave==0) )
		i=NAXIS-1
		do
			if( i<0 )
				break
			endif
			if( dims[i]<=1 )
				dims[i]= 0
				trueNDims -= 1
			else
				break
			endif
			i-=1
		while(1)
		
		if( trueNDims > 4 )
			String/G errorstr= "NAXIS > 4 not supported at present time (could be done with data folders)"
			return 1
		endif
		if( gDataBytes > bigBytes )
			String s1
			sprintf s1,"load big data (%d)?",gDataBytes
			DoAlert 1,s1
			gSkipData= V_Flag!=1
		endif
		if( !gSkipData )
			Make/O/Y=(numberType)/N=(dims[0],dims[1],dims[2],dims[3]) data
		endif
	endif
	KillWaves dims

	return 0
end

Static Function NI1_KWCheck(kw,s8)
	String kw,s8
	
	return CmpStr(PadString(kw,8,0x20),s8) == 0
end

Static  Function/S NI1_StripTrail(s)
	String s
	
	Variable n= strlen(s)-1
	do
		if( (n<0) || (char2num(s[n])!=0x20) )
			break
		endif
		n-=1
	while(1)
	return s[0,n]
end




// read optional header stuff until END or error
// Reads all keywords into variables
//
Static Function NI1_GetOptional(refnum,nb, doHeader,doHistory, doComment)
	Variable refnum
	String nb
	Variable doHeader,doHistory,doComment
	SVAR/Z AllHeaderInfoAsString= ::AllHeaderInfoAsString
	
	
	String s= PadString("",80,0)
	String nbText=""
	do
		FStatus refnum
		if( (V_filePos+80) > V_logEOF )
			String/G errorstr= "hit end of file before END card"
			return 1
		endif
		FBinRead refnum,s
		if( CmpStr("HISTORY",s[0,6]) == 0 )
			if( doHistory )
				nbText += s+"\r"
				if(SVAR_Exists(AllHeaderInfoAsString))
					AllHeaderInfoAsString+=s+";"
				endif
			endif
			continue
		elseif( CmpStr("COMMENT",s[0,6]) == 0 )
			if( doComment )
				nbText += s+"\r"
				if(SVAR_Exists(AllHeaderInfoAsString))
					AllHeaderInfoAsString+=s+";"
				endif
			endif
			continue
		else
			if( doHeader )
				nbText += s+"\r"
				if(SVAR_Exists(AllHeaderInfoAsString))
					AllHeaderInfoAsString+=s+";"
				endif
			endif
		endif
		
		if( CmpStr("END ",s[0,3]) == 0 )		// this is how we exit; Very liberal
			break
		endif
		
		String kw=  NI1_StripTrail(s[0,7])
		String strVal
		Variable strValValid=0,sp1,sp2
		sp1= StrSearch(s,"'",10)
		if( sp1 >= 10 )
			sp2= StrSearch(s,"'",sp1+1)
			if( sp2 > 0 )
				strValValid= 1
				strVal= NI1_StripTrail(s[sp1+1,sp2-1])
			endif
		endif

		Variable val1= str2num(s[10,29])
		String stemp = s[29,29]
		if( numtype(val1) == 2 )        // NaN?
			if( CmpStr(stemp,"T") == 0 )
				val1= 1            // Boolean T
			elseif( CmpStr(stemp,"F") == 0 )
				val1= 0            // Boolean F
			endif
		endif
		Variable hasVal= CmpStr(s[8,9],"= ") == 0

		if( hasVal )
			if( strValValid )
				String/G $kw= strVal
			else
				Variable/G $kw= val1
			endif
		endif
	while(1)

//	if( (strlen(nb)!=0)  && (strlen(nbText)!=0) )
//		Notebook $nb,text=nbText
//	endif
		
	return 0
end



Static Function NI1_GetRequiredBinTable(refnum,nb,doHeader)
	Variable refnum
	String nb
	Variable doHeader
	
	if( !doHeader )
		nb= ""
	endif
	
	String s= PadString("",80,0)
	FBinRead refnum,s
	NI1_FITSAppendNB(nb,s)

	Variable tmp
	if( CmpStr("BITPIX  = ",s[0,9]) != 0 )
		String/G errorstr= "BITPIX missing"
		return 1
	endif
	tmp= str2num(s[10,29])
	if( tmp != 8 )
		String/G errorstr= "BITPIX not 8"
		return 1
	endif
	Variable/G BITPIX=8
	

	FBinRead refnum,s
	NI1_FITSAppendNB(nb,s)
	if( CmpStr("NAXIS   = ",s[0,9]) != 0 )
		String/G errorstr= "NAXIS missing"
		return 1
	endif
	tmp= str2num(s[10,29])
	if( tmp != 2 )
		String/G errorstr= "NAXIS not 2"
		return 1
	endif

	Variable/G gDataBytes= 1
	FBinRead refnum,s
	NI1_FITSAppendNB(nb,s)
	if( CmpStr("NAXIS1  = ",s[0,9]) != 0 )
		String/G errorstr= "NAXIS1  missing"
		return 1
	endif
	Variable/G NAXIS1= str2num(s[10,29])		// bytes per row
	gDataBytes *= NAXIS1

	FBinRead refnum,s
	NI1_FITSAppendNB(nb,s)
	if( CmpStr("NAXIS2  = ",s[0,9]) != 0 )
		String/G errorstr= "NAXIS2  missing"
		return 1
	endif
	Variable/G NAXIS2= str2num(s[10,29])		// rows
	gDataBytes *= NAXIS2

	FBinRead refnum,s
	NI1_FITSAppendNB(nb,s)
	if( CmpStr("PCOUNT  = ",s[0,9]) != 0 )
		String/G errorstr= "PCOUNT  missing"
		return 1
	endif
	Variable/G PCOUNT= str2num(s[10,29])		//Random parameter count 
	
	FBinRead refnum,s
	NI1_FITSAppendNB(nb,s)
	if( CmpStr("GCOUNT  = ",s[0,9]) != 0 )
		String/G errorstr= "GCOUNT  missing"
		return 1
	endif
	Variable/G GCOUNT= str2num(s[10,29])		//Group count
	
	FBinRead refnum,s
	NI1_FITSAppendNB(nb,s)
	if( CmpStr("TFIELDS = ",s[0,9]) != 0 )
		String/G errorstr= "TFIELDS  missing"
		return 1
	endif
	Variable/G TFIELDS= str2num(s[10,29])		//Number of columns

	return 0
end


Static Function NI1_ReadDataBinTable(refnum,errMessage)
	Variable refnum
	String &errMessage

	NVAR NAXIS2
	if( NAXIS2 != 1 )
		return NI1_ReadDataBinTableMultirow(refnum,errMessage)
	endif
	
	Variable i
	for(i=1;;i+=1)
		SVAR/Z tform= $"TFORM"+num2str(i)
		if( !SVAR_Exists(tform) )
			break
		endif
		Variable nType,numpnts,isAscii
		
		numpnts= NI1_ParseTFORM(tform,nType,isAscii)
		if( nType<0 )
			errMessage= "Don't know how to handle BINTABLE with tform= "+tform
			return 1
		endif
		if( numpnts==0 )		// null records are allowed
			continue
		endif
		
		
		String wname= "BTData"+num2str(i)
		Make/O/N=(numpnts)/Y=(nType) $wname
		WAVE data= $wname
		FBinRead/B=2 refnum,data

		SVAR/Z tdim= $"TDIM"+num2str(i)
		if( SVAR_Exists(tdim) )
			Variable dim1,dim2,err
			err= NI1_ParseTDIM(tdim,dim1,dim2)
			if( !err )
				Redimension/N=(dim1,dim2) data
				MatrixTranspose data
			endif
		
		endif
		SVAR/Z tunit= $"TUNIT"+num2str(i)
		if( SVAR_Exists(tunit) )
			SetScale d 0,0,tunit, data
		endif
		// swap if complex?, split mult cols?
		
	endfor
	
	return 0
end

// Returns number of bytes for a given number type
// See /Y flag for Make,Redimension
Static Function NI1_NumSize(ntype)
	Variable ntype
	
	Variable cmult= (ntype&0x01) ? 2 : 1;

	if( ntype&0x40 )
		return 1*cmult
	elseif( ntype &0x10 )
		return 2*cmult
	elseif( (ntype&0x20) || (ntype&0x02) )
		return 4*cmult
	elseif( ntype&0x04 )
		return 8*cmult
	else
		return -1
	endif
End


Static  Function NI1_ReadDataBinTableMultirow(refnum,errMessage)
	Variable refnum
	String &errMessage

	NVAR NAXIS1
	NVAR NAXIS2
	Variable emode= CmpStr( IgorInfo(4 ),"Intel")==0 ? 2 : 1;		// ASSUME: platforms other than Intel are big endian (need better indication). See Redimension's new /E flag for meaning of emode

	
	// read entire data into unsigned byte wave
	Make/B/U/N=(NAXIS1,NAXIS2) bindata
	if( !WaveExists(bindata) )
		errMessage= "not enough memory"
		return 1
	endif
	FBinRead refnum,bindata
	
	// disburse individual columns
	Variable i,colStart=0,colBytes
	for(i=1;;i+=1)
		SVAR/Z tform= $"TFORM"+num2str(i)
		if( !SVAR_Exists(tform) )
			break
		endif
		Variable nType,numpnts,isAscii=0
		
		numpnts= NI1_ParseTFORM(tform,nType,isAscii)
		if( nType<0 )
			errMessage= "Don't know how to handle BINTABLE with tform= "+tform
			return 1
		endif
		if( numpnts==0 )		// null records are allowed
			continue
		endif
		
		colBytes= numpnts*NI1_NumSize(nType)

		String wname= "BTData"+num2str(i)
		SVAR/Z ttype= $"TTYPE"+num2str(i)
		if( SVAR_Exists(ttype) )
			wname= NI1_StripTrail(ttype)
		endif
		if( CheckName(wname, 1) != 0 )
			wname= UniqueName(wname,1,0)
		endif
		
		Duplicate/O/R=[colStart,colStart+colBytes-1] bindata,$wname
		WAVE w= $wname
		if( !WaveExists(w) )
			errMessage= "not enough mem for extract"
			return 1
		endif

		if( isAscii )
			if( NI1_Convert2Text(w,1) )
				errMessage= "couldn't create text version"
				return 1
			endif
		else
			Redimension/E=(emode)/N=(NAXIS2,numpnts==1 ? 0 : numpnts)/Y=(nType) w
			SVAR/Z tunit= $"TUNIT"+num2str(i)
			if( SVAR_Exists(tunit) )
				if( Strlen( NI1_StripTrail(tunit) ) > 0 )
					SetScale d,0,0,NI1_StripTrail(tunit) w
				endif
			endif
		endif
		
		// Handle TDIM here?
		
		colStart += colBytes
		
	endfor
	
	KillWaves bindata
	
	return 0
end

Static  Function NI1_ParseTFORM(tform,nType,isAscii)
	String tform
	Variable &nType
	Variable &isAscii
	
	Variable i,digit,num=0
	String s=""
	for(i=0;;i+=1)
		digit= char2num( tform[i]) - 48
		if( digit < 0 || digit > 9 )
			break
		endif
		num= num*10+digit
	endfor
	if( i==0 )
		num= 1		// missing repeat count is defined as 1
	endif

	strswitch(tform[i])
		case "A":
			isAscii= 1			// data is really text
		case "L":
		case "B":
			nType= 0x48		// unsigned byte
			break
		case "I":
			nType= 0x10		// signed 16 bit int
			break
		case "J":
			nType= 0x20		// signed 32 bit int
			break
		case "E":
			nType= 0x02		// 32 bit float
			break
		case "D":
			nType= 0x04		// 64 bit float
			break
		case "C":
			nType= 0x03		// 32 bit float complex
			break
		case "M":
			nType= 0x05		// 64 bit float complex
			break
		default:						// Don't handle X,A,P yet
			nType= -1
	endswitch
	return num
end

// Kinda' special purpose for now
Static  Function NI1_ParseTDIM(tdim,dim1,dim2)
	String tdim
	Variable &dim1,&dim2
	
	Variable ddim1,ddim2
	
	sscanf tdim,"(%d,%d)",ddim1,ddim2		// BUG: sscanf can accept pass-by-ref but doesn't work
	dim1= ddim1
	dim2= ddim2
	return V_Flag!=2			// i.e., failed
end







//Function NI1_CheckProcFitsGeneric(ctrlName,checked) // : CheckBoxControl
//	String ctrlName
//	Variable checked
//
//	if( CmpStr(ctrlName,"checkHead") == 0 )
//		Variable/G root:Packages:Nika_FITS:wantHeader= checked
//	elseif( CmpStr(ctrlName,"checkHist") == 0 )
//		Variable/G root:Packages:Nika_FITS:wantHistory= checked
//	elseif( CmpStr(ctrlName,"checkCom") == 0 )
//		Variable/G root:Packages:Nika_FITS:wantComments= checked
//	elseif( CmpStr(ctrlName,"checkAutoDisp") == 0 )
//		Variable/G root:Packages:Nika_FITS:wantAutoDisplay= checked
//	elseif( CmpStr(ctrlName,"checkPromoteInts") == 0 )
//		Variable/G root:Packages:Nika_FITS:promoteInts= checked
//	endif
//End
//
//Function NI1_ButtonProcLoadFits(ctrlName)//  : ButtonControl
//	String ctrlName
//
//	NI1_LoadFITS()
//End
//
//Function NI1_DoFITSPanel()
//	if( NumVarOrDefault("root:Packages:Nika_FITS:wantHeader",-1) == -1 )
//		String dfSav= GetDataFolder(1)
//		NewDataFolder/O/S root:Packages
//		NewDataFolder/O/S Nika_FITS
//		
//		Variable/G wantHeader=1
//		Variable/G wantHistory=0
//		Variable/G wantComments=0
//		Variable/G wantAutoDisplay= 1
//		Variable/G promoteInts=0			// if true, then ints are converted floats
//		Variable/G askifSize= 1e6			// ask if ok to load if data size is bigger than this
//		
//		String/G thePath= "_current_"
//		SetDataFolder dfSav
//	endif
//
//	NewPanel/K=1 /W=(71,89,371,289)
//	DoWindow/C NI1_FITSPanel
//	CheckBox checkHead,pos={47,42},size={139,20},proc=NI1_CheckProcFitsGeneric,title="Include Header",value=1
//	CheckBox checkHist,pos={47,59},size={139,20},proc=NI1_CheckProcFitsGeneric,title="Include History",value=0
//	CheckBox checkCom,pos={47,75},size={139,20},proc=NI1_CheckProcFitsGeneric,title="Include Comments",value=0
//	CheckBox checkAutoDisp,pos={47,107},size={139,20},proc=NI1_CheckProcFitsGeneric,title="Auto Display",value=1
//	CheckBox checkPromoteInts,pos={47,91},size={139,20},proc=NI1_CheckProcFitsGeneric,title="Promote Ints",value=0
//	SetVariable setvarAskSize,pos={47,127},size={216,17},title="Max autoload size"
//	SetVariable setvarAskSize,format="%d"
//	SetVariable setvarAskSize,limits={0,INF,100000},value= root:Packages:Nika_FITS:askifSize
//	Button buttonLoad,pos={24,14},size={99,20},proc=NI1_ButtonProcLoadFits,title="Load FITS..."
//	PopupMenu popupPath,pos={133,14},size={126,19},proc=NI1_FITS_PathPopMenuProc,title="path"
//	PopupMenu popupPath,mode=2,popvalue="_current_",value= #"\"_new_;_current_;\"+PathList(\"*\", \";\", \"\")"
//	PopupMenu killpop,pos={24,163},size={98,20},proc=NI1_FITS_KillMenuProc,title="Unload FITS"
//	PopupMenu killpop,mode=0,value= #"NI1_FITS_GetLoadedList()"
//EndMacro
//
//
//Function NI1_FITSSetVarProcPlane(ctrlName,varNum,varStr,varName) // : SetVariableControl
//	String ctrlName
//	Variable varNum
//	String varStr
//	String varName
//
//	ModifyImage data,plane=varNum
//End
//
//
//Function NI1_FITS_PathPopMenuProc(ctrlName,popNum,popStr) // : PopupMenuControl
//	String ctrlName
//	Variable popNum
//	String popStr
//	
//	if( CmpStr(popStr,"_new_") == 0 )
//		popStr= ""
//		Prompt popStr,"name for new path"
//		DoPrompt "Get Path Name",popStr
//		if( strlen(popStr)!=0 )
//			NewPath /M="folder containing FITS files"/Q $popStr
//			PopupMenu popupPath,mode=1,popvalue=popStr
//		else
//			SVAR cp= root:Packages:Nika_FITS:thePath
//			PopupMenu popupPath,mode=1,popvalue=cp
//			return 0								// exit if cancel
//		endif
//	endif
//
//	String/G root:Packages:Nika_FITS:thePath= popStr
//End
//
//
//Function NI1_FITS_KillMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
//	String ctrlName
//	Variable popNum
//	String popStr
//	
//	SVAR/Z nbName= root:$(popStr):NotebookName
//	SVAR/Z gName= root:$(popStr):GraphName
//	
//	if( !SVAR_Exists(nbName) || !SVAR_Exists(gName) )
//		return 0		// should never happen
//	endif
//	
//	if( strlen(nbName) != 0 )
//		DoWindow/K $nbName
//	endif
//	if( strlen(gName) != 0 )
//		DoWindow/K $gName
//	endif
//	KillDataFolder root:$(popStr)
//End
//
//// returns list of data folders in root from loaded fits files
//Function/S NI1_FITS_GetLoadedList()	
//	Variable i
//	String dfList="",dfName
//	for(i=0;;i+=1)
//		dfName= GetIndexedObjName("root:",4,i )
//		if( strlen(dfName) == 0 )
//			break
//		endif
//		SVAR/Z nbName= root:$(dfName):NotebookName
//		if( SVAR_Exists(nbName) )			// we take the existance of this string var as an indication that this df is from a fits load
//			dfList += dfName+";"
//		endif
//	endfor
//	if( strlen(dfList)==0 )
//		return "_none found_"
//	else
//		return dfList
//	endif
//End
//

Static Function NI1_Convert2Text(w,useRow)
	WAVE w
	Variable useRow
	
	String s,swtxt= NameOfWave(w)+"_txt"
	Variable nrows= DimSize(w,0)
	Variable ncols= DimSize(w,1)
	
	Variable row,col
	Make/O/T/N=(useRow ? ncols : nrows) $swtxt
	WAVE/T wtxt= $swtxt
	if( !WaveExists(wtxt) )
		return 1
	endif
	if( useRow )
		for(col=0;col<ncols;col+=1)
			s= PadString("",nrows,0x20)
			for(row=0;row<nrows;row+=1)
				s[row]= num2char(w[row][col])
			endfor
			wtxt[col]= s	// StripTrail(s)
		endfor
	else
		for(row=0;row<nrows;row+=1)
			s= PadString("",ncols,0x20)
			for(col=0;col<ncols;col+=1)
				s[col]= num2char(w[row][col])
			endfor
			wtxt[row]= s	// StripTrail(s)
		endfor
	endif
	return 0
end