Ext.override(Ext.form.field.Number, {

	forcePrecision: false,
	setValue: function(value) {
		var i_self = this;
		if (value != null && value != undefined) {
			if (Ext.isString(value)) {
				var n_value = Number(value);
				if (!isNaN(n_value)) {
					value = n_value;
					i_self.callOverridden([value]);
					if (i_self.originalValue == "") {
						i_self.originalValue = n_value;
					}
				}
			}
			else {
				i_self.callOverridden(arguments);
			}
		}
	}
});

Ext.override(Ext.form.field.Base, {
	iconCls: '',

	onRender: function() {
		var i_self = this;
		var a_excludedTypes = ["checkbox", "radio", "slider"];
		i_self.callParent(arguments);
		if (i_self.inputEl && a_excludedTypes.indexOf(i_self.inputType) == -1 && i_self.iconCls) {
			i_self.inputEl.addCls(i_self.iconCls + " x-ux-icon-bg");
		}
	},
	setIconCls: function(cls) {
		var a_excludedTypes = ["checkbox", "radio", "slider"];
		var i_self = this;
		if (i_self.inputEl && a_excludedTypes.indexOf(i_self.inputType) == -1) {
			var oldCls = i_self.iconCls || '';
			if (oldCls != cls) {
				if (cls == "") {
					i_self.inputEl.removeCls("x-ux-icon-bg " + oldCls);
					i_self.iconCls = cls;
				}
				else {
					i_self.iconCls = cls;
					i_self.inputEl.removeCls("x-ux-icon-bg " + oldCls);
					i_self.inputEl.addCls("x-ux-icon-bg " + cls);
				}
				i_self.fireEvent("iconchange", i_self, oldCls, cls);
			}
		}
	},
	getIconCls: function() {
		var i_self = this;
		return i_self.iconCls || '';
	},
	setValue: function(value) {
		var i_self = this;
		i_self.callOverridden(arguments);
		if (i_self.originalValue == undefined || i_self.originalValue == null) {
			i_self.resetOriginalValue();
		}
	}
});

Ext.override(Ext.form.field.Text, {

	invokeTriggers: function(s_methode, args) {

		var i_self = this;
		i_self.callOverridden(arguments);
		var a_triggers = Ext.Object.getKeys(i_self.getTriggers());
		Ext.Array.each(a_triggers, function(s_trigger) {
			var i_trigger = i_self.getTrigger(s_trigger);
			if (i_trigger && i_trigger.tooltip) {
				var i_el = i_trigger.getEl();
				if (i_el) {
					i_el.dom.setAttribute('data-qtip', i_trigger.tooltip);
				}
			}
		});
	}
});

