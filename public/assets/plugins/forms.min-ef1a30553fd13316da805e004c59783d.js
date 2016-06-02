/*!
 * froala_editor v2.3.0 (https://www.froala.com/wysiwyg-editor)
 * License https://froala.com/wysiwyg-editor/terms/
 * Copyright 2014-2016 Froala Labs
 */


!function(a){"function"==typeof define&&define.amd?define(["jquery"],a):"object"==typeof module&&module.exports?module.exports=function(b,c){return void 0===c&&(c="undefined"!=typeof window?require("jquery"):require("jquery")(b)),a(c),c}:a(jQuery)}(function(a){"use strict";a.extend(a.FE.POPUP_TEMPLATES,{"forms.edit":"[_BUTTONS_]","forms.update":"[_BUTTONS_][_TEXT_LAYER_]"}),a.extend(a.FE.DEFAULTS,{formEditButtons:["inputStyle","inputEdit"],formStyles:{"fr-rounded":"Rounded","fr-large":"Large"},formMultipleStyles:!0,formUpdateButtons:["inputBack","|"]}),a.FE.PLUGINS.forms=function(b){function c(c){c.preventDefault(),b.selection.clear(),a(this).data("mousedown",!0)}function d(b){a(this).data("mousedown")&&(b.stopPropagation(),a(this).removeData("mousedown"),s=this,j(this)),b.preventDefault()}function e(){b.$el.find("input, textarea, button").removeData("mousedown")}function f(){a(this).removeData("mousedown")}function g(){b.events.$on(b.$el,b._mousedown,"input, textarea, button",c),b.events.$on(b.$el,b._mouseup,"input, textarea, button",d),b.events.$on(b.$el,"touchmove","input, textarea, button",f),b.events.$on(b.$el,b._mouseup,e),b.events.$on(b.$win,b._mouseup,e),m(!0)}function h(){return s?s:null}function i(){var a="";b.opts.formEditButtons.length>0&&(a='<div class="fr-buttons">'+b.button.buildList(b.opts.formEditButtons)+"</div>");var c={buttons:a},d=b.popups.create("forms.edit",c);return b.$wp&&b.events.$on(b.$wp,"scroll.link-edit",function(){get()&&b.popups.isVisible("forms.edit")&&j(h())}),d}function j(c){var d=b.popups.get("forms.edit");d||(d=i()),s=c;var e=a(c);b.popups.refresh("forms.edit"),b.popups.setContainer("forms.edit",a(b.opts.scrollableContainer));var f=e.offset().left+e.outerWidth()/2,g=e.offset().top+e.outerHeight();b.popups.show("forms.edit",f,g,e.outerHeight())}function k(){var c=b.popups.get("forms.update"),d=h();if(d){var e=a(d);e.is("button")?c.find('input[type="text"][name="text"]').val(e.text()):c.find('input[type="text"][name="text"]').val(e.attr("placeholder"))}c.find('input[type="text"][name="text"]').trigger("change")}function l(){s=null}function m(a){if(a)return b.popups.onRefresh("forms.update",k),b.popups.onHide("forms.update",l),!0;var c="";b.opts.formUpdateButtons.length>=1&&(c='<div class="fr-buttons">'+b.button.buildList(b.opts.formUpdateButtons)+"</div>");var d="",e=0;d='<div class="fr-forms-text-layer fr-layer fr-active">',d+='<div class="fr-input-line"><input name="text" type="text" placeholder="Text" tabIndex="'+ ++e+'"></div>',d+='<div class="fr-action-buttons"><button class="fr-command fr-submit" data-cmd="updateInput" href="#" tabIndex="'+ ++e+'" type="button">'+b.language.translate("Update")+"</button></div></div>";var f={buttons:c,text_layer:d},g=b.popups.create("forms.update",f);return g}function n(){var c=h();if(c){var d=a(c),e=b.popups.get("forms.update");e||(e=m()),b.popups.isVisible("forms.update")||b.popups.refresh("forms.update"),b.popups.setContainer("forms.update",a(b.opts.scrollableContainer));var f=d.offset().left+d.outerWidth()/2,g=d.offset().top+d.outerHeight();b.popups.show("forms.update",f,g,d.outerHeight())}}function o(c,d,e){"undefined"==typeof d&&(d=b.opts.formStyles),"undefined"==typeof e&&(e=b.opts.formMultipleStyles);var f=h();if(!f)return!1;if(!e){var g=Object.keys(d);g.splice(g.indexOf(c),1),a(f).removeClass(g.join(" "))}a(f).toggleClass(c)}function p(){b.events.disableBlur(),b.selection.restore(),b.events.enableBlur();var a=h();a&&b.$wp&&("BUTTON"==a.tagName&&b.selection.restore(),j(a))}function q(){var c=b.popups.get("forms.update"),d=h();if(d){var e=a(d),f=c.find('input[type="text"][name="text"]').val()||"";f.length&&(e.is("button")?e.text(f):e.attr("placeholder",f)),b.popups.hide("forms.update"),j(d)}}function r(){g(),b.events.$on(b.$el,"submit","form",function(a){return a.preventDefault(),!1})}var s;return{_init:r,updateInput:q,getInput:h,applyStyle:o,showUpdatePopup:n,showEditPopup:j,back:p}},a.FE.RegisterCommand("updateInput",{undo:!1,focus:!1,title:"Update",callback:function(){this.forms.updateInput()}}),a.FE.DefineIcon("inputStyle",{NAME:"magic"}),a.FE.RegisterCommand("inputStyle",{title:"Style",type:"dropdown",html:function(){var a='<ul class="fr-dropdown-list">',b=this.opts.formStyles;for(var c in b)b.hasOwnProperty(c)&&(a+='<li><a class="fr-command" data-cmd="inputStyle" data-param1="'+c+'">'+this.language.translate(b[c])+"</a></li>");return a+="</ul>"},callback:function(a,b){var c=this.forms.getInput();c&&(this.forms.applyStyle(b),this.forms.showEditPopup(c))},refreshOnShow:function(b,c){var d=this.forms.getInput();if(d){var e=a(d);c.find(".fr-command").each(function(){var b=a(this).data("param1");a(this).toggleClass("fr-active",e.hasClass(b))})}}}),a.FE.DefineIcon("inputEdit",{NAME:"edit"}),a.FE.RegisterCommand("inputEdit",{title:"Edit Button",undo:!1,refreshAfterCallback:!1,callback:function(){this.forms.showUpdatePopup()}}),a.FE.DefineIcon("inputBack",{NAME:"arrow-left"}),a.FE.RegisterCommand("inputBack",{title:"Back",undo:!1,focus:!1,back:!0,refreshAfterCallback:!1,callback:function(){this.forms.back()}}),a.FE.RegisterCommand("updateInput",{undo:!1,focus:!1,title:"Update",callback:function(){this.forms.updateInput()}})});
