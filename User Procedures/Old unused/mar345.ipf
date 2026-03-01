#pragma rtGlobals=3			// Use modern global access method.
#pragma TextEncoding = "UTF-8"

// MAR345 Image Plate File Reader
//
// Loads CCP4-packed binary images from a MAR345 area detector into Igor.
//
// Active code path:
//   DoReadMAR345 → ReadMAR345_Header + ReadMAR345_Data
//   ReadMAR345_Data relies on the ccp4unpack external operation (XOP).
//
// ReadMAR345_Data_NEWER and ReadMAR345_Data_NEW are incomplete, never-called
// attempts to reimplement CCP4 unpacking in pure Igor without the XOP.
// They are retained for reference only.

Menu "Load Waves"
	"Load MAR345 Image\xE2\x80\xA6", DoReadMAR345("", "")
	help = {"Load a MAR345 image plate file into the current datafolder"}
End

// Entry point. Prompts the user for a file if theFilename is "".
// inWaveName sets the output wave name; pass "" to derive it from the filename.
Function DoReadMAR345(theFilename, inWaveName)
	String	theFilename
	String	inWaveName

	Variable	marFile
	String		savedDF = GetDataFolder(1)

	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:MAR345

	if (strlen(theFilename) == 0)
		Open/D/T="????"/R/M="Select a MAR345 image" marFile
		theFilename = S_filename
	endif

	Open/R/Z marFile as theFilename
	switch(V_flag)
		case 0:		// OK
			break
		case -1:	// User cancelled dialog
			return 0
		default:
			Abort "Error opening file " + theFilename + ": " + num2str(V_flag) + ".\rCheck the file name."
	endswitch

	// headerData indices and their meaning:
	//   0 nx, 1 ny, 2 overflows, 3 pixelx, 4 pixely,
	//   5 wavelength, 6 distance, 7 phi, 8 oscillationRange
	Make/O/N=9 headerData
	SetDimLabel 0, 0, nx,               headerData
	SetDimLabel 0, 1, ny,               headerData
	SetDimLabel 0, 2, overflows,        headerData
	SetDimLabel 0, 3, pixelx,          headerData
	SetDimLabel 0, 4, pixely,          headerData
	SetDimLabel 0, 5, wavelength,      headerData
	SetDimLabel 0, 6, distance,        headerData
	SetDimLabel 0, 7, phi,             headerData
	SetDimLabel 0, 8, oscillationRange, headerData

	ReadMAR345_Header(marFile, headerData)
	ReadMAR345_Data(marFile, theFilename, headerData, savedDF, inWaveName)

	KillWaves headerData
	Close marFile

	SetDataFolder savedDF
End

// Reads the 4096-byte binary header and fills headerData with calibrated values.
// The raw header contains 16 big-endian 32-bit integers at fixed offsets.
// Unit conversions:  pixel size  ×1e-3 → mm
//                    wavelength  ×1e-6 → mm
//                    distance    ×1e-3 → mm
//                    angles      ×1e-3 → degrees
Function ReadMAR345_Header(marFile, headerData)
	Variable	marFile
	Wave		headerData

	Make/O/I/N=16 rawHeader
	SetDimLabel 0, 0,  BOM,       rawHeader	// byte-order marker — must equal 1234
	SetDimLabel 0, 1,  nPixels,   rawHeader	// pixels per side (square detector)
	SetDimLabel 0, 2,  overflows, rawHeader	// number of overflow pixels
	SetDimLabel 0, 6,  pixelx,   rawHeader	// pixel size X (raw units: 1e-3 mm)
	SetDimLabel 0, 7,  pixely,   rawHeader	// pixel size Y (raw units: 1e-3 mm)
	SetDimLabel 0, 8,  wavelength, rawHeader	// X-ray wavelength (raw units: 1e-6 mm)
	SetDimLabel 0, 9,  distance,  rawHeader	// sample-detector distance (raw units: 1e-3 mm)
	SetDimLabel 0, 10, phi1,      rawHeader	// start phi angle (raw units: 1e-3 deg)
	SetDimLabel 0, 11, phi2,      rawHeader	// end phi angle (raw units: 1e-3 deg)

	FBinRead/B=3/F=3 marFile, rawHeader
	if (rawHeader[%BOM] != 1234)
		Abort "Badly formatted file."
	endif

	// MAR345 is always a square detector
	headerData[%nx] = rawHeader[%nPixels]
	headerData[%ny] = rawHeader[%nPixels]

	headerData[%overflows] = rawHeader[%overflows]

	// If one pixel dimension is absent in the header, assume square pixels
	if (rawHeader[%pixelx] <= 0)
		rawHeader[%pixelx] = rawHeader[%pixely]
	endif
	if (rawHeader[%pixely] <= 0)
		rawHeader[%pixely] = rawHeader[%pixelx]
	endif

	headerData[%pixelx]           = rawHeader[%pixelx]   / 1e3		// → mm
	headerData[%pixely]           = rawHeader[%pixely]   / 1e3		// → mm
	headerData[%wavelength]       = rawHeader[%wavelength] / 1e6	// → mm
	headerData[%distance]         = rawHeader[%distance]  / 1e3	// → mm
	headerData[%phi]              = rawHeader[%phi1]      / 1e3	// → deg
	headerData[%oscillationRange] = (rawHeader[%phi2] - rawHeader[%phi1]) / 1e3	// → deg

	KillWaves rawHeader
	FSetPos marFile, 4096	// skip to end of 4096-byte header block
