Ext.define("Ext.ux.grid.filter.view.Edit", {

	extend: "Ext.window.Window",

	alias: "widget.filterviewedit",

	okFn: Ext.emptyFn,
	layout: "fit",

	width: 360,
	height: 160,
	modal: true,

	initComponent: function() {
		var i_self = this;
		i_self.callParent(arguments);
		i_self.add(i_self.createForm());
		return i_self;
	},

	createForm: function() {
		var i_self = this;
		var i_form = Ext.widget("form", {
			layout: "fit",
			items: i_self.createPanel(),
			buttons: i_self.createButtons()
		});
		i_self.form = i_form;
		return i_form;
	},

	createPanel: function() {
		var i_self = this;
		var i_panel = Ext.widget("panel", {
			layout: "anchor",
			bodyPadding: 5,
			items: i_self.createItems()
		});

		return i_panel;
	},

	createItems: function() {
		var i_self = this;
		var a_items = [];
		var i_checkbox = Ext.widget("checkbox", {
			name: "PUBLIC",
			checked: false,
			fieldLabel: ip2.i18n({
				"da": "Offentlig",
				"en": "Public"
			}),
			anchor: "98%"
		});

		var i_textfield = Ext.widget("textfield", {
			name: "NAME",
			emptyText: ip2.i18n({
				"da": "Skriv title på filter",
				"en": "Enter name of filter"
			}),
			fieldLabel: ip2.i18n({
				"da": "Navn",
				"en": "Name"
			}),
			anchor: "98%"
		});

		a_items.push(i_checkbox);
		a_items.push(i_textfield);
		return a_items;
	},

	createButtons: function() {
		var i_self = this;
		var a_items = [];
		var i_btn_ok = Ext.widget("button", {
			text: ip2.i18n({
				"da": "Gem",
				"en": "Save"
			}),
			handler: function(i_button) {
				var i_form = i_self.getForm();
				var o_value = i_form.getFieldValues();

				var b_public = o_value.PUBLIC;
				var s_name = o_value.NAME;

				if (i_self.okFn != null) {
					i_self.okFn(b_public, s_name);
				}
			}
		});

		var i_btn_cancel = Ext.widget("button", {
			text: ip2.i18n({
				"da": "Anuller",
				"en": "Cancel"
			}),
			handler: function(i_button) {
				i_self.close();
			}
		});

		a_items.push(i_btn_ok);
		a_items.push(i_btn_cancel);

		return a_items;
	},

	getForm: function() {
		var i_self = this;
		return i_self.form.getForm();
	}
});
