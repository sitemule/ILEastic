Ext.define("Mvvm.crud.ux.grid.filter.Date", {
	extend: "Mvvm.crud.ux.grid.filter.Base",
	alias: "widget.filterdate",

	initComponent: function() {
		var i_self = this;
		i_self.callParent(arguments);
	},

	createMenu: function() {
		var i_self = this;
		i_self.callParent(arguments);
		var config = {
			dataIndex: i_self.dataIndex,
			dataType: "date",
			dataDateType: i_self.dataDateType || "datetime",
			overRuleable: i_self.overRuleable != null ? i_self.overRuleable : true,
			applyFn: i_self.applyFn || Ext.emptyFn,
			removeFn: i_self.removeFn || Ext.emptyFn,
			asHigh: true
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
		var s_eqDateValue = "";
		var s_eqTimeValue = "";
		var s_value = "";
		var s_second = "";
		var s_where = "";
		var s_criteria = "";
		var s_type = "";
		var n_index = 0;
		Ext.Array.each(a_checkbox, function(i_checkbox) {
			var i_field = a_field[n_index];
			if (i_checkbox.checked) {
				s_criteria = i_checkbox.criteria;
				s_type = i_checkbox.type;
				if (s_type == "bt") {
					var a_items = i_field.items.items;
					var i_first = a_items[0];
					var i_second = a_items[1];
					s_value = i_first.getValue();
					s_second = i_second.getValue();
				}
				else {
					if (s_type == "eq") {
						var i_datefield = i_field.getDateField();
						var i_timefield = i_field.getTimeField();
						s_eqDateValue = i_datefield.getSubmitValue();
						s_eqTimeValue = i_timefield.getSubmitValue();
						s_eqTimeValue = s_eqTimeValue.replace(new RegExp(":","g"), ".");
					}

					s_value = i_field.getValue();
				}
			}
			n_index++;
		});
		if (s_value !== "") {
			if (s_type == "bt") {
				if (o_config.dataDateType == "datetime" || o_config.dataDateType == "datetimesec") {
					s_criteria = s_criteria
					.replace("{0}", "TIMESTAMP('" + s_value + "')")
					.replace("{1}", "TIMESTAMP('" + s_second + "')");
					s_where = o_config.dataIndex + (b_not ? " NOT " + s_criteria : " " + s_criteria);
				}
				else {
					s_criteria = s_criteria
					.replace("{0}", "DATE('" + s_value + "')")
					.replace("{1}", "DATE('" + s_second + "')");
					s_where = "DATE(" + o_config.dataIndex + ") " + (b_not ? " NOT " + s_criteria : " " + s_criteria);
				}
			}
			else {
				if (s_type == "eq") {
					s_criteria = "char({0}){2}like '{1}%'"
					.replace("{0}", o_config.dataIndex)
					.replace("{1}", (s_eqDateValue + "-" + s_eqTimeValue))
					.replace("{2}", (b_not ? " NOT " : " "));
					s_where = s_criteria;
				}
				else {
					if (o_config.dataDateType == "datetime" || o_config.dataDateType == "datetimesec") {
						s_criteria = s_criteria.replace("{0}", "TIMESTAMP('" + s_value + "')");
						s_where = o_config.dataIndex + (b_not ? " NOT " + s_criteria : " " + s_criteria);
					}
					else {
						s_criteria = s_criteria.replace("{0}", "DATE('" + s_value + "')");
						s_where = "DATE(" + o_config.dataIndex + ") " + (b_not ? " NOT " + s_criteria : " " + s_criteria);
					}
				}
			}
			return s_where;
		}
		else {
			return "";
		}
	}
});
