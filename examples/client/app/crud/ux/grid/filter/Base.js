Ext.define("Mvvm.crud.ux.grid.filter.Base", {
	extend: "Ext.button.Split",

	alias: "widget.filterbase",
	dataIndex: '',
	dataType: 'string',
	overRuleable: true,
	toolbar: undefined,
	menu: undefined,
	fields: undefined,
	config: undefined,
	sortInfo: undefined,
	isFilter: true,
	iconCls: "icon icon-init icon-arrow-up",
	sortDirection: "ASC",

	initComponent: function() {
		var i_self = this;
		i_self.iconCls = i_self.sortDirection == "ASC" ? "icon icon-init icon-arrow-up" : "icon icon-init icon-arrow-down";
		i_self.callParent(arguments);
		i_self.createMenu();
		i_self.createSortInfo();
		i_self.on({
			mouseover: {
				fn: function () {
					var i_self = this;
					var s_iconCls = i_self.sortInfo.direction == "ASC" ? "icon icon-active icon-over icon-arrow-up" : "icon icon-active icon-over icon-arrow-down";
					i_self.setIconCls(s_iconCls);
				}
			},
			mouseout: {
				fn: function () {
					var s_iconCls = i_self.sortInfo.direction == "ASC" ? "icon icon-init icon-arrow-up" : "icon icon-init icon-arrow-down";
					i_self.setIconCls(s_iconCls);
				}
			},
			click: {
				fn: function() {
					i_self.changeSort();
					var o_config = i_self.getConfig();
					o_config.applyFn();
				}
			}
		});
		return i_self;
	},

	createMenu: function() {
		var i_self = this;
		i_self.menu = Ext.widget("menu", {
			plain: true,
			enableKeyNav: false,
			onMouseOver: Ext.emptyFn,
			doHiding: true,
			listeners: {
				beforehide: {
					fn: function() {
						var b_close = this.doHiding;
						var a_fields = this.query("combobox");
						Ext.Array.each(a_fields, function(i_field) {
							if (i_field.isExpanded) {
								b_close = false;
							}
						});
						return b_close;
					}
				}
			}
		});
		i_self.menu.button = i_self;
	},

	createSortInfo: function() {
		var i_self = this;
		var o_sortInfo = {
			property: i_self.dataIndex,
			direction: i_self.sortDirection || "ASC"
		};
		i_self.sortInfo = o_sortInfo;
	},

	changeSort: function() {
		var i_self = this;
		i_self.sortInfo.direction = i_self.sortInfo.direction == "ASC" ? "DESC" : "ASC";
		var s_iconCls = i_self.sortInfo.direction == "ASC" ? "icon icon-init icon-arrow-up" : "icon icon-init icon-arrow-down";
		i_self.setIconCls(s_iconCls);
	},

	getNot: function() {
		var i_self = this;
		var o_config = i_self.getConfig();
		return o_config.checkBoxNot.getValue();
	},

	setNot: function(value) {
		var i_self = this;
		var o_config = i_self.getConfig();
		o_config.checkBoxNot.setValue(value);
	},

	getValue: function() {
		// Implement in extended class
	},

	getSortInfo: function() {
		var i_self = this;
		return i_self.sortInfo;
	},

	getConfig: function() {
		var i_self = this;
		return i_self.config;
	},

	onFocusLeave: function(e) {
		var i_self = this;
		var i_menu = i_self.menu;
		var event = e.event;
		if (i_menu && !event.within(i_menu.getEl())) {
			i_menu.hide();
		}
	}
});