End

// Reads the CCP4-packed pixel data using the ccp4unpack external operation (XOP).
// Overflow pixels (stored as index/value pairs before the packed stream) are
// passed to ccp4unpack for in-place correction of saturated pixels.
Function ReadMAR345_Data(marFile, theFilename, headerData, inDF, inWaveName)
	Variable	marFile
	String		theFilename
	Wave		headerData
	String		inDF
	String		inWaveName

	// Read overflow table (pairs of [pixel_index, corrected_value])
	Make/O/I/N=(2*headerData[%overflows]) mar345overflow
	FBinRead/B=3/F=3 marFile, mar345overflow

	// Scan text lines until the CCP4 pack-format marker is found
	Variable nx, ny
	Variable PACK = 2	// sentinel: stays > 1 if no valid marker is found
	do
		String	str
		FReadLine marFile, str
		sscanf str, "CCP4 packed image, X: %04d, Y: %04d", nx, ny
		if (V_flag == 2)
			PACK = 1	// version 1 header (no explicit version number)
			break
		endif
		sscanf str, "CCP4 packed image V%d, X: %04d, Y: %04d", PACK, nx, ny
		if (V_flag == 3)
			break		// version number found
		endif
	while (1)

	if (PACK > 1)
		// mar345 does not exist at this point; the KillWaves here is harmless
		// (Igor ignores attempts to kill non-existent waves)
		KillWaves mar345
		if (headerData[%overflows] > 0)
			KillWaves mar345overflow
		endif
		Abort "Bad image format"
	endif

	// Read remaining bytes and hand off to the ccp4unpack XOP
	FStatus marFile
	Make/B/O/N=(V_logEOF - V_filePos) raw
	FBinRead/F=1 marFile, raw

	if (cmpstr(inWaveName, "") == 0)
		inWaveName = ParseFilePath(0, theFilename, ":", 1, 0)
	endif
	ccp4unpack/O /V=mar345overflow nx, ny, raw as $(inDF + inWaveName)

	KillWaves mar345overflow
	KillWaves raw
End


// =============================================================================
// EXPERIMENTAL — NOT CALLED
//
// ReadMAR345_Data_NEWER and ReadMAR345_Data_NEW are two unfinished attempts to
// reimplement CCP4 unpacking in pure Igor Pro, without depending on the
// ccp4unpack XOP.  Neither function is called from anywhere.
//
// shiftLeft and shiftRight are helper functions used only by these two variants.
// Because Igor lacks native bit-shift operators, multiplication and division by
// powers of 2 are used instead; the caller is responsible for creating 'bitshift'
// and 'setbits' waves before calling either helper.
// =============================================================================

