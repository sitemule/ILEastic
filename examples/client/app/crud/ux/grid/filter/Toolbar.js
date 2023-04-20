Ext.define("Mvvm.crud.ux.grid.filter.Toolbar", {
	extend: "Ext.toolbar.Toolbar",
	alias: "widget.filterbar",
	dock: "top",
	menu: null,
	grid: null,
	requires:  [
		"Mvvm.crud.ux.grid.filter.Base",
		"Mvvm.crud.ux.grid.filter.Boolean",
		"Mvvm.crud.ux.grid.filter.Date",
		"Mvvm.crud.ux.grid.filter.Number",
		"Mvvm.crud.ux.grid.filter.String",
		"Mvvm.crud.ux.grid.filter.util"
	],

	initComponent: function() {
		var i_self = this;
		i_self.plugins = i_self.createPlugins();
		i_self.callParent(arguments);
		i_self.add(i_self.createItems());
		i_self.on({
			afterrender: {
				fn: function(item) {
					var i_grid = i_self.ownerCt;
					i_grid.on({
						afterrender: {
							fn: function(item) {

								var s_ddGroup = item.headerCt.reorderer.dragZone.ddGroup;
								i_self.dd.addDDGroup(s_ddGroup);
								i_self.grid = item;
							}
						},
						single: true
					});
				},
				single: true
			}
		});
		return i_self;
	},

	createItems: function() {
		var i_self = this;
		var items = [
			{
				xtype: "button",
				itemId: "button-clear",
				text: "Clear",
				reorderable: false,
				handler: function(i_button) {
					i_self.clearFilters();
				}
			},
			{
				xtype: 'tbseparator',
				reorderable: false
			}
		];
		return items;
	},

	createMenu: function() {
		var i_self = this;
		var i_splitbutton = Ext.widget("filtermenu", {
			text: "Filter",
			reorderable: false,
			toolbar: i_self,
			itemId: "menuFilter"
		});
		i_self.menu = i_splitbutton;
		return i_splitbutton;
	},

	getFilters: function() {
		var i_self = this;
		return i_self.query("splitbutton[isFilter=true]");
	},

	clearFilters: function() {
		var i_self = this;
		var i_grid = i_self.grid;
		var i_store = i_grid.getStore();
		var a_filters = i_self.getFilters();

		Ext.Array.each(a_filters, function(i_button) {
			if (i_button.overRuleable == null) {
				i_self.remove(i_button);
			}
			else {
				if (i_button.overRuleable) {
					i_self.remove(i_button);
				}
			}
		});

		a_filters = i_self.getFilters();

		delete i_store.proxy.extraParams.where;
		delete i_store.proxy.extraParams.sort;

		var o_sorters = i_store.getSorters();
		o_sorters.clear();
		var a_sorters = [];

		Ext.Array.each(a_filters, function(i_filter) {
			var o_sort = i_filter.getSortInfo();
			a_sorters.push(o_sort);
		});

		if (a_sorters.length > 0) {
			o_sorters.add(a_sorters);
		}
		else {
			i_store.clearAndLoad({
				callback: function() {
					i_store.fireEvent('sort', i_store, o_sorters.getRange());
				}
			});
		}

		//i_self.menu.reset();
	},

	clearStatus: function(i_menu) {
		var i_self = this;
		var a_items = i_menu.items.items;
		Ext.Array.each(a_items, function(i_item) {
			if (i_item.menu != null) {
				i_item.setIconCls("");
				i_self.clearStatus(i_item.menu);
			}
			else {
				i_item.setIconCls("");
			}
		});
	},

	clearFiltersNoReload: function() {
		var i_self = this;
		var i_grid = i_self.ownerCt;
		var i_store = i_grid.getStore();
		var a_filters = i_self.getFilters();
		Ext.Array.each(a_filters, function(i_button) {
			if (i_button.overRuleable == null) {
				i_self.remove(i_button);
			}
			else {
				if (i_button.overRuleable) {
					i_self.remove(i_button);
				}
			}
		});
		delete i_store.proxy.extraParams.where;
		delete i_store.proxy.extraParams.sort;
	},

	createWhere: function() {

		var i_self = this;
		var i_grid = i_self.ownerCt;
		var i_store = i_grid.getStore();
		var i_proxy = i_store.getProxy();
		var o_extraParams = i_proxy.getExtraParams();
		var a_filters = i_self.getFilters();
		var s_where = "";
		var s_sort = "";
		var n_whereAdded = 0;
		var n_sortAdded = 0;
		var o_sorters = i_store.getSorters();
		var a_sorters = [];

		Ext.Array.each(a_filters, function(i_filter, n_index) {
			var s_value = i_filter.getValue();
			if (s_value) {
				if (n_whereAdded == 0) {
					s_where += s_value;
					n_whereAdded++;
				}
				else {
					s_where += " AND " + s_value;
				}
			}
			a_sorters.push(i_filter.getSortInfo());
		});

		a_sorters = a_sorters.filter(function(o_sort) {
			var b_found = false;
			Ext.Array.each(o_sorters.items, function(i_sorter) {
				if (i_sorter.getProperty() == o_sort.property) {
					if (i_sorter.getDirection() != o_sort.direction) {
						i_sorter.setDirection(o_sort.direction);
					}
					b_found = true;
				}
			});
			return !b_found;
		});
		o_extraParams.where = s_where;
	},

	applyFilters: function() {

		var i_self = this;
		var i_grid = i_self.grid;
		var i_store = i_grid.getStore();
		var i_proxy = i_store.getProxy();
		var o_extraParams = i_proxy.getExtraParams();
		var a_filters = i_self.getFilters();
		var s_where = "";
		var s_sort = "";
		var n_whereAdded = 0;
		var n_sortAdded = 0;
		var o_sorters = i_store.getSorters();
		var a_sorters = [];

		Ext.Array.each(a_filters, function(i_filter, n_index) {
			var s_value = i_filter.getValue();
			if (s_value) {
				if (n_whereAdded == 0) {
					s_where += s_value;
					n_whereAdded++;
				}
				else {
					s_where += " AND " + s_value;
				}
			}
			a_sorters.push(i_filter.getSortInfo());
		});

		a_sorters = a_sorters.filter(function(o_sort) {
			var b_found = false;
			Ext.Array.each(o_sorters.items, function(i_sorter) {
				if (i_sorter.getProperty() == o_sort.property) {
					if (i_sorter.getDirection() != o_sort.direction) {
						i_sorter.setDirection(o_sort.direction);
					}
					b_found = true;
				}
			});
			return !b_found;
		});
		o_extraParams.where = s_where;
		if (a_sorters.length > 0) {
			o_sorters.add(a_sorters);
		}
		else {
			i_store.clearAndLoad({
				callback: function() {
					i_store.fireEvent('sort', i_store, o_sorters.getRange());
				}
			});
		}
	},

	removeFilter: function(i_filter) {

		var i_self = this;
		i_self.remove(i_filter);

		var i_grid = i_self.ownerCt;
		var i_store = i_grid.getStore();
		var o_sorters = i_store.getSorters();
		var o_sort = i_filter.getSortInfo();
		var a_filters = i_self.getFilters();

		var a_removed = o_sorters.items.filter(function(i_sorter) {
			var b_found = false;
			if (i_sorter.getProperty() == o_sort.property) {
				b_found = true;
			}
			return b_found;
		});
		if (a_removed.length > 0 && a_filters.length > 0) {
			i_self.createWhere();
			o_sorters.remove(a_removed);
		}
		else {
			if (a_filters.length > 0) {
				i_self.applyFilters();
			}
			else {
				i_self.clearFilters();
			}
		}
	},

	sortChange: function(i_column) {
		var i_self = this;
		var a_filters = i_self.getFilters();
		var b_found = false;
		Ext.Array.each(a_filters, function(i_filter) {
			if (i_filter.dataIndex == i_column.dataIndex) {
				var o_sort = i_filter.getSortInfo();
				b_found = true;
				if (i_column.sortState != null) {
					if (o_sort.direction != i_column.sortState) {
						i_filter.changeSort();
					}
				}
			}
		});
		if (!b_found) {
			var i_plugin = i_self.getPlugin("plugin-drop");
			i_plugin.createItem({
				header: i_column
			});
		}
	},

	createPlugins: function() {
		var i_self = this;
		var a_plugins = [
			i_self.createReorderplugin(),
			i_self.createDropPlugin()
		];
		return a_plugins;
	},

	createReorderplugin: function() {

		var i_self = this;
		var o_reorder = {
			pluginId: "plugin-reorderer",
			ptype: "boxreorder",
			removeOnDrop: function(element, i_button) {
				var i_dropped = Ext.getCmp(element.id);
				var b_remove = false;
				if (i_dropped && i_dropped.itemId == "button-clear") {
					b_remove = true;
					i_self.removeFilter(i_button);
				}
				return b_remove;
			},
			listeners: {
				Drop: {
					fn: function(i_self, i_toolbar, component, startIdx, idx) {
						if (startIdx != idx) {
							i_toolbar.applyFilters();
						}
					}
				}
			}
		};
		return o_reorder;
	},

	createDropPlugin: function() {
		var i_self = this;
		var o_dropplugin = {
			pluginId: "plugin-drop",
			ptype: "toolbardroppable",
			canDrop: function(ddSource, event, i_data) {
				if (i_data.header) {
					if (i_data.header.filterable == null) {
						i_data.header.filterable = true;
					}
					if (i_data.header.filterable) {
						var o_header = i_data.header;
						var a_filters = i_self.getFilters();
						var b_result = true;
						Ext.Array.each(a_filters, function(o_filter) {
							if (o_filter.text == o_header.text) {
								b_result = false;
							}
						});
						return b_result;
					}
					else {
						return false;
					}
				}
				else {
					return false;
				}
			},
			createItem: function(i_data) {
				var i_grid = i_self.ownerCt;
				var i_store = i_grid.getStore();
				var i_header = i_data.header;
				var i_model = i_store.getModel();
				var a_fields = i_model.getFields();
				var s_type = "string";
				Ext.Array.each(a_fields, function(i_field) {
					if (i_field.name == i_header.dataIndex) {
						if (i_field.datatype) {
							switch(i_field.datatype) {
								case "char":
								case "varchar":
								case "auto":
									s_type = "string";
									break;
								case "dec":
								case "int":
								case "float":
								case "decimal":
									s_type = "number";
									break;
								default:
									s_type = i_field.datatype;
									break;
							}
						}
						else {
							s_type = "string"
						}
					}
				})
				var s_datetype = "date";
				var b_string = false;
				var b_mulitiSelect = false;
				var b_like = false;
				var o_dmd = {};

				if (s_type == "int") {
					s_type = "number";
				}
				if (i_header.xpd && !i_header.enum && !i_header.filterXpd) {
					var o_xpdInfo = ip2.getFieldXpdInfo(i_header.dataIndex, o_dmdInfo.entity, i_header);
					if (!o_xpdInfo) {
						var o_xpd = ip2.resource.get(i_header.xpd + ".xpd");
						var o_xpdProp = o_xpd.properties[i_header.xpdProp];
						o_xpdInfo = {
							definition: o_xpdProp
						};
					}
					var o_definition = o_xpdInfo.definition;
					if (o_definition.dmd) {
						o_dmd = o_definition.dmd;
						o_dmd.view = o_dmdConfig.uiName;
						s_type = "entity";
					}
					else if (o_definition.context) {
						if (o_definition.context.grid.uitype) {
							s_type = o_definition.context.grid.uitype;
						}
					}
					else if (o_definition.type == "isotimestamp") {
						s_type = "date";
					}
					else if (o_definition.type == "date") {
						s_type = "date";
						s_datetype = "date";
					}
					else {
						var s_db = o_definition.type || "";
						if (s_db.indexOf("varchar") != -1 || s_db.indexOf("display") != -1) {
							s_type = "string";
						}
						else if (o_definition.type == "boolean") {
							s_type = o_definition.type;
						}
						else {
							var o_xpd = o_xpdInfo.xpd;
							var a_keys = Object.keys(o_xpd.collections);
							var a_values = [];
							Ext.Array.each(a_keys, function(s_key) {
								if (s_key != "all") {
									var o_collection = o_xpd.collections[s_key];
									var o_value = {
										key: o_collection.id,
										value: ip2.xpd.translate(o_xpd, o_collection.title)
									};
									a_values.push(o_value);
								}
							});
							a_values.sort(function(o_first, o_second) {
								return o_first.value > o_second.value;
							});
							s_type = "enum";
						}
					}
				}
				else if (i_header.filterXpd) {
					var o_column = {
						xpd: i_header.filterXpd
					};
					var o_xpdInfo = ip2.getFieldXpdInfo(i_header.supportProp, o_dmdInfo.entity, o_column);
					if (!o_xpdInfo) {
						var o_xpd = ip2.resource.get(i_header.xpd + ".xpd");
						var o_xpdProp = o_xpd.properties[i_header.xpdProp];
						o_xpdInfo = {
							definition: o_xpdProp
						};
					}
					var o_definition = o_xpdInfo.definition;
					if (o_definition.dmd) {
						o_dmd = o_definition.dmd;
						o_dmd.view = o_dmdConfig.uiName;
						s_type = "entity";
					}
					else if (o_definition.context) {
						if (o_definition.context.grid.uitype) {
							s_type = o_definition.context.grid.uitype;
						}
					}
					else if (o_definition.type == "isotimestamp") {
						s_type = "date";
					}
					else if (o_definition.type == "date") {
						s_type = "date";
						s_datetype = "date";
					}
					else {
						var s_db = o_definition.type || "";
						if (s_db.indexOf("varchar") != -1 || s_db.indexOf("display") != -1) {
							s_type = "string";
						}
						else if (o_definition.type == "boolean") {
							s_type = o_definition.type;
						}
						else {
							var o_xpd = o_xpdInfo.xpd;
							var a_keys = Object.keys(o_xpd.collections);
							var a_values = [];
							Ext.Array.each(a_keys, function(s_key) {
								if (s_key != "all") {
									var o_collection = o_xpd.collections[s_key];
									var o_value = {
										key: o_collection.id,
										value: ip2.xpd.translate(o_xpd, o_collection.title)
									};
									a_values.push(o_value);
								}
							});
							a_values.sort(function(o_first, o_second) {
								return o_first.value > o_second.value;
							});
							s_type = "enum";
						}
					}
				}
				else if (i_header.enum) {
					var o_ns = ip2.resource.get("adm.ns");
					var o_enums = o_ns.enums[i_header.enum].values;
					var a_keys = Object.keys(o_enums);
					var a_values = [];
					Ext.Array.each(a_keys, function(s_key) {
						var o_enum = o_enums[s_key];
						var o_value = {
							key: s_key,
							value: ip2.i18n(o_enum)
						};
						a_values.push(o_value);
					});
					b_string = true;
					s_type = "enum";
					if (i_header.xpd) {
						var o_xpdInfo = ip2.getFieldXpdInfo(i_header.dataIndex, o_dmdInfo.entity, i_header);
						var o_definition = o_xpdInfo.definition;
						b_mulitiSelect = o_definition.multiSelect || i_header.multiSelect != undefined ? i_header.multiSelect : false;
						b_like = o_definition.useLike || i_header.useLike != undefined ? i_header.useLike : false;
					}
				}

				else if (i_header.uitype != "") {
					if (i_header.uitype == "boolean") {
						s_type = i_header.uitype;
						b_string = true;
					}
					else if (i_header.uitype == "isotimestamp") {
						s_type = "date";
					}
				}

				if (s_type == "timestamp") {
					s_type = "date";
					s_datetype = "datetime";
				}

				var o_config = {
					text: i_header.text,
					dataIndex: i_header.filterXpd != null ? i_header.supportProp : i_header.dataIndex,
					dataType: s_type,
					dataDateType: s_datetype,
					isString: b_string,
					multiSelect: b_mulitiSelect,
					sortDirection: i_header.sortState || "ASC",
					overRuleable: true,
					useLike: b_like,
					values: a_values,
					dmd: o_dmd,
					applyFn: function() {
						i_self.applyFilters();
					},
					removeFn: function(i_filter) {
						i_self.removeFilter(i_filter);
					}
				};

				var i_filter = Mvvm.crud.ux.grid.filter.util.createFilter(o_config);

				i_self.add(i_filter);
				i_self.applyFilters();
			}
		};
		return o_dropplugin;
	}
});
