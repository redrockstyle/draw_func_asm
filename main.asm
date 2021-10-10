.x64
option casemap:none
option frame:auto
option win64:1

include C:\wininc\Include\windows.inc
include C:\wininc\Include\stdio.inc
include C:\wininc\Include\string.inc
include C:\wininc\Include\stdlib.inc

include Strings.mac
include consts.inc
;----------------------------------------

polynom struct
	coeff dword ?
	degree dword ?
polynom ends

interval struct
	left dword ?
	right dword ?
	lenght dword ?
	left_string_ptr qword ?
	right_string_ptr qword ?
interval ends

h_edit_struct struct
	buf_ptr qword ?
	buf_size dword ?
	h_edit HWND ?
h_edit_struct ends

;----------------------------------------

; строковая константа с именем окна
AppWindowName equ <"Application">

;----------------------------------------
; объявление функций

RegisterClassMainWindow proto

CreateMainWindow proto

DrawLine proto hdc:HDC, startX:dword, startY:dword, endX:dword, endY:dword, color: COLORREF

DrawAbscissa proto hdc:HDC, startX:dword, startY:dword, endX:dword, color: COLORREF

DrawOrdinate proto hdc:HDC, startX:dword, startY:dword, endY:dword, color: COLORREF

WndProcMain proto hwnd:HWND, iMsg:UINT, wParam:WPARAM, lParam:LPARAM

Integral proto a:dword, b:dword, func_code_tmp:dword

;----------------------------------------
; описание данных

.data

; коэффициенты
y_coeff qword 1.0
y_offset_coeff qword 0.0
pixel_price_x qword 0.0
pixel_price_y qword 0.0

; флаги
func_code dword 0
button_pushed_flag dword 0
first_point_flag dword 1
buf_is_empty_flag dword 0
first_func_was_drawn_flag dword 0
log_can_not_be_drawn_flag dword 0
func_can_not_be_drawn_flag dword 0
sign_must_be_changed_flag dword 0

; области перерисовки
text_rect RECT <GRAPHIC_REGION_LEFT+GRAPHIC_REGION_WIDTH+10,COORDOY+GRAPHIC_REGION_HEIGHT/2,GRAPHIC_REGION_LEFT+GRAPHIC_REGION_WIDTH+10+150,COORDOY+GRAPHIC_REGION_HEIGHT/2+50>
interval_left_rect RECT <GRAPHIC_REGION_LEFT-150,COORDOY-10,GRAPHIC_REGION_LEFT,COORDOY+50>
interval_right_rect RECT <GRAPHIC_REGION_LEFT+GRAPHIC_REGION_WIDTH+10,COORDOY-10,GRAPHIC_REGION_LEFT+GRAPHIC_REGION_WIDTH+10+150,COORDOY+50>
frame_rect RECT <GRAPHIC_REGION_LEFT-2, GRAPHIC_REGION_TOP-2, GRAPHIC_REGION_LEFT+GRAPHIC_REGION_WIDTH+2, GRAPHIC_REGION_TOP+GRAPHIC_REGION_HEIGHT+2>

; маски
mask1 dw 1111001111111111b
mask2 dw 0000110000000000b
tmpw dw 0

step	dd 0.001
intSum	dq 0

BlackColor	dd 0000000h
GrayColor	dd 0808080h
SilverColor	dd 0C0C0C0h
WhiteColor	dd 0FFFFFFh
RedColor	dd 00000FFh
OrangeColor	dd 01E96FFh
YellowColor	dd 000FFFFh
LimeColor	dd 000FF00h
GreenColor	dd 0008000h
BlueColor	dd 0FF0000h

.data?

interval_x interval <>

edit_interval_left h_edit_struct <>
edit_interval_right h_edit_struct <>

edit_poly_coeff h_edit_struct <>
edit_poly_degree h_edit_struct <>

poly polynom <>

x dword ?
y dword ?
z dword ?
tmpd dword ?
tmpq qword ?
poly_coeff_tmp dword ?

tmp_x dword ?
tmp_y dword ?
prev_x dword ?
prev_y dword ?

ordinate_x_offset_left dword ?

graphic_string qword ?

i dword ?
j dword ?

hIns HINSTANCE ?

HwndMainWindow HWND ?

h_button_1 HWND ?
h_button_2 HWND ?
h_button_3 HWND ?
h_button_4 HWND ?
h_button_5 HWND ?
h_button_6 HWND ?
h_button_7 HWND ?
h_button_8 HWND ?
h_button_9 HWND ?
h_button_10 HWND ?

h_control_1 HWND ?
h_control_2 HWND ?
h_control_3 HWND ?
h_control_4 HWND ?
h_control_5 HWND ?
h_control_6 HWND ?
h_control_7 HWND ?
h_control_8 HWND ?
h_control_9 HWND ?
h_control_10 HWND ?
h_control_11 HWND ?
h_control_12 HWND ?
h_control_13 HWND ?
hIntWindow	HWND ?

.const

.code


;----------------------------------------
; описание функций
;
; Основная функция оконных приложений
;
WinMain proc frame hInstance:HINSTANCE, hPrevInstance:HINSTANCE, szCmdLine:PSTR, iCmdShow:DWORD

    local msg: MSG

    mov rax, [hInstance]
    mov [hIns], rax

    invoke CreateMainWindow
    mov [HwndMainWindow], rax
    .if [HwndMainWindow] == 0
        xor rax, rax
        ret
    .endif
	
	; Основной цикл обработки сообщений
    .while TRUE
        invoke GetMessage, addr msg, NULL, 0, 0
            .break .if rax == 0

        invoke TranslateMessage, addr msg
        invoke DispatchMessage, addr msg

    .endw

    mov rax, [msg].wParam
    ret

WinMain endp

;--------------------

;
; Регистрация класса основного окна приложения
;
RegisterClassMainWindow proc frame

    local WndClass:WNDCLASSEX	; структура класса

    ; заполняем поля структуры
    mov WndClass.cbSize, sizeof (WNDCLASSEX)    ; размер структуры класса
    mov WndClass.style, 0
    mov rax, offset WndProcMain
    mov WndClass.lpfnWndProc,  rax              ; адрес оконной процедуры класса
    mov WndClass.cbClsExtra, 0
    mov WndClass.cbWndExtra, 0                  ; размер дополнительной памяти окна
    mov rax, [hIns]
    mov WndClass.hInstance, rax	                ; описатель приложения
    invoke LoadIcon, hIns, $CTA0("MainIcon")    ; иконка приложения
    mov WndClass.hIcon, rax
    invoke LoadCursor, NULL, IDC_ARROW
    mov WndClass.hCursor, rax
    invoke GetStockObject, WHITE_BRUSH          ; кисть для фона
    mov WndClass.hbrBackground, rax
    mov WndClass.lpszMenuName, NULL
    mov rax, $CTA0(AppWindowName)
    mov WndClass.lpszClassName, rax             ; имя класса
    invoke LoadIcon, hIns, $CTA0("MainIcon")
    mov WndClass.hIconSm, rax

    invoke RegisterClassEx, addr WndClass
    ret

RegisterClassMainWindow endp

;--------------------

;
; Создание основного окна приложения
;
CreateMainWindow proc frame

    local hwnd:HWND

    ; регистрация класса основного окна
    invoke RegisterClassMainWindow

    ; создание окна зарегестрированного класса
    invoke CreateWindowEx, 
        WS_EX_CONTROLPARENT or WS_EX_APPWINDOW, ; расширенный стиль окна
        $CTA0(AppWindowName),	; имя зарегестрированного класса окна
        $CTA0("Application"),	; заголовок окна
        WS_OVERLAPPEDWINDOW,	; стиль окна
        10,	    ; X-координата левого верхнего угла
        10,	    ; Y-координата левого верхнего угла
        WINDOW_WIDTH,    ; ширина окна
        WINDOW_HEIGHT,    ; высота окна
        NULL,   ; описатель родительского окна
        NULL,   ; описатель главного меню (для главного окна)
        [hIns], ; идентификатор приложения
        NULL
    mov [hwnd], rax
    
    .if [hwnd] == 0
        invoke MessageBox, NULL, $CTA0("Cannot create main window"), NULL, MB_OK
        xor rax, rax
        ret
    .endif
        
    invoke ShowWindow, [hwnd], SW_SHOWNORMAL
    invoke UpdateWindow, [hwnd]
    
    mov rax, [hwnd]
    ret

