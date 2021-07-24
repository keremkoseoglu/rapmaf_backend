@AbapCatalog.sqlViewName: 'ZMAFV_002'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'MAF marketing'
@Search.searchable: true
define view ZI_MAF_MARKET
  as select from ztmaf_market
{
      @ObjectModel.text.element: ['MaterialDescription']
  key mafid  as MafId,
      @Search.defaultSearchElement: true
      maktx  as MaterialDescription,
      @Semantics.quantity.unitOfMeasure: 'SizeUom'
      length as Length,
      @Semantics.quantity.unitOfMeasure: 'SizeUom'
      width  as Width,
      @Semantics.quantity.unitOfMeasure: 'SizeUom'
      height as Height,
      @Semantics.unitOfMeasure: true
      meabm  as SizeUom,
      @Semantics.quantity.unitOfMeasure: 'VolumeUom'
      volum  as Volume,
      @Semantics.unitOfMeasure: true
      voleh  as VolumeUom
}
