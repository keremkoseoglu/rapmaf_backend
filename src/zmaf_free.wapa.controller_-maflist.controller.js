sap.ui.define(["sap/base/Log","sap/ui/table/library","sap/ui/core/mvc/Controller","sap/m/MessageToast","sap/ui/model/json/JSONModel","sap/ui/core/format/DateFormat","sap/ui/thirdparty/jquery"],function(e,t,r,a,o,s,i){"use strict";return r.extend("sap.ui.+
table.sample.Selection.Controller",{onInit:function(){},onMafDocPress:function(e){var t=this.getSelectedMafId();var r=sap.ui.core.UIComponent.getRouterFor(this);r.navTo("r_list_doc",{iv_mafid:t})},onCreatePress:function(e){var t=sap.ui.core.UIComponent.g+
etRouterFor(this);t.navTo("r_list_header")},onDeletePress:function(e){var t=this.getSelectedMafId();var r=this.getView();var a=r.getModel();var o="/ZC_MAF_DOC('"+t+"')";a.remove(o);a.refresh()},getSelectedMafId:function(){var e=this.getView();var t=e.byI+
d("tabMafList");var r=t.getSelectedIndices();var a=t.getContextByIndex(r[0]);var o=e.getModel();var s=o.getProperty(a.sPath);var i=s.MafId;return i}})});                                                                                                      