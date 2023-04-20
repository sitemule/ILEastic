Ext.define("Ext.ux.grid.filter.Menu", {
	extend: "Ext.button.Split",

	alias: "widget.filtermenu",
	currentFilter: "",
	creator: "",
	reorderable: false,

	initComponent: function() {
		var i_self = this;

		i_self.menu = {
			items: [],
			listeners: {
				show: {
					fn: function(i_menu) {

						var i_toolbar = i_self.toolbar;
						var a_filters = i_toolbar.getFilters();
						var i_itemSaveAs = i_menu.down("#itemSaveAs");
						var i_itemSave = i_menu.down("#itemSave");
						var s_user = ip2.navigator.user.id;

						if (a_filters.length == 0) {
							i_itemSaveAs.disable();
						}
						else {
							i_itemSaveAs.enable();
						}

						if (!i_self.currentFilter) {
							i_itemSave.disable();
						}
						else {
							if (i_self.creator) {
								if (s_user != i_self.creator) {
									i_itemSave.disable();
								}
								else {
									i_itemSave.enable();
								}
							}
							else {
								i_itemSave.enable();
							}
						}
					}
				}
			}
		};

		i_self.callParent();
		i_self.on({
			beforerender: {
				fn: function(i_button) {
					var i_menu = i_button.menu;
					var a_items = i_self.createMenuItems();
					i_menu.add(a_items);
				}
			}
		});
	},

	createEdit: function(f_callback) {
		var i_self = this;
		var wnd = Ext.widget("filterviewedit", {
			title: ip2.i18n({
				"da": "Gem filter",
				"en": "Save filter"
			}),
			okFn: f_callback
		});
		return wnd;
	},

	createMenuItems: function() {

		var i_self = this;
		var i_grid = i_self.up("ip2pagingGridOld");
		var a_columns = i_grid.columns;
		var s_key = i_grid.s_id;
		var s_unique = ip2.unique();
		var s_user = ip2.navigator.user.id;

		var o_return = i_self.getFilters(s_key, s_user, s_unique);

		var a_public_items = o_return.public.items;
		var a_private_items = o_return.private.items;
		var a_recently = o_return.private.recent;

		i_self.addApplyHandler(o_return, a_columns, true);
		i_self.addApplyHandler(o_return, a_columns, false);

		var a_items = [];

		if (a_recently.length > 0) {
			var o_recent = {
				text: ip2.i18n({
					"da": "Senest anvendte",
					"en": "Recently used"
				}),
				disabledCls: "menu-item",
				disabled: true
			};
			a_items.push(o_recent);
			a_items.push({
				xtype: "menuseparator"
			});
			var a_return = i_self.createRecentItems(s_unique, a_recently);
			ip2.each(a_return, function(i_recent) {
				a_items.push(i_recent);
			});
			a_items.push({
				xtype: "menuseparator"
			});
		}

		var o_public = {
			xtype: "menuitem",
			text: ip2.i18n({
				"da": "Offentlig",
				"en": "Public"
			}),
			itemId: "public_menu_" + s_unique,
			disabled: a_public_items.length == 0 ? true : false,
			iconCls: i_self.currentFilter != "" ? i_self.isPublic ? "x-ux-filter-check" : "" : ""
		};

		var o_private = {
			xtype: "menuitem",
			text: ip2.i18n({
				"da": "Privat",
				"en": "Private"
			}),
			itemId: "private_menu_" + s_unique,
			disabled: a_private_items.length == 0 ? true : false,
			iconCls: i_self.currentFilter != "" ? i_self.isPublic == false ? "x-ux-filter-check" : "" : ""
		};

		if (a_public_items.length > 0) {
			o_public.menu = {
				items: a_public_items
			};
		}

		if (a_private_items.length > 0) {
			o_private.menu = {
				items: a_private_items
			};
		}

		a_items.push(o_public);
		a_items.push(o_private);

		a_items.push({
			xtype: "menuitem",
			itemId: "itemSave",
			text: ip2.i18n({
				"da": "Gem",
				"en": "Save"
			}),
			disabled: i_self.currentFilter != "" ? false : true,
			handler: function(i_button) {
				i_self.saveFilters(s_key, s_user, i_self.currentFilter, i_self.isPublic);
			}
		},
			i_self.createSaveAs(s_key, s_user)
		);

		return a_items;
	},

	createRecentItems: function(s_unique, a_recent) {

		var i_self = this;
		var a_items = [];
		ip2.each(a_recent, function(o_recent) {

			var s_text = "";
			var i_public;
			if (o_recent.isPublic) {

				s_text = o_recent.name + " ( " + ip2.i18n({
					"da": "Offentlig",
					"en": "Public"
				}) + " )";
			}
			else {
				s_text = o_recent.name;
			}

			var i_menuitem = Ext.widget("menuitem", {
				text: s_text,
				tag: o_recent.tag,
				isPublic: o_recent.isPublic,
				iconCls: i_self.currentFilter == o_recent.name ? i_self.isPublic == o_recent.isPublic ? "x-ux-filter-check" : "" : "",
				unique: s_unique,
				handler: function(i_recent) {
					var s_unique = i_recent.unique;
					var s_tag = i_recent.tag + "-" + s_unique;
					var s_itemId = i_recent.isPublic ? "public-" + s_tag : "private-" + s_tag;
					var s_menuId = i_recent.isPublic ? "public_menu_" + s_unique : "private_menu_" + s_unique;
					var i_item = i_self.menu.down("#" + s_itemId);
					var i_menu = i_self.menu.down("#" + s_menuId);

					if (i_item) {
						i_item.handler(i_item);
					}
					if (i_menu) {
						i_menu.setIconCls("x-ux-filter-check");
					}

					i_recent.setIconCls("x-ux-filter-check");
				}
			});
			a_items.push(i_menuitem);
		});
		return a_items;
	},

	createSaveAs: function(s_gridId, s_id) {

		var i_self = this;
		var s_key = s_gridId;
		var s_user = s_id;

		var i_menuitem = Ext.widget("menuitem", {
			itemId: "itemSaveAs",
			text: ip2.i18n({
				"da": "Gem som",
				"en": "Save as"
			}),
			handler: function(i_button) {
				var wnd = i_self.createEdit(function(b_public, s_name) {

					if (b_public) {

						var b_found = false;
						var o_filter;

						var o_settings = ip2.global.get(s_key + '.filters', {
							filters: []
						});

						ip2.each(o_settings.filters, function(db_filter) {
							if (db_filter.name == s_name) {
								o_filter = db_filter;
								b_found = true;
							}
						});
						if (b_found) {
							if (o_filter.creator != s_user) {
								Ext.Msg.show({
									title: ip2.i18n({
										"da": "Fejl",
										"en": "Error"
									}),
									msg: ip2.i18n({
										"da": "Du har ikke rettighed til at gemme et under dette navn (<b> " + s_name + " </b>)<br>" +
										"Da en anden bruger ( <b>" + o_filter.creator + "</b> ) har alrede oprettet et under sammen navn.<br>" +
										"Hvis du ønsker at gemme dette navn prøv da at gemme som privat stedet for..",
										"en": "You do not have permissions to save under this name (<b> " + s_name + " </b>)</br>" +
										"Since another user (<b> " + o_filter.creator + "</b> ) already has created one under this name.</br>" +
										"If you want to use this name try to save as a private instead.."
									}),
									buttons: Ext.Msg.OK,
									icon: Ext.Msg.ERROR
								});
							}
							else {
								i_self.saveFilters(s_key, s_user, s_name, b_public);
								wnd.close();
							}
						}
						else {
							i_self.saveFilters(s_key, s_user, s_name, b_public);
							wnd.close();
						}
					}
					else {
						i_self.saveFilters(s_key, s_user, s_name, b_public);
						wnd.close();
					}
				});
				wnd.show();
			}
		});
		return i_menuitem;
	},

	/*********************
	*     FUNCTIONS     *
	*********************/

	addApplyHandler: function(o_return, a_columns, b_public) {
		var i_self = this;
		var i_toolbar = i_self.toolbar;
		var n_count = 0;
		var s_name = "";
		var a_items = b_public ? o_return.public.items : o_return.private.items;
		var a_filters = b_public ? o_return.public.filters : o_return.private.filters;
		var s_key = o_return.key;

		var count = function() {
			n_count--;
			if (n_count == 0) {
				i_self.currentFilter = s_name;
				i_toolbar.applyFilters();
			}
		};

		ip2.each(a_items, function(i_menuitem) {
			i_menuitem.handler = function(i_menuitem) {

				var a_configs = [];

				ip2.each(a_filters, function(o_filter) {
					if (o_filter.tag == i_menuitem.tag) {
						a_configs = o_filter.configs;
						s_name = o_filter.name;
					}
				});

				var s_text = ip2.i18n({
					"da": "Filter - ",
					"en": "Filter - "
				});

				s_text = s_text + s_name;

				i_self.setText(s_text);
				i_self.clearStatus(i_self.menu);
				i_self.menu.hide();

				i_menuitem.setIconCls("x-ux-filter-check");

				if (i_menuitem.parentMenu.parentItem) {
					i_menuitem.parentMenu.parentItem.setIconCls("x-ux-filter-check");
				}

				i_self.isPublic = b_public;
				i_self.creator = i_menuitem.creator;

				if (a_configs.length > 0) {

					i_toolbar.clearFiltersNoReload();

					ip2.each(a_configs, function(o_config) {

						var i_column;

						for (var i = 0; i < a_columns.length; i++) {
							var c = a_columns[i];
							if (c.dataIndex == o_config.dataIndex) {
								o_config.text = c.text;
								break;
							}
						}

						var a_values = o_config.fieldValues;
						var a_checkbox = o_config.checkboxes;
						var b_not = o_config.notValue || false;

						o_config.applyFn = function() {
							i_toolbar.applyFilters();
						},

						o_config.removeFn = function(i_filter) {
							i_toolbar.removeFilter(i_filter);
						};

						/* REMOVE UNUSED PROPERTIES SO THEY DONT POLLUTE THE FILTER */
						delete o_config.checkboxes;
						delete o_config.fieldValues;
						delete o_config.notValue;

						var i_filter = Ext.ux.grid.filter.util.createFilter(o_config);
						i_filter.setNot(b_not);

						/* ADD PROPERTIES SO WE DONT LOSE THEM FOR FURTHER USAGES */
						o_config.checkboxes = a_checkbox;
						o_config.fieldValues = a_values;
						o_config.notValue = b_not;

						var o_filterConfig = i_filter.getConfig();
						var a_filtercheckboxs = o_filterConfig.checkboxes;
						var a_filterfields = o_filterConfig.fields;
						var n_index = 0;

						ip2.each(a_filtercheckboxs, function(o_checkbox) {
							var i_field = a_filterfields[n_index];
							var value = a_values[n_index];
							o_checkbox.setValue(a_checkbox[n_index]);
							if (i_field.fieldtype != "bt") {
								if (o_checkbox.dataType == "enum" || o_checkbox.dataType == "entity") {
									n_count++;
									var i_store = i_field.getStore();
									i_store.on({
										load: {
											fn: function(store, records) {
												i_field.setValue(value);
												count();
											}
										}
									});
								}
								else {
									i_field.setValue(value);
								}
							}
							else {
								var o_value = a_values[n_index];
								var a_items = i_field.items.items;
								var i_first = a_items[0];
								var i_second = a_items[1];
								i_first.setValue(o_value.first);
								i_second.setValue(o_value.second);
							}
							n_index++;
						});
						i_toolbar.add(i_filter);
						i_self.saveRecently(s_key, s_name, b_public);
					});
					if (n_count == 0) {
						n_count++;
						count();
					}
				}
			};
		});
	},

	clearStatus: function(i_menu) {
		var i_self = this;
		var a_items = i_menu.items.items;
		ip2.each(a_items, function(i_item) {
			if (i_item.menu != null) {
				i_item.setIconCls("");
				i_self.clearStatus(i_item.menu);
			}
			else {
				i_item.setIconCls("");
			}
		});
	},

	copyToPrivat: function(s_name) {
		var i_self = this;
		var i_grid = i_self.up("ip2pagingGridOld");
		var s_user = ip2.navigator.user.id;
		var s_key = i_grid.s_id;

		var o_private;

		var o_settings_public = ip2.global.get(s_key + '.filters', {
			filters: []
		});

		var o_settings_private = ip2.profile.get(s_key + '.filters', {
			filters: [],
			recent: []
		});

		var b_found = false;
		var s_filter = "";
		ip2.each(o_settings_private.filters, function(o_filter) {
			if (o_filter.tag == s_name) {
				s_filter = o_filter.name;
				b_found = true;
			}
		});

		if (b_found) {

			Ext.Msg.show({
				title: ip2.i18n({
					"da": "Fejl",
					"en": "Error"
				}),
				msg: ip2.i18n({
					"da": "Du har allerede gemt et filter under det navn (<b> " + s_filter + " </b>)<br>" +
					"Hvis du ønsker at gemme dette filter, vælg da filteret først<br>" +
					"og der næst brug da <b>Gem som </b> og indtast et andet navn.",
					"en": "You already have saved a filter under this name (<b> " + s_filter + " </b>)</br>" +
					"If wish to save this filter please select the filter first<br>" +
					"and then use <b>Save as<b> and choose another name."
				}),
				buttons: Ext.Msg.OK,
				icon: Ext.Msg.ERROR
			});
		}
		else {
			ip2.each(o_settings_public.filters, function(o_filter) {
				if (o_filter.tag == s_name) {
					o_private = ip2.extend({}, o_filter);
					o_private.creator = s_user;
				}
			});

			o_settings_private.filters.push(o_private);
			ip2.profile.set(s_key + ".filters", JSON.stringify(o_settings_private), function() {
				i_self.reload();
			});
		}
	},

	copyToPublic: function(s_name) {
		var i_self = this;
		var i_grid = i_self.up("ip2pagingGridOld");
		var s_user = ip2.navigator.user.id;
		var s_key = i_grid.s_id;

		var o_public;
		var o_private;

		var o_settings_public = ip2.global.get(s_key + '.filters', {
			filters: []
		});

		var o_settings_private = ip2.profile.get(s_key + '.filters', {
			filters: [],
			recent: []
		});

		var b_found = false;
		var s_filter = "";
		ip2.each(o_settings_public.filters, function(o_filter) {
			if (o_filter.tag == s_name) {
				o_public = o_filter;
				s_filter = o_public.name;
				b_found = true;
			}
		});

		if (b_found) {

			Ext.Msg.show({
				title: ip2.i18n({
					"da": "Fejl",
					"en": "Error"
				}),
				msg: ip2.i18n({
					"da": "Du har ikke rettighed til at gemme et under dette navn (<b> " + s_filter + " </b>)<br>" +
					"Da en anden bruger ( <b>" + o_public.creator + "</b> ) har alrede oprettet et under sammen navn.<br>" +
					"Hvis du ønsker at gemme dette navn prøv da at gemme som privat stedet for..",
					"en": "You do not have permissions to save under this name (<b> " + s_filter + " </b>)</br>" +
					"Since another user (<b> " + o_public.creator + "</b> ) already has created one under this name.</br>" +
					"If you want to use this name try to save as a private instead.."
				}),
				buttons: Ext.Msg.OK,
				icon: Ext.Msg.ERROR
			});
		}
		else {
			ip2.each(o_settings_private.filters, function(o_filter) {
				if (o_filter.tag == s_name) {
					o_public = ip2.extend({}, o_filter);
					o_public.creator = s_user;
				}
			});
			o_settings_public.filters.push(o_public);
			ip2.global.set(s_key + ".filters", JSON.stringify(o_settings_public), function() {
				i_self.reload();
			});
		}
	},

	deleteFilter: function(s_gridId, s_name, b_public) {
		var i_self = this;
		var i_toolbar = i_self.toolbar;
		var s_key = s_gridId;
		var o_settings;

		if (b_public) {
			o_settings = ip2.global.get(s_key + '.filters', {
				filters: []
			});
		}
		else {
			o_settings = ip2.profile.get(s_key + '.filters', {
				filters: [],
				recent: []
			});
		}

		var b_found = false;
		for (var i = 0; i < o_settings.filters.length; i++) {
			var o_filter = o_settings.filters[i];
			if (o_filter.tag == s_name) {
				o_settings.filters.splice(i, 1);
				b_found = true;
				if (o_filter.name == i_self.currentFilter && b_public == i_self.isPublic) {
					i_self.currentFilter = "";
					var s_text = ip2.i18n({
						"da": "Filter",
						"en": "Filter"
					});
					i_self.setText(s_text);
					i_toolbar.clearFilters();
				}
				break;
			}
		}
		if (b_found) {
			if (b_public) {
				ip2.global.set(s_key + ".filters", JSON.stringify(o_settings), function() {
					i_self.deleteRecently(s_key, s_name, b_public);
				});
			}
			else {
				ip2.profile.set(s_key + ".filters", JSON.stringify(o_settings), function() {
					i_self.deleteRecently(s_key, s_name, b_public);
				});
			}
		}
	},

	deleteRecently: function(s_key, s_name, b_public) {

		var i_self = this;
		var o_settings = ip2.profile.get(s_key + '.filters', {
			filters: [],
			recent: []
		});

		var b_found = false;
		var n_idx = 0;
		ip2.each(o_settings.recent, function(o_recently, n_index) {
			if (o_recently.name == s_name && o_recently.isPublic == b_public) {
				b_found = true;
				n_idx = n_index;
			}
		});
		if (b_found) {
			o_settings.recent.splice(n_idx, 1);
		}
		ip2.profile.set(s_key + ".filters", JSON.stringify(o_settings), function() {
			i_self.reload();
		});
	},

	getFilters: function(s_gridId, s_id, s_unique) {

		var i_self = this;

		var a_public = [];
		var a_private = [];
		var s_user = s_id;
		var s_key = s_gridId;

		var o_settings_public = ip2.global.get(s_key + '.filters', {
			filters: []
		});

		var o_settings_private = ip2.profile.get(s_key + '.filters', {
			filters: [],
			recent: []
		});

		if (!o_settings_private.recent) {
			o_settings_private.recent = [];
		}

		var b_diffPublic = false;
		var b_diff = false;

		ip2.each(o_settings_public.filters, function(o_filter) {
			if (!o_filter.tag) {
				o_filter.tag = "filter-" + Ext.id();
				b_diffPublic = true;
			}
			var menuitem = Ext.widget("menuitem", {
				text: o_filter.name + " ( " + o_filter.creator + " ) ",
				tag: o_filter.tag,
				itemId: "public-" + o_filter.tag + "-" + s_unique,
				creator: o_filter.creator,
				iconCls: i_self.currentFilter == o_filter.name ? i_self.isPublic == true ? "x-ux-filter-check" : "" : "",
				listeners: {
					afterrender: {
						fn: function(i_menuitem) {
							var i_el = i_menuitem.getEl();
							var i_menu;
							i_el.on({
								contextmenu: function(e) {
									e.stopEvent();
									var s_id = this.id;
									var i_menuitem = Ext.getCmp(s_id);
									var b_hide = false;

									if (i_menu) {
										i_menu.hide();
										i_menu.destroy();
										delete i_menu;
									}

									i_menu = Ext.widget("menu", {
										allowOtherMenus: true,
										items: [
											{
												text: ip2.i18n({
													"da": "Slet",
													"en": "delete"
												}),
												tag: i_menuitem.tag,
												isPublic: true,
												disabled: i_menuitem.creator != s_user ? true : false,
												handler: function(i_contextitem) {
													var s_name = i_contextitem.tag;
													var b_public = i_contextitem.isPublic;
													i_self.deleteFilter(s_key, s_name, b_public);
												}
											},
											{
												text: ip2.i18n({
													"da": "Kopier til privat",
													"en": "Copy to privat"
												}),
												tag: i_menuitem.tag,
												handler: function(i_contextitem) {
													var s_name = i_contextitem.tag;
													i_self.copyToPrivat(s_name);
												}
											}
										]
									});
									i_menu.on({
										hide: {
											fn: function(item) {
												b_hide = true;
												i_self.menu.syncHidden();
											}
										}
									});
									var i_parentMenu = i_menuitem.parentMenu;
									i_self.menu.on({
										beforehide: {
											fn: function(item) {
												return b_hide;

											}
										}
									});
									i_menu.mon(i_parentMenu, "beforehide", function(i_menuitem) {
										return b_hide;
									});

									i_menu.showAt(e.getXY());
								}
							});
						}
					}
				}
			});
			a_public.push(menuitem);
		});

		ip2.each(o_settings_private.filters, function(o_filter) {
			if (!o_filter.tag) {
				o_filter.tag = "filter-" + Ext.id();
				b_diff = true;
			}
			var menuitem = Ext.widget("menuitem", {
				text: o_filter.name,
				tag: o_filter.tag,
				itemId: "private-" + o_filter.tag + "-" + s_unique,
				creator: o_filter.creator,
				iconCls: i_self.currentFilter == o_filter.name ? i_self.isPublic == false ? "x-ux-filter-check" : "" : "",
				listeners: {
					afterrender: {
						fn: function(i_menuitem) {
							var i_el = i_menuitem.getEl();
							var i_menu;
							i_el.on({
								contextmenu: function(e) {
									e.stopEvent();
									var s_id = this.id;
									var i_menuitem = Ext.getCmp(s_id);
									var b_hide = false;

									if (i_menu) {
										i_menu.hide();
										i_menu.destroy();
										delete i_menu;
									}

									i_menu = Ext.widget("menu", {
										allowOtherMenus: true,
										items: [
											{
												text: ip2.i18n({
													"da": "Slet",
													"en": "delete"
												}),
												tag: i_menuitem.tag,
												isPublic: false,
												handler: function(i_contextitem) {
													var s_name = i_contextitem.tag;
													var b_public = i_contextitem.isPublic;
													i_self.deleteFilter(s_key, s_name, b_public);
												}
											},
											{
												text: ip2.i18n({
													"da": "Kopier til offentlig",
													"en": "Copy to public"
												}),
												tag: i_menuitem.tag,
												handler: function(i_contextitem) {
													var s_name = i_contextitem.tag;
													i_self.copyToPublic(s_name);
												}
											}
										]
									});
									i_menu.on({
										hide: {
											fn: function(item) {
												b_hide = true;
												i_self.menu.syncHidden();
											}
										}
									});
									var i_parentMenu = i_menuitem.parentMenu;
									i_self.menu.on({
										beforehide: {
											fn: function(item) {
												return b_hide;

											}
										}
									});
									i_menu.mon(i_parentMenu, "beforehide", function(i_menuitem) {
										return b_hide;
									});


									i_menu.showAt(e.getXY());
								}
							});
						}
					}
				}
			});
			a_private.push(menuitem);
		});
		ip2.each(o_settings_private.recent, function(o_recent, n_index) {
			if (o_recent.isPublic) {
				var b_found = false;
				ip2.each(o_settings_public.filters, function(o_filter) {
					if (o_recent.name == o_filter.name) {
						o_recent.tag = o_filter.tag;
						b_found = true;
					}
				});
				if (!b_found) {
					b_diff = true;
					o_settings_private.recent.splice(n_index, 1);
				}
			}
			else {
				ip2.each(o_settings_private.filters, function(o_filter) {
					if (o_recent.name == o_filter.name) {
						o_recent.tag = o_filter.tag;
					}
				});
			}
		});

		if (b_diffPublic) {
			ip2.global.set(s_key + ".filters", JSON.stringify(o_settings_public));
		}

		if (b_diff) {
			ip2.profile.set(s_key + ".filters", JSON.stringify(o_settings_private));
		}

		var o_return = {
			public: {
				items: a_public,
				filters: o_settings_public.filters
			},
			private: {
				items: a_private,
				filters: o_settings_private.filters,
				recent: o_settings_private.recent
			},
			key: s_key
		};
		return o_return;
	},

	saveFilters: function(s_key, s_user, s_name, b_public) {

		var i_self = this;
		var i_toolbar = i_self.toolbar;
		var a_filers = [];
		var a_items = [];
		var o_settings = "";

		if (b_public) {
			o_settings = ip2.global.get(s_key + '.filters', {
				filters: []
			});
		}
		else {
			o_settings = ip2.profile.get(s_key + '.filters', {
				filters: [],
				recent: []
			});
		}
		if (!b_public) {
			if (!o_settings.recent) {
				o_settings.recent = [];
			}
		}

		var found = false;
		var db_filter;
		ip2.each(o_settings.filters, function(o_filter) {
			if (o_filter.name == s_name) {
				found = true;
				db_filter = o_filter;
			}
		});

		var a_filters = i_toolbar.getFilters();
		if (!found) {
			db_filter = {
				tag: "filter-" + Ext.id(),
				name: s_name,
				creator: s_user,
				configs: []
			};
		}
		else {
			db_filter.configs = [];
		}

		ip2.each(a_filters, function(i_button) {
			var i_config = i_button.getConfig();
			var o_sortInfo = i_button.getSortInfo();
			var a_checkbox = [];
			var a_values = [];
			ip2.each(i_config.checkboxes, function(i_checkbox) {
				a_checkbox.push(i_checkbox.checked);
			});
			ip2.each(i_config.fields, function(i_field) {
				if (i_field.fieldtype != "bt") {
					var value = i_field.getValue() || "";
					a_values.push(value);
				}
				else {
					var a_items = i_field.items.items;
					var i_first = a_items[0];
					var i_second = a_items[1];
					var o_value = {
						first: i_first.getValue() || "",
						second: i_second.getValue() || ""
					};
					a_values.push(o_value);
				}
			});
			var o_config = {
				dataIndex: i_button.dataIndex,
				dataType: i_button.dataType,
				dataDateType: i_button.dataDateType || "",
				isString: i_button.isString || false,
				multiSelect: i_button.multiSelect || false,
				sortDirection: o_sortInfo.direction,
				overRuleable: i_button.overRuleable,
				dmd: i_button.dmd || "",
				checkboxes: a_checkbox,
				fieldValues: a_values,
				notValue: i_button.getNot(),
				values: i_button.values || []
			};
			db_filter.configs.push(o_config);
		});
		if (!found) {
			o_settings.filters.push(db_filter);
		}

		i_self.currentFilter = s_name;
		i_self.isPublic = b_public;
		var s_text = ip2.i18n({
			"da": "Filter - ",
			"en": "Filter - "
		});
		s_text = s_text + s_name;
		i_self.setText(s_text);

		if (b_public) {
			ip2.global.set(s_key + ".filters", JSON.stringify(o_settings), function() {
				i_self.saveRecently(s_key, s_name, b_public);
			});
		}
		else {
			ip2.profile.set(s_key + ".filters", JSON.stringify(o_settings), function() {
				i_self.saveRecently(s_key, s_name, b_public);
			});
		}
	},

	saveRecently: function(s_key, s_name, b_public) {

		var i_self = this;
		var o_settings = ip2.profile.get(s_key + '.filters', {
			filters: [],
			recent: []
		});

		var b_found;
		var n_idx = 0;
		ip2.each(o_settings.recent, function(o_recently, n_index) {
			if (o_recently.name == s_name && o_recently.isPublic == b_public) {
				b_found = true;
				n_idx = n_index;
			}
		});
		if (b_found) {
			var a_recent = o_settings.recent.splice(n_idx, 1);
			o_settings.recent.unshift(a_recent[0]);
		}
		else {
			o_recent = {
				tag: "recent-" + Ext.id(),
				name: s_name,
				isPublic: b_public
			};
			o_settings.recent.unshift(o_recent);
			if (o_settings.recent.length > 5) {
				o_settings.recent.pop();
			}
		}
		ip2.profile.set(s_key + ".filters", JSON.stringify(o_settings), function() {
			i_self.reload();
		});
	},

	reload: function() {
		var i_self = this;
		var i_menu = this;
		i_self.menu.hide();
		i_self.menu.removeAll(true);
		var a_items = i_self.createMenuItems();
		i_self.menu.add(a_items);
	},

	reset: function() {
		var i_self = this;
		i_self.currentFilter = "";
		var s_text = ip2.i18n({
			"da": "Filter",
			"en": "Filter"
		});
		i_self.setText(s_text);
		i_self.reload();
	},

	cleanUp: function() {

		var i_self = this;
		var i_grid = i_self.up("ip2pagingGridOld");

		var a_public = [];
		var a_private = [];
		var s_key = i_grid.s_id;

		var o_settings_public = ip2.global.get(s_key + '.filters', {
			filters: []
		});

		var o_settings_private = ip2.profile.get(s_key + '.filters', {
			filters: [],
			recent: []
		});

		o_settings_public.filters = o_settings_public.filters.filter(function(o_filter) {
			return o_filter != null;
		});

		o_settings_private.recent = o_settings_private.recent.filter(function(o_filter) {
			return o_filter != null;
		});

		ip2.global.set(s_key + ".filters", JSON.stringify(o_settings_public));

		ip2.profile.set(s_key + ".filters", JSON.stringify(o_settings_private));
	}
});
