Ext.define("Mvvm.crud.ux.form.field.ISOTimestampField", {
	extend: "Ext.form.FieldContainer",
	mixins: {
		field: 'Ext.form.field.Field'
	},

	alias: "widget.isotimestampfield",

	dateParseFormat: "Y-m-d-H.i.s.u",
	dateFormat: "Y-m-d-H.i.s.u000",
	format: "d-m-Y",
	value: "",
	datevalue: "",
	timevalue: 0,

	maxValue: 0,
	minValue: 0,
	step: 0,
	asHigh: false,

	decimalPrecision: 0,
	forcePrecision: true,
	decimalSeparator: ":",

	datefield: undefined,
	timefield: undefined,
	microfield: undefined,
	fieldLabel: undefined,

	secondsValue: "00",

	date: true,
	time: true,
	micro: false,
	seconds: false,

	altFormats: "|d-n-Y|d-n-y|j-n-Y|j-n-y|" +
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
	"|Ynd|ynd|Ynj|ynj|",

	layout: "hbox",
	defaults: {
		"margin": "0 5 0 0"
	},
	readOnly: false,

	initComponent: function () {
		var me = this;
		me.callParent();

		me.fieldLabel = me.fieldLabel;
		me.step = me.seconds ? 0.0001 : 0.01,
		me.maxValue = me.seconds ? 23.5959 : 23.59,
		me.minValue = 0.00,
		me.decimalPrecision = me.seconds ? 4 : 2,
		me.datefield = me.createDateField();
		me.timefield = me.createTimeField();
		me.microfield = me.createMicroField();

		if (!me.date) {
			me.datefield.hidden = true;
		}
		if (!me.time) {
			me.timefield.hidden = true;
		}
		if (!me.micro) {
			me.microfield.hidden = true;
		}

		me.datefield.on({
			change: {
				fn: function(item) {
					me.checkChange();
				}
			}
		});

		me.timefield.on({
			change: {
				fn: function(item) {
					me.checkChange();
				}
			}
		});

		me.timefield.on({
			change: {
				fn: function(item) {
					me.checkChange();
				}
			}
		});

		me.add(me.datefield);
		me.add(me.timefield);
		me.add(me.microfield);

		me.initField();
	},

	createDateField: function () {
		var me = this;
		var field = Ext.create("Ext.form.field.Date", {
			format: me.format,
			submitFormat: "Y-m-d",
			altFormats: me.altFormats,
			isFormField: false,
			selectOnFocus: me.selectOnFocus || false,
			emptyText: me.emptyText,
			readOnly: me.readOnly,
			value: me.datevalue != "" ? me.datevalue : ""
		});
		if (me.flex) {
			field.flex = me.flex;
		}
		else {
			field.width = me.readOnly ? 80 : 100;
		}
		return field;
	},

	createTimeField: function () {
		var me = this;
		var field = Ext.create("Ext.form.field.Number", {
			dateField: me.datefield,
			forcePrecision: me.forcePrecision,
			decimalPrecision: me.decimalPrecision,
			decimalSeparator: me.decimalSeparator,
			maxValue: me.maxValue,
			minValue: me.minValue,
			selectOnFocus: me.selectOnFocus || false,
			value: me.timevalue != 0 ? me.timevalue : 0,
			step: me.step,
			fieldStyle: 'text-align: right;',
			isFormField: false,
			readOnly: me.readOnly,
			parseValue: function (value) {
				var me = this;
				if (me.decimalPrecision > 2) {
					value = String(value).replace(/\:/g, ".");
					var lastIndex = String(value).lastIndexOf(".");
					if (lastIndex > 2) {
						var valueBefore = String(value).substring(0, lastIndex);
						value = valueBefore + String(value).substr(lastIndex + 1, 2);
					}
				}
				else {
					value = String(value).replace(/\:/g, ".");
				}
				value = parseFloat(String(value));
				return isNaN(value) ? '' : value;
			},

			setValue: function (value) {
				var me = this;
				if (me.decimalPrecision > 2) {
					value = String(value).replace(/\:/g, ".");
					var lastIndex = String(value).lastIndexOf(".");
					if (lastIndex > 2) {
						var valueBefore = String(value).substring(0, lastIndex);
						value = valueBefore + String(value).substr(lastIndex + 1, 2);
					}
				}
				value = typeof value == 'number' ? value : String(value).replace(this.decimalSeparator, ".").replace(/,/g, "");

				//v = isNaN(v) ? '' : String(v).replace(".", this.decimalSeparator);
				value = parseFloat(value);
				value = isNaN(value) ? '' : me.forcePrecision ? value.toFixed(me.decimalPrecision) : parseFloat(value);

				//this.setRawValue(value);
				return Ext.form.NumberField.superclass.setValue.call(this, parseFloat(value));
			},

			validateValue: function (value) {
				var me = this;
				if (me.decimalPrecision > 2) {
					value = String(value).replace(/\:/g, ".");
					var lastIndex = String(value).lastIndexOf(".");
					if (lastIndex > 2) {
						var valueBefore = String(value).substring(0, lastIndex);
						value = valueBefore + String(value).substr(lastIndex + 1, 2);
					}
				}
				if (value.length < 1) {
					// if it's blank and textfield didn't flag it then it's valid
					return true;
				}
				value = String(value).replace(this.decimalSeparator, ".").replace(/,/g, "");
				if (isNaN(value)) {
					this.markInvalid(this.nanText.replace("{0}", value));
					return false;
				}
				var num = this.parseValue(value);
				if (num < this.minValue) {
					this.markInvalid(this.minText.replace("{0}", this.minValue));
					return false;
				}
				else if (num > this.maxValue) {
					this.markInvalid(this.maxText.replace("{0}", this.maxValue));
					return false;
				}
				else {
					this.clearInvalid();
				}
				return true;
			},

			getSubmitValue: function() {
				var me = this;
				var value = me.getRawValue();
				value = String(value).replace(/\:/g, ".");
				return value;
			},

			//valueToRaw: function (c) {
			//    var b = this,
			//    a = b.decimalSeparator;
			//    c = b.parseValue(c);
			//    c = b.fixPrecision(c);
			//    c = Ext.isNumber(c) ? c : parseFloat(String(c).replace(a, "."));
			//    c = isNaN(c) ? "" : String(c).replace(".", a);
			//    return c
			//}

			valueToRaw: function (value) {
				var me = this;
				var decimalSeparator = me.decimalSeparator;
				value = isNaN(value) || value == null ? 0 : me.forcePrecision ? parseFloat(value.toFixed(me.decimalPrecision)) : parseFloat(value);
				value = Ext.isNumber(value) ? value : parseFloat(String(value).replace(decimalSeparator, '.'));
				if (isNaN(value)) {
					value = '';
				}
				else {
					var hourIndex = String(value).indexOf(".");
					if (hourIndex == -1) {
						if (String(value).length == 3) {
							var preHours = String(value).substr(0, 1);
							var preMins = String(value).substr(1, 2);
							value = preHours + "." + preMins;
							hourIndex = String(value).indexOf(".");
							value = parseFloat(value).toFixed(me.decimalPrecision);
						}
						else if (String(value).length == 4) {
							var preHours = String(value).substr(0, 2);
							var preMins = String(value).substr(2, 2);
							value = preHours + "." + preMins;
							hourIndex = String(value).indexOf(".");
							value = parseFloat(value).toFixed(me.decimalPrecision);
						}

						else if (String(value).length == 5) {
							var preHours = String(value).substr(0, 2);
							var preMins = String(value).substr(2, 2);
							var preSecs = String(value).substr(4, 1);
							value = preHours + "." + preMins + preSecs;
							hourIndex = String(value).indexOf(".");
							value = parseFloat(value).toFixed(me.decimalPrecision);
						}

						else if (String(value).length == 6) {
							var preHours = String(value).substr(0, 2);
							var preMins = String(value).substr(2, 2);
							var preSecs = String(value).substr(4, 2);
							value = preHours + "." + preMins + preSecs;
							hourIndex = String(value).indexOf(".");
							value = parseFloat(value).toFixed(me.decimalPrecision);
						}
					}
					var hours = "";
					var minutes = "";
					var seconds = "";
					if (hourIndex == -1) {
						var hours = value;
					}
					else {
						hours = String(value).substring(0, String(value).indexOf("."));
					}

					var step = me.step;
					var stepSeconds = 0;
					var stepMinues = 0;

					var stepIndex = String(step).indexOf(".") + 1;
					var stepDecimal = String(step).substring(stepIndex, String(step).length);
					if (String(step).length == 5) {
						stepDecimal = parseInt(stepDecimal);
					}

					if (String(stepDecimal).length < 2) {
						stepDecimal += "0";
					}

					if (String(step).length == 6) {
						stepDecimal = parseInt(stepDecimal);
					}

					else if (String(step).length > 6) {
						stepDecimal = parseInt(String(step).substr(stepIndex, 4));
					}
					var stepDecimal = parseInt(stepDecimal);
					if (stepDecimal >= 1000) {
						stepMinues = parseInt(String(stepDecimal).substr(0, 2));
						stepSeconds = parseInt(String(stepDecimal).substr(2, 2));
					}
					else {
						if (stepDecimal > 100) {
							stepMinues = parseInt(String(stepDecimal).substr(0, 1));
							stepSeconds = parseInt(String(stepDecimal).substr(1, 2));
						}
						else {
							if (stepDecimal > 9) {
								stepSeconds = parseInt(String(stepDecimal).substr(0, 2));
							}
							else {
								stepSeconds = parseInt(String(stepDecimal).substr(0, 1));
							}
						}
					}
					if (me.decimalPrecision == 4) {
						var decimalIndex = String(value).indexOf(".") + 1;
						if (decimalIndex == 0) {
							minutes = "";
						}

						else {
							minutes = String(value).substring(decimalIndex, decimalIndex + 2);
							if (String(minutes).length < 2) {
								minutes += "0";
							}
						}

						seconds = String(value).substring((decimalIndex + 2), ((decimalIndex + 2) + 2));

						if (minutes == "") {
							minutes = 0;
						}

						if (seconds == "") {
							seconds = 0;
						}

						var diffMin = minutes;
						var diffSec = seconds;

						if (String(diffSec).length < 2) {
							diffSec += "0";
						}

						if (parseInt(diffSec) > 59) {
							if ((parseInt(diffSec) + parseInt(stepSeconds)) >= 100) {
								var number = (parseInt(diffSec) + parseInt(stepSeconds));
								var diffSeconds = number - 100;
								diffSec = 60 - (parseInt(stepSeconds) - diffSeconds);
							}
							else {
								diffSec = diffSec - 60;
								diffMin = parseInt(minutes);
								diffMin++;
								if (diffMin < 10) {
									diffMin = "0" + diffMin;
								}

								minutes = diffMin;

								if (diffSec < 10) {
									diffSec = "0" + diffSec;
								}
							}
						}
						if (parseInt(minutes) > 59) {
							if (parseInt(minutes) + stepMinues >= 100) {
								var diffMinutes = (parseInt(minutes) + stepMinues) - 100;
								diffMin = 60 - (stepMinues - diffMinutes);
							}
							else {
								diffMin = minutes - 60;
								if (diffMin < 10) {
									diffMin = "0" + diffMin;
								}
								hours++;
							}
						}
						if (String(diffSec).length < 2) {
							diffSec = "0" + diffSec;
						}

						seconds = diffSec;

						if (String(diffMin).length < 2) {
							diffMin = "0" + diffMin;
						}

						minutes = diffMin;
						value = me.parseValue(hours + "." + diffMin + "." + diffSec);
					}
					else {

						var decimalIndex = String(value).indexOf(".") + 1;
						var decimals = String(value).substring(decimalIndex, String(value).length);
						var diff = 0;
						if (decimals.length < 2) {
							if (decimalIndex == 0) {
								decimals = "00";
							}
							else {
								decimals += "0";
							}
						}

						if (parseInt(decimals) > 59) {
							if ((parseInt(decimals) + parseInt(stepDecimal)) >= 100) {
								var number = (parseInt(decimals) + parseInt(stepDecimal));
								var diffNumber = number - 100;
								var diff = 60 - (parseInt(stepDecimal) - diffNumber);
							}
							else {
								var diff = decimals - 60;
								hours++;
								if (diff < 10) {
									diff = "0" + diff;
								}
							}
							value = me.parseValue(hours + "." + diff);
						}
					}
				}
				value = me.forcePrecision ? Ext.isNumber(value) ? value.toFixed(me.decimalPrecision) :
				parseFloat(value).toFixed(me.decimalPrecision) : parseFloat(value);

				if (me.decimalPrecision != 4) {
					if (hours < 10) {
						value = "0" + String(value);
					}
					value = (value).replace(/\./g, decimalSeparator);
				}
				else {
					if (hours < 10) {
						hours = "0" + hours;
					}
					value = String(hours) + "." + String(minutes) + "." + String(seconds);
					value = (value).replace(/\./g, decimalSeparator);
				}
				return String(value);
			}
		});
		if (me.flex) {
			field.flex = me.flex;
		}
		else {
			field.width = me.readOnly ? me.seconds ? 70 : 50 : me.seconds ? 90 : 70;
		}
		return field;
	},

	createMicroField: function () {
		var me = this;
		var field = Ext.create("Ext.form.field.Text", {
			readOnly: true,
			width: 50,
			isFormField: false
		});

		return field;
	},

	getValue: function () {
		var me = this;
		if (!me.datefield.value) {
			me.setValue(me.value);
		}
		var dateValue = me.datefield.getSubmitValue();
		var timeValue = me.timefield.getSubmitValue();
		var microValue = me.microfield.getValue();
		var i_microLength = microValue.length;
		if (i_microLength < 6) {
			while (i_microLength < 6) {
				microValue = microValue + "0";
				i_microLength++;
			}
		}
		if (!me.time) {
			if (me.asHigh) {
				timeValue = "23.59";
			}
		}
		if (!me.seconds) {
			if (me.asHigh) {
				me.secondsValue = "59";
			}
			timeValue = timeValue + "." + me.secondsValue;
		}
		if (me.asHigh) {
			microValue = "999999";
		}

		var value = dateValue + "-" + timeValue + "." + microValue;
		return value;
	},

	getDateField: function() {
		var i_self = this;
		return i_self.datefield;
	},

	getTimeField: function() {
		var i_self = this;
		return i_self.timefield;
	},

	setValue: function (value) {
		var me = this;
		var date = undefined;

		if (value instanceof Date) {
			date = value;
		}
		else {
			if (value) {
				if (Ext.isArray(value)) {
					value = value[0];
				}
				var a_split = value.split("-");
				if (a_split[1].length == 2) {
					date = Ext.Date.parse(value, me.dateParseFormat);
				}
				else {
					// WHEN THE MONTH HAS A NO LEADING ZERO
					date = Ext.Date.parse(value, "Y-n-d-H.i.s.u");
				}
			}
			else {
				var v = "0001-01-01-00.00.00.000000";
				date = Ext.Date.parse(v, me.dateParseFormat);
			}
		}
		var time = undefined;
		var micro = 0;

		var h = date.getHours();
		var m = date.getMinutes() < 10 ? "0" + date.getMinutes() : date.getMinutes();
		var s = date.getSeconds() < 10 ? "0" + date.getSeconds() : date.getSeconds();
		var mi = undefined;
		if (value instanceof Date) {
			mi = date.getMilliseconds() < 10 ? "0" + date.getMilliseconds() : date.getMilliseconds();
		}
		else {
			if (value) {
				var index = value.lastIndexOf(".");
				mi = value.substr(index + 1);
			}
			else {
				mi = "0000";
			}

			//mi = parseFloat(mi);
		}
		if (me.seconds) {
			time = parseFloat(h + "." + m + "" + s);
		}
		else {
			time = parseFloat(h + "." + m);
			me.secondsValue = s;
		}

		me.datefield.setValue(date);
		me.timefield.setValue(time);
		me.microfield.setValue(mi);
		me.value = me.getValue();
		var b_reset = false;

		if (me.datefield.originalValue == undefined) {
			me.datefield.originalValue = me.datefield.getValue();
			b_reset = true;
		}

		if (me.timefield.originalValue == undefined || me.timefield.originalValue == 0) {
			me.timefield.originalValue = me.timefield.getValue();
			b_reset = true;
		}
		if (me.microfield.originalValue == undefined || me.microfield.originalValue == "") {
			me.microfield.originalValue = me.microfield.getValue();
			b_reset = true;
		}

		if (b_reset) {
			me.resetOriginalValue();
		}
	},

	isDirty: function () {
		var me = this;
		return me.value != me.getValue();
	}

});
