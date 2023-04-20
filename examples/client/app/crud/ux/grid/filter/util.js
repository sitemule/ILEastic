Ext.define("Mvvm.crud.ux.grid.filter.util", {
	singleton: true,

	create: function(config) {
		var i_self = this;
		var i_panel = i_self.createPanel(config);
		return i_panel;
	},

	createFilter: function(o_config) {
		var i_self = this;
		var i_button = undefined;
		switch (o_config.dataType){
			case "string":
				i_button = Ext.widget("filterstring", o_config);
			break;
			case "int":
			case "float":
			case "decimal":
			case "number":
				i_button = Ext.widget("filternumber", o_config);
			break;
			case "enum":
				i_button = Ext.widget("filterenum", o_config);
			break;
			case "boolean":
				i_button = Ext.widget("filterboolean", o_config);
			break;
			case "entity":
				i_button = Ext.widget("filterentity", o_config);
			break;
			case "date":
				i_button = Ext.widget("filterdate", o_config);
			break;
		}
		return i_button;
	},

	createPanel: function (config) {
		var i_self = this;
		var size = undefined;
		switch (config.dataType) {
			case 'string':
				size = { height: 142, width: 380 };
			break;
			case "int":
			case "float":
			case "decimal":
			case 'number':
				size = { height: 212, width: 380 };
			break;
			case 'date':
				if (config.dataDateType == "datetime" || config.dataDateType == "datetimesec") {
					size = { height: 175, width: 600 };
				}
				else {
					size = { height: 175, width: 500 };
				}
			break;
			case 'boolean':
				size = { height: 115, width: 380 };
			break;
			case 'enum':
				size = {
					height: config.useLike ? 142 : 115,
					width: 380
				};
			break;
			case 'entity':
				size = { height: 115, width: 380 };
			break;
		}
		var i_panel = Ext.widget("form", {
			items: [{
				border: false,
				width: size.width,
				height: size.height,
				layout: "border",
				bodyPadding: 5,
				items: [{
					border: false,
					region: "north",
					height: 30,
					defaults: { "margins": "0 0 5 0" },
					items: [i_self.GenerateCheckBoxNot(config)],
					layout: {
						type: "anchor"
					},
					bodyPadding: 5
				},
				{
					border: false,
					region: "west",
					flex: 1,
					defaults: { "margins": "0 0 5 0" },
					items: i_self.GenerateCheckBoxes(config),
					layout: {
						type: "vbox",
						align: "strech"
					},
					bodyPadding: 5
				},
				{
					border: false,
					region: "center",
					flex: 2,
					items: i_self.GenerateFields(config),
					layout: {
						type: "anchor"
					},
					bodyPadding: 5
				},
				{
					border: false,
					region: "south",
					defaults: { "margin": "0 5 0 0" },
					layout: "hbox",
					bodyPadding: 5,
					items: [{
						xtype: "button",
						flex: 1,
						disabled: false,
						text: "Apply",
						dataIndex: config.dataIndex,
						dataType: config.dataType,
						handler: function(item) {
							var i_menu = item.up("menu");
							var i_form = i_menu.down("form");
							var a_fields = i_form.query("field");
							var b_valid = true;
							Ext.Array.each(a_fields, function(i_field) {
								if (!i_field.isValid()) {
									b_valid = false;
								}
							});
							if (b_valid) {
								i_menu.hide();
								config.applyFn();
							}
						}
					},
					{
						xtype: "button",
						margin: "0 0 0 0",
						flex: 1,
						disabled: !config.overRuleable ? true : false,
						text: "Remove",
						handler: function(item) {
							var i_menu = item.up("menu");
							i_menu.hide();
							config.removeFn(i_menu.button);
						}
					}]
				}]
			}],
			layout: "fit",
			bodyPadding: 0
		});
		return i_panel;
	},

	GenerateCheckBoxes: function (config) {
		var i_self = this;
		var items = [];

		switch (config.dataType) {
			case 'string':
				items.push(i_self.GenerateCheckBox(config, "like"));
				items.push(i_self.GenerateCheckBox(config, "eq"));
			break;
			case 'number':
				items.push(i_self.GenerateCheckBox(config, "lt"));
				items.push(i_self.GenerateCheckBox(config, "gt"));
				items.push(i_self.GenerateCheckBox(config, "eq"));
				items.push(i_self.GenerateCheckBox(config, "bt"));
			break;
			case 'date':
				items.push(i_self.GenerateCheckBox(config, "gt"));
				items.push(i_self.GenerateCheckBox(config, "eq"));
				items.push(i_self.GenerateCheckBox(config, "bt"));
			break;
			case 'boolean':
				items.push(i_self.GenerateCheckBox(config, "eq"));
			break;
			case 'enum':
				if (config.useLike) {
					items.push(i_self.GenerateCheckBox(config, "like"));
					items.push(i_self.GenerateCheckBox(config, "eq"));
				}
				else {
					items.push(i_self.GenerateCheckBox(config, "eq"));
				}

			break;
			case 'entity':
				items.push(i_self.GenerateCheckBox(config, "eq"));
			break;
		}
		config.checkboxes = items;
		return items;
	},

	GenerateCheckBox: function (config, criteria) {
		var i_self = this;
		var o_chkConfig = undefined;
		if (criteria == "like") {
			o_chkConfig = {
				fieldLabel: "Like",
				criteria: "like '%{0}%'",
				inputValue: ""
			};
		}
		if (criteria == "eq") {
			o_chkConfig = {
				fieldLabel: "Equal to",
				criteria: "= {0}",
				inputValue: ""
			};
		}
		if (criteria == "gt") {
			o_chkConfig = {
				fieldLabel: "Greater than",
				criteria: "> {0}",
				inputValue: ""
			};
			if (config.dataType == "date") {
				o_chkConfig.fieldLabel = "After";
			}
		}
		if (criteria == "lt") {
			o_chkConfig = {
				fieldLabel: "Less than",
				criteria: "< {0}",
				inputValue: ""
			};
			if (config.dataType == "date") {
				o_chkConfig.fieldLabel = "Before";
			}
		}
		if (criteria == "bt") {
			o_chkConfig = {
				fieldLabel: "Between",
				criteria: "between {0} and {1}",
				inputValue: ""

			};
		}
		Ext.apply(o_chkConfig, {
			dataType: config.dataType,
			dateType: config.dataDateType,
			type: criteria,
			allowChange: true
		});
		o_chkConfig.listeners = {
			change: function (item, newValue, oldValue) {
				var i_menu = item.up("menu");
				var button = i_menu.button;
				if (item.allowChange) {
					i_self.HandleCheckChange(button.config, item.type, newValue);
				}
			}
		};
		var checkBox = Ext.widget("checkboxfield", o_chkConfig);
		return checkBox;
	},

	GenerateFields: function(config) {
		var i_self = this;
		var items = [];
		switch (config.dataType) {
			case 'string':
				items.push(i_self.GenerateField(config, "like"));
				items.push(i_self.GenerateField(config, "eq"));
			break;
			case 'number':
				items.push(i_self.GenerateField(config, "lt"));
				items.push(i_self.GenerateField(config, "gt"));
				items.push(i_self.GenerateField(config, "eq"));
				items.push(i_self.GenerateField(config, "bt"));
			break;
			case "enum":
			case "entity":
			case "boolean":
				if (config.useLike) {
					items.push(i_self.GenerateField(config, "like"));
					items.push(i_self.GenerateField(config, "eq"));
				}
				else {
					items.push(i_self.GenerateField(config, "eq"));
				}
			break;
			case 'date':
				items.push(i_self.GenerateDateTimeField(config, "gt"));
				items.push(i_self.GenerateDateTimeField(config, "eq"));
				items.push(i_self.GenerateDateTimeField(config, "bt"));
			break;
		}
		if (items.length == config.checkboxes.length) {
			for (var i = 0; i < items.length; i++) {
				var f = items[i];
				var c = config.checkboxes[i];
				if (config.dataDateType != "datetime" && config.dataDateType != "datetimesec") {
					if (config.dataType != "date") {
						if (f.fieldtype != "bt") {
							f.checkBox = c;
							i_self.AddListener(f, config);
						}
						else {
							var f1 = f.items.items[0];
							var f2 = f.items.items[1];

							f1.checkBox = c;
							f2.checkBox = c;

							i_self.AddListener(f1, config);
							i_self.AddListener(f2, config);
						}
					}
					else {
						if (f.fieldtype != "bt") {
							var i_datefield = f.getDateField();
							i_datefield.checkBox = c;
							i_self.AddListener(i_datefield, config);
						}
						else {
							var fc1 = f.items.items[0];
							var fc2 = f.items.items[1];

							var i_datefield1 = fc1.getDateField();
							var i_datefield2 = fc2.getDateField();

							i_datefield1.checkBox = c;
							i_datefield2.checkBox = c;

							i_self.AddListener(i_datefield1, config);
							i_self.AddListener(i_datefield2, config);
						}
					}
				}
				else {
					if (f.fieldtype != "bt") {
						var i_datefield = f.getDateField();
						var i_timefield = f.getTimeField();

						i_datefield.checkBox = c;
						i_timefield.checkBox = c;

						i_self.AddListener(i_datefield, config);
						i_self.AddListener(i_timefield), config;
					}
					else {
						var fc1 = f.items.items[0];
						var fc2 = f.items.items[1];

						var i_datefield1 = fc1.getDateField();
						var i_timefield1 = fc1.getTimeField();

						var i_datefield2 = fc2.getDateField();
						var i_timefield2 = fc2.getTimeField();

						i_datefield1.checkBox = c;
						i_timefield1.checkBox = c;

						i_datefield2.checkBox = c;
						i_timefield2.checkBox = c;

						i_self.AddListener(i_datefield1, config);
						i_self.AddListener(i_timefield1, config);

						i_self.AddListener(i_datefield2, config);
						i_self.AddListener(i_timefield2, config);
					}
				}
			}
		}
		config.fields = items;
		return items;
	},

	GenerateField: function(config, type) {
		var i_self = this;
		var o_field = undefined;
		var labelAlign = "left";
		var i_field = undefined;
		switch (type) {
			case 'like':
				if (config.dataType == "enum") {
					o_field = {
						xtype: "combobox",
						anchor: "100%",
						readOnly: true,
						labelAlign: labelAlign,
						name: "cmbEqual",
						forceSelection: true,
						displayField: "value",
						editable: false,
						multiSelect: config.multiSelect || false,
						valueField: "key",
						listConfig: {
							getInnerTpl: function () {
								return "<div><SPAN>{value}</SPAN></div>";
							}
						},
						queryMode: "local",
						triggerAction: "all",
						store: {
							model: Ext.define(Ext.id(), {
								extend: "Ext.data.Model",
								fields: [
									{ name: "key" },
									{ name: "value" }
								]
							}),
							autoDestroy: true,
							autoLoad: true,
							proxy: {
								data: config.values,
								type: 'memory'
							}
						},
						listeners: {
							afterRender: {
								fn: function (item) {
									var value = item.getValue();
									if (value == null) {
										item.setValue(item.store.getAt(0).get('key'));
									}
								}
							}
						}
					};
				}
				else {
					o_field = {
						anchor: "100%",
						labelAlign: labelAlign,
						name: "fieldLike",
						readOnly: true
					};
				}
			break;
			case 'lt':
				o_field = {
					anchor: "100%",
					labelAlign: labelAlign,
					selectOnFocus: true,
					name: "fieldLess",
					readOnly: true
				};
			break;
			case 'gt':
				o_field = {
					anchor: "100%",
					labelAlign: labelAlign,
					selectOnFocus: true,
					name: "fieldGreater",
					readOnly: true
				};
			break;
			case "eq":
				if (config.dataType == 'enum') {
					o_field = {
						xtype: "combobox",
						anchor: "100%",
						readOnly: true,
						labelAlign: labelAlign,
						name: "cmbEqual",
						forceSelection: true,
						displayField: "value",
						editable: false,
						multiSelect: config.multiSelect || false,
						valueField: "key",
						listConfig: {
							getInnerTpl: function () {
								return "<div><SPAN>{value}</SPAN></div>";
							}
						},
						queryMode: "local",
						triggerAction: "all",
						store: {
							model: Ext.define(Ext.id(), {
								extend: "Ext.data.Model",
								fields: [
									{ name: "key" },
									{ name: "value" }
								]
							}),
							autoDestroy: true,
							autoLoad: true,
							proxy: {
								data: config.values,
								type: 'memory'
							}
						},
						listeners: {
							afterRender: {
								fn: function (item) {
									var value = item.getValue();
									if (value == null) {
										item.setValue(item.store.getAt(0).get('key'));
									}
								}
							}
						}
					};
				}
				else if (config.dataType == "entity") {
					o_field = {
						anchor: "100%",
						dmd: config.dmd,
						readOnly: true,
						labelAlign: labelAlign,
						forceSelection: true,
						queryMode: "local",
						triggerAction: "all",
						listeners: {
							afterRender: {
								fn: function (item) {
									var value = item.getValue();
									if (value == null) {
										item.setValue(item.store.getAt(0));
									}
								}
							}
						}
					};
				}
				else if (config.dataType == "boolean") {
					o_field = {
						xtype: "combobox",
						anchor: "100%",
						readOnly: true,
						labelAlign: labelAlign,
						name: "cmbEqual",
						forceSelection: true,
						displayField: "value",
						editable: false,
						valueField: "key",
						listConfig: {
							getInnerTpl: function () {
								return "<div><SPAN>{value}</SPAN></div>";
							}
						},
						queryMode: "local",
						triggerAction: "all",
						store: {
							model: Ext.define(Ext.id(), {
								extend: "Ext.data.Model",
								fields: [
									{ name: "key" },
									{ name: "value" }
								]
							}),
							autoDestroy: true,
							autoLoad: true,
							proxy: {
								data: [{
									key: 1,
									value: "Yes"
								},
								{
									key: 0,
									value: "No"
								}],
								type: 'memory'
							}
						},
						listeners: {
							afterRender: {
								fn: function (item) {
									item.setValue(item.store.getAt(0).get('key'));
								}
							}
						}
					};
				}
				else {
					o_field = {
						anchor: "100%",
						labelAlign: labelAlign,
						name: "fieldEqual",
						readOnly: true
					};
				}
			break;
			case 'bt':
				switch (config.dataType) {
					case 'number':
						var fField = Ext.widget("numberfield", {
							anchor: "100%",
							flex: 1,
							name: "FirstBetween",
							emptyText: "From",
							readOnly: true,
							selectOnFocus: true,
							decimals: config.decimals || 0,
							validator: function() {
								var i_self = this;
								if (i_self.readOnly) {
									return true;
								}
								else {
									var i_parent = i_self.up("form");
									var a_from = i_parent.query("field[name=SecondBetween]");
									var i_from = a_from.length > 0 ? a_from[0] : null;
									if (i_from) {
										var n_fromValue = i_from.getValue();
										var n_value = i_self.getValue();
										if (n_fromValue && n_fromValue < n_value) {
											return "This field has to have the smallest value";
										}
									}
									return true;
								}
							}
						});
						var sField = Ext.widget("numberfield", {
							margin: "0 0 0 0",
							anchor: "100%",
							flex: 1,
							name: "SecondBetween",
							emptyText: "To",
							readOnly: true,
							decimals: config.decimals || 0,
							validator: function() {
								var i_self = this;
								if (i_self.readOnly) {
									return true;
								}
								else {
									var i_parent = i_self.up("form");
									var a_from = i_parent.query("field[name=FirstBetween]");
									var i_from = a_from.length > 0 ? a_from[0] : null;
									if (i_from) {
										var n_fromValue = i_from.getValue();
										var n_value = i_self.getValue();
										if (n_value && n_fromValue > n_value) {
											return "This field has to have the largest value";
										}
									}
									return true;
								}
							}
						});
						if (config.decimals > 0) {
							fField.forcePrecision = true;
							fField.decimalSeparator = ".";

							sField.forcePrecision = true;
							sField.decimalSeparator = ".";
						}
						o_field = {
							border: false,
							defaults: { "margin": "0 5 0 0" },
							items: [fField, sField],
							layout: {
								type: "hbox",
								align: "strech"
							},
							bodyPadding: 0
						};
					break;
				}
		}
		o_field.fieldtype = type;
		if (type == "bt") {
			i_field = Ext.widget("fieldcontainer", o_field);
		}
		else {
			switch (config.dataType) {
				case "string":
					i_field = Ext.widget("textfield", o_field);
				break;
				case "number":
					if (type != "bt") {
						if (o_field.decimals > 0) {
							o_field.decimalSeparator = ".";
							o_field.forcePrecision = true;
						}
						i_field = Ext.widget("numberfield", o_field);
					}
				break;
				case "enum":
				case "boolean":
					i_field = Ext.widget("combobox", o_field);
				break;
				case "entity":
					i_field = Ext.widget("entitycombobox", o_field);
				break;
			}
		}
		return i_field;
	},

	GenerateDateTimeField: function (config, type) {
		var i_self = this;
		var o_field = undefined;
		var labelAlign = "left";
		var i_field = undefined;
		switch (type) {
			case 'gt':
			case 'eq':
				o_field = {
					anchor: "100%",
					flex: 1,
					labelAlign: labelAlign,
					readOnly: true,
					selectOnFocus: true,
					time: (config.dataDateType == "datetime" || config.dataDateType == "datetimesec") ? true : false
				};
			break;
			case 'bt':
				var fField = Ext.widget("isotimestampfield", {
					anchor: "100%",
					flex: 1,
					emptyText: "From",
					time: (config.dataDateType == "datetime" || config.dataDateType == "datetimesec") ? true : false,
					readOnly: true,
					selectOnFocus: true
				});
				var sField = Ext.widget("isotimestampfield", {
					anchor: "100%",
					flex: 1,
					emptyText: "To",
					asHigh: config.asHigh ? config.asHigh : false,
					time: (config.dataDateType == "datetime" || config.dataDateType == "datetimesec") ? true : false,
					readOnly: true,
					selectOnFocus: true,
					timevalue: 23.59
				});
				o_field = {
					border: false,
					items: [fField, sField],
					layout: {
						type: "hbox",
						align: "strech"
					},
					bodyPadding: 0
				};
			break;
		}
		o_field.dateType = config.dataDateType;
		o_field.fieldtype = type;

		if (type != "bt") {
			i_field = Ext.widget("isotimestampfield", o_field);
			var i_datefield = i_field.getDateField();
			i_datefield.on({
				expand: function() {
					var i_menu = i_datefield.up("menu");
					if (i_menu) {
						i_menu.doHiding = false;
					}
				},
				collapse: function() {
					var i_menu = i_datefield.up("menu");
					if (i_menu) {
						i_menu.doHiding = true;
					}
				}
			});
		}
		else {
			i_field = Ext.widget("fieldcontainer", o_field);

			var i_isodatetimefield1 = i_field.items.items[0];
			var i_isodatetimefield2 = i_field.items.items[1];

			var i_datefield1 = i_isodatetimefield1.getDateField();
			var i_datefield2 = i_isodatetimefield2.getDateField();

			i_datefield1.on({
				expand: function() {
					var i_menu = i_datefield1.up("menu");
					if (i_menu) {
						i_menu.doHiding = false;
					}
				},
				collapse: function() {
					var i_menu = i_datefield1.up("menu");
					if (i_menu) {
						i_menu.doHiding = true;
					}
				},
				change: {
					fn: function(i_field, newValue, oldValue) {
						if (i_field.isValid()) {
							i_datefield2.setMinValue(newValue);
						}
					}
				}
			});

			i_datefield2.on({
				expand: function() {
					var i_menu = i_datefield2.up("menu");
					if (i_menu) {
						i_menu.doHiding = false;
					}
				},
				collapse: function() {
					var i_menu = i_datefield2.up("menu");
					if (i_menu) {
						i_menu.doHiding = true;
					}
				},
				change: {
					fn: function(i_field, newValue, oldValue) {
						if (i_field.isValid()) {
							i_datefield1.setMaxValue(newValue);
						}
					}
				}
			});
		}
		return i_field;
	},

	GenerateCheckBoxNot: function(config) {
		var i_self = this;
		var i_checkboxNot = Ext.widget("checkboxfield", {
			anchor: "100%",
			fieldLabel: "Not",
			inputValue: ""
		});
		config.checkBoxNot = i_checkboxNot;
		return i_checkboxNot;
	},

	AddListener: function(i_field, config) {
		var i_self = this;
		i_field.on("specialkey", function (item, e) {
			if (e.getKey() == e.ENTER) {
				var i_menu = item.up("menu");
				config.applyFn();
			}
		});
		i_field.on("render", function (item) {
			if (i_field.inputEl) {
				i_field.inputEl.on("click", function (item) {
					var i_checkbox = i_field.checkBox;
					if (!i_checkbox.checked) {
						i_checkbox.setValue(true);
					}
				}, i_field);
			}
		});
	},

	HandleCheckChange: function(config, type, value) {
		var a_checkbox = config.checkboxes;
		var a_fields = config.fields;
		var n_index = 0;
		Ext.Array.each(a_checkbox, function(i_checkbox) {
			var i_field = a_fields[n_index];
			if (i_checkbox.type == type) {
				if (i_checkbox.allowChange) {
					if (type != "bt") {
						if (i_checkbox.dataType != "date") {
							i_field.setReadOnly(!value);
							if (value) {
								i_field.focus(true, 20);
								i_field.fireEvent("enable", i_field);
							}
						}
						else {
							var i_datefield = i_field.getDateField();
							var i_timefield = i_field.getTimeField();

							i_datefield.setReadOnly(!value);
							i_timefield.setReadOnly(!value);

							i_datefield.focus(true, 20);
						}
					}
					else {
						if (i_checkbox.dataType != "date") {

							var f1 = i_field.items.items[0];
							var f2 = i_field.items.items[1];
							f1.setReadOnly(!value);
							f2.setReadOnly(!value);

							if (value) {
								f1.focus(true, 20);
							}
						}
						else {
							var i_isodatetimefield1 = i_field.items.items[0];
							var i_isodatetimefield2 = i_field.items.items[1];

							var i_datefield1 = i_isodatetimefield1.getDateField();
							var i_timefield1 = i_isodatetimefield1.getTimeField();

							var i_datefield2 = i_isodatetimefield2.getDateField();
							var i_timefield2 = i_isodatetimefield2.getTimeField();

							i_datefield1.setReadOnly(!value);
							i_timefield1.setReadOnly(!value);

							i_datefield2.setReadOnly(!value);
							i_timefield2.setReadOnly(!value);

							if (value) {
								i_datefield1.focus(true, 20);
							}
						}
					}
				}
			}
			else {
				i_checkbox.allowChange = false;
				i_checkbox.setValue(false);
				if (i_checkbox.type != "bt") {
					if (i_checkbox.dataType != "date") {
						i_field.setReadOnly(true);
					}
					else {
						var i_datefield = i_field.getDateField();
						var i_timefield = i_field.getTimeField();

						i_datefield.setReadOnly(true);
						i_timefield.setReadOnly(true);
					}
				}
				else {
					if (i_checkbox.dataType != "date") {

						var f1 = i_field.items.items[0];
						var f2 = i_field.items.items[1];
						f1.setReadOnly(true);
						f2.setReadOnly(true);
					}
					else {
						var i_isodatetimefield1 = i_field.items.items[0];
						var i_isodatetimefield2 = i_field.items.items[1];

						var i_datefield1 = i_isodatetimefield1.getDateField();
						var i_timefield1 = i_isodatetimefield1.getTimeField();

						var i_datefield2 = i_isodatetimefield2.getDateField();
						var i_timefield2 = i_isodatetimefield2.getTimeField();

						i_datefield1.setReadOnly(true);
						i_timefield1.setReadOnly(true);

						i_datefield2.setReadOnly(true);
						i_timefield2.setReadOnly(true);
					}
				}
				i_checkbox.allowChange = true;
			}
			n_index++;
		});
	}
});
