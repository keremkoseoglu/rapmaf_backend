sap.ui.define(["sap/base/Log","sap/ui/table/library","sap/ui/core/mvc/Controller","sap/m/MessageToast","sap/ui/model/json/JSONModel","sap/ui/core/format/DateFormat","sap/ui/thirdparty/jquery"],function(e,t,a,r,o,i,n){"use strict";return a.extend("sap.ui.+
table.sample.Selection.Controller",{onInit:function(){var e=sap.ui.core.UIComponent.getRouterFor(this);e.getRoute("r_list_doc").attachPatternMatched(this.loadName,this)},loadName:function(e){var t=e.getParameter("arguments").iv_mafid;var a="/ZC_MAF_DOC('+
"+t+"')";var r=this.getView();r.bindElement({path:a})},onPressHeader:function(e){var t=this.getView();var a=t.byId("headerMaf");var r=a.getObjectSubtitle();var o=sap.ui.core.UIComponent.getRouterFor(this);o.navTo("r_doc_header",{iv_mafid:r})},onEditFinan+
ce:function(e){var t=this.getView();var a=t.byId("headerMaf");var r=a.getObjectSubtitle();var o=sap.ui.core.UIComponent.getRouterFor(this);o.navTo("r_doc_finance",{iv_mafid:r})},onEditProd:function(e){var t=this.getView();var a=t.byId("headerMaf");var r=+
a.getObjectSubtitle();var o=sap.ui.core.UIComponent.getRouterFor(this);o.navTo("r_doc_prod",{iv_mafid:r})}})});                                                                                                                                                