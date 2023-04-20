Ext.define("Mvvm.crud.ux.grid.filter.Enum", {
	extend: "Mvvm.crud.ux.grid.filter.Base",
	alias: "widget.filterenum",

	initComponent: function() {
		var i_self = this;
		i_self.callParent(arguments);
	},

	createMenu: function() {
		var i_self = this;
		i_self.callParent(arguments);
		var config = {
			dataIndex: i_self.dataIndex,
			dataType: "enum",
			overRuleable: i_self.overRuleable != null ? i_self.overRuleable : true,
			multiSelect: i_self.multiSelect || false,
			values: i_self.values,
			applyFn: i_self.applyFn || Ext.emptyFn,
			removeFn: i_self.removeFn || Ext.emptyFn,
			useLike: i_self.useLike || false
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
		ip2.each(a_checkbox, function(i_checkbox) {
			var i_field = a_field[n_index];
			if (i_checkbox.checked) {
				s_criteria = i_checkbox.criteria;
				s_type = i_checkbox.type;
				s_value = i_field.getValue();
			}
			n_index++;
		});
		if (s_value !== "") {
			if (i_self.isString) {
				if (Ext.isArray(s_value)) {
					if (s_type == "eq") {
						s_criteria = s_criteria.replace("{0}", "'" + JSON.stringify(s_value) + "'");
					}
					else {
						var a_criteries = [];
						ip2.each(s_value, function(s_key) {
							var s_tmp = s_criteria.replace("{0}", s_key);
							s_tmp = s_tmp = (b_not ? " NOT " + s_tmp : " " + s_tmp);
							a_criteries.push(s_tmp);
						});
						if (b_not) {
							s_criteria = a_criteries.join(" AND 'atz' ");
						}
						else {
							s_criteria = a_criteries.join(" OR 'atz' ");
						}

						var regex = new RegExp("'atz'","g");
						if (!b_not) {
							s_where = "(" + o_config.dataIndex + s_criteria.replace(regex, o_config.dataIndex) + ")";
						}
						else {
							s_where = o_config.dataIndex + s_criteria.replace(regex, o_config.dataIndex);
						}
					}
				}
				else {
					s_criteria = s_criteria.replace("{0}", "'" + s_value + "'");
				}
				if (s_where == "") {
					s_where = o_config.dataIndex + (b_not ? " !" + s_criteria : " " + s_criteria);
				}
			}
			else {
				s_criteria = s_criteria.replace("{0}", s_value);
				s_where = o_config.dataIndex + (b_not ? " !" + s_criteria : " " + s_criteria);
			}
			return s_where;
		}
		else {
			return "";
		}
	}
});