Ext.override(Ext.form.field.ComboBox, {

	collapseIf: function(e) {
		var i_self = this;
		var i_picker = i_self.picker;
		if (!i_self.isDestroyed && !e.within(i_picker.el, false, true)) {
			i_self.collapse();
		}
	},

	onFocusLeave: Ext.emptyFn,

	setValue: function(value) {
		var i_self = this;
		i_self.callOverridden(arguments);
		if (i_self.originalValue == undefined) {
			i_self.resetOriginalValue();
		}
		if (i_self.originalValue == undefined && value) {
			i_self.resetOriginalValue();
		}
	},

	getValue: function() {
		var i_self = this;
		var picker = i_self.picker;
		var rawValue = i_self.getRawValue();
		var value = i_self.value;
		if (Ext.isArray(value) && value.length == 0) {
			value = null;
		}
		if (value == null) {
			value = rawValue;
			i_self.value = value;
		}
		if (!value) {
			if (i_self.getDisplayValue() !== rawValue) {
				value = rawValue;
				i_self.value = i_self.displayTplData = i_self.valueModels = null;
				if (picker) {
					i_self.ignoreSelection++;
					picker.getSelectionModel().deselectAll();
					i_self.ignoreSelection--;
				}
			}
		}
		return value;
	},

	onValueCollectionEndUpdate: function() {
		var me = this;
		var store = me.store;
		var selectedRecords = me.valueCollection.getRange();
		var selectedRecord = selectedRecords[0];
		var selectionCount = selectedRecords.length;
		me.updateBindSelection(me.pickerSelectionModel, selectedRecords);
		if (me.isSelectionUpdating()) {
			return;
		}
		Ext.suspendLayouts();
		me.updateValue();
		Ext.resumeLayouts(true);
		if (selectionCount && !me.suspendCheckChange) {
			if (!me.multiSelect) {
				selectedRecords = selectedRecord;
			}
			me.fireEvent('select', me, selectedRecords);
		}
	},

	onItemClick: function(i_picker, i_record) {
		var i_self = this;
		if (!i_self.multiSelect) {
			i_self.setValue(i_record);
			i_self.collapse();
		}
		var a_records = i_self.valueCollection.getRange();
		i_self.fireEvent("select", i_self, a_records);
	},

	doSetValue: function(value, add) {
		var me = this;
		var store = me.getStore();
		var Model = store.getModel();
		var matchedRecords = [];
		var valueArray = [];
		var key;
		var autoLoadOnValue = me.autoLoadOnValue;
		var isLoaded = store.getCount() > 0 || store.isLoaded();
		var pendingLoad = store.hasPendingLoad();
		var unloaded = autoLoadOnValue && !isLoaded && !pendingLoad;
		var forceSelection = me.forceSelection;
		var selModel = me.pickerSelectionModel;
		var displayTplData = me.displayTplData || (me.displayTplData = []);
		var displayIsValue = me.displayField === me.valueField;
		var i;
		var len;
		var record;
		var dataObj;
		var raw;

		if (add && !me.multiSelect) {
			Ext.Error.raise('Cannot add values to non muiltiSelect ComboBox');
		}

		if (value != null && !displayIsValue && (pendingLoad || unloaded || !isLoaded || store.isEmptyStore)) {
			if (value.isModel) {
				displayTplData.length = 0;
				displayTplData.push(value.data);
				raw = me.getDisplayValue();
			}
			if (add) {
				me.value = Ext.Array.from(me.value).concat(value);
			}
			else {
				if (value.isModel) {
					value = value.get(me.valueField);
				}
				me.value = value;
			}
			me.setHiddenValue(me.value);

			me.setRawValue(raw || '');
			if (unloaded && store.getProxy().isRemote) {
				store.load();
			}
			return me;
		}

		value = add ? Ext.Array.from(me.value).concat(value) : Ext.Array.from(value);

		for (i = 0, len = value.length; i < len; i++) {
			record = value[i];

			if (!record || !record.isModel) {
				record = me.findRecordByValue(key = record);

				if (!record) {
					record = me.valueCollection.find(me.valueField, key);
				}
			}

			if (!record) {

				if (!forceSelection) {
					if (!record) {
						dataObj = {};
						dataObj[me.displayField] = value[i];
						record = new Model(dataObj);
					}
				}

				else if (me.valueNotFoundRecord) {
					record = me.valueNotFoundRecord;
				}
			}

			if (record) {
				matchedRecords.push(record);
				valueArray.push(record.get(me.valueField));
			}
		}
		me.lastSelection = matchedRecords;

		me.suspendEvent('select');
		me.valueCollection.beginUpdate();
		if (matchedRecords.length) {
			selModel.select(matchedRecords, false);
		}
		else {
			selModel.deselectAll();
		}
		me.valueCollection.endUpdate();
		me.resumeEvent('select');
		return me;
	}
});

/* BoundListView */

Ext.override(Ext.view.BoundList, {

	onItemClick: function(record) {
		var i_self = this;
		var pickerField = i_self.pickerField;
		var valueField = pickerField.valueField;
		var selected = i_self.getSelectionModel().getSelection();
		if (!pickerField.multiSelect) {
			selected = selected[0];

			if (selected && pickerField.collapse) {
				pickerField.collapse();
			}
		}
	}
});

