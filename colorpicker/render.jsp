<%@include file="/libs/granite/ui/global.jsp" %><%
%><%@page session="false"
          import="com.adobe.granite.ui.components.AttrBuilder,
                  com.adobe.granite.ui.components.Config,
                  com.adobe.granite.ui.components.Field,
                  com.adobe.granite.ui.components.Tag" %>
                      <%
	Config cfg = cmp.getConfig();
    ValueMap vm = (ValueMap) request.getAttribute(Field.class.getName());
    Field field = new Field(cfg);

    boolean isMixed = field.isMixed(cmp.getValue());
    
    String name = cfg.get("name", String.class);

    Tag tag = cmp.consumeTag();
	
    AttrBuilder attrs = tag.getAttrs();
    attrs.add("id", cfg.get("id", String.class));
    attrs.addClass(cfg.get("class", String.class));
    attrs.addRel(cfg.get("rel", String.class));
    attrs.add("title", i18n.getVar(cfg.get("title", String.class)));
    attrs.addClass("coral-InputGroup");
    attrs.add("value", cfg.get("value", String.class)); 

    // Use JCR standard date format for storage
    // FIXME data-stored-format is a bad name; use data-value-format
    if (isMixed) {
        attrs.addClass("foundation-field-mixed");
    }
    
    attrs.addOthers(cfg.getProperties(), "id", "class", "rel", "title", "name", "value", "emptyText", "type", "displayedFormat", "minDate", "maxDate", "displayTimezoneMessage", "fieldLabel", "fieldDescription", "renderReadOnly", "ignoreData");
    
    AttrBuilder attrsInput = new AttrBuilder(request, xssAPI);
    attrsInput.addClass("coral-InputGroup-input coral-Textfield");
    attrsInput.add("name", name);
	attrsInput.add("maxlength",7);
    attrsInput.addDisabled(cfg.get("disabled", false));
    attrsInput.add("type", cfg.get("type", "text"));

    if (isMixed) {
        attrsInput.add("placeholder", i18n.get("<Mixed Entries>")); 
    } else {
        attrsInput.add("value", vm.get("value", String.class));
        log.info("Current value:" + vm.get("value", String.class)+":");
        attrsInput.add("placeholder", i18n.getVar(cfg.get("emptyText", String.class)));
    }

    if (cfg.get("required", false)) {
        attrsInput.add("aria-required", true);
    }

    AttrBuilder typeAttrs = new AttrBuilder(request, xssAPI);
    typeAttrs.add("type", "hidden");
    typeAttrs.add("value", "Color");
    if (name != null && name.trim().length() > 0) {
        typeAttrs.add("name", name + "@TypeHint");
    }
    
    String id = cfg.get("id", String.class);
    id = (id != null && !id.isEmpty()) ? id +"-" : "";

%><div <%= attrs.build() %>>
    <input id="<%= id %>mycolor" <%= attrsInput.build() %>>
    <div class="coral-InputGroup-button">
        <button data-toggle="popover" data-target="#<%= id %>colorpicker" class="coral-Button coral-Button--square" id="<%= id %>customColorButton" type="button" title="<%= xssAPI.encodeForHTMLAttr(i18n.get("Color Picker")) %>">
            <i class="coral-Icon coral-Icon--sizeS coral-Icon coral-Icon--colorPalette"></i>
        </button>
    </div>
</div>

<div  id="<%= id %>colorpicker" class="coral-Popover"></div>
<script type="text/javascript">

$(document).ready(function() {

	$('#<%= id %>colorpicker').farbtastic('#<%= id %>mycolor');
	$("#<%= id %>customColorButton").click(function(){
		$('#<%= id %>colorpicker').toggle();
		var x = $("#<%= id %>mycolor").val();
		if(x.length==0) {
			$("#<%= id %>mycolor").val("#000000");
		}
	});

	$(window).adaptTo("foundation-registry").register("foundation.validation.validator", {
		selector: "input[id=<%= id %>mycolor]",
		validate: function(el) {
			var field = el.closest(".coral-Form-field");
			var value = el.value.trim();

			if (value.substring(0,1) !== '#' && value.length > 0){
				value = '#' + value;
				el.value = value;
			}

			var match = value.match(/^#?([0-9a-fA-F]{3}){1,2}$/i)
			var length = (value.length === 4 || value.length === 7);
			if (value.length !== 0 && (!length || match === null)) {
				return Granite.I18n.get('Not valid Hex Code');
			}
		}
	});
});
</script>
