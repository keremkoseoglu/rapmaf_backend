@AbapCatalog.sqlViewName: 'ZMAFV_004'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'MAF material'
@Search.searchable: true
@Metadata.allowExtensions: true
define view ZI_MAF_MATERIAL
  as select from ztmaf_material
{
      @Search.defaultSearchElement: true
      @ObjectModel.text.element: ['Description']
  key matnr as Material,
      @Search.defaultSearchElement: true
      maktx as Description,
      @Semantics.unitOfMeasure: true
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_UnitOfMeasure', element: 'UnitOfMeasure' } }]
      meins as Uom
}
