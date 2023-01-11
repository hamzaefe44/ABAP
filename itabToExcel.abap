*&---------------------------------------------------------------------*
*& Report ZHD_EXCEL_002
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZHD_EXCEL_002.
" ITAB SAVE AS EXCEL
TYPES: BEGIN OF GTY_HEADER, "excel başlıkları
        line TYPE char30,
       END OF GTY_HEADER.


DATA: gv_filename TYPE STRING.

DATA: gt_scarr TYPE TABLE OF scarr,
      gt_header TYPE TABLE OF GTY_HEADER,
      gs_header TYPE GTY_HEADER.

PARAMETERS: p_path TYPE string.

at SELECTION-SCREEN ON VALUE-REQUEST FOR p_path.
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>DIRECTORY_BROWSE "dosya konumu almayı sağlar
*    EXPORTING
*      WINDOW_TITLE         =
*      INITIAL_FOLDER       =
    CHANGING
      SELECTED_FOLDER      = p_path
    EXCEPTIONS
      CNTL_ERROR           = 1
      ERROR_NO_GUI         = 2
      NOT_SUPPORTED_BY_GUI = 3
      others               = 4
          .


START-OF-SELECTION.

  SELECT *
    FROM scarr
    INTO TABLE gt_scarr.

  CONCATENATE p_path '\' sy-uname
              'den' sy-uzeit '.xls'
              INTO gv_filename.

  GS_HEADER-LINE = 'mandt'.
  APPEND GS_HEADER TO GT_HEADER.
  GS_HEADER-LINE = 'Kısa Tanım'.
  APPEND GS_HEADER TO GT_HEADER.
  GS_HEADER-LINE = 'Hş ad'.
  APPEND GS_HEADER TO GT_HEADER.
  GS_HEADER-LINE = 'Para Birimi'.
  APPEND GS_HEADER TO GT_HEADER.
  GS_HEADER-LINE = 'URL'.
  APPEND GS_HEADER TO GT_HEADER.

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
     FILENAME                        = gv_filename   " dosya path + name
     FILETYPE                        = 'ASC'
     WRITE_FIELD_SEPARATOR           = 'X' "KOLON BAZINDA AYARLAMA YAPAR(her bir kolan itabdakii kolana denk gelecek şekilde)
    TABLES
     DATA_TAB                        = gt_scarr
     FIELDNAMES                      = GT_HEADER
   . 
