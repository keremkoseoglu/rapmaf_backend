CLASS lhc_document DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS create FOR MODIFY IMPORTING entities FOR CREATE document.
    METHODS update FOR MODIFY IMPORTING entities FOR UPDATE document.
    METHODS delete FOR MODIFY IMPORTING keys FOR DELETE document.
    METHODS read FOR READ IMPORTING keys FOR READ document RESULT result.
    METHODS lock FOR LOCK IMPORTING keys FOR LOCK document.

    METHODS rba_cost FOR READ
      IMPORTING keys_rba FOR READ document\_cost FULL result_requested RESULT result LINK association_links.

    METHODS rba_finance FOR READ
      IMPORTING keys_rba FOR READ document\_finance FULL result_requested RESULT result LINK association_links.

    METHODS rba_production FOR READ
      IMPORTING keys_rba FOR READ document\_production FULL result_requested RESULT result LINK association_links.

    METHODS cba_production FOR MODIFY
      IMPORTING entities_cba FOR CREATE document\_production.

    METHODS get_instance_features FOR FEATURES
      IMPORTING keys REQUEST requested_features FOR document RESULT result.

    METHODS acceptdoc FOR MODIFY
      IMPORTING keys FOR ACTION document~approvedoc RESULT result.

    METHODS rejectdoc FOR MODIFY
      IMPORTING keys FOR ACTION document~rejectdoc RESULT result.
ENDCLASS.