// Attempt 1: bit-stream decoder using a 2-element "register" wave.
// The disabled pixel-prediction block (if (0) in the original) has been removed.
Function ReadMAR345_Data_NEWER(marFile, theFilename, headerData)
	Variable	marFile
	String		theFilename
	Wave		headerData

	Variable pixels = headerData[%nx] * headerData[%ny]

	Make/O/W/N=(pixels) $"TEST"
	Wave mar345 = $"TEST"

	if (headerData[%overflows] > 0)
		Make/O/I/N=(2*headerData[%overflows]) $("TEST_over")
		Wave mar345_over = $("TEST_over")
		FBinRead/B=3/F=3 marFile, mar345_over
	endif

	// Parse CCP4 pack marker (same loop as ReadMAR345_Data)
	Variable nx, ny
	Variable PACK = 2
	do
		String	str
		FReadLine marFile, str
		sscanf str, "CCP4 packed image, X: %04d, Y: %04d", nx, ny
		if (V_flag == 2)
			PACK = 1
			break
		endif
		sscanf str, "CCP4 packed image V%d, X: %04d, Y: %04d", PACK, nx, ny
		if (V_flag == 3)
			break
		endif
	while (1)

	if (PACK > 1)
		KillWaves mar345
		if (headerData[%overflows] > 0)
			KillWaves mar345_over
		endif
		Abort "Bad image format"
	endif

	// Read packed byte stream
	FStatus marFile
	Make/B/U/O/N=(V_logEOF - V_filePos) raw
	FBinRead/U/F=1 marFile, raw

	// Bit-manipulation tables; also consumed by shiftLeft/shiftRight
	Make/I/U/O/N=32 bitshift = 2^x	// bitshift[k] = 2^k
	Make/B/U/O decode = { 0, 4, 5, 6, 7, 8, 16, 32 }

	// Two-slot register: 'in' holds the current input byte, 'next' accumulates bits
	Make/I/U/O/N=2 register
	SetDimLabel 0, 0, in,   register
	SetDimLabel 0, 1, next, register
	register[%in] = 0

	Variable inCount = 0	// valid bits remaining in register[%in]
	Variable get     = 6	// number of bits to collect for the next field
	Variable init    = 1	// 1 = next field is a 6-bit control word

	nx = headerData[%nx]

	Variable n    = 0	// linear output index
	Variable nRaw = 0	// index into raw[]

	Variable pixel
	for (pixel = 0; pixel < pixels;)
		register[%next] = 0
		Variable need = get

		// Shift 'get' bits out of the byte stream into register[%next]
		for (;need;)
			if (inCount == 0)
				register[%in] = raw[nRaw]
				nRaw   += 1
				inCount = 8
			endif
			if (need > inCount)
				register[%next] = register[%next] | shiftLeft(register[%in], get - need)
				need    -= inCount
				register[%in] = 0
				inCount = 0
			else
				register[%next] = register[%next] | shiftLeft(register[%in] & (bitshift[need] - 1), get - need)
				register[%in]   = shiftRight(register[%in], need)
				inCount -= need
				break
			endif
		endfor

		Variable pixCount
		if (init)
			// 6-bit control word: low 3 bits = log2(run length), high 3 bits = bit-width index
			pixCount = bitshift[register[%next] & 7]
			get      = decode[shiftRight(register[%next], 3) & 7]
			init     = 0
		else
			// Sign-extend the delta value using the top bit
			if (get)
				register[%next] = register[%next] | -(register[%next] & bitshift[get - 1])
			endif

			// Store raw delta (no neighbor prediction in this version)
			mar345[n] = register[%next] & 0x0FFFF

			pixel    += 1
			n        += 1
			pixCount -= 1

			if (pixCount == 0)	// run exhausted; expect a new control word
				init = 1
				get  = 6
			endif
		endif
	endfor

	Redimension/N=(headerData[%nx],headerData[%ny]) mar345
End