CreateMainWindow endp

;--------------------

Create_Buttons proc, hwnd:HWND
    
    invoke CreateWindowEx, WS_EX_CLIENTEDGE, $CTA0("button"), $CTA0("sin(x)"), WS_CHILD or WS_VISIBLE,
							BUTTONS_OFFSET_LEFT, 										; смещение по x
							FIRST_BUTTON_OFFSET_TOP,									; смещение по y
                            BUTTON_WIDTH, BUTTON_HEIGHT,
                            [hwnd], BT_1, hIns, NULL
    mov [h_button_1], rax
    
    invoke CreateWindowEx, WS_EX_CLIENTEDGE, $CTA0("button"), $CTA0("cos(x)"), WS_CHILD or WS_VISIBLE,
							BUTTONS_OFFSET_LEFT, 										; смещение по x
							FIRST_BUTTON_OFFSET_TOP+BUTTON_HEIGHT+BUTTONS_MARGIN_TOP,	; смещение по y
                            BUTTON_WIDTH, BUTTON_HEIGHT,
                            [hwnd], BT_2, hIns, NULL
    mov [h_button_2], rax
    
	invoke CreateWindowEx, WS_EX_CLIENTEDGE, $CTA0("button"), $CTA0("tg(x)"), WS_CHILD or WS_VISIBLE,
							BUTTONS_OFFSET_LEFT, 											; смещение по x
							FIRST_BUTTON_OFFSET_TOP+BUTTON_HEIGHT*2+BUTTONS_MARGIN_TOP*2,	; смещение по y
                            BUTTON_WIDTH, BUTTON_HEIGHT,
                            hwnd, BT_3, hIns, NULL
    mov [h_button_3], rax                          
      
	invoke CreateWindowEx, WS_EX_CLIENTEDGE, $CTA0("button"), $CTA0("ctg(x)"), WS_CHILD or WS_VISIBLE,
							BUTTONS_OFFSET_LEFT, 											; смещение по x
							FIRST_BUTTON_OFFSET_TOP+BUTTON_HEIGHT*3+BUTTONS_MARGIN_TOP*3,	; смещение по y
                            BUTTON_WIDTH, BUTTON_HEIGHT,
                            hwnd, BT_4, hIns, NULL
    mov [h_button_4], rax   
    
	invoke CreateWindowEx, WS_EX_CLIENTEDGE, $CTA0("button"), $CTA0("log2(x)"), WS_CHILD or WS_VISIBLE,
							BUTTONS_OFFSET_LEFT, 											; смещение по x
							FIRST_BUTTON_OFFSET_TOP+BUTTON_HEIGHT*4+BUTTONS_MARGIN_TOP*4,	; смещение по y
                            BUTTON_WIDTH, BUTTON_HEIGHT,
                            hwnd, BT_5, hIns, NULL
    mov [h_button_5], rax 
    
	invoke CreateWindowEx, WS_EX_CLIENTEDGE, $CTA0("button"), $CTA0("log(x)"), WS_CHILD or WS_VISIBLE,
							BUTTONS_OFFSET_LEFT, 											; смещение по x
							FIRST_BUTTON_OFFSET_TOP+BUTTON_HEIGHT*5+BUTTONS_MARGIN_TOP*5,	; смещение по y
                            BUTTON_WIDTH, BUTTON_HEIGHT,
                            hwnd, BT_6, hIns, NULL
    mov [h_button_6], rax 
    
	invoke CreateWindowEx, WS_EX_CLIENTEDGE, $CTA0("button"), $CTA0("ln(x)"), WS_CHILD or WS_VISIBLE,
							BUTTONS_OFFSET_LEFT, 											; смещение по x
							FIRST_BUTTON_OFFSET_TOP+BUTTON_HEIGHT*6+BUTTONS_MARGIN_TOP*6,	; смещение по y
                            BUTTON_WIDTH, BUTTON_HEIGHT,
                            hwnd, BT_7, hIns, NULL
    mov [h_button_7], rax 
    
	invoke CreateWindowEx, WS_EX_CLIENTEDGE, $CTA0("button"), $CTA0("X^"), WS_CHILD or WS_VISIBLE,
							BUTTONS_OFFSET_LEFT, 											; смещение по x
							FIRST_BUTTON_OFFSET_TOP+BUTTON_HEIGHT*7+BUTTONS_MARGIN_TOP*7,	; смещение по y
                            BUTTON_WIDTH, BUTTON_HEIGHT,
                            hwnd, BT_8, hIns, NULL
    mov [h_button_8], rax 
    
    invoke CreateWindowEx, WS_EX_WINDOWEDGE, $CTA0("edit"), NULL,
							WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or ES_MULTILINE or ES_AUTOVSCROLL or ES_AUTOHSCROLL,
							BUTTONS_OFFSET_LEFT-EDIT_WIDTH-10, 																	; смещение по x							
							FIRST_BUTTON_OFFSET_TOP+BUTTON_HEIGHT*7+BUTTONS_MARGIN_TOP*7,	; смещение по y
                            EDIT_WIDTH, EDIT_HEIGHT,
							[hwnd], ED_1, hIns, NULL
    mov [edit_poly_coeff].h_edit, rax
    
    invoke CreateWindowEx, WS_EX_WINDOWEDGE, $CTA0("edit"), NULL,
							WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or ES_MULTILINE or ES_AUTOVSCROLL or ES_AUTOHSCROLL,
							BUTTONS_OFFSET_LEFT+BUTTON_WIDTH+10, 																	; смещение по x							
							FIRST_BUTTON_OFFSET_TOP+BUTTON_HEIGHT*7+BUTTONS_MARGIN_TOP*7,	; смещение по y
                            EDIT_WIDTH, EDIT_HEIGHT,
							[hwnd], ED_2, hIns, NULL
    mov [edit_poly_degree].h_edit, rax    
    
  	invoke CreateWindowEx, WS_EX_WINDOWEDGE, $CTA0("edit"), NULL,
							WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or ES_MULTILINE or ES_AUTOVSCROLL or ES_AUTOHSCROLL,
							BUTTONS_OFFSET_LEFT + EDIT_WIDTH/2, 																	; смещение по x							
							FIRST_BUTTON_OFFSET_TOP+BUTTON_HEIGHT*COUNT_OF_FUNCTIONS+BUTTONS_MARGIN_TOP*COUNT_OF_FUNCTIONS+BUTTON_HEIGHT/2+10,	; смещение по y
                            EDIT_WIDTH, EDIT_HEIGHT,
							[hwnd], ED_3, hIns, NULL
    mov [edit_interval_left].h_edit, rax
      
	invoke CreateWindowEx, WS_EX_WINDOWEDGE, $CTA0("edit"), NULL,
							WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or ES_MULTILINE or ES_AUTOVSCROLL or ES_AUTOHSCROLL,
							BUTTONS_OFFSET_LEFT+EDIT_WIDTH/2+EDIT_WIDTH+EDIT_WIDTH/2, 											; смещение по x							
							FIRST_BUTTON_OFFSET_TOP+BUTTON_HEIGHT*COUNT_OF_FUNCTIONS+BUTTONS_MARGIN_TOP*COUNT_OF_FUNCTIONS+BUTTON_HEIGHT/2+10,	; смещение по y
                            EDIT_WIDTH, EDIT_HEIGHT,
							[hwnd], ED_4, hIns, NULL
    mov [edit_interval_right].h_edit, rax
    
    invoke CreateWindowEx, WS_EX_CLIENTEDGE, $CTA0("button"), $CTA0("X * 2"), WS_CHILD or WS_VISIBLE,
							SCALE_OFFSET_TOP,
							SCALE_OFFSET_LEFT,
                            CONTROL_WIDTH, CONTROL_HEIGHT,
                            hwnd, CT_1, hIns, NULL
    mov h_control_1, rax 
    
    invoke CreateWindowEx, WS_EX_CLIENTEDGE, $CTA0("button"), $CTA0("X / 2"), WS_CHILD or WS_VISIBLE,
							SCALE_OFFSET_TOP+SCALE_SHIFT_CONTROL,
							SCALE_OFFSET_LEFT,
                            CONTROL_WIDTH, CONTROL_HEIGHT,
                            hwnd, CT_2, hIns, NULL
    mov [h_control_2], rax 
    
    invoke CreateWindowEx, WS_EX_CLIENTEDGE, $CTA0("button"), $CTA0("Y * 2"), WS_CHILD or WS_VISIBLE,
							SCALE_OFFSET_TOP,
							SCALE_OFFSET_LEFT+40,
                            CONTROL_WIDTH, CONTROL_HEIGHT,
                            hwnd, CT_3, hIns, NULL
    mov [h_control_3], rax 
    
    invoke CreateWindowEx, WS_EX_CLIENTEDGE, $CTA0("button"), $CTA0("Y / 2"), WS_CHILD or WS_VISIBLE,
							SCALE_OFFSET_TOP+SCALE_SHIFT_CONTROL,
							SCALE_OFFSET_LEFT+40,
                            CONTROL_WIDTH, CONTROL_HEIGHT,
                            hwnd, CT_4, hIns, NULL
    mov [h_control_4], rax 
    
    invoke CreateWindowEx, WS_EX_CLIENTEDGE, $CTA0("button"), $CTA0(" * 2"), WS_CHILD or WS_VISIBLE,
							SCALE_OFFSET_TOP+2*SCALE_SHIFT_CONTROL+2*SCALE_SHIFT_CONTROLS,
							SCALE_OFFSET_LEFT,
                            CONTROL_WIDTH, CONTROL_HEIGHT,
                            hwnd, CT_5, hIns, NULL
    mov [h_control_5], rax 
    
    invoke CreateWindowEx, WS_EX_CLIENTEDGE, $CTA0("button"), $CTA0(" / 2"), WS_CHILD or WS_VISIBLE,
							SCALE_OFFSET_TOP+3*SCALE_SHIFT_CONTROL+2*SCALE_SHIFT_CONTROLS,
							SCALE_OFFSET_LEFT,
                            CONTROL_WIDTH, CONTROL_HEIGHT,
                            hwnd, CT_6, hIns, NULL
    mov [h_control_6], rax 
    
	invoke CreateWindowEx, WS_EX_CLIENTEDGE, $CTA0("button"), $CTA0("X + 1"), WS_CHILD or WS_VISIBLE,
							SCALE_OFFSET_TOP+SCALE_SHIFT_CONTROL+SCALE_SHIFT_CONTROLS,
							SCALE_OFFSET_LEFT,
                            CONTROL_WIDTH, CONTROL_HEIGHT,
                            hwnd, CT_7, hIns, NULL
    mov [h_control_7], rax 
    
    invoke CreateWindowEx, WS_EX_CLIENTEDGE, $CTA0("button"), $CTA0("X - 1"), WS_CHILD or WS_VISIBLE,
							SCALE_OFFSET_TOP+2*SCALE_SHIFT_CONTROL+SCALE_SHIFT_CONTROLS,
							SCALE_OFFSET_LEFT,
                            CONTROL_WIDTH, CONTROL_HEIGHT,
                            hwnd, CT_8, hIns, NULL
    mov [h_control_8], rax    
        
    invoke CreateWindowEx, WS_EX_CLIENTEDGE, $CTA0("button"), $CTA0("Y + 1"), WS_CHILD or WS_VISIBLE,
							SCALE_OFFSET_TOP+SCALE_SHIFT_CONTROL+SCALE_SHIFT_CONTROLS,
							SCALE_OFFSET_LEFT+40,
                            CONTROL_WIDTH, CONTROL_HEIGHT,
                            hwnd, CT_9, hIns, NULL
    mov [h_control_9], rax
    
    invoke CreateWindowEx, WS_EX_CLIENTEDGE, $CTA0("button"), $CTA0("Y - 1"), WS_CHILD or WS_VISIBLE,
							SCALE_OFFSET_TOP+2*SCALE_SHIFT_CONTROL+SCALE_SHIFT_CONTROLS,
							SCALE_OFFSET_LEFT+40,
                            CONTROL_WIDTH, CONTROL_HEIGHT,
                            hwnd, CT_10, hIns, NULL
    mov [h_control_10], rax
    
    invoke CreateWindowEx, WS_EX_CLIENTEDGE, $CTA0("button"), $CTA0(" + 1"), WS_CHILD or WS_VISIBLE,
							SCALE_OFFSET_TOP+2*SCALE_SHIFT_CONTROL+2*SCALE_SHIFT_CONTROLS,
							SCALE_OFFSET_LEFT+40,
                            CONTROL_WIDTH, CONTROL_HEIGHT,
                            hwnd, CT_11, hIns, NULL
    mov [h_control_11], rax
    
    invoke CreateWindowEx, WS_EX_CLIENTEDGE, $CTA0("button"), $CTA0(" - 1"), WS_CHILD or WS_VISIBLE,
							SCALE_OFFSET_TOP+3*SCALE_SHIFT_CONTROL+2*SCALE_SHIFT_CONTROLS,
							SCALE_OFFSET_LEFT+40,
                            CONTROL_WIDTH, CONTROL_HEIGHT,
                            hwnd, CT_12, hIns, NULL
    mov [h_control_12], rax
	
	invoke CreateWindowEx, WS_EX_CLIENTEDGE, $CTA0("button"), $CTA0("Integral"), WS_CHILD or WS_VISIBLE,
							BUTTONS_OFFSET_LEFT, 			
							FIRST_BUTTON_OFFSET_TOP+BUTTON_HEIGHT*9+BUTTONS_MARGIN_TOP*9+CONTROL_WIDTH,	
                            BUTTON_WIDTH, BUTTON_HEIGHT,
                            hwnd, CT_13, hIns, NULL
    mov [h_control_13], rax
	
	invoke CreateWindowEx, WS_EX_WINDOWEDGE, $CTA0("edit"), NULL,
							WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or ES_READONLY,
							CONTROLS_OFFSET_LEFT,
							FIRST_CONTROL_OFFSET_TOP+CONTROLS_MARGIN_TOP*9+CONTROL_HEIGHT*9+CONTROL_WIDTH,
							CONTROL_WIDTH*2+CONTROLS_MARGIN_LEFT, CONTROL_HEIGHT, hwnd, ED_INT, hIns, NULL
    mov [hIntWindow], rax
    
    ret