CLASS lhc_document IMPLEMENTATION.
  METHOD create.
    SELECT MAX( mafid ) FROM ztmaf_doc INTO @DATA(mafid).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<entity>).
      mafid           = mafid + 1.
      DATA(doc)       = CORRESPONDING ztmaf_doc( <entity> MAPPING FROM ENTITY USING CONTROL ).
      doc-mafid       = mafid.
      doc-created_by  = sy-uname.
      doc-created_at  = |{ sy-datum }{ sy-uzeit }|.
      INSERT ztmaf_doc FROM doc.

      DATA(mar)       = CORRESPONDING ztmaf_market( <entity> MAPPING FROM ENTITY USING CONTROL ).
      mar-mafid       = mafid.
      INSERT ztmaf_market FROM mar.

      APPEND VALUE #( %cid  = <entity>-%cid
                      mafid = doc-mafid
                    ) TO mapped-document.
    ENDLOOP.
  ENDMETHOD.


  METHOD update.
    CHECK entities IS NOT INITIAL.

    SELECT * FROM ztmaf_doc
             FOR ALL ENTRIES IN @entities
             WHERE mafid = @entities-mafid
             INTO TABLE @DATA(docs).

    SELECT * FROM ztmaf_market
             FOR ALL ENTRIES IN @entities
             WHERE mafid = @entities-mafid
             INTO TABLE @DATA(markets).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<entity>).
      ASSIGN docs[ mafid = <entity>-mafid ] TO FIELD-SYMBOL(<doc>).
      CHECK sy-subrc = 0.
      <doc>-last_changed_at = |{ sy-datum }{ sy-uzeit }|.
      <doc>-last_changed_by = sy-uname.

      <doc>-stext = COND #( WHEN <entity>-%control-description IS INITIAL
                            THEN <doc>-stext
                            ELSE <entity>-description ).

      <doc>-waers = COND #( WHEN <entity>-%control-currencycode IS INITIAL
                            THEN <doc>-waers
                            ELSE <entity>-currencycode ).

      <doc>-approved = COND #( WHEN <entity>-%control-approved IS INITIAL
                               THEN <doc>-approved
                               ELSE <entity>-approved ).

      MODIFY ztmaf_doc FROM <doc>.

      ASSIGN markets[ mafid = <entity>-mafid ] TO FIELD-SYMBOL(<market>).
      IF sy-subrc <> 0.
        APPEND VALUE #( mafid = <entity>-mafid ) TO markets ASSIGNING <market>.
      ENDIF.

      <market>-maktx = COND #( WHEN <entity>-%control-materialdescription IS INITIAL
                               THEN <market>-maktx
                               ELSE <entity>-materialdescription ).

      <market>-length = COND #( WHEN <entity>-%control-length IS INITIAL
                               THEN <market>-length
                               ELSE <entity>-length ).

      <market>-width = COND #( WHEN <entity>-%control-width IS INITIAL
                               THEN <market>-width
                               ELSE <entity>-width ).

      <market>-height = COND #( WHEN <entity>-%control-height IS INITIAL
                               THEN <market>-height
                               ELSE <entity>-height ).

      <market>-meabm = COND #( WHEN <entity>-%control-sizeuom IS INITIAL
                               THEN <market>-meabm
                               ELSE <entity>-sizeuom ).

      <market>-volum = COND #( WHEN <entity>-%control-volume IS INITIAL
                               THEN <market>-volum
                               ELSE <entity>-volume ).

      <market>-voleh = COND #( WHEN <entity>-%control-volumeuom IS INITIAL
                               THEN <market>-voleh
                               ELSE <entity>-volumeuom ).

      <market>-height = COND #( WHEN <entity>-%control-height IS INITIAL
                                THEN <market>-height
                                ELSE <entity>-height ).

      MODIFY ztmaf_market FROM <market>.

      APPEND VALUE #( mafid = <doc>-mafid ) TO mapped-document.
    ENDLOOP.
  ENDMETHOD.


  METHOD delete.
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
      DELETE FROM ztmaf_doc WHERE mafid = <key>-mafid.
      DELETE FROM ztmaf_market WHERE mafid = <key>-mafid.
      APPEND VALUE #( mafid = <key>-mafid ) TO mapped-document.
    ENDLOOP.
  ENDMETHOD.


  METHOD read.
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
      SELECT SINGLE * FROM ztmaf_doc
             WHERE mafid = @<key>-mafid
             INTO @DATA(doc).

      CHECK sy-subrc = 0.

      SELECT SINGLE * FROM ztmaf_market
             WHERE mafid = @<key>-mafid
             INTO @DATA(market).

      IF sy-subrc <> 0.
        CLEAR market.
      ENDIF.

      INSERT CORRESPONDING #( doc MAPPING TO ENTITY ) INTO TABLE result ASSIGNING FIELD-SYMBOL(<result>).
      <result>-height     = market-height.
      <result>-length     = market-length.
      <result>-sizeuom    = market-meabm.
      <result>-volume     = market-volum.
      <result>-volumeuom  = market-voleh.
      <result>-width      = market-width.

      zbp_i_maf_doc=>sync_prod_finance( <key>-mafid ).
    ENDLOOP.
  ENDMETHOD.


  METHOD lock.
    TRY.
        DATA(lock) = cl_abap_lock_object_factory=>get_instance( 'EZMAFID' ).

        LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
          TRY.
              lock->enqueue( it_parameter = VALUE #( ( name  = 'MAFID'
                                                       value = REF #( <key>-mafid ) ) ) ).

            CATCH cx_abap_foreign_lock INTO DATA(lock_error).
              APPEND VALUE #( mafid = <key>-mafid ) TO failed-document.

              APPEND VALUE #( mafid = <key>-mafid
                              %msg  = new_message_with_text( severity = CONV #( 'E' )
                                                             text     = lock_error->get_text( ) )
                            ) TO reported-document.
          ENDTRY.
        ENDLOOP.

      CATCH cx_root INTO DATA(diaper).
        LOOP AT keys ASSIGNING <key>.
          APPEND VALUE #( mafid = <key>-mafid ) TO failed-document.

          APPEND VALUE #( mafid = <key>-mafid
                          %msg  = new_message_with_text( severity = CONV #( 'E' )
                                                         text     = diaper->get_text( ) )
                        ) TO reported-document.
        ENDLOOP.
    ENDTRY.
  ENDMETHOD.


  METHOD rba_cost.
    CHECK keys_rba IS NOT INITIAL.

    LOOP AT keys_rba ASSIGNING FIELD-SYMBOL(<key_rba>).
      zbp_i_maf_doc=>calc_cost( <key_rba>-mafid ).
    ENDLOOP.

    SELECT * FROM ztmaf_cost_calc
           FOR ALL ENTRIES IN @keys_rba
           WHERE mafid = @keys_rba-mafid
           INTO TABLE @DATA(calcs).

    LOOP AT keys_rba ASSIGNING <key_rba>.
      LOOP AT calcs ASSIGNING FIELD-SYMBOL(<calc>) WHERE mafid = <key_rba>-mafid.

        INSERT VALUE #( source-%key = <key_rba>-%key
                        target-%key = VALUE #( mafid       = <calc>-mafid
                                               componentid = <calc>-comp_uuid ) )
               INTO TABLE association_links .

        IF result_requested = abap_true.
          INSERT CORRESPONDING #( <calc> MAPPING TO ENTITY ) INTO TABLE result.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.


  METHOD rba_finance.
    CHECK keys_rba IS NOT INITIAL.

    LOOP AT keys_rba ASSIGNING FIELD-SYMBOL(<key_rba>).
      zbp_i_maf_doc=>sync_prod_finance( <key_rba>-mafid ).
    ENDLOOP.

    SELECT * FROM ztmaf_finance
           FOR ALL ENTRIES IN @keys_rba
           WHERE mafid = @keys_rba-mafid
           INTO TABLE @DATA(finances).

    LOOP AT keys_rba ASSIGNING <key_rba>.
      LOOP AT finances ASSIGNING FIELD-SYMBOL(<finance>) WHERE mafid = <key_rba>-mafid.

        INSERT VALUE #( source-%key = <key_rba>-%key
                        target-%key = VALUE #( mafid    = <finance>-mafid
                                               material = <finance>-matnr ) )
               INTO TABLE association_links .

        IF result_requested = abap_true.
          INSERT CORRESPONDING #( <finance> MAPPING TO ENTITY ) INTO TABLE result.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.


  METHOD rba_production.
    CHECK keys_rba IS NOT INITIAL.

    LOOP AT keys_rba ASSIGNING FIELD-SYMBOL(<key_rba>).
      zbp_i_maf_doc=>sync_prod_finance( <key_rba>-mafid ).
    ENDLOOP.

    SELECT * FROM ztmaf_prod
           FOR ALL ENTRIES IN @keys_rba
           WHERE mafid = @keys_rba-mafid
           INTO TABLE @DATA(prods).

    LOOP AT keys_rba ASSIGNING <key_rba>.
      LOOP AT prods ASSIGNING FIELD-SYMBOL(<prod>) WHERE mafid = <key_rba>-mafid.

        INSERT VALUE #( source-%key = <key_rba>-%key
                        target-%key = VALUE #( mafid       = <prod>-mafid
                                               componentid = <prod>-comp_uuid ) )
               INTO TABLE association_links .

        IF result_requested = abap_true.
          INSERT CORRESPONDING #( <prod> MAPPING TO ENTITY ) INTO TABLE result.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.


  METHOD cba_production.
    LOOP AT entities_cba ASSIGNING FIELD-SYMBOL(<entity_cba>).
      LOOP AT <entity_cba>-%target ASSIGNING FIELD-SYMBOL(<target>).
        DATA(prod)     = CORRESPONDING ztmaf_prod( <target> MAPPING FROM ENTITY USING CONTROL ).
        prod-comp_uuid = cl_system_uuid=>create_uuid_x16_static( ).
        prod-mafid     = <entity_cba>-mafid.
        INSERT ztmaf_prod FROM prod.

        INSERT VALUE #( %cid        = <target>-%cid
                        mafid       = <target>-mafid
                        componentid = <target>-componentid
                      ) INTO TABLE mapped-production.
      ENDLOOP.

      zbp_i_maf_doc=>sync_prod_finance( <entity_cba>-mafid ).
    ENDLOOP.
  ENDMETHOD.


  METHOD get_instance_features.
    CHECK keys IS NOT INITIAL.

    SELECT mafid, approved
           FROM ztmaf_doc
           FOR ALL ENTRIES IN @keys
           WHERE mafid = @keys-mafid
           INTO TABLE @DATA(docs).

    LOOP AT docs ASSIGNING FIELD-SYMBOL(<doc>).
      APPEND VALUE #( mafid = <doc>-mafid ) TO result ASSIGNING FIELD-SYMBOL(<result>).

      <result>-%action-approvedoc =
        SWITCH #( <doc>-approved
                  WHEN abap_true
                  THEN if_abap_behv=>fc-o-disabled
                  ELSE if_abap_behv=>fc-o-enabled ).


      <result>-%action-rejectdoc =
        SWITCH #( <doc>-approved
                  WHEN abap_true
                  THEN if_abap_behv=>fc-o-enabled
                  ELSE if_abap_behv=>fc-o-disabled ).
    ENDLOOP.
  ENDMETHOD.


  METHOD acceptdoc.
    CHECK keys IS NOT INITIAL.

    SELECT * FROM zi_maf_doc
             FOR ALL ENTRIES IN @keys
             WHERE mafid = @keys-mafid
             INTO TABLE @DATA(docs).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
      ASSIGN docs[ mafid = <key>-mafid ] TO FIELD-SYMBOL(<doc>).
      CHECK sy-subrc = 0.

      UPDATE ztmaf_doc SET approved = abap_true
                       WHERE mafid  = <key>-mafid.

      <doc>-approved = abap_true.

      APPEND VALUE #( mafid = <key>-mafid ) TO mapped-document.

      APPEND VALUE #( mafid  = <key>-mafid
                      %param = <doc>
                    ) TO result.
    ENDLOOP.
  ENDMETHOD.


  METHOD rejectdoc.
    CHECK keys IS NOT INITIAL.

    SELECT * FROM zi_maf_doc
             FOR ALL ENTRIES IN @keys
             WHERE mafid = @keys-mafid
             INTO TABLE @DATA(docs).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
      ASSIGN docs[ mafid = <key>-mafid ] TO FIELD-SYMBOL(<doc>).
      CHECK sy-subrc = 0.

      UPDATE ztmaf_doc SET approved = abap_false
                       WHERE mafid  = <key>-mafid.

      <doc>-approved = abap_false.

      APPEND VALUE #( mafid = <key>-mafid ) TO mapped-document.

      APPEND VALUE #( mafid  = <key>-mafid
                      %param = <doc>
                    ) TO result.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
