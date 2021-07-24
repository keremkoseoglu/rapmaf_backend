@EndUserText.label: 'MAF document'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Search.searchable: true
@Metadata.allowExtensions: true
define root view entity ZC_MAF_DOC
  as projection on ZI_MAF_DOC
{
      /* Regular fields */
      @ObjectModel.text.element: ['Description']
  key MafId,
      @Search.defaultSearchElement: true
      Description,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Currency', element: 'Currency' } }]
      CurrencyCode,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      Approved,
      /* Fields pulled from marketing */
      MaterialDescription,
      @Semantics.quantity.unitOfMeasure: 'SizeUom'
      Width,
      @Semantics.quantity.unitOfMeasure: 'SizeUom'
      Height,
      @Semantics.quantity.unitOfMeasure: 'SizeUom'
      Length,
      @Semantics.unitOfMeasure: true
      SizeUom,
      @Semantics.quantity.unitOfMeasure: 'VolumeUom'
      Volume,
      @Semantics.unitOfMeasure: true
      VolumeUom,
      /* Associations */
      _cost       : redirected to composition child ZC_MAF_COST_CALC,
      _finance    : redirected to composition child ZC_MAF_FINANCE,
      _production : redirected to composition child ZC_MAF_PROD
}
