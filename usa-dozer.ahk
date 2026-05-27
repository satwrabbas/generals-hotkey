#Requires AutoHotkey >=2.0
#SingleInstance Off ; إيقاف الميزة الافتراضية لتجنب رسالة الخطأ المزعجة عند إعادة التشغيل

; 1. طلب صلاحيات المسؤول أولاً
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

; 2. بعد الحصول على الصلاحيات، يتم البحث عن النسخة القديمة وإغلاقها بقوة وصمت
DetectHiddenWindows True
old_instances := WinGetList(A_ScriptFullPath " ahk_class AutoHotkey")
for hwnd in old_instances {
    if (hwnd != A_ScriptHwnd) { ; تجنب إغلاق النسخة الجديدة الحالية
        try {
            pid := WinGetPID(hwnd)
            ProcessClose(pid) ; إنهاء عملية النسخة القديمة فوراً
        }
    }
}

; ضبط وضع الإحداثيات ليكون متوافقاً مع الشاشة بأكملها لضمان الدقة
CoordMode "Pixel", "Screen"
CoordMode "Mouse", "Screen"

; =======================================================
; مفاتيح التحكم بالبرنامج (تعمل في أي وقت)
; =======================================================

; الضغط على زر F12 يغلق السكربت نهائياً
F12::ExitApp

; الضغط على زر F11 يعطل الاختصارات مؤقتاً
F11:: {
    Suspend ; إيقاف مؤقت للاختصارات
    if A_IsSuspended {
        ToolTip("تم إيقاف السكربت مؤقتاً (Suspended)")
    } else {
        ToolTip("تم إعادة تفعيل السكربت (Active)")
    }
    SetTimer () => ToolTip(), -2000 ; إخفاء التنبيه بعد ثانيتين
}

; =======================================================
; الاختصارات الخاصة باللعبة
; =======================================================
#HotIf WinActive("ahk_exe game.dat") or WinActive("ahk_exe generals.exe") or WinActive("Command & Conquer")

; اختصار زر d: يرسل i (لبناء Firebase) إذا كان البلدوزر محدداً، وإلا يرسل d كالمعتاد
$d:: {
    if IsDozerSelected() {
        Send("i")
    } else {
        Send("d")
    }
}

; اختصار زر s: يرسل y (لبناء Strategy Center) إذا كان البلدوزر محدداً، وإلا يرسل s كالمعتاد
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

; ==========================================
; دالة مساعدة مشتركة لفحص وجود صورة البلدوزر
; ==========================================
IsDozerSelected() {
    static image_path := "*50 " A_ScriptDir "\dozer.png"
    
    ; التحقق من وجود ملف الصورة وتنبيه اللاعب دون إيقاف اللعبة
    if !FileExist(A_ScriptDir "\dozer.png") {
        ToolTip("خطأ: ملف dozer.png غير موجود بجانب السكربت!")
        SetTimer () => ToolTip(), -3000
        return false
    }

    ; تحديد إحداثيات الزاوية السفلية اليمنى ديناميكياً
    x1 := Integer(A_ScreenWidth * 0.60)
    y1 := Integer(A_ScreenHeight * 0.70)
    x2 := A_ScreenWidth
    y2 := A_ScreenHeight

    ; إرجاع نتيجة البحث (صح أو خطأ)
    return ImageSearch(&FoundX, &FoundY, x1, y1, x2, y2, image_path)
}