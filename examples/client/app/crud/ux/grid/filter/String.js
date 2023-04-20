Ext.define("Mvvm.crud.ux.grid.filter.String", {
	extend: "Mvvm.crud.ux.grid.filter.Base",
	alias: "widget.filterstring",

	initComponent: function() {
		var i_self = this;
		i_self.callParent(arguments);
	},

	createMenu: function() {
		var i_self = this;
		i_self.callParent(arguments);
		var config = {
			dataIndex: i_self.dataIndex,
			dataType: "string",
			overRuleable: i_self.overRuleable != null ? i_self.overRuleable : true,
			applyFn: i_self.applyFn || Ext.emptyFn,
			removeFn: i_self.removeFn || Ext.emptyFn
		};
		var i_panel = Mvvm.crud.ux.grid.filter.util.create(config);
		i_self.config = config;
		i_self.menu.add(i_panel);
	},

	getValue: function() {
		var i_self = this;
		var o_config = i_self.getConfig();
		var a_checkbox = o_config.checkboxes;
		var a_field = o_config.fields;
		var b_not = i_self.getNot();
		var s_value = "";
		var s_where = "";
		var s_criteria = "";
		var s_type = "";
		var n_index = 0;
		Ext.Array.each(a_checkbox, function(i_checkbox) {
			var i_field = a_field[n_index];
			if (i_checkbox.checked) {
				s_value = i_field.getValue();
				s_criteria = i_checkbox.criteria;
				s_type = i_checkbox.type;
			}
			n_index++;
		});
		if (s_value !== "") {
			if (s_type == "eq") {
				s_criteria = s_criteria.replace("{0}", "'" + s_value + "'");
			}
			else {
				s_criteria = s_criteria.replace("{0}", s_value);
			}
			s_where = o_config.dataIndex + (b_not ? " NOT " + s_criteria : " " + s_criteria);
			return s_where;
		}
		else {
			return "";
		}
	}
});