Create_Buttons endp
;
; Рисует отрезок на контексте устройства с указанными координатами.
;
DrawLine proc frame hdc:HDC, startX:dword, startY:dword, endX:dword, endY:dword, color: COLORREF 

    local pen:HPEN
    
    ; создаём объект "перо" для рисования линий
    invoke CreatePen, 
        PS_SOLID,       ; задаём тип линии (сплошная)
        2,              ; толщина линии
        [color] ; цвет линии
    mov [pen], rax
    
    ; ассоциируем созданную кисть с контекстом устройства
    invoke SelectObject, [hdc], [pen]
    
    ; перемещаем текущую позицию, с которой начинается рисование
    invoke MoveToEx,
        [hdc],          ; описатель контекста устройства
        startX,         ; X-координата
        startY,         ; Y-координата
        NULL
        
    ; рисуем линию выбранной кистью от текущей позиции до указанной точки
    invoke LineTo,
        [hdc],          ; описатель контекста устройства
        endX,           ; X-координата конечной точки
        endY            ; Y-координата конечной точки

    ; удаляем созданное "перо"
    invoke DeleteObject, pen

    ret

DrawLine endp


;--------------------

;
; Рисует ось абсцисс.
;
DrawAbscissa proc frame hdc:HDC, startX:dword, startY:dword, endX:dword, color: COLORREF

    invoke DrawLine, [hdc], [startX], [startY], [endX], [startY], [color]
    
    mov r10d, [endX]
    sub r10d, 10
    mov r11d, [startY]
    sub r11d, 5
    invoke DrawLine, [hdc], r10d, r11d, [endX], [startY], [color]
    
    mov r10d, [endX]
    sub r10d, 10
    mov r11d, [startY]
    add r11d, 5
    invoke DrawLine, [hdc], r10d, r11d, [endX], [startY], [color]
    
    ret

DrawAbscissa endp

;--------------------

;
; Рисует ось ординат.
;
DrawOrdinate proc frame hdc:HDC, startX:dword, startY:dword, endY:dword, color: COLORREF

    invoke DrawLine, [hdc], [startX], [startY], [startX], [endY], [color]
    
    mov r10d, [endY]
    add r10d, 10
    mov r11d, [startX]
    sub r11d, 5
    invoke DrawLine, [hdc], r11d, r10d, [startX], [endY], [color]
    
    mov r10d, [endY]
    add r10d, 10
    mov r11d, [startX]
    add r11d, 5
    invoke DrawLine, [hdc], r11d, r10d, [startX], [endY], [color]
    
    ret

DrawOrdinate endp


;--------------------

Draw_Func proc frame hdc:HDC, func_code_tmp:dword, color: COLORREF, interval_x_tmp:ptr interval
	
	local func_max:dword
	local func_min:dword
	local func_y_height:dword
	
	; Инициализация минимумов и максимумов функций
	.if [func_code_tmp] == FUNC_CODE_SIN || [func_code_tmp] == FUNC_CODE_COS
		
		mov [func_max], FMAX_SIN_COS
		mov [func_min], FMIN_SIN_COS		
		
	.elseif [func_code_tmp] == FUNC_CODE_TG || [func_code_tmp] == FUNC_CODE_CTG
		
		mov [func_max], FMAX_TG_CTG		
		mov [func_min], FMIN_TG_CTG
		
	.elseif [func_code_tmp] == FUNC_CODE_LOG2 || [func_code_tmp] == FUNC_CODE_LG || [func_code_tmp] == FUNC_CODE_LN
		
		mov [func_max], FMAX_LOG		
		mov [func_min], FMIN_LOG
		
	.elseif [func_code_tmp] == FUNC_CODE_POLY_EVEN
		
		mov [func_max], FMAX_POLY_EVEN
		mov [func_min], FMIN_POLY_EVEN
		
		cmp [poly_coeff_tmp], 0
		jg skip_sub
		mov [tmpd], FMAX_POLY_EVEN
		fld [tmpd]
		fld [func_max]
		fsub st(0), st(1)
		fstp [func_max]
		mov [tmpd], FMAX_POLY_EVEN
		fld [tmpd]
		fld [func_min]
		fsub st(0), st(1)
		fstp [func_min]
		skip_sub:
		
	.elseif [func_code_tmp] == FUNC_CODE_POLY_ODD
		
		mov [func_max], FMAX_POLY_ODD
		mov [func_min], FMIN_POLY_ODD		
		
	.endif
	
	; Умножаем max и min на коэффициент по y
	finit
	fld [func_max]
	fld [y_coeff]
	fmul st(0), st(1)
	fstp [func_max]
	finit
	fld [func_min]
	fld [y_coeff]
	fmul st(0), st(1)
	fstp [func_min]
	
	; разница максимума и минимума
	finit
	fld [func_min]
	fld [func_max]
	fsub st(0), st(1)
	fstp [func_y_height]
    
	finit
	mov [tmpd], XLENGHT			
	fild [tmpd]	
	mov rax, [interval_x_tmp]
	fld [rax].interval.lenght	
	fdiv st(0), st(1)			; interval.lenght / XLENGHT 
	fst [pixel_price_x]			

	finit
	mov [tmpd], YLENGHT			
	fild [tmpd]
	fld [func_y_height]
	fdiv st(0), st(1)			; func_y_height / YLENGHT
	fstp [pixel_price_y]		
    
	mov [tmp_x], 0
	mov [tmp_y], 0
    mov [i], 0    
    .while [i] != XLENGHT
		
		; Копируем предыдущие значения
		mov r8d, [tmp_x]
		mov [prev_x], r8d
		
		mov r8d, [tmp_y]
		mov [prev_y], r8d		
	
		; Вычисляем новые значения	
		; Вычисление X		
		mov eax, [i]				; Помещаем в х текущий i
		mov [tmp_x], eax		
		
		; Вычисление Y
		finit 
		fild [i]					
		fld [pixel_price_x]			
		fmul st(0), st(1)			; i * pixel_price_x
		mov rax, [interval_x_tmp]	
		fld [rax].interval.left			
		fadd st(0), st(1)			

		; вычисление функции
		;-----------------------------
		.if [func_code_tmp] == FUNC_CODE_SIN
			fsin						; Вычисляем синус
		.elseif [func_code_tmp] == FUNC_CODE_COS
			fcos						; Вычисляем косинус
		.elseif [func_code_tmp] == FUNC_CODE_TG
			fptan						; Вычисляем тангенс
			fdivp st(1), st(0)
		.elseif[func_code_tmp] == FUNC_CODE_CTG
			fptan						; Вычисляем котангенс
			fdivp st(1), st(0)
			fld1
			fdiv st(0), st(1)
		.elseif [func_code_tmp] == FUNC_CODE_LOG2
			fld1
			fxch st(1)	
			fyl2x						; Вычисляем двоичный логарифм
		.elseif [func_code_tmp] == FUNC_CODE_LG
			fld1
			fxch st(1)	
			fyl2x						
			fldl2t								
			fdivp st(1), st(0)
		.elseif [func_code_tmp] == FUNC_CODE_LN
			fld1
			fxch st(1)	
			fyl2x						
			fldl2e						
			fdivp st(1), st(0)
		.elseif [func_code_tmp] == FUNC_CODE_POLY_EVEN
			fabs
			fld [poly].degree
			fxch
			fyl2x							; Стек содержит: ST(0)=z
			
		    ;Теперь считаем 2^z:
		    fld st(0)						; Создаем еще одну копию z
		    
	  	    fnstcw  [tmpw]					; Сохраняем значение CR
	  	    mov r8w, [mask1]
		    and [tmpw], r8w					; Очищаем 10 и 11 биты
	  	    mov r8w, [mask2]
		    or [tmpw], r8w					; Устанавливаем нужный режим
		    fldcw [tmpw]					; Восстанавливаем
		  
		    frndint							; Округляем ST(0)=trunc(z)
		    fsubr st(0),st(1)				; ST(1)=z, ST(0)=z-trunc(z)
		    f2xm1							; ST(1)=z, ST(0)=2^(z-trunc(z))-1
		    fld1
		    faddp st(1), st(0)				; ST(1)=z, ST(0)=2^(z-trunc(z))
		    fscale							; ST(1)=z, ST(0)=(2^trunc(z))*(2^(z-trunc(z)))
		    fxch st(1)
		    fstp st(0)						; Результат остается на вершине стека ST(0)
			fld [poly].coeff				; Умножаем результат на коэффициент перед х
			fmul st(0), st(1)
		  
		.elseif [func_code_tmp] == FUNC_CODE_POLY_ODD
			fldz
			fucomip st(0), st(1)
			jb skip1
			fabs
			mov [sign_must_be_changed_flag], 1
			skip1:
			fld [poly].degree
			fxch
			fyl2x							; Стек содержит: ST(0)=z
			
			;Теперь считаем 2^z:
		    fld st(0)						; Создаем еще одну копию z
		    
	  	    fnstcw  [tmpw]					; Сохраняем значение CR
	  	    mov r8w, [mask1]
		    and [tmpw], r8w					; Очищаем 10 и 11 биты
	  	    mov r8w, [mask2]
		    or [tmpw], r8w					; Устанавливаем нужный режим
		    fldcw [tmpw]					; Восстанавливаем
		  
		    frndint							; Округляем ST(0)=trunc(z)
		    fsubr st(0),st(1)				; ST(1)=z, ST(0)=z-trunc(z)
		    f2xm1							; ST(1)=z, ST(0)=2^(z-trunc(z))-1
		    fld1
		    faddp st(1), st(0)				; ST(1)=z, ST(0)=2^(z-trunc(z))
		    fscale							; ST(1)=z, ST(0)=(2^trunc(z))*(2^(z-trunc(z)))
		    fxch st(1)
		    fstp st(0)						; Результат остается на вершине стека ST(0)
		    .if [sign_must_be_changed_flag]	; Меняем знак, если х был меньше нуля
				fchs
				mov [sign_must_be_changed_flag], 0
		    .endif
			fld [poly].coeff				; Умножаем результат на коэффициент перед х
			fmul st(0), st(1)
		.endif
		
		;-------------------------------
		 
		fld [func_min]								
		fsubp st(1), st(0)				
		fld [y_offset_coeff]
		fadd
		fld [pixel_price_y]				
		fxch st(1)						
		fdiv st(0), st(1)				
		fist [tmp_y]					
		
		add [tmp_x], COORDOX			; Прибавляем смещение начала координат по х	
		
		; проверка, чтобы не рисовать, где х < 0
		.if [func_code_tmp] == FUNC_CODE_LOG2 || [func_code_tmp] == FUNC_CODE_LG || [func_code_tmp] == FUNC_CODE_LN
		
			finit
			fld [interval_x].lenght
			mov [tmpd], GRAPHIC_REGION_WIDTH
			fild [tmpd]
			fdiv st(0), st(1)
			fld [interval_x].left
			fchs
			fmul st(0), st(1)
			fistp [ordinate_x_offset_left]
			mov r8d, [ordinate_x_offset_left]
			add r8d, GRAPHIC_REGION_LEFT
			
			cmp [tmp_x], r8d
			jg skip						; Если tmp_x > ordinate_x_offset_left
				mov [log_can_not_be_drawn_flag], 1
			skip:			
		.endif		
		
		.if [log_can_not_be_drawn_flag] == 0
		
			; Вычитаем из смещения начала координат по у
			mov r8d, COORDOY + YLENGHTHALF	
			sub r8d, [tmp_y]
			mov [tmp_y], r8d
			
			; проверка тангенса на лишние асимптоты
			mov [tmpd], 0
			.if [func_code_tmp] == FUNC_CODE_TG
				cmp [prev_y], 0
				jg skipc1
					inc [tmpd]
				skipc1:					
				cmp [tmp_y], 0
				jl skipc2
					inc [tmpd]
				skipc2:	
				
				.if	[tmpd] == 2
					jmp skip_drawing
				.endif
			.endif
			
			; проверка котангенса на лишние асимптоты
			mov [tmpd], 0
			.if [func_code_tmp] == FUNC_CODE_CTG
				cmp [prev_y], 0
				jl skipc3
					inc [tmpd]
				skipc3:					
				cmp [tmp_y], 0
				jg skipc4
					inc [tmpd]
				skipc4:	
				
				.if	[tmpd] == 2
					jmp skip_drawing
				.endif
			.endif
				
			; Рисуем линии
			.if [first_point_flag] == 1		
				invoke DrawLine, [hdc], [tmp_x], [tmp_y], [tmp_x], [tmp_y], [color]
				mov [first_point_flag], 0
			.elseif [first_point_flag] == 0
				invoke DrawLine, [hdc], [prev_x], [prev_y], [tmp_x], [tmp_y], [color]
			.endif
			
			skip_drawing:
			
		.endif
		
		.if [log_can_not_be_drawn_flag] == 1
			mov [log_can_not_be_drawn_flag], 0
		.endif	
		
		inc [i]
	.endw
	
	mov [first_point_flag], 1
	
	ret
