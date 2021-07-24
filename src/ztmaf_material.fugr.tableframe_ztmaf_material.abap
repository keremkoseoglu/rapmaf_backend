*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZTMAF_MATERIAL
*   generation date: 16.07.2021 at 08:32:16
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZTMAF_MATERIAL     .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
