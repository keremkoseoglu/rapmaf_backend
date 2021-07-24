@AbapCatalog.sqlViewName: 'ZMAFV_005'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'MAF finance evaluation'
@Search.searchable: true
define view ZI_MAF_FINANCE
  as select from ztmaf_finance
  association        to parent ZI_MAF_DOC as _doc        on  $projection.MafId = _doc.MafId
  association [1..1] to ZI_MAF_MATERIAL   as _material   on  _material.Material = $projection.Material
  association [1..*] to ZI_MAT_PROD       as _production on  _production.MafId    = $projection.MafId
                                                         and _production.Material = $projection.Material
{
  key mafid             as MafId,
      @Search.defaultSearchElement: true
  key matnr             as Material,
      @Semantics.amount.currencyCode: '_doc.CurrencyCode'
      wrbtr             as Price,
      @Semantics.currencyCode: true
      _doc.CurrencyCode as CurrencyCode,
      peinh             as PriceUnit,
      _doc,
      _material,
      _production
}
