@EndUserText.label: 'MAF production'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_MAF_PROD
  as projection on ZI_MAT_PROD
{
  key MafId,
  key ComponentId,
      ParentId,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_MAF_MATERIAL', element: 'Material' } }]
      @ObjectModel.text.element: ['MaterialDescription']
      Material,
      _material.Description as MaterialDescription,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      Quantity,
      @Semantics.unitOfMeasure: true
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_UnitOfMeasure', element: 'UnitOfMeasure' } }]
      Uom,
      BomLevel,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_MAF_MATERIAL', element: 'Material' } }]
      @ObjectModel.text.element: ['ParentMaterialDescription']
      ParentMaterial,
      ParentMaterialDescription,
      /* Associations */
      _cost    : redirected to ZC_MAF_COST_CALC,
      _doc     : redirected to parent ZC_MAF_DOC,
      _finance : redirected to ZC_MAF_FINANCE,
      _material,
      _parent  : redirected to ZC_MAF_PROD
}
