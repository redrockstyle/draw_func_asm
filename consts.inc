; Константы проекта

; Коды функций
FUNC_CODE_SIN				equ		1
FUNC_CODE_COS				equ		2
FUNC_CODE_TG				equ		3
FUNC_CODE_CTG				equ		4
FUNC_CODE_LOG2				equ		5
FUNC_CODE_LG				equ		6
FUNC_CODE_LN				equ		7
FUNC_CODE_POLY_EVEN			equ		8
FUNC_CODE_POLY_ODD			equ		9

; Максимумы функций
; sin / cos
FMAX_SIN_COS				equ		1.0
FMIN_SIN_COS				equ		-1.0
; tg / ctg
FMAX_TG_CTG					equ		20.0
FMIN_TG_CTG					equ		-20.0
; log2 / log / ln
FMAX_LOG					equ		10.0
FMIN_LOG					equ		-10.0
; x^(y mod 2 == 0)
FMAX_POLY_EVEN				equ		10.0
FMIN_POLY_EVEN				equ		0.0
; x^(y mod 2 == 1)
FMAX_POLY_ODD				equ		10.0
FMIN_POLY_ODD				equ		-10.0

; Размеры главного окна
WINDOW_WIDTH				equ		1100
WINDOW_HEIGHT				equ		700

; Размеры окна рисования графика
GRAPHIC_REGION_LEFT			equ		150
GRAPHIC_REGION_TOP			equ		50
GRAPHIC_REGION_RIGHT		equ		GRAPHIC_REGION_LEFT+GRAPHIC_REGION_WIDTH
GRAPHIC_REGION_BOTTOM		equ		GRAPHIC_REGION_TOP+GRAPHIC_REGION_HEIGHT
GRAPHIC_REGION_WIDTH		equ		600
GRAPHIC_REGION_HEIGHT		equ		500

; Координаты осей
COORDOX						equ		GRAPHIC_REGION_LEFT
COORDOXHALF					equ		COORDOX/2
COORDOY						equ		GRAPHIC_REGION_TOP + GRAPHIC_REGION_HEIGHT/2
COORDOYHALF					equ		COORDOY/2

; Длины осей
XLENGHT						equ		GRAPHIC_REGION_WIDTH
YLENGHT						equ		GRAPHIC_REGION_HEIGHT
XLENGHTHALF					equ		XLENGHT/2
YLENGHTHALF					equ		YLENGHT/2

; Размеры кнопок
BUTTON_WIDTH				equ		100
BUTTON_HEIGHT				equ		30
BUTTONS_MARGIN_TOP			equ		20
FIRST_BUTTON_OFFSET_TOP		equ		100
BUTTONS_OFFSET_LEFT			equ		850
COUNT_OF_FUNCTIONS			equ		8

EDIT_WIDTH					equ		30
EDIT_HEIGHT					equ		30

; Размеры управляющих элементов (кнопок)
FIRST_CONTROL_OFFSET_TOP	equ		100
SCALE_OFFSET_LEFT			equ		562
SCALE_OFFSET_TOP			equ		148
SCALE_SHIFT_CONTROL			equ		60
SCALE_SHIFT_CONTROLS		equ		80
CONTROLS_MARGIN_TOP			equ		20
CONTROLS_MARGIN_LEFT		equ		10
CONTROLS_OFFSET_LEFT		equ		BUTTONS_OFFSET_LEFT - CONTROL_WIDTH*2 - CONTROLS_MARGIN_LEFT*3
CONTROL_WIDTH				equ		50
CONTROL_HEIGHT				equ		30

; Идентификаторы
ED_1 equ 201
ED_2 equ 202
ED_3 equ 202     ; Идентификатор левого края интервала
ED_4 equ 202     ; Идентификатор правого края интервала
ED_INT equ 203

; Идентификаторы кнопок
BT_1 equ 204
BT_2 equ 205
BT_3 equ 206
BT_4 equ 207
BT_5 equ 208
BT_6 equ 209
BT_7 equ 210
BT_8 equ 211

; Идентификаторы контрольных кнопок
CT_1 equ 221     
CT_2 equ 222
CT_3 equ 223
CT_4 equ 224
CT_5 equ 225
CT_6 equ 226
CT_7 equ 227
CT_8 equ 228
CT_9 equ 229
CT_10 equ 230
CT_11 equ 231
CT_12 equ 232
CT_13 equ 233
CT_14 equ 234


