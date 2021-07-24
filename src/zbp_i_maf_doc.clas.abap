CLASS zbp_i_maf_doc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC
  FOR BEHAVIOR OF zi_maf_doc.

  PUBLIC SECTION.
    CLASS-METHODS sync_prod_finance IMPORTING !mafid TYPE ztmaf_doc-mafid.
    CLASS-METHODS calc_cost IMPORTING !mafid TYPE ztmaf_doc-mafid.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zbp_i_maf_doc IMPLEMENTATION.
  METHOD sync_prod_finance.
    zcl_maf_prod_bom_level_setter=>get_instance( )->execute( mafid ).

    SELECT * FROM ztmaf_prod
             WHERE mafid = @mafid
             INTO TABLE @DATA(prods).

    SELECT * FROM ztmaf_finance
             WHERE mafid = @mafid
             INTO TABLE @DATA(finances).

    LOOP AT prods ASSIGNING FIELD-SYMBOL(<prod>).
      CHECK NOT line_exists( finances[ matnr = <prod>-matnr ] ).
      DATA(new_finance) = VALUE ztmaf_finance( mafid = <prod>-mafid
                                               matnr = <prod>-matnr ).
      INSERT ztmaf_finance FROM new_finance.
    ENDLOOP.

    LOOP AT finances ASSIGNING FIELD-SYMBOL(<finance>).
      CHECK NOT line_exists( prods[ matnr = <finance>-matnr ] ).

      DELETE FROM ztmaf_finance WHERE mafid = <finance>-mafid AND
                                      matnr = <finance>-matnr.
    ENDLOOP.

    calc_cost( mafid ).
  ENDMETHOD.


  METHOD calc_cost.
    SELECT SINGLE * FROM ztmaf_prod
           WHERE mafid = @mafid AND
                 parent_uuid IS INITIAL
           INTO @DATA(prod).

    DATA(cost) = VALUE ztmaf_cost_calc( mafid     = mafid
                                        comp_uuid = prod-comp_uuid
                                        wrbtr     = 123 ).

    MODIFY ztmaf_cost_calc FROM cost.
  ENDMETHOD.
ENDCLASS.