Ext.override(Ext.data.Model, {

	constructor: function(data, session) {
		var me = this;
		var cls = me.self;
		var identifier = cls.identifier;
		var Model = Ext.data.Model;
		var modelIdentifier = Model.identifier;
		var idProperty = me.idField.name;
		var array;
		var id;
		var initializeFn;
		var internalId;
		var len;
		var i;
		var fields;
		me.data = data || (data = {});
		me.session = session || null;
		me.internalId = internalId = modelIdentifier.generate();
		var dataId = data[idProperty];
		if (session && !session.isSession) {
			Ext.Error.raise('Bad Model constructor argument 2 - "session" is not a Session');
		}
		if ((array = data) instanceof Array) {
			me.data = data = {};
			fields = me.getFields();
			len = Math.min(fields.length, array.length);
			for (i = 0; i < len; ++i) {
				data[fields[i].name] = array[i];
			}
		}
		if (!(initializeFn = cls.initializeFn)) {
			cls.initializeFn = initializeFn = Model.makeInitializeFn(cls);
		}
		if (!initializeFn.$nullFn) {
			cls.initializeFn(me);
		}
		if (!(me.id = id = data[idProperty]) && id !== 0) {
			if (dataId) {
				Ext.Error.raise('The model ID configured in data ("' + dataId + '") has been rejected by the ' + me.fieldsMap[idProperty].type + ' field converter for the ' + idProperty + ' field');
			}
			if (session) {
				identifier = session.getIdentifier(cls);
				id = identifier.generate();
			}
			else if (modelIdentifier === identifier) {
				id = internalId;
			}
			else {
				id = identifier.generate();
			}
			me.id = id;
			me.phantom = true;
		}
		if (session) {
			session.add(me);
		}
		if (me.init && Ext.isFunction(me.init)) {
			me.init();
		}
	}
});

