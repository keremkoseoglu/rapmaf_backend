class lhc_Cost definition inheriting from cl_abap_behavior_handler.
  private section.
    methods delete for modify importing keys for delete Cost.

    methods read for read importing keys for read Cost result result.

    methods rba_Document for read
      importing keys_rba for read Cost\_doc full result_requested RESULT result LINK association_links.
endclass.


class lhc_Cost implementation.
  method delete.
    ##todo.
  endmethod.


  method read.
    ##todo.
  endmethod.


  method rba_document.
    ##todo.
  endmethod.
endclass.
