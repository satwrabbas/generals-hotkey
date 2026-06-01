#Requires AutoHotkey >=2.0
#SingleInstance Off ;
full_command_line := DllCall("GetCommandLine", "str")
if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)")) {
    try {
        if A_IsCompiled
            Run '*RunAs "' A_ScriptFullPath '" /restart'
        else
            Run '*RunAs "' A_ScriptFullPath '" /restart "' A_ScriptFullPath '"'
    }
    ExitApp
}
DetectHiddenWindows True
old_instances := WinGetList(A_ScriptFullPath " ahk_class AutoHotkey")
for hwnd in old_instances {
    if (hwnd != A_ScriptHwnd) {
        try {
            pid := WinGetPID(hwnd)
            ProcessClose(pid)
        }
    }
}
CoordMode "Pixel", "Screen"
CoordMode "Mouse", "Screen"
#HotIf WinActive("ahk_exe game.dat") or WinActive("ahk_exe generals.exe") or WinActive("Command & Conquer")
$d:: {
    if IsDozerSelected() {
        Send("i")
    } else {
        Send("d")
    }
}
$v:: {
    if IsDozerSelected() {
        Send("y")
    } else {
        Send("v")
    }
}
$g:: {
    if IsDozerSelected() {
        Send("p")
    } else {
        Send("g")
    }
}

#HotIf
F12:: ExitApp
F11:: {
    Suspend
    if A_IsSuspended {
        ToolTip("تم إيقاف السكربت مؤقتاً")
    } else {
        ToolTip("تم إعادة تفعيل السكربت")
    }
    SetTimer () => ToolTip(), -2000
}
IsDozerSelected() {
    static image_path := "*50 " A_ScriptDir "\dozer.png"

    if !FileExist(A_ScriptDir "\dozer.png") {
        ToolTip("خطأ: ملف dozer.png غير موجود بجانب السكربت!")
        SetTimer () => ToolTip(), -3000
        return false
    }

    x1 := Integer(A_ScreenWidth * 0.60)
    y1 := Integer(A_ScreenHeight * 0.70)
    x2 := A_ScreenWidth
    y2 := A_ScreenHeight

    return ImageSearch(&FoundX, &FoundY, x1, y1, x2, y2, image_path)
}
