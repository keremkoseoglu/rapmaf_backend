CLASS zcl_maf_prod_bom_level_setter DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.
    CLASS-METHODS get_instance RETURNING VALUE(result) TYPE REF TO zcl_maf_prod_bom_level_setter.
    METHODS execute IMPORTING !mafid TYPE ztmaf_prod-mafid.
  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES prod_list TYPE STANDARD TABLE OF ztmaf_prod WITH EMPTY KEY.

    TYPES: BEGIN OF state_dict,
             mafid TYPE ztmaf_prod-mafid,
             prods TYPE prod_list,
           END OF state_dict.

    CLASS-DATA singleton TYPE REF TO zcl_maf_prod_bom_level_setter.
    DATA state TYPE state_dict.

    METHODS read_prod.
    METHODS set_bom_levels.
    METHODS write_prod.
    METHODS set_bom_levels_of_parent
      IMPORTING !parent_uuid      TYPE ztmaf_prod-parent_uuid
                !parent_bom_level TYPE ztmaf_prod-bom_level.
ENDCLASS.



CLASS zcl_maf_prod_bom_level_setter IMPLEMENTATION.
  METHOD get_instance.
    result = zcl_maf_prod_bom_level_setter=>singleton.

    IF result IS INITIAL.
      result = NEW #( ).
    ENDIF.
  ENDMETHOD.


  METHOD execute.
    me->state = VALUE #( mafid = mafid ).
    read_prod( ).
    set_bom_levels( ).
    write_prod( ).
  ENDMETHOD.


  METHOD read_prod.
    SELECT * FROM ztmaf_prod
             WHERE mafid = @me->state-mafid
             INTO CORRESPONDING FIELDS OF TABLE @me->state-prods.
  ENDMETHOD.


  METHOD set_bom_levels.
    DATA empty_uuid TYPE ztmaf_prod-parent_uuid.

    MODIFY me->state-prods FROM VALUE #( bom_level = 0 )
                           TRANSPORTING bom_level
                           WHERE parent_uuid = empty_uuid.

    set_bom_levels_of_parent( parent_uuid      = empty_uuid
                              parent_bom_level = 0 ).
  ENDMETHOD.


  METHOD write_prod.
    MODIFY ztmaf_prod FROM TABLE @me->state-prods.
  ENDMETHOD.


  METHOD set_bom_levels_of_parent.
    DATA(child_bom_level) = parent_bom_level + 1.

    LOOP AT me->state-prods ASSIGNING FIELD-SYMBOL(<prod>)
                            WHERE parent_uuid = parent_uuid.

      <prod>-bom_level = parent_bom_level.

      set_bom_levels_of_parent( parent_uuid      = <prod>-comp_uuid
                                parent_bom_level = child_bom_level ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
