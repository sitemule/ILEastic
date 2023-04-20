Ext.define("Mvvm.crud.view.Grid", {
	extend: "Ext.grid.Panel",
	requires:  [
		"Mvvm.crud.ux.BoxReorderer",
		"Mvvm.crud.ux.TabReorderer",
		"Mvvm.crud.ux.ToolbarDroppable",
		"Mvvm.crud.controller.Grid",
		"Mvvm.crud.ux.grid.filter.Toolbar",
		"Mvvm.crud.ux.form.field.ISOTimestampField",
		"Mvvm.crud.ux.form.field.Search",
	],
	alias: "widget.crud.gridpanel",

	controller: "crud.gridpanel",

	listeners: {
		itemdblclick: {
			fn: "onEdit"
		},
		itemcontextmenu: {
			fn: "onItemMenu"
		}
	},

	url: "",
	params:  null,

	initComponent: function() {

		var i_self = this;
		i_self.addConfig();
		i_self.callParent(arguments);
		i_self.addDocked(i_self.createToolbars());
		return i_self;
	},

	addConfig: function() {

		var i_self = this;
		Ext.apply(i_self, {
			store: i_self.createStore(),
			columns: i_self.createColumns()
		});
	},

	createStore: function() {

		var i_self = this;
		var o_params = i_self.params || {};

		var i_model = Ext.define("crud.model.Detail", {
			extend: "Ext.data.Model",
			fields: i_self.fields,
			idProperty: i_self.idProperty,
			proxy: {
				url: i_self.url + '/' + i_self.params.routes.getRows,
				type: "ajax",
				paramsAsJson: true,
				$configStrict: false,
				reader: {
					type: 'json',
					rootProperty: "rows",
					totalProperty: "totalRows"
				},
				getMethod: function(request) {
					return "POST";
				}
			}
		})

		var i_store = Ext.create('Ext.data.BufferedStore', {
			model: i_model,
			remoteSort: true,
			autoSync: false,
			pageSize: 100,
			listeners: {
				beforeload: {
					fn: function(store) {

						var i_proxy = store.getProxy();
						var o_extraParams = i_proxy.getExtraParams();

						var o_sorters = store.getSorters();

						//Ext.apply(o_extraParams, i_self.params.routes.getRows);

						var a_sort = [];
						var s_sort = "";
						Ext.Array.each(o_sorters.items, function(o_sort) {
							var s_sorter = o_sort.getProperty() + " " + o_sort.getDirection();
							a_sort.push(s_sorter);
						});
						s_sort = a_sort.join(", ");
						o_extraParams.sort = s_sort;
					}
				}
			}
		});
		i_store.load();
		return i_store;
	},

	createColumns: function() {

		var i_self = this;
		var a_fields = i_self.fields

		var a_columns = [];

		Ext.Array.each(a_fields, function(i_field) {

			var o_column = {
				dataIndex: i_field.name,
				text: i_field.header,
				flex: 1,
				hidden: i_field.hidden ? i_field.hidden : !i_field.header,
				datatype: i_field.datatype
			}
			if (i_field.datatype == "date") {
				o_column.align = "center";
				o_column.renderer = function(value, i_cellValues) {
					if (value) {
						var i_date;
						var s_format = Ext.util.Format.dateFormat;
						var i_column = i_cellValues.column;
						var o_properties = i_column.properties || {};

						if (o_properties.fmt) {
							s_format = o_properties.fmt;
						}
						var f_renderer = Ext.util.Format.dateRenderer(s_format);

						if (value instanceof Date) {
							i_date = value;
						}
						else {
							i_date = new Date(value);
						}
						value = f_renderer(i_date);
					}
					return value;
				};
			}
			if (i_field.datatype == "timestamp") {
				o_column.renderer = function(value) {
					var s_date = value.toLocaleDateString();
					var s_time = value.toLocaleTimeString();
					return s_date + " " + s_time;
				}
			}
			if (i_field.datatype == "dec") {
				o_column.xtype = "numbercolumn";
			}
			if (i_field.datatype == "dec" || i_field.datatype == "int") {
				o_column.align = 'right';
			}

			a_columns.push(o_column);
		});
		return a_columns;
	},

	createToolbars: function() {

		var a_return = [];

		var i_self = this;
		var i_store = i_self.getStore();
		var o_sorters = i_store.getSorters();

		var i_toolbar = Ext.widget("toolbar", {
			dock: "top",
			items:[
				{
					text: "Refresh",
					handler: function() {
						i_store.clearAndLoad({
							callback: function() {
								i_store.fireEvent('sort', i_store, o_sorters.getRange());
							}
						});
					}
				},
				"-",
				{
					xtype: "button",
					text: "Add",
					handler: "onAdd"
				},
				"-",
				{
					xtype: "searchfield",
					store: i_store,
					width: 250,
					isFormField: false
				}
			]
		});

		var i_filterbar = Ext.widget("filterbar", {
			dock: "top"
		})

		a_return.push(i_toolbar);
		a_return.push(i_filterbar);

		return a_return;
	}
});
