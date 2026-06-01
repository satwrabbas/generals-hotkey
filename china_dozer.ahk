#Requires AutoHotkey v2.0

#Requires AutoHotkey >=2.0
#SingleInstance Off ; إيقاف الميزة الافتراضية لتجنب رسالة الخطأ المزعجة عند إعادة التشغيل

; 1. طلب صلاحيات المسؤول أولاً لضمان عمل السكربت داخل اللعبة
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

; 2. بعد الحصول على الصلاحيات، يتم البحث عن النسخة القديمة وإغلاقها صامتاً لمنع التكرار
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

; ضبط وضع الإحداثيات ليكون متوافقاً مع الشاشة بأكملها لضمان الدقة
CoordMode "Pixel", "Screen"
CoordMode "Mouse", "Screen"

; ==============================================================================
; آلية الخمول الدائم الصامت (Dormant State):
; السكربت يظل يعمل في الخلفية باستهلاك 0% من المعالج ومساحة رام لا تذكر (~2MB).
; بفضل تعليمة #HotIf بالأسفل، بمجرد إغلاق اللعبة أو الخروج منها، يدخل السكربت 
; تلقائياً في حالة نوم عميق ولا يتفاعل مع أي زر حتى تفتح اللعبة مجدداً.
; ==============================================================================

; =======================================================
; الاختصارات الخاصة باللعبة (تنشط فقط داخل اللعبة)
; =======================================================
#HotIf WinActive("ahk_exe game.dat") or WinActive("ahk_exe generals.exe") or WinActive("Command & Conquer")

; --- يمكنك تغيير الأحرف والاختصارات بالأسفل بحرية تامة ---

; اختصار زر d: يرسل i إذا كان البلدوزر الصيني محدداً، وإلا يرسل d كالمعتاد
$d:: {
    if IsChinaDozerSelected() {
        Send("i")
    } else {
        Send("d")
    }
}

; اختصار زر v: يرسل y إذا كان البلدوزر الصيني محدداً، وإلا يرسل v كالمعتاد
$v:: {
    if IsChinaDozerSelected() {
        Send("y")
    } else {
        Send("v")
    }
}

; اختصار زر g: يرسل p إذا كان البلدوزر الصيني محدداً، وإلا يرسل g كالمعتاد
$g:: {
    if IsChinaDozerSelected() {
        Send("p")
    } else {
        Send("g")
    }
}

#HotIf

; مفاتيح التحكم اليدوية الطارئة (تعمل في أي وقت)
F12::ExitApp
F11:: {
    Suspend
    if A_IsSuspended {
        ToolTip("تم إيقاف السكربت مؤقتاً")
    } else {
        ToolTip("تم إعادة تفعيل السكربت")
    }
    SetTimer () => ToolTip(), -2000
}

; دالة فحص وجود صورة البلدوزر الصيني
IsChinaDozerSelected() {
    ; تم تغيير مسار الملف المستهدف هنا إلى china_dozer.png
    static image_path := "*50 " A_ScriptDir "\china_dozer.png"
    
    if !FileExist(A_ScriptDir "\china_dozer.png") {
        ToolTip("خطأ: ملف china_dozer.png غير موجود بجانب السكربت!")
        SetTimer () => ToolTip(), -3000
        return false
    }

    x1 := Integer(A_ScreenWidth * 0.60)
    y1 := Integer(A_ScreenHeight * 0.70)
    x2 := A_ScreenWidth
    y2 := A_ScreenHeight

    return ImageSearch(&FoundX, &FoundY, x1, y1, x2, y2, image_path)
}