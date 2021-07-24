@AbapCatalog.sqlViewName: 'ZMAFV_001'
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'MAF Document'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
@Search.searchable: true
@Metadata.allowExtensions: true
define root view ZI_MAF_DOC
  as select from    ztmaf_doc
    left outer join ZI_MAF_MARKET as _marketing on _marketing.MafId = ztmaf_doc.mafid
  composition [0..*] of ZI_MAT_PROD      as _production
  composition [0..*] of ZI_MAF_FINANCE   as _finance
  composition [0..*] of ZI_MAF_COST_CALC as _cost
{
      /* Regular fields */
      @Search.defaultSearchElement: true
      @ObjectModel.text.element: ['Description']
  key ztmaf_doc.mafid                 as MafId,
      @Search.defaultSearchElement: true
      ztmaf_doc.stext                 as Description,
      ztmaf_doc.waers                 as CurrencyCode,
      @Semantics.user.createdBy: true
      ztmaf_doc.created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      ztmaf_doc.created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      ztmaf_doc.last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      ztmaf_doc.last_changed_at       as LastChangedAt,
      ztmaf_doc.local_last_changed_at as LocalLastChangedAt,
      ztmaf_doc.approved              as Approved,
      /* Marketing fields */
      @Search.defaultSearchElement: true
      _marketing.MaterialDescription  as MaterialDescription,
      @Semantics.quantity.unitOfMeasure: 'SizeUom'
      _marketing.Length               as Length,
      @Semantics.quantity.unitOfMeasure: 'SizeUom'
      _marketing.Width                as Width,
      @Semantics.quantity.unitOfMeasure: 'SizeUom'
      _marketing.Height               as Height,
      @Semantics.unitOfMeasure: true
      _marketing.SizeUom              as SizeUom,
      @Semantics.quantity.unitOfMeasure: 'VolumeUom'
      _marketing.Volume               as Volume,
      @Semantics.unitOfMeasure: true
      _marketing.VolumeUom            as VolumeUom,
      /* Associations */
      _production,
      _finance,
      _cost
}
