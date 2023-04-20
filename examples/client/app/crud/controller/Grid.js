Ext.define("Mvvm.crud.controller.Grid", {
	extend: "Ext.app.ViewController",

	alias: "controller.crud.gridpanel",

	onEdit: function(i_view, i_record) {

		var i_controller = this;
		var i_grid = i_controller.getView();
		var i_store = i_grid.getStore();
		var i_model = i_store.getModel();

		var i_window = Ext.widget("crud.detail", {
			title: "Edit: " + i_record.get(i_model.idProperty),
			width: 800,
			height: 600,
			record: i_record,
			model: i_model,
			grid: i_grid,
			action: "edit"
		});

		i_window.show();
	},

	onAdd: function() {

		var i_controller = this;
		var i_grid = i_controller.getView();
		var i_store = i_grid.getStore();
		var i_model = i_store.getModel();
		var i_record = i_model.create();

		var i_window = Ext.widget("crud.detail", {
			title: "New: ",
			width: 800,
			height: 600,
			record: i_record,
			model: i_model,
			grid: i_grid,
			action: "add"
		});

		i_window.show();
	},

	onItemMenu: function(i_view, i_record, item, index, e) {

		var i_controller = this;
		var i_grid = i_controller.getView();
		var i_store = i_grid.getStore();
		var a_coords = e.getXY();
		e.preventDefault();

		var i_menu = Ext.widget("menu", {
			items: [
				{
					text: "Edit",
					handler: function() {
						i_controller.onEdit(i_grid.getView(), i_record);
					}
				},
				{
					text: "Delete",
					handler: function() {
						i_controller.onDelete(i_record);
					}
				}
			]
		});

		i_menu.showAt(a_coords[0], a_coords[1]);
	},

	onSave: function() {

		var i_controller = this;
		var i_window = i_controller.getView();
		var i_form = i_window.down("form").getForm();
		var i_viewModel = i_controller.getViewModel();
		var a_fields = i_form.getFields().items;

		var i_grid = i_viewModel.get("grid");
		var i_record = i_viewModel.get("record");
		var i_store = i_grid.getStore();

		var o_values = {};

		Ext.Array.each(a_fields, function(i_field) {
			if (i_field.xtype != "datefield") {
				o_values[i_field.name] = i_field.getValue();
			}
			else {
				o_values[i_field.name] = i_field.getSubmitValue();
			}
		})

		o_values[i_record.idProperty] = i_record.get(i_record.idProperty);


		var o_json = {
			row: o_values
		};

		if (o_json.row[i_record.idProperty] == null) {
			o_json.row[i_record.idProperty] = 0;
		}

		// Ext.apply(o_json, i_grid.params.routes.update);

		Ext.Ajax.request({
			url: i_grid.url + '/' + i_grid.params.routes.update,
			method: "POST",
			jsonData: o_json,
			success: function (response, request) {
				i_window.close();
				i_store.load();
			}
		});
	},

	onDelete: function(i_record) {

		var i_controller = this;
		var i_grid = i_controller.getView();

		var i_store = i_grid.getStore();
		var o_params = {
			key: i_record.get(i_record.idProperty)
		};

		// Ext.apply(o_params, i_grid.params.routes.delete);

		Ext.Ajax.request({
			url: i_grid.url + '/' + i_grid.params.routes.delete ,
			method: "POST",
			jsonData: o_params,
			success: function (response, request) {
				i_store.load();
			}
		});
	},

	onClose: function() {

		var i_controller = this;
		var i_window = i_controller.getView();
		i_window.close();
	}
})
