@EndUserText.label: 'MAF finance evaluation'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Search.searchable: true
@Metadata.allowExtensions: true
define view entity ZC_MAF_FINANCE
  as projection on ZI_MAF_FINANCE
{
  key MafId,
      @ObjectModel.text.element: ['MaterialDescription']
  key Material,
      @Search.defaultSearchElement: true
      _material.Description as MaterialDescription,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      Price,
      @Semantics.currencyCode: true
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Currency', element: 'Currency' } }]
      _doc.CurrencyCode     as CurrencyCode,
      PriceUnit,
      /* Associations */
      _doc        : redirected to parent ZC_MAF_DOC,
      _material,
      _production : redirected to ZC_MAF_PROD
}
