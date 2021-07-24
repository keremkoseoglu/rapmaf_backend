@AbapCatalog.sqlViewName: 'ZMAFV_003'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'MAF production data'
@Metadata.allowExtensions: true
define view ZI_MAT_PROD
  as select from    ztmaf_prod

    left outer join ztmaf_prod     as _lj_parent     on  _lj_parent.mafid     = ztmaf_prod.mafid
                                                     and _lj_parent.comp_uuid = ztmaf_prod.parent_uuid

    left outer join ztmaf_material as _lj_parent_mat on _lj_parent_mat.matnr = _lj_parent.matnr

  association        to parent ZI_MAF_DOC as _doc      on  $projection.MafId = _doc.MafId
  association [0..1] to ZI_MAF_MATERIAL   as _material on  $projection.Material = _material.Material
  association [0..1] to ZI_MAT_PROD       as _parent   on  $projection.MafId    = _parent.MafId
                                                       and $projection.ParentId = _parent.ComponentId
  association [0..1] to ZI_MAF_FINANCE    as _finance  on  $projection.MafId    = _finance.MafId
                                                       and $projection.Material = _finance.Material
  association [0..1] to ZI_MAF_COST_CALC  as _cost     on  $projection.MafId       = _cost.MafId
                                                       and $projection.ComponentId = _cost.ComponentId
{
  key ztmaf_prod.mafid       as MafId,
  key ztmaf_prod.comp_uuid   as ComponentId,
      ztmaf_prod.parent_uuid as ParentId,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_MAF_MATERIAL', element: 'Material' } }]
      ztmaf_prod.matnr       as Material,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      ztmaf_prod.menge       as Quantity,
      @Semantics.unitOfMeasure: true
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_UnitOfMeasure', element: 'UnitOfMeasure' } }]
      ztmaf_prod.meins       as Uom,
      ztmaf_prod.bom_level   as BomLevel,
      _lj_parent.matnr       as ParentMaterial,
      _lj_parent_mat.maktx   as ParentMaterialDescription,
      _doc,
      _material,
      _parent,
      _finance,
      _cost
}
