*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 16.07.2021 at 08:32:16
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZTMAF_MATERIAL..................................*
DATA:  BEGIN OF STATUS_ZTMAF_MATERIAL                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTMAF_MATERIAL                .
CONTROLS: TCTRL_ZTMAF_MATERIAL
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZTMAF_MATERIAL                .
TABLES: ZTMAF_MATERIAL                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