Draw_Func endp

 
Processing_Edits proc edit_struct_tmp:ptr h_edit_struct    
	
    ; получаем длину текста в окне
	mov r15, [edit_struct_tmp]	
    invoke GetWindowTextLength, [r15].h_edit_struct.h_edit    
	mov r15, [edit_struct_tmp]	
    mov [r15].h_edit_struct.buf_size, eax   
     
    .if [r15].h_edit_struct.buf_size == 0
		mov rax, 1
        ret
	.endif
	
	mov r14d, [r15].h_edit_struct.buf_size
	inc r14d		; хотим получить на 1 символ больше (учитывая признак конца строки)
	
	; получаем данные из окна в буфер
	mov r15, [edit_struct_tmp]
	invoke GetWindowText, [r15].h_edit_struct.h_edit, [r15].h_edit_struct.buf_ptr, r14d
	
	mov r15, [edit_struct_tmp]
	mov r8d, [r15].h_edit_struct.buf_size	
	.if eax != r8d
		mov rax, 2
		invoke free, [r15].h_edit_struct.buf_ptr
		ret
	.endif
	
	mov rax, 0	; успешное завершение	
    ret
Processing_Edits endp
            
Init_New_Interval_Lenght proc			
		
	finit
	fld [interval_x].left
	fld [interval_x].right
	fsub st(0), st(1)
	fstp [interval_x].lenght
	
	ret
Init_New_Interval_Lenght endp  

; Вычисляет интеграл на отрезке [a,b] для функции func.
;
Integral proc frame a:dword, b:dword, func_code_tmp:dword
	
	local k:dword
	local stop:dword

;---------------- Вычисляем зачение для завершения цикла
	mov eax, b
	sub eax, a
	cdq
	mov ecx, 1000
	imul ecx
	mov [stop], eax
	finit
	fld a
	fst a