Ext.override(Ext.data.BufferedStore, {

	onSorterEndUpdate: function() {
		var i_self = this;
		var i_sorter = i_self.getSorters();
		var sorters = i_self.getSorters().getRange();

		if (sorters.length && !i_sorter.loading) {
			i_self.clearAndLoad({
				callback: function() {
					i_self.fireEvent('sort', i_self, sorters);
				}
			});
		}
		else {
			i_self.fireEvent('sort', i_self, sorters);
		}
	},

	reload: function(options) {
		var me = this;
		var startIdx;
		var endIdx;
		var startPage;
		var endPage;
		var i;
		var waitForReload;
		var bufferZone;
		var records;
		var data = me.getData();

		if (me.loading) {
			return;
		}
		if (!options) {
			options = {};
		}

		delete me.totalCount;

		data.clear(true);
		waitForReload = function() {
			if (me.rangeCached(startIdx, Math.min(endIdx, me.getTotalCount()))) {
				me.loading = false;
				data.un('pageadd', waitForReload);
				records = data.getRange(startIdx, startIdx + 1);
				me.fireEvent('load', me, records, true);
				me.fireEvent('refresh', me);
			}
		};
		bufferZone = Math.ceil((me.getLeadingBufferZone() + me.getTrailingBufferZone()) / 2);

		if (!me.lastRequestStart) {
			startIdx = options.start || 0;
			endIdx = startIdx + (options.count || me.getPageSize()) - 1;
		}
		else {
			startIdx = me.lastRequestStart;
			endIdx = me.lastRequestEnd;
		}

		startIdx = Math.max(startIdx - bufferZone, 0);
		endIdx += bufferZone;
		startPage = me.getPageFromRecordIndex(startIdx);
		endPage = me.getPageFromRecordIndex(endIdx);
		if (me.fireEvent('beforeload', me, options) !== false) {
			me.loading = true;

			data.on('pageadd', waitForReload);

			for (i = startPage; i <= endPage; i++) {
				me.prefetchPage(i, options);
			}
		}
	},

	onRangeAvailable: function(options) {
		var me = this;
		var totalCount = me.getTotalCount();
		var start = options.prefetchStart;
		var end = (options.prefetchEnd > totalCount - 1) ? totalCount - 1 : options.prefetchEnd;
		var range;
		end = Math.max(-1, end);
		if (start > end && end > 0) {
			Ext.log({
				level: 'warn',
				msg: 'Start (' + start + ') was greater than end (' + end + ') for the range of records requested (' + start + '-' + options.prefetchEnd + ')' + (this.storeId ? ' from store "' + this.storeId + '"' : '')
			});
		}
		range = me.getData().getRange(start, end + 1);
		if (options.fireEvent !== false) {
			me.fireEvent('guaranteedrange', range, start, end, options);
		}
		if (options.callback) {
			options.callback.call(options.scope || me, range, start, end, options);
		}
	},
	loadToPrefetch: function(options) {

		var me = this;
		var prefetchOptions = options;
		var purgePageCount = me.getPurgePageCount();
		var i;
		var records;
		var dataSetSize;
		var startIdx = options.start;
		var endIdx = options.start + options.limit - 1;
		var loadEndIdx = Math.min(endIdx, options.start + (me.getViewSize() || options.limit) - 1);
		var startPage = me.getPageFromRecordIndex(Math.max(startIdx - me.getTrailingBufferZone(), 0));
		var endPage = me.getPageFromRecordIndex(endIdx + me.getLeadingBufferZone());
		var data = me.getData();

		var waitForRequestedRange = function() {
			if (me.rangeCached(startIdx, loadEndIdx)) {
				me.loading = false;
				records = data.getRange(startIdx, loadEndIdx + 1);
				data.un('pageadd', waitForRequestedRange);

				if (me.hasListeners.guaranteedrange) {
					me.guaranteeRange(startIdx, loadEndIdx, options.callback, options.scope);
				}

				if (options.loadCallback) {
					options.loadCallback.call(options.scope || me, records, operation, true);
				}
				if (options.callback) {
					options.callback.call(options.scope || me, records, startIdx, endIdx, options);
				}
				me.fireEvent('datachanged', me);
				me.fireEvent('refresh', me);
				me.fireEvent('load', me, records, true);
			}
		};

		var operation;

		if (isNaN(me.pageSize) || !me.pageSize) {
			Ext.Error.raise('Buffered store configured without a pageSize', me);
		}

		if (purgePageCount) {
			data.setMaxSize(purgePageCount ? (endPage - startPage + 1) + purgePageCount : 0);
		}
		if (me.fireEvent('beforeload', me, options) !== false) {

			delete me.totalCount;
			me.loading = true;

			if (options.callback) {
				prefetchOptions = Ext.apply({}, options);
				delete prefetchOptions.callback;
			}

			me.on('prefetch', function(store, records, successful, op) {
				if (successful) {

					operation = op;

					if ((dataSetSize = me.getTotalCount())) {

						data.on('pageadd', waitForRequestedRange);

						loadEndIdx = Math.min(loadEndIdx, dataSetSize - 1);

						endPage = me.getPageFromRecordIndex(Math.min(loadEndIdx + me.getLeadingBufferZone(), dataSetSize - 1));
						if (startPage + 1 <= endPage) {
							for (i = startPage + 1; i <= endPage; ++i) {
								me.prefetchPage(i, prefetchOptions);
							}
						}
						else {
							me.fireEvent('load', me, records, false);
						}
					}
					else {
						me.fireEvent('datachanged', me);
						me.fireEvent('refresh', me);
						me.fireEvent('load', me, records, true);
					}
				}
				else {
					me.fireEvent('load', me, records, false);
				}
			}, null, {
				single: true
			});
			me.prefetchPage(startPage, prefetchOptions);
		}
	}
});

Ext.override(Ext.data.PageMap, {

	getRange: function(start, end) {

		end--;

		var me = this;
		var pageSize = me.getPageSize();
		var startPageNumber = me.getPageFromRecordIndex(start);
		var endPageNumber = me.getPageFromRecordIndex(end);
		var dataStart = (startPageNumber - 1) * pageSize;
		var dataEnd = (endPageNumber * pageSize) - 1;
		var pageNumber = startPageNumber;
		var result = [];
		var sliceBegin;
		var sliceEnd;
		var doSlice;

		for (; pageNumber <= endPageNumber; pageNumber++) {

			if (pageNumber === startPageNumber) {
				sliceBegin = start - dataStart;
				doSlice = true;
			}
			else {
				sliceBegin = 0;
				doSlice = false;
			}
			if (pageNumber === endPageNumber) {
				sliceEnd = pageSize - (dataEnd - end);
				doSlice = true;
			}

			if (doSlice) {
				var a_values = me.getPage(pageNumber) || [];
				if (a_values.length > 0) {
					var a_sliced = me.getPage(pageNumber).slice(sliceBegin, sliceEnd);
					result = result.concat(a_sliced);
				}
				else {
					result = a_values;
				}
			}
			else {
				var a_values = me.getPage(pageNumber) || [];
				result = a_values;
			}
		}
		return result;
	}
});

