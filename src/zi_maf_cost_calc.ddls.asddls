@AbapCatalog.sqlViewName: 'ZMAFV_006'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'MAF cost calculation'
define view ZI_MAF_COST_CALC
  as select from ztmaf_cost_calc
  association        to parent ZI_MAF_DOC as _doc        on  $projection.MafId = _doc.MafId
  association [1..1] to ZI_MAT_PROD       as _production on  $projection.MafId       = _production.MafId
                                                         and $projection.ComponentId = _production.ComponentId
{
  key mafid     as MafId,
  key comp_uuid as ComponentId,
      wrbtr     as Cost,
      _doc,
      _production
}