;---------------- Цикл
    mov [k], 0
    mov ecx, [k]
    .while ecx <= [stop]
		finit
		fld step ;st 2
		fild a	;st 1
		fild k	;st 0	
		fmul st, st(2)
		fadd st, st(1)

		.if [func_code_tmp] == FUNC_CODE_LOG2 || [func_code_tmp] == FUNC_CODE_LG || [func_code_tmp] == FUNC_CODE_LN || [func_code_tmp] == FUNC_CODE_CTG
			fldz
			fxch				; меняем местами
			fcomi st(0), st(1)	; Она сравнивает параметр c 0
			jz while_inc				; переход, если 0 = параметр
		.endif

		;-------------------------------------
		.if [func_code_tmp] == FUNC_CODE_SIN
			fsin						; Вычисляем синус
		.elseif [func_code_tmp] == FUNC_CODE_COS
			fcos						; Вычисляем косинус
		.elseif [func_code_tmp] == FUNC_CODE_TG
			fptan						; Вычисляем тангенс
			fdivp st(1), st(0)
		.elseif[func_code_tmp] == FUNC_CODE_CTG
			fptan						; Вычисляем котангенс
			fdivp st(1), st(0)
			fld1
			fdiv st(0), st(1)
		.elseif [func_code_tmp] == FUNC_CODE_LOG2
			fld1
			fxch				; поменять местами
			fyl2x
		.elseif [func_code_tmp] == FUNC_CODE_LG
			fld1
			fxch st(1)	
			fyl2x				; Вычисляем log2_X
			fldl2t				; Загружаем в st(0) log2_10
			fdivp st(1), st(0)	; st(1) /= st(0) ; pop => st(0) : log10_X = log2_X / log2_10
		.elseif [func_code_tmp] == FUNC_CODE_LN
			fld1
			fxch st(1)	
			fyl2x				; Вычисляем log2_X
			fldl2e				; Загружаем в st(0) log2_e
			fdivp st(1), st(0)	; st(1) /= st(0) ; pop => st(0) : loge_X = log2_X / log2_e
		.elseif [func_code_tmp] == FUNC_CODE_POLY_EVEN
			fabs
			fld [poly].degree
			fxch
			fyl2x							; Стек содержит: ST(0)=z
			
		    ;Теперь считаем 2^z:
		    fld st(0)						; Создаем еще одну копию z
		    
	  	    fnstcw  [tmpw]					; Сохраняем значение CR
	  	    mov r8w, [mask1]
		    and [tmpw], r8w					; Очищаем 10 и 11 биты
	  	    mov r8w, [mask2]
		    or [tmpw], r8w					; Устанавливаем нужный режим
		    fldcw [tmpw]					; Восстанавливаем
		  
		    frndint							; Округляем ST(0)=trunc(z)
		    fsubr st(0),st(1)				; ST(1)=z, ST(0)=z-trunc(z)
		    f2xm1							; ST(1)=z, ST(0)=2^(z-trunc(z))-1
		    fld1
		    faddp st(1), st(0)				; ST(1)=z, ST(0)=2^(z-trunc(z))
		    fscale							; ST(1)=z, ST(0)=(2^trunc(z))*(2^(z-trunc(z)))
		    fxch st(1)
		    fstp st(0)						; Результат остается на вершине стека ST(0)
			fld [poly].coeff				; Умножаем результат на коэффициент перед х
			fmul st(0), st(1)
		  
		.elseif [func_code_tmp] == FUNC_CODE_POLY_ODD
			fldz
			fucomip st(0), st(1)
			jb skip1
			fabs
			mov [sign_must_be_changed_flag], 1
			skip1:
			fld [poly].degree
			fxch
			fyl2x							; Стек содержит: ST(0)=z
			
			;Теперь считаем 2^z:
		    fld st(0)						; Создаем еще одну копию z
		    
	  	    fnstcw  [tmpw]					; Сохраняем значение CR
	  	    mov r8w, [mask1]
		    and [tmpw], r8w					; Очищаем 10 и 11 биты
	  	    mov r8w, [mask2]
		    or [tmpw], r8w					; Устанавливаем нужный режим
		    fldcw [tmpw]					; Восстанавливаем
		  
		    frndint							; Округляем ST(0)=trunc(z)
		    fsubr st(0),st(1)				; ST(1)=z, ST(0)=z-trunc(z)
		    f2xm1							; ST(1)=z, ST(0)=2^(z-trunc(z))-1
		    fld1
		    faddp st(1), st(0)				; ST(1)=z, ST(0)=2^(z-trunc(z))
		    fscale							; ST(1)=z, ST(0)=(2^trunc(z))*(2^(z-trunc(z)))
		    fxch st(1)
		    fstp st(0)						; Результат остается на вершине стека ST(0)
		    .if [sign_must_be_changed_flag]	; Меняем знак, если х был меньше нуля
				fchs
				mov [sign_must_be_changed_flag], 0
		    .endif
			fld [poly].coeff				; Умножаем результат на коэффициент перед х
			fmul st(0), st(1)
		.endif
		;-----------------------------------------

		fld step
		fmul
		fld intSum 
		fadd st(0), st(1)

		fst intSum 
while_inc:
        inc [k]
        mov ecx, [k]
    .endw

	ret