Ext.override(Ext.grid.plugin.BufferedRenderer, {

	refreshSize: function() {
		var me = this;
		var view = me.view;
		var oldScrollHeight = me.scrollHeight;
		var scrollHeight;

		scrollHeight = me.getScrollHeight();

		if (view.all.endIndex === (me.store.getCount()) - 1) {
			me.scrollHeight = 0;
			if (view.body.dom) {
				me.stretchView(view, me.scrollHeight + view.body.dom.offsetHeight);
			}
		}
		else {
			if (scrollHeight !== oldScrollHeight) {
				me.stretchView(view, scrollHeight);
			}
		}
	},

	renderRange: function(start, end, forceSynchronous, fromLockingPartner) {
		var me = this;
		var rows = me.view.all;
		var store = me.store;

		if (!(start === rows.startIndex && end === rows.endIndex)) {

			if (store.rangeCached(start, end)) {
				me.cancelLoad();
				if (me.synchronousRender || forceSynchronous) {
					var a_range = store.getRange(start, end);
					me.onRangeFetched(a_range, start, end, null, fromLockingPartner);
				}
				else {
					if (!me.renderTask) {
						me.renderTask = new Ext.util.DelayedTask(me.onRangeFetched,me,null,false);
					}

					me.renderTask.delay(1, null, null, [
						null,
						start,
						end,
						null,
						fromLockingPartner
					]);
				}
			}
			else {
				me.attemptLoad(start, end);
			}
		}
	}
});

Ext.override(Ext.grid.column.Column, {
	toggleSortState: function() {
		if (this.isSortable()) {
			var s_direction = this.sortState;
			if (s_direction) {
				s_direction = s_direction == "ASC" ? "DESC" : "ASC";
			}
			else {
				s_direction = "ASC";
			}
			this.sort(s_direction);
		}
	}
});

Ext.override(Ext.dd.StatusProxy, {
	reset: function(clearGhost) {
		var i_self = this;

		var clsPrefix = Ext.baseCSSPrefix + 'dd-drag-proxy ';

		var clsTreeAppend = Ext.baseCSSPrefix + 'tree-drop-ok-append';
		var clsTreeBetween = Ext.baseCSSPrefix + 'tree-drop-ok-between';
		var clsTreeAbove = Ext.baseCSSPrefix + 'tree-drop-ok-above';
		var clsTreeBelow = Ext.baseCSSPrefix + 'tree-drop-ok-below';

		i_self.el.replaceCls(clsPrefix + i_self.dropAllowed, clsPrefix + i_self.dropNotAllowed);
		i_self.el.removeCls(clsTreeAppend);
		i_self.el.removeCls(clsTreeBetween);
		i_self.el.removeCls(clsTreeAbove);
		i_self.el.removeCls(clsTreeBelow);
		i_self.dropStatus = i_self.dropNotAllowed;
		if (clearGhost) {
			i_self.ghost.setHtml('');
		}
	}
});

