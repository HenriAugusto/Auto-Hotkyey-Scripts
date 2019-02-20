debug := 0

;F1::
    str := "1 - selected the folder containing the files to be renamed"
    str := str . "`n" . "2 - select the file containing the names to be used in the renaming"
    str := str . "`n" . "3 - Select the extension of the files to be renamed"
    str := str . "`n" . "4 - Select the extension of the renamed files"
    str := str . "`n" . "5 - You will be prompted if you want to sort files numerically"
    MsgBox, 1, Massrename, %str%
    IfMsgBox, Cancel
    {
        return
    }
    ;=== Read stuff ===
    FileSelectFolder, selectedFolder , C:\Users\User\Desktop , 7, Choose the folder containing the files to be renamed ;use 3 instead of 7?
    if (!selectedFolder){
        TrayTip, , no folder selected`naborting
        Sleep, 3000
        return
    }
    FileSelectFile, selectedFile, 3, , Open the file containing the file names, name list (*.txt)
    if(!selectedFile){
        TrayTip, , no names list selected`naborting
        Sleep, 3000
        return
    }
    FileRead, sourceNames, %selectedFile%

    InputBox, ext, Extension, Enter the source extension (without the dot), , 200, 150, , , , , pdf
    InputBox, targetExt, Target Extension, Enter the target extension (without the dot), , 200, 150, , , , , pdf
    
    names := StrSplit(sourceNames ,"`n")
    
    ;=== Parse the folder for pdf files ===
    FileList := []
    fileCount := 1
    Loop, Files, %selectedFolder%\*.%ext%
    {
        ;FileList = %FileList%%A_LoopFileFullPath%`n
        ;NameList = %FileList%%A_LoopFileName%`n
        FileList[fileCount] := A_LoopFileFullPath
        ;dbgTray("fileCount = "  . fileCount . "`nFileList[" . fileCount . "] = " . FileList[fileCount], 100)
        fileCount := fileCount+1
    }
    
    debugArray(FileList, "before sorting")
    MsgBox, 4, Sorting, Sort files numerically?
    IfMsgBox Yes
    {
        sortNumbers(FileList)
        debugArray(FileList, "after sorting")
    }

    MsgBox, , , % "Found " . FileList.MaxIndex() . " " . ext . " files`nFound " names.MaxIndex() . " names on the list"

    if ( names.MaxIndex() != FileList.MaxIndex()){
        MsgBox, , , % "names.MaxIndex() != FileList.MaxIndex()`n`nnames.MaxIndex() = " . names.MaxIndex() . "`nFileList.MaxIndex() = " . FileList.MaxIndex() . "`n`naborting operation"
    }
    
    ;=== For each PDF... ===
    Loop, %fileCount%
    {
        ;=== check the file name ===
        ;dbgTray(FileList[A_Index], 1000)

        ;=== get the original file name ===
        start_pos := StrLen(selectedFolder)+2
        end_pos := StrLen(FileList[A_Index])-StrLen(selectedFolder)-StrLen(ext)-2
        nameWithoutExtension := SubStr(FileList[A_Index], start_pos, end_pos) 
            ;MsgBox, , ,nameWithoutExtension = %nameWithoutExtension%
            ;Sleep, 1000
        
        ;=== Rename the file ===
        temp := Trim(names[A_Index], "`n")  ;get rid of the `r created by StrSplit ...
        temp := Trim(temp, "`r")

        if (!debug){
            newName := selectedFolder . "\" . temp . ".pdf"
            FileMove, % FileList[A_Index], % newName
        } else {
            newName := selectedFolder . "\" . nameWithoutExtension . " - " . temp . "." . targetExt
            FileMove, % FileList[A_Index], % newName
        }
        If(ErrorLevel)
        {
            MsgBox, , ERROR, %ErrorLevel%
        }
    }
    TrayTip, Done, Done
        Sleep, 2000
    ExitApp
;Return

;F5::
    ;Reload ;empty
;Return

sortNumbers(arr){
    TrayTip, , sortNumbers()
    i := 1
    Loop, % arr.MaxIndex()-1
    {
        j := i+1
        Loop, % arr.MaxIndex()-j+1
        {
            RegExMatch(getFileName(arr[i]),"Oim)\d+", search)
            if (search.Count() >= 0){
                ;dbgTray("search.Count() = [" . search.Count() . "]`nsearch1.Value(0) = " . search1.Value(0), 500)
            } else {
                MsgBox, , , % "could not find digits in getFileName(arr[i]) = " . getFileName(arr[i]) . "`n" . "search.Count() = " . search.Count() . "`naborting operation"
                ExitApp
            }

            ; === search arr[j]
            RegExMatch(getFileName(arr[j]),"O)\d+", search2)
            if (search2.Count() >= 0){
                ;dbgTray("search2.Count() = [" . search2.Count() . "]`nsearch2.Value(0) = " . search2.Value(0), 500)
            } else {
                MsgBox, , , % "could not find digits in getFileName(arr[j]) = " . getFileName(arr[j]) . "`n" . "search.Count() = " . search.Count() . "`naborting operation"
                ExitApp
            }

            ; swap
            i1 := stringToInteger( search.Value(0) )
            i2 := stringToInteger( search2.Value(0) )
            if ( i1 > i2){
                temp := arr[j]
                arr[j] := arr[i]
                arr[i] := temp
            }
            j := j+1
        }
        i := i+1
    }
}

stringToInteger(s){
    len := StrLen(s)
    output := 0
    i := 0 ;counter 
    power := 1 ;powers of ten
    Loop, % len
    {
        test := SubStr(s, i , 1)
        current_digit := charToDigit(test)
        
        output := output+current_digit*power
        
        power := power*10
        i := i-1
    }
    return output
}

charToDigit(c){
    If (c = 0){
        return 0
    } else if(c = 1){
        return 1
    } else if(c = 2){
        return 2
    } else if(c = 3){
        return 3
    } else if(c = 4){
        return 4
    } else if(c = 5){
        return 5
    } else if(c = 6){
        return 6
    } else if(c = 7){
        return 7
    } else if(c = 8){
        return 8
    } else if(c = 9){
        return 9
    } else {
        MsgBox, , ERROR, error on charToDigit()
        ;ErrorLevel := 1
    }
}

debugArray(arr, label = 0){
    msg := ""
    if (label){
     msg := label . "`n"
    }
    c := 1
    Loop, % arr.MaxIndex()
    {
        msg := msg . "`n" . arr[A_Index]
        c := c+1
        If (c>15){
        msg := msg . "`n[...]"
            break
        }
    }
    MsgBox, , Debug Array, % msg
}

dbgTray(s, sl){
    global debug
    if (debug){
        TrayTip, dbg, %s%
        Sleep, %sl%
    }
}

getFileName(str){
    out := ""
    Loop, % StrLen(str)
    {
        char := SubStr(str, StrLen(str)-A_Index+1 , 1)
        if(char != "\"){
            out := char . out
        } else {
            break
        }
    }
    return out
}
