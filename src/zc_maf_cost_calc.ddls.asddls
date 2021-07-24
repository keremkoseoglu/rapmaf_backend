@EndUserText.label: 'MAF cost calculation'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Search.searchable: true
@Metadata.allowExtensions: true
define view entity ZC_MAF_COST_CALC
  as projection on ZI_MAF_COST_CALC
{
  key MafId,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_MAT_PROD', element: 'ComponentId' } }]
  key ComponentId,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_MAF_MATERIAL', element: 'Material' } }]
      @ObjectModel.text.element: ['MaterialDescription']
      _production.Material              as Material,
      @Search.defaultSearchElement: true
      _production._material.Description as MaterialDescription,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      Cost,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Currency', element: 'Currency' } }]
      _doc.CurrencyCode                 as CurrencyCode,
      /* Associations */
      _doc        : redirected to parent ZC_MAF_DOC,
      _production : redirected to ZC_MAF_PROD
}
