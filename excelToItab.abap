 TYPES: BEGIN OF gty_table,
        kolon1 TYPE char20,
        kolon2 TYPE char20,
        kolon3 TYPE char20,
       END OF gty_table.

DATA: gt_data TYPE TABLE OF gty_table,
      gs_data TYPE gty_table,
      gt_excel TYPE TABLE OF ALSMEX_TABLINE,
      gs_excel TYPE ALSMEX_TABLINE.

FIELD-SYMBOLS: <gfs_smbol> TYPE ANY.

PARAMETERS: p_file TYPE RLGRAP-FILENAME.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.
  CALL FUNCTION 'F4_FILENAME'
   EXPORTING
*     PROGRAM_NAME        = SYST-CPROG
*     DYNPRO_NUMBER       = SYST-DYNNR
     FIELD_NAME          = 'P_FILE'
   IMPORTING
     FILE_NAME           = P_FILE
            .

START-OF-SELECTION.
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      FILENAME                      = p_file "excell path
      I_BEGIN_COL                   = 1 "baslangıç kkolonu
      I_BEGIN_ROW                   = 1  "baslangıç satır
      I_END_COL                     = 3
      I_END_ROW                     = 9
    TABLES
      INTERN                        = gt_excel "itab
   EXCEPTIONS
     INCONSISTENT_PARAMETERS       = 1
     UPLOAD_OLE                    = 2
     OTHERS                        = 3
            .
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

  LOOP AT gt_excel into gs_excel.
    ASSIGN COMPONENT gs_excel-col OF STRUCTURE GS_DATA TO <GFS_SMBOL>.
    <GFS_SMBOL> = GS_EXCEL-VALUE.
    at END OF row.
      APPEND GS_DATA to GT_DATA.
    endat.
  ENDLOOP. 
