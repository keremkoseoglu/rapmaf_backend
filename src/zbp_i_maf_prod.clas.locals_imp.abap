CLASS lhc_production DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    TYPES mafid_list TYPE STANDARD TABLE OF ztmaf_doc-mafid WITH KEY table_line.

    METHODS create FOR MODIFY IMPORTING entities FOR CREATE production.
    METHODS update FOR MODIFY IMPORTING entities FOR UPDATE production.
    METHODS delete FOR MODIFY IMPORTING keys FOR DELETE production.

    METHODS read FOR READ IMPORTING keys FOR READ production RESULT result.

    METHODS rba_document FOR READ
      IMPORTING keys_rba FOR READ production\_doc FULL result_requested RESULT result LINK association_links.
ENDCLASS.


CLASS lhc_production IMPLEMENTATION.
  METHOD create.
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<entity>).
      DATA(prod)     = CORRESPONDING ztmaf_prod( <entity> MAPPING FROM ENTITY USING CONTROL ).
      prod-comp_uuid = cl_system_uuid=>create_uuid_x16_static( ).
      MODIFY ztmaf_prod FROM prod.

      APPEND VALUE #( %cid        = <entity>-%cid
                      mafid       = prod-mafid
                      componentid = prod-comp_uuid
                    ) TO mapped-production.

      zbp_i_maf_doc=>sync_prod_finance( <entity>-mafid ).
    ENDLOOP.
  ENDMETHOD.


  METHOD update.
    CHECK entities IS NOT INITIAL.

    SELECT * FROM ztmaf_prod
             FOR ALL ENTRIES IN @entities
             WHERE mafid     = @entities-mafid AND
                   comp_uuid = @entities-componentid
             INTO TABLE @DATA(prods).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<entity>).
      ASSIGN prods[ mafid     = <entity>-mafid
                    comp_uuid = <entity>-componentid
                  ] TO FIELD-SYMBOL(<prod>).

      CHECK sy-subrc = 0.

      <prod>-matnr = COND #( WHEN <entity>-%control-material IS NOT INITIAL
                             THEN <entity>-material
                             ELSE <prod>-matnr ).

      <prod>-meins = COND #( WHEN <entity>-%control-uom IS NOT INITIAL
                             THEN <entity>-uom
                             ELSE <prod>-meins ).

      <prod>-menge = COND #( WHEN <entity>-%control-quantity IS NOT INITIAL
                             THEN <entity>-quantity
                             ELSE <prod>-menge ).

      MODIFY ztmaf_prod FROM <prod>.

      APPEND VALUE #( mafid       = <prod>-mafid
                      componentid = <prod>-comp_uuid
                    ) TO mapped-production.
    ENDLOOP.

    DATA(mafids) = VALUE mafid_list( FOR GROUPS _grp OF _entity IN entities
                                     GROUP BY _entity-mafid
                                     ( _grp ) ).

    LOOP AT mafids ASSIGNING FIELD-SYMBOL(<mafid>).
      zbp_i_maf_doc=>sync_prod_finance( <mafid> ).
    ENDLOOP.
  ENDMETHOD.


  METHOD delete.
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
      DELETE FROM ztmaf_prod WHERE mafid     = <key>-mafid AND
                                   comp_uuid = <key>-componentid.

      APPEND VALUE #( mafid       = <key>-mafid
                      componentid = <key>-componentid
                    ) TO mapped-production.

      zbp_i_maf_doc=>sync_prod_finance( <key>-mafid ).
    ENDLOOP.
  ENDMETHOD.


  METHOD read.
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
      SELECT SINGLE * FROM ztmaf_prod
             WHERE mafid     = @<key>-mafid AND
                   comp_uuid = @<key>-componentid
             INTO @DATA(prod).

      CHECK sy-subrc = 0.
      INSERT CORRESPONDING #( prod MAPPING TO ENTITY ) INTO TABLE result.
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