Ext.override(Ext.view.DragZone, {
	containerScroll: false,

	constructor: function(config) {
		var me = this;
		var view;
		var ownerCt;
		var el;

		Ext.apply(me, config);

		if (!me.ddGroup) {
			me.ddGroup = 'view-dd-zone-' + me.view.id;
		}

		view = me.view;
		ownerCt = view.ownerCt;

		if (ownerCt) {
			el = ownerCt.getTargetEl().dom;
		}
		else {
			el = view.el.dom.parentNode;
		}
		me.callParent([el]);

		me.ddel = document.createElement('div');
		me.ddel.className = Ext.baseCSSPrefix + 'grid-dd-wrap';
	},

	init: function(id, sGroup, config) {
		var me = this;
		var eventSpec = {
			itemmousedown: me.onItemMouseDown,
			scope: me
		};

		// If there may be ambiguity with touch/swipe to scroll and a drag gesture
		// *also* trigger drag start on longpress
		if (Ext.supports.touchScroll) {
			eventSpec.itemlongpress = me.onItemMouseDown;

			// Longpress fires contextmenu in some touch platforms, so if we are using longpress
			// inhibit the contextmenu on this element
			eventSpec.contextmenu = {
				element: 'el',
				fn: function(e) {
					e.preventDefault();
				}
			};
		}
		me.initTarget(id, sGroup, config);
		me.view.mon(me.view, eventSpec);
	},

	onItemMouseDown: function(view, record, item, index, e) {
		var navModel;

		if ((e.pointerType === 'touch' && e.type !== 'longpress') || (e.position && e.position.isEqual(e.view.actionPosition))) {
			return;
		}

		if (!this.isPreventDrag(e, record, item, index)) {
			navModel = view.getNavigationModel();

			if (e.position) {
				navModel.setPosition(e.position);
			}
			// Otherwise, just use the item index
			else {
				navModel.setPosition(index);
			}
			this.handleMouseDown(e);
		}
	},

	isPreventDrag: function(e, record, item, index) {
		return false;
	},

	getDragData: function(e) {
		var view = this.view;
		var item = e.getTarget(view.getItemSelector());

		if (item) {
			return {
				copy: view.copy || (view.allowCopy && e.ctrlKey),
				event: e,
				view: view,
				ddel: this.ddel,
				item: item,
				records: view.getSelectionModel().getSelection(),
				fromPosition: Ext.fly(item).getXY()
			};
		}
	},

	onInitDrag: function(x, y) {
		var me = this;
		var data = me.dragData;
		var view = data.view;
		var selectionModel = view.getSelectionModel();
		var record = view.getRecord(data.item);

		// Update the selection to match what would have been selected if the user had
		// done a full click on the target node rather than starting a drag from it
		if (!selectionModel.isSelected(record)) {
			selectionModel.selectWithEvent(record, me.DDMInstance.mousedownEvent);
		}
		data.records = selectionModel.getSelection();

		Ext.fly(me.ddel).setHtml(me.getDragText());
		me.proxy.update(me.ddel);
		me.onStartDrag(x, y);
		return true;
	},

	getDragText: function() {
		var count = this.dragData.records.length;
		return Ext.String.format(this.dragText, count, count === 1 ? '' : 's');
	},

	getRepairXY: function(e, data) {
		return data ? data.fromPosition : false;
	}
});

Ext.override(Ext.form.field.Date, {

	constructor: function() {
		var i_self = this;
		i_self.altFormats =  "|d-n-Y|d-n-y|j-n-Y|j-n-y|" +
		"|d/n/Y|d/n/y|j/n/Y|j/n/y|" +
		"|d-m-Y|d-m-y|j-m-Y|j-m-y|" +
		"|d/m/Y|d/m/y|j/m/Y|j/m/y|" +
		"|m/d/Y|m/d/y|m/j/Y|m/j/y|" +
		"|m-d-Y|m-d-y|m/j/Y|m/j/y|" +
		"|n/d/Y|n/d/y|n/j/Y|n/j/y|" +
		"|n-d-Y|n-d-y|n-j-Y|n-j-y|" +
		"|Y-m-d|y-m-d|Y-n-d|y-n-d|" +
		"|Y-m-j|y-m-j|Y-n-j|y-n-j|" +
		"|Y/m/d|y/m/d|Y/n/d|y/n/d|" +
		"|Y/m/j|y/m/j|Y/n/j|y/n/j|" +
		"|d.m.Y|d.m.y|j.m.Y|j.m.y|" +
		"|d.n.Y|d.n.y|j.n.Y|j.n.y|" +
		"|m.d.Y|m.d.Y|m.j.Y|m.j.y|" +
		"|n.d.Y|n.d.y|n.j.Y|n.j.y|" +
		"|Y.m.d|y.m.d|Y.m.j|y.m.j|" +
		"|Y.n.d|y.n.d|Y.n.j|y.n.j|" +
		"|dmY|dmy|jmY|jmy|" +
		"|dnY|dny|jnY|jny|" +
		"|mdY|mdy|mjY|mjy|" +
		"|ndY|ndy|njY|njy|" +
		"|Ymd|ymd|Ymj|ymj|" +
		"|Ynd|ynd|Ynj|ynj|";
		i_self.callOverridden(arguments);
	}
})
