*&---------------------------------------------------------------------*
*& Report ZHD_EMAIL_004
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zhd_email_005.


START-OF-SELECTION.

  DATA: go_gbt        TYPE REF TO cl_gbt_multirelated_service,
        go_bcs        TYPE REF TO cl_bcs,
        go_doc_bcs    TYPE REF TO cl_document_bcs,
        go_recipient  TYPE REF TO if_recipient_bcs,
        gt_soli       TYPE TABLE OF soli,
        gs_soli       TYPE soli,
        gv_status     TYPE bcs_rqst,
        gv_content    TYPE string,
        bcs_exception TYPE REF TO cx_bcs.


  DATA: gt_scarr TYPE TABLE OF scarr,
        gs_scarr TYPE scarr. "DİNAMİK VARİABLE GÖNDERMEK İÇİN HTMLDE

START-OF-SELECTION.
  SELECT * FROM scarr INTO TABLE gt_scarr.

  TRY.
      CREATE OBJECT go_gbt.

      gv_content = '  <!DOCTYPE html>                               '
                    &&'<html>                                       '
                    &&'  <head>                                      '
                    &&'   <meta charset="utf-8">                    '
                    &&'        <style>                              '
                    &&'        th{                                  '
                    &&'          background-color: lightgreen;       '
                    &&'            border: 4px solid;               '
                    &&'          }                                   '
                    &&'        td{                                  '
                    &&'          background-color: lightblue;        '
                    &&'            border: 2px solid;               '
                    &&'          }                                   '
                    &&'        </style>                             '
                    &&'    </head>                                  '
                    &&'  <body>                                      '
                    &&'   <table>                                   '
                    &&'          <tr>                                '
                    &&'                 <th>Mandt</th>               '
                    &&'                <th>Kısa Tnım</th>           '
                    &&'                <th>Adı</th>                 '
                    &&'                <th>Para Birimi</th>         '
                    &&'                <th>URL</th>                 '
                    &&'         </tr>                               '.

      LOOP AT gt_scarr INTO gs_scarr.
        gv_content = gv_content
                  &&'         <tr>                                                      '
                  &&'                 <td>'&& gs_scarr-mandt && '</td>                   '
                  &&'                 <td>'&& gs_scarr-carrid && '</td>                  '
                  &&'                 <td>'&& gs_scarr-carrname && '</td>                '
                  &&'                 <td>'&& gs_scarr-currcode && '</td>                '
                  &&'                 <td>'&& gs_scarr-url && '</td>                     '
                  &&'         </tr>                                                     '.
      ENDLOOP.

      gv_content = gv_content
      &&'   </table>                                  '
      &&'  </body>                                     '
      &&'                                             '
      &&'</html>                                      '.


      gt_soli = cl_document_bcs=>string_to_soli( gv_content )."içerik itab olur

      CALL METHOD go_gbt->set_main_html "gbtye içeriği bağladık
        EXPORTING
          content = gt_soli.

      go_doc_bcs = cl_document_bcs=>create_from_multirelated("mail başlığı ve gövdeyi bağladık
                     i_subject          = 'Mail Başlığı'
                     i_multirel_service = go_gbt
                 ).

      go_recipient = cl_cam_address_bcs=>create_internet_address("alıcı ekleme
                       i_address_string = 'hamzaefe44@hotmail.com'
                   ).

      go_bcs = cl_bcs=>create_persistent( )."işlem başlatma
      go_bcs->set_document( i_document = go_doc_bcs )."documanı ekleme
      go_bcs->add_recipient("alıcı eklme
        EXPORTING
          i_recipient     = go_recipient ).

      gv_status = 'N'."mail durumu hakkında geri dönüş yapar
      CALL METHOD go_bcs->set_status_attributes
        EXPORTING
          i_requested_status = gv_status.
      .

      go_bcs->send( )."gönderme
      COMMIT WORK.
    CATCH cx_bcs INTO bcs_exception.

  ENDTRY. 