Integral endp

         
;
; Функция обработки сообщений главного окна приложения.
; Вызывается системой при поступлении сообщения для главного окна
; с соответствующими параметрами.
;
; Агрументы:
;
; hwnd      описатель окна, получившего сообщение
; iMsg      идентификатор (номер) сообщения
; wParam    параметр сообщения
; lParam    параметр сообщения
;
WndProcMain proc frame hwnd:HWND, iMsg:UINT, wParam:WPARAM, lParam:LPARAM

    local hdc:HDC
    local ps:PAINTSTRUCT
    local h_font:HFONT
	local brush:HBRUSH
	local frame_brush:HBRUSH
	local buf[20]:dword

    .if [iMsg] == WM_CREATE
        ; создание окна

		invoke malloc, 100
		mov [edit_interval_left].buf_ptr, rax
		invoke malloc, 100
		mov [edit_interval_right].buf_ptr, rax		
		invoke malloc, 100
		mov [edit_poly_coeff].buf_ptr, rax
		invoke malloc, 100
		mov [edit_poly_degree].buf_ptr, rax
	
		invoke malloc, 50
		mov [graphic_string], rax
		invoke malloc, 50
		mov [interval_x].left_string_ptr, rax
		invoke malloc, 50
		mov [interval_x].right_string_ptr, rax
		
        invoke Create_Buttons, [hwnd]
        
        xor rax, rax
        ret
        
    .elseif [iMsg] == WM_DESTROY
        ; уничтожение окна       
		invoke free, [edit_interval_left].buf_ptr
		invoke free, [edit_interval_right].buf_ptr
		invoke free, [edit_poly_coeff].buf_ptr
		invoke free, [edit_poly_degree].buf_ptr
		;invoke free, [graphic_string]	
		
        invoke PostQuitMessage, 0
        xor rax, rax
        ret
        
    .elseif [iMsg] == WM_SIZE
        ; изменение размера
        
    .elseif [iMsg] == WM_SETFOCUS
        ; получение фокуса
        
    .elseif [iMsg] == WM_CLOSE
        ; закрытие окна
        
    .elseif [iMsg] == WM_QUIT
        ; завершение приложения
        
    .elseif [iMsg] == WM_KEYDOWN
        ;нажание клавиши
        
        .if wParam == VK_SHIFT
        .endif
        
    .elseif [iMsg] == WM_CHAR
        ; ввод с клавиатуры
    
    .elseif [iMsg] == WM_COMMAND
    
		; обработка выбора функции
		.if wParam == BT_1			
			mov [func_code], FUNC_CODE_SIN
			mov [button_pushed_flag], 1
		.elseif wParam == BT_2     			
			mov [func_code], FUNC_CODE_COS
			mov [button_pushed_flag], 1
		.elseif wParam == BT_3			
			mov [func_code], FUNC_CODE_TG
			mov [button_pushed_flag], 1			
		.elseif wParam == BT_4			
			mov [func_code], FUNC_CODE_CTG
			mov [button_pushed_flag], 1			
		.elseif wParam == BT_5			
			mov [func_code], FUNC_CODE_LOG2
			mov [button_pushed_flag], 1			
		.elseif wParam == BT_6			
			mov [func_code], FUNC_CODE_LG
			mov [button_pushed_flag], 1			
		.elseif wParam == BT_7			
			mov [func_code], FUNC_CODE_LN
			mov [button_pushed_flag], 1			
		.elseif wParam == BT_8
			invoke Processing_Edits, addr edit_poly_coeff
			mov [tmpq], rax
			invoke Processing_Edits, addr edit_poly_degree
			or [tmpq], rax
			.if [tmpq] == 0
				; преобразовываем число из строки
				finit
				invoke atoi, [edit_poly_coeff].buf_ptr				
				mov [poly].coeff, eax
				mov [poly_coeff_tmp], eax
				fild [poly].coeff
				fstp [poly].coeff
				invoke atoi, [edit_poly_degree].buf_ptr
				mov [poly].degree, eax	
				mov [tmpd], 2		; проверяем, четная степень или нет		
				fild [tmpd]
				fild [poly].degree
				fst [poly].degree
				fprem				; остаток от деления на 2
				fistp [tmpd]					
				.if [tmpd] == 0					
					mov [func_code], FUNC_CODE_POLY_EVEN
				.elseif [tmpd] == 1
					mov [func_code], FUNC_CODE_POLY_ODD
				.endif
				mov [button_pushed_flag], 1
			.else
				invoke MessageBox, NULL, $CTA0("Incorrect polynom values"), NULL, MB_OK
				mov [buf_is_empty_flag], 0
			.endif
		.endif
		
		.if [button_pushed_flag] == 1

			invoke Processing_Edits, addr edit_interval_left
			mov [tmpq], rax
			invoke Processing_Edits, addr edit_interval_right

			.if [tmpq] == 0
			
				; задаем начальные значения коэффициентов по y
				finit
				fld1
				fstp [y_coeff]
				fldz	
				fstp [y_offset_coeff]			
				
				; преобразовываем число из строки
				finit
				invoke atoi, [edit_interval_left].buf_ptr				
				mov [interval_x].left, eax
				fild [interval_x].left
				fst [interval_x].left				
				invoke atoi, [edit_interval_right].buf_ptr
				mov [interval_x].right, eax	
				fild [interval_x].right
				fst [interval_x].right
				; считаем длину интервала
				fsub st(0), st(1)
				fstp [interval_x].lenght				
				finit
				
				; Проверка на правильность указанного интервала
				fld [interval_x].right
				fld [interval_x].left
				fucomi st(0), st(1)
				jae incorrect_intervals
				invoke InvalidateRect, [hwnd], addr frame_rect, TRUE
				invoke InvalidateRect, [hwnd], addr text_rect, TRUE
				invoke InvalidateRect, [hwnd], addr interval_left_rect, TRUE
				invoke InvalidateRect, [hwnd], addr interval_right_rect, TRUE
				jmp skip_ii				
				incorrect_intervals:
				invoke MessageBox, NULL, $CTA0("Incorrect interval"), NULL, MB_OK
				skip_ii:															
			.else	
				
				invoke MessageBox, NULL, $CTA0("Incorrect interval value"), NULL, MB_OK
				mov [buf_is_empty_flag], 0
				
			.endif
			
			mov [button_pushed_flag], 0
		
		.endif
        
        .if [first_func_was_drawn_flag] == 1
			; обработка нажатия контроллеров функций
			.if wParam == CT_1							; X * 2       
				finit
				mov [tmpd], 2
				fild [tmpd]
				fld [interval_x].right
				fmul st(0), st(1)
				fstp [interval_x].right		
			.elseif wParam == CT_2						; X / 2       
				finit
				mov [tmpd], 2
				fild [tmpd]
				fld [interval_x].right
				fdiv st(0), st(1)
				fstp [interval_x].right	
			.elseif wParam == CT_3						; Y * 2       
				finit
				mov [tmpd], 2
				fild [tmpd]		
				fld [y_coeff]
				fmul st(0), st(1)
				fstp [y_coeff]
			.elseif wParam == CT_4						; Y / 2       	
				finit
				mov [tmpd], 2
				fild [tmpd]	
				fld [y_coeff]
				fdiv st(0), st(1)
				fstp [y_coeff]
				
			.elseif wParam == CT_5						; * 2       
				finit									; X * 2
				mov [tmpd], 2
				fild [tmpd]
				fld [interval_x].right
				fmul st(0), st(1)
				fstp [interval_x].right
  
				finit									; Y * 2
				mov [tmpd], 2
				fild [tmpd]		
				fld [y_coeff]
				fmul st(0), st(1)
				fstp [y_coeff]
					
			.elseif wParam == CT_6						; / 2       
				finit									; X / 2
				mov [tmpd], 2
				fild [tmpd]
				fld [interval_x].right
				fdiv st(0), st(1)
				fstp [interval_x].right			
       	
				finit									; Y / 2
				mov [tmpd], 2
				fild [tmpd]	
				fld [y_coeff]
				fdiv st(0), st(1)
				fstp [y_coeff]	
				
			.elseif wParam == CT_7						; X + 1     	
				finit
				fld1
				fld [interval_x].right
				fadd st(0), st(1)
				fstp [interval_x].right
				
			.elseif wParam == CT_8						; X - 1       	
				finit    
				fld1
				fld [interval_x].left
				fsub st(0), st(1)
				fstp [interval_x].left
				
			.elseif wParam == CT_9						; Y + 1        	
				finit    
				mov [tmpd], 0.2
				fld [tmpd]	
				fld [y_offset_coeff]
				fadd st(0), st(1)
				fstp [y_offset_coeff]
				
			.elseif wParam == CT_10						; Y - 1            	
				finit
				mov [tmpd], 0.2
				fld [tmpd]	
				fld [y_offset_coeff]
				fsub st(0), st(1)
				fstp [y_offset_coeff]     
				
			.elseif wParam == CT_11						; + 1     	
				finit
				fld1
				fld [interval_x].left
				fadd st(0), st(1)
				fstp [interval_x].left
				finit
				fld1
				fld [interval_x].right
				fadd st(0), st(1)
				fstp [interval_x].right
					      
			.elseif wParam == CT_12						; - 1
				finit    
				fld1
				fld [interval_x].left
				fsub st(0), st(1)
				fstp [interval_x].left			
				finit    
				fld1
				fld [interval_x].right
				fsub st(0), st(1)
				fstp [interval_x].right	

			.elseif wParam == CT_13
				invoke atoi, [edit_interval_left].buf_ptr				
				mov ebx, eax		
				invoke atoi, [edit_interval_right].buf_ptr
				mov intSum, 0
				.if [func_code] ==  FUNC_CODE_LOG2 || [func_code] == FUNC_CODE_LG || [func_code] == FUNC_CODE_LN
					cmp ebx, 0
					jg normaly
					invoke Integral, 0, eax, [func_code]
				.else
			
			normaly:
					invoke Integral, ebx, eax, [func_code]
				.endif

				invoke sprintf, addr buf, $CTA0("%7.3f"), intSum
				invoke SetWindowTextA, hIntWindow, addr buf			
			.endif
			invoke Init_New_Interval_Lenght
			invoke InvalidateRect, [hwnd], addr frame_rect, TRUE
			invoke InvalidateRect, [hwnd], addr interval_left_rect, TRUE
			invoke InvalidateRect, [hwnd], addr interval_right_rect, TRUE
		.endif
		
    .elseif [iMsg] == WM_PAINT
        ; перерисовка окна
        
        ; получаем контекст устройства
        invoke BeginPaint, HwndMainWindow, addr ps
        mov [hdc], rax              
        
        invoke GetStockObject,DKGRAY_BRUSH
        mov [frame_brush], rax        
        invoke FrameRect, [hdc], addr frame_rect, [frame_brush]        
        invoke DeleteObject, [frame_brush]
        
        ; установить цвет текста
        invoke SetTextColor, [hdc], NULL      
            
        ; вывод текста на контекст устройства
        invoke TextOut, [hdc], 
			BUTTONS_OFFSET_LEFT, 				
			FIRST_BUTTON_OFFSET_TOP - 25, 
			$CTA0("Functions:"), sizeof($CTA0("Functions:"))			
		invoke TextOut, [hdc], 
			BUTTONS_OFFSET_LEFT, 				
			FIRST_BUTTON_OFFSET_TOP+BUTTON_HEIGHT*COUNT_OF_FUNCTIONS+BUTTONS_MARGIN_TOP*COUNT_OF_FUNCTIONS, 
			$CTA0("Interval:"), sizeof($CTA0("Interval:"))			
		invoke TextOut, [hdc], 
			BUTTONS_OFFSET_LEFT + EDIT_WIDTH/2 - 10, 										; смещение по x							
			FIRST_BUTTON_OFFSET_TOP+BUTTON_HEIGHT*COUNT_OF_FUNCTIONS+BUTTONS_MARGIN_TOP*COUNT_OF_FUNCTIONS + BUTTON_HEIGHT,	; смещение по y
			$CTA0("["), sizeof($CTA0("["))
		invoke TextOut, [hdc], 
			BUTTONS_OFFSET_LEFT+EDIT_WIDTH+EDIT_WIDTH*3/4, 									; смещение по x					
			FIRST_BUTTON_OFFSET_TOP+BUTTON_HEIGHT*COUNT_OF_FUNCTIONS+BUTTONS_MARGIN_TOP*COUNT_OF_FUNCTIONS + BUTTON_HEIGHT,	; смещение по y
			$CTA0(","), sizeof($CTA0(","))
		invoke TextOut, [hdc], 
			BUTTONS_OFFSET_LEFT+2*EDIT_WIDTH+EDIT_WIDTH + 7, 								; смещение по x					
			FIRST_BUTTON_OFFSET_TOP+BUTTON_HEIGHT*COUNT_OF_FUNCTIONS+BUTTONS_MARGIN_TOP*COUNT_OF_FUNCTIONS + BUTTON_HEIGHT,	; смещение по y
			$CTA0("]"), sizeof($CTA0("]"))
		
		; вывод названия текущей функции
		.if [func_code] == FUNC_CODE_SIN   
			mov rax, $CTA0("sin(x)")
			mov [graphic_string], rax
		.elseif [func_code] == FUNC_CODE_COS
			mov rax, $CTA0("cos(x)")
			mov [graphic_string], rax
		.elseif [func_code] == FUNC_CODE_TG
			mov rax, $CTA0("tg(x)")
			mov [graphic_string], rax
		.elseif [func_code] == FUNC_CODE_CTG
			mov rax, $CTA0("ctg(x)")
			mov [graphic_string], rax
		.elseif [func_code] == FUNC_CODE_LOG2
			mov rax, $CTA0("log2(x)")
			mov [graphic_string], rax
		.elseif [func_code] == FUNC_CODE_LG
			mov rax, $CTA0("lg(x)")
			mov [graphic_string], rax
		.elseif [func_code] == FUNC_CODE_LN
			mov rax, $CTA0("ln(x)")
			mov [graphic_string], rax
		.elseif [func_code] == FUNC_CODE_POLY_EVEN || [func_code] == FUNC_CODE_POLY_ODD
			mov rax, $CTA0("poly")
			mov [graphic_string], rax
		.endif
		
		; Рисование графика	
		.if [func_code]
			; функция рисования графика
			invoke Draw_Func, [hdc], [func_code], BlueColor, addr [interval_x]
			
			.if [first_func_was_drawn_flag] != 1
				inc [first_func_was_drawn_flag]
			.endif
		
			invoke strlen, [graphic_string]
			mov [tmpd], eax
			; пишем название графика
			invoke CreateFont, 40, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
			mov [h_font], rax
			invoke SelectObject, [hdc], [h_font]
			invoke TextOut, [hdc],								; выводим текст
			GRAPHIC_REGION_LEFT+GRAPHIC_REGION_WIDTH+10,		; смещение по x					
			COORDOY+GRAPHIC_REGION_HEIGHT/2,					; смещение по y
			[graphic_string], [tmpd]							; длина строки
			invoke DeleteObject, [h_font]
			
			finit
			fld [interval_x].left
			fistp [tmpd]
			invoke _itoa, [tmpd], [interval_x].left_string_ptr, 10
			invoke strlen, [interval_x].left_string_ptr
			mov [tmpd], eax	
									
			; пишем левый интервал
			invoke CreateFont, 30, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
			mov [h_font], rax
			invoke SelectObject, [hdc], [h_font]
			
			mov r9d, [tmpd]
			imul r9d, 18
			mov r8d, GRAPHIC_REGION_LEFT
			sub r8d, r9d
			invoke TextOut, [hdc],								; выводим текст
			r8d,												; смещение по x					
			COORDOY-10,											; смещение по y
			[interval_x].left_string_ptr, [tmpd]				; длина строки
			invoke DeleteObject, [h_font]
			
			finit
			fld [interval_x].right
			fistp [tmpd]
			invoke _itoa, [tmpd], [interval_x].right_string_ptr, 10
			invoke strlen, [interval_x].right_string_ptr
			mov [tmpd], eax
			; пишем правый интервал
			invoke CreateFont, 30, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
			mov [h_font], rax
			invoke SelectObject, [hdc], [h_font]
			invoke TextOut, [hdc],								; выводим текст
			GRAPHIC_REGION_LEFT+GRAPHIC_REGION_WIDTH+10,		; смещение по x					
			COORDOY-10,											; смещение по y
			[interval_x].right_string_ptr, [tmpd]				; длина строки
			invoke DeleteObject, [h_font]					
		.endif
		
		; рисование ординаты и абсциссы
		.if [func_code]
				
			; Проверка интервала на содержание ординаты
			fld [interval_x].left
			fldz
			fucomi st(0), st(1)
			jbe incorrect_left_interval
				mov [func_can_not_be_drawn_flag], 0					
				jmp skip_mark1				
			incorrect_left_interval:
				mov [func_can_not_be_drawn_flag], 1		
			skip_mark1:
			
			fld [interval_x].right
			fldz
			fucomi st(0), st(1)
			jae incorrect_right_interval
				or [func_can_not_be_drawn_flag], 0					
				jmp skip_mark2				
			incorrect_right_interval:
				or [func_can_not_be_drawn_flag], 1		
			skip_mark2:
				
			.if [func_can_not_be_drawn_flag] == 0
				finit
				fld [interval_x].lenght
				mov [tmpd], GRAPHIC_REGION_WIDTH
				fild [tmpd]
				fdiv st(0), st(1)
				fld [interval_x].left
				fchs
				fmul st(0), st(1)
				fistp [ordinate_x_offset_left]
				mov r8d, [ordinate_x_offset_left]
				add r8d, GRAPHIC_REGION_LEFT
				.if r8d >= GRAPHIC_REGION_LEFT && r8d <= GRAPHIC_REGION_RIGHT 					
					invoke DrawOrdinate, [hdc], r8d, GRAPHIC_REGION_BOTTOM, GRAPHIC_REGION_TOP, (30 shl 16) + (150 shl 8) + 255			; startX, startY, endY, color
				.endif
			.endif
				
			finit 
			fld [pixel_price_y]			
			fld [y_offset_coeff]
			fdiv st(0), st(1)			
			mov [tmpd], COORDOY
			fild [tmpd]
			fsub st(0), st(1)
			fistp [tmpd]
			
			.if [func_code] == FUNC_CODE_POLY_EVEN	
				cmp [poly_coeff_tmp], 0
				jg add_mark
				sub [tmpd], GRAPHIC_REGION_HEIGHT/2
				jmp skip_add
				add_mark:				
				add [tmpd], GRAPHIC_REGION_HEIGHT/2
				skip_add:
			.endif
						
			.if [tmpd] >= GRAPHIC_REGION_TOP && [tmpd] <= GRAPHIC_REGION_BOTTOM 
				invoke DrawAbscissa, [hdc], COORDOX, [tmpd], COORDOX+XLENGHT, (30 shl 16) + (150 shl 8) + 255							; startX, startY, endX, color
			.endif					
        .endif  
		
        ; завершение перерисовки
        invoke EndPaint, [hwnd], addr ps
        
        xor rax, rax
        ret
    .endif
    
    ; Необработанные сообщения направляются в функцию
    ; обработки по умолчанию.
    invoke DefWindowProc, hwnd, iMsg, wParam, lParam
    ret

WndProcMain endp

;--------------------
;--------------------


end
