Ext.define("Mvvm.crud.view.Detail", {
	extend: "Ext.window.Window",
	requires:  [
		"Mvvm.crud.viewmodel.Detail"
	],
	alias: "widget.crud.detail",

	collapsible: true,

	viewModel: {
		type: "crud.detail"
	},

	controller:"crud.gridpanel",

	layout: "fit",
	constrain: true,

	initComponent: function() {

		var i_self = this;
		var o_config = i_self.initialConfig;
		var i_record = o_config.model.create(o_config.record.data);
		i_self.callParent(arguments);

		var i_form = i_self.createForm(o_config.model);
		i_self.add(i_form);
		i_self._form = i_form;

		var i_viewModel = i_self.getViewModel();
		i_viewModel.setData({
			record: i_record,
			grid: o_config.grid
		});

		i_form.loadRecord(i_record);

		return i_self;
	},

	createForm: function(i_model) {

		var i_self = this;
		var i_form = Ext.widget("form", {
			layout: "anchor",
			bodyPadding: 5,
			trackResetOnLoad: true,
			autoScroll: true,
			defaults: {
				anchor: "100%"
			},
			items: i_self.createFields(i_model),
			buttons: i_self.createButtons(),
			listeners: {
				dirtychange: {
					fn: function(i_form, b_dirty) {
						var i_button = i_form.owner.down("#btn-save");
						if (i_button) {
							if (b_dirty) {
								i_button.enable();
							}
							else {
								i_button.disable();
							}
						}
					}
				}
			}
		});
		return i_form;
	},

	createFields: function(i_model) {

		var i_self = this;
		var a_modelFields = i_model.getFields();
		var a_fields = [];

		Ext.Array.each(a_modelFields, function(i_modelField) {
			var i_field;
			if (!i_modelField.generated) {
				var b_readyOnly = i_modelField.name == i_model.idProperty;
				switch(i_modelField.datatype){
					case "string":
						i_field = Ext.widget("textfield", {
							fieldLabel: i_modelField.header,
							name: i_modelField.name,
							readOnly: b_readyOnly,
							bind: {
								value: "{record." + i_modelField.name + "}"
							},
							maxLenght: i_modelField.size
						});
						break;
					case "integer":
					case "int":
						i_field = Ext.widget("numberfield", {
							fieldLabel: i_modelField.header,
							name: i_modelField.name,
							readOnly: b_readyOnly,
							decimalPrecision: 0,
							bind: {
								value: "{record." + i_modelField.name + "}"
							},
							maxLenght: i_modelField.size
						});
						break;
					case "decimal":
					case "dec":
					case "float":
						i_field = Ext.widget("numberfield", {
							fieldLabel: i_modelField.header,
							forcePrecision: true,
							decimalPrecision: i_modelField.prec || 0,
							decimalSeparator: Ext.util.Format.decimalSeparator,
							name: i_modelField.name,
							readOnly: b_readyOnly,
							bind: {
								value: "{record." + i_modelField.name + "}"
							},
							maxLenght: i_modelField.size
						});
						break;
					case "timestamp":
						i_field = Ext.widget("isotimestampfield", {
							fieldLabel: i_modelField.header,
							name: i_modelField.name,
							readOnly: b_readyOnly,
							bind: {
								value: "{record." + i_modelField.name + "}"
							}
						});
						break;
					case "date":
						i_field = Ext.widget("datefield", {
							fieldLabel: i_modelField.header,
							name: i_modelField.name,
							readOnly: b_readyOnly,
							submitFormat: "Y-m-d",
							format: Ext.util.Format.dateFormat,
							bind: {
								value: "{record." + i_modelField.name + "}",
							}
						});
						break;
					default :
						if (i_modelField.size >= 40) {
							i_field = Ext.widget("textarea", {
								fieldLabel: i_modelField.header,
								name: i_modelField.name,
								readOnly: b_readyOnly,
								bind: {
									value: "{record." + i_modelField.name + "}"
								},
								maxLenght: i_modelField.size
							});
						}
						else {
							i_field = Ext.widget("textfield", {
								fieldLabel: i_modelField.header,
								name: i_modelField.name,
								readOnly: b_readyOnly,
								bind: {
									value: "{record." + i_modelField.name + "}"
								},
								maxLenght: i_modelField.size || 30
							});
						}

						break;
				}
				i_field.readOnly = i_modelField.identifier ? true : false;
				i_field.fieldLabel = i_modelField.identifier ? "ID" : i_field.fieldLabel;
				a_fields.push(i_field);
			}

		})

		return a_fields;
	},

	createButtons: function() {

		var a_buttons = [
			{
				xtype: "button",
				text: "Save",
				itemId: "btn-save",
				handler: "onSave",
				disabled: true
			},
			{
				xtype: "button",
				text: "Close",
				itemId: "btn-close",
				handler: "onClose"
			}
		]
		return a_buttons;
	}
});
