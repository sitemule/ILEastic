Ext.define('Mvvm.crud.ux.form.field.Search', {
	extend: 'Ext.form.field.Text',
	alias: 'widget.searchfield',

	triggers: {
		clear: {
			weight: 0,
			cls: Ext.baseCSSPrefix + 'form-clear-trigger',
			hidden: true,
			handler: 'onClearClick',
			scope: 'this'
		},
		search: {
			weight: 1,
			cls: Ext.baseCSSPrefix + 'form-search-trigger',
			handler: 'onSearchClick',
			scope: 'this'
		}
	},
	hasSearch: false,
	paramName: 'search',

	initComponent: function() {

		var i_self = this;
		var i_store = i_self.store;

		i_self.callParent(arguments);
		i_self.on('specialkey', function(f, e) {
			if (e.getKey() == e.ENTER) {
				i_self.onSearchClick();
			}
		});

		i_self.on({
			change: {
				fn: function(i_field, value) {
					if (value) {
						i_self.getTrigger("clear").show();
					}
					else {
						i_self.getTrigger("clear").hide();
					}
				}
			}
		});

		if (!i_store || !i_store.isStore) {
			i_store = i_self.store = Ext.data.StoreManager.lookup(i_store);
		}

		// We're going to use filtering
		i_store.setRemoteFilter(true);
	},

	onClearClick: function() {
		var i_self = this;
		var i_store = i_self.store;
		var i_proxy = i_store.getProxy();
		var o_extraParams = i_proxy.getExtraParams();
		var o_sorters = i_store.getSorters();

		i_self.setValue('');
		i_self.getTrigger('clear').hide();

		delete o_extraParams.search;

		i_store.clearAndLoad({
			callback: function() {
				i_store.fireEvent('sort', i_store, o_sorters.getRange());
			}
		});
	},

	onSearchClick: function() {
		var i_self = this;
		var i_store = i_self.store;
		var i_proxy = i_store.getProxy();
		var o_extraParams = i_proxy.getExtraParams();
		var value = i_self.getValue();

		if (value.length > 0) {
			o_extraParams.search = value;
			i_self.getTrigger('clear').show();
		}
		else {
			delete o_extraParams.search;
			i_self.getTrigger('clear').hide();
		}
		i_store.loadPage(1);
	}
});