// Attempt 2: bit-stream decoder using scalar state variables (no register wave).
// NOTE: The neighbor-prediction line originally read "pixel-x+1" which is a bug;
//       the variable x is undefined in this context and equals 0, making the
//       index pixel+1 instead of the intended pixel-nx+1.  Fixed below.
Function ReadMAR345_Data_NEW(marFile, theFilename, headerData)
	Variable	marFile
	String		theFilename
	Wave		headerData

	Variable pixels = headerData[%nx] * headerData[%ny]

	Make/O/W/N=(pixels) $"TEST"
	Wave mar345 = $"TEST"

	if (headerData[%overflows] > 0)
		Make/O/I/N=(2*headerData[%overflows]) $("TEST_over")
		Wave mar345_over = $("TEST_over")
		FBinRead/B=3/F=3 marFile, mar345_over
	endif

	// Parse CCP4 pack marker (same loop as ReadMAR345_Data)
	Variable nx, ny
	Variable PACK = 2
	do
		String	str
		FReadLine marFile, str
		sscanf str, "CCP4 packed image, X: %04d, Y: %04d", nx, ny
		if (V_flag == 2)
			PACK = 1
			break
		endif
		sscanf str, "CCP4 packed image V%d, X: %04d, Y: %04d", PACK, nx, ny
		if (V_flag == 3)
			break
		endif
	while (1)

	if (PACK > 1)
		KillWaves mar345
		if (headerData[%overflows] > 0)
			KillWaves mar345_over
		endif
		Abort "Bad image format"
	endif

	nx = headerData[%nx]

	// Read packed byte stream
	FStatus marFile
	Make/B/U/O/N=(V_logEOF - V_filePos) raw
	FBinRead/U/F=1 marFile, raw

	Make/B/U/O bitshift = {1,2,4,8,16,32,64,128,256}
	Make/B/U/O decode   = { 0, 4, 5, 6, 7, 8, 16, 32 }

	// Precomputed masks: setbits[n] = (1 << n) - 1
	Make/I/O/N=33 setbits
	setbits[ 0] = 0x00000000 ; setbits[ 1] = 0x00000001 ; setbits[ 2] = 0x00000003
	setbits[ 3] = 0x00000007 ; setbits[ 4] = 0x0000000F ; setbits[ 5] = 0x0000001F
	setbits[ 6] = 0x0000003F ; setbits[ 7] = 0x0000007F ; setbits[ 8] = 0x000000FF
	setbits[ 9] = 0x000001FF ; setbits[10] = 0x000003FF ; setbits[11] = 0x000007FF
	setbits[12] = 0x00000FFF ; setbits[13] = 0x00001FFF ; setbits[14] = 0x00003FFF
	setbits[15] = 0x00007FFF ; setbits[16] = 0x0000FFFF ; setbits[17] = 0x0001FFFF
	setbits[18] = 0x0003FFFF ; setbits[19] = 0x0007FFFF ; setbits[20] = 0x000FFFFF
	setbits[21] = 0x001FFFFF ; setbits[22] = 0x003FFFFF ; setbits[23] = 0x007FFFFF
	setbits[24] = 0x00FFFFFF ; setbits[25] = 0x01FFFFFF ; setbits[26] = 0x03FFFFFF
	setbits[27] = 0x07FFFFFF ; setbits[28] = 0x0FFFFFFF ; setbits[29] = 0x1FFFFFFF
	setbits[30] = 0x3FFFFFFF ; setbits[31] = 0x7FFFFFFF ; setbits[32] = 0xFFFFFFFF

	Variable valids    = 0	// number of valid bits currently in bitwindow
	Variable spillbits = 0	// leftover bits from the last byte read
	Variable bitwindow = 0	// bit accumulator
	Variable spill     = 0	// partially consumed byte
	Variable nRaw      = 0	// index into raw[]

	Variable pixel
	for (pixel = 0; pixel < pixels;)
		if (valids < 6)
			// Refill bitwindow until it holds at least one 6-bit control word
			if (spillbits > 0)
				bitwindow  = bitwindow | shiftLeft(spill, valids)
				valids    += spillbits
				spillbits  = 0
			else
				spill     = raw[nRaw]
				nRaw     += 1
				spillbits = 8
			endif
		else
			// Decode 6-bit control word: low 3 bits = run length, next 3 = bit-width index
			Variable pixnum = bitshift[bitwindow & setbits[3]]
			Variable bitnum
			bitwindow = shiftRight(bitwindow, 3)
			bitnum    = decode[bitwindow & setbits[3]]
			bitwindow = shiftRight(bitwindow, 3)
			valids   -= 6

			// Decode 'pixnum' pixel delta values, each 'bitnum' bits wide
			for (;(pixnum > 0) && (pixel < pixels);)
				if (valids < bitnum)
					// Need more bits — refill from spill or next raw byte
					if (spillbits > 0)
						bitwindow = bitwindow | shiftLeft(spill, valids)
						if ((32 - valids) > spillbits)
							valids    += spillbits
							spillbits  = 0
						else
							Variable usedbits  = 32 - valids
							spill             = shiftRight(spill, usedbits)
							spillbits        -= usedbits
							valids            = 32
						endif
					else
						spill     = raw[nRaw]
						nRaw     += 1
						spillbits = 8
					endif
				else
					Variable nextint

					pixnum -= 1
					if (bitnum == 0)
						nextint = 0
					else
						nextint   = bitwindow & setbits[bitnum]
						valids   -= bitnum
						bitwindow = shiftRight(bitwindow, bitnum)
						// Sign-extend: if top bit is set, the delta is negative
						if ((nextint & bitshift[bitnum - 1]) != 0)
							nextint -= bitshift[bitnum]
						endif
					endif

					// Reconstruct absolute value from delta using up to 4 neighbors
					if (pixel > nx)
						// Interior pixel: bilinear prediction from left and row above
						mar345[pixel] = nextint + (mar345[pixel-1] + mar345[pixel-nx+1] + mar345[pixel-nx] + mar345[pixel-nx-1] + 2) / 4
					elseif (pixel != 0)
						// First row: carry from left neighbour only
						mar345[pixel] = mar345[pixel-1] + nextint
					else
						// First pixel: delta is the absolute value
						mar345[pixel] = nextint
					endif

					pixel += 1
				endif
			endfor
		endif
	endfor

	Redimension/N=(headerData[%nx],headerData[%ny]) mar345
End

// Left bit-shift: returns (value << bits) masked to 32 bits.
// Caller must have 'bitshift' (powers of 2) and 'setbits' (bit masks) waves in scope.
Function shiftLeft(value, bits)
	Variable	value
	Variable	bits

	Wave bitshift
	Wave setbits
	return (value * bitshift[bits]) & setbits[32 - bits]
End

// Right bit-shift (logical, unsigned): returns floor(value / 2^bits).
// Caller must have 'bitshift' wave in scope.
Function shiftRight(value, bits)
	Variable	value
	Variable	bits

	Wave bitshift
	return trunc(value / bitshift[bits])
End
