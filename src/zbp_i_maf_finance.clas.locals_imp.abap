CLASS lhc_Finance DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS update FOR MODIFY IMPORTING entities FOR UPDATE Finance.
    METHODS read FOR READ IMPORTING keys FOR READ Finance RESULT result.

    METHODS rba_Document FOR READ
      IMPORTING keys_rba FOR READ Finance\_doc FULL result_requested RESULT result LINK association_links.
ENDCLASS.


CLASS lhc_Finance IMPLEMENTATION.
  METHOD update.
    CHECK entities IS NOT INITIAL.

    SELECT * FROM ztmaf_finance
             FOR ALL ENTRIES IN @entities
             WHERE mafid = @entities-mafid AND
                   matnr = @entities-material
             INTO TABLE @DATA(finances).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<entity>).
      ASSIGN finances[ mafid = <entity>-mafid
                       matnr = <entity>-material
                     ] TO FIELD-SYMBOL(<finance>).

      CHECK sy-subrc = 0.

      <finance>-peinh = COND #( WHEN <entity>-%control-PriceUnit IS NOT INITIAL
                                THEN <entity>-PriceUnit
                                ELSE <finance>-peinh ).

      <finance>-wrbtr = COND #( WHEN <entity>-%control-Price IS NOT INITIAL
                                THEN <entity>-Price
                                ELSE <finance>-wrbtr ).

      MODIFY ztmaf_finance FROM <finance>.

      APPEND VALUE #( mafid    = <finance>-mafid
                      material = <finance>-matnr
                    ) TO mapped-finance.
    ENDLOOP.
  ENDMETHOD.


  METHOD read.
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
      SELECT SINGLE * FROM ztmaf_finance
             WHERE mafid = @<key>-mafid AND
                   matnr = @<key>-material
             INTO @DATA(finance).

      CHECK sy-subrc = 0.
      INSERT CORRESPONDING #( finance MAPPING TO ENTITY ) INTO TABLE result.
    ENDLOOP.
  ENDMETHOD.


  METHOD rba_document.
    CHECK keys_rba IS NOT INITIAL.

    SELECT * FROM ztmaf_doc
           FOR ALL ENTRIES IN @keys_rba
           WHERE mafid = @keys_rba-mafid
           INTO TABLE @DATA(docs).

    LOOP AT keys_rba ASSIGNING FIELD-SYMBOL(<key_rba>).
      LOOP AT docs ASSIGNING FIELD-SYMBOL(<doc>) WHERE mafid = <key_rba>-mafid.

        INSERT VALUE #( source-%key = <key_rba>-%key
                        target-%key = VALUE #( mafid = <doc>-mafid ) )
               INTO TABLE association_links .

        IF result_requested = abap_true.
          INSERT CORRESPONDING #( <doc> MAPPING TO ENTITY ) INTO TABLE result.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
