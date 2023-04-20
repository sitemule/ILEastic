Ext.application({
	name: 'Mvvm',
	autoCreateViewport: false,
	views: [
		'Mvvm.crud.view.Detail',
		"Mvvm.crud.view.Grid"
	],
	requires: [
		"Mvvm.crud.view.Grid"
	],
	cfg: {
		title: "Microservice Demo",
		router: "/router/product",
		routes: {
			meta     : "meta",
 			getRows  : "find",
			delete   : "delete",
			update   : "update"
		}
	},
	viewport: null,

	launch: function () {

		var s_lang = "";
		if (navigator.appName == "Microsoft Internet Explorer") {
			s_lang = navigator.browserLanguage.split("-").shift();
		}
		else {
			s_lang = navigator.language.split("-").shift();
		}

		var head = document.getElementsByTagName('head')[0];
		var script = document.createElement('script');
		script.type = 'text/javascript';
		script.src = "http://cdn.sencha.com/ext/gpl/5.1.0/packages/ext-locale/build/ext-locale-" + s_lang + ".js";
		head.appendChild(script);

		var i_self = this;
		var i_viewport = Ext.create('Ext.container.Viewport', {
			layout: 'fit'
		});
		i_self.viewport = i_viewport;

		var o_params = i_self.cfg;

		var s_url = o_params.router;
		var s_title = o_params.title;

		delete o_params.title;
		delete o_params.url;

		i_self.getMetaData(s_url, o_params, function(o_metaData) {

			var i_grid = Ext.widget("crud.gridpanel",{
				title: s_title,
				fields: o_metaData.fields || [{name: "id", header: "ID",},{name: "name", header: "Name"}],
				idProperty: o_metaData.idProperty || "id",
				url: s_url ,
				params: o_params,
				viewConfig: {
					trackOver: true,
					loadMask: true,
					variableRowHeight: true
				},
				numFromEdge: 4
			});
			i_viewport.add(i_grid);
		})
	},

	getMetaData: function(s_url, o_params, f_callback) {

		var i_self = this;
		Ext.Ajax.request({
			url: s_url + '/' + o_params.routes.meta,
			// jsonData: o_params.routes.meta ,
			success: function (response, request) {
				var o_result = {};
				eval('o_result =' + response.responseText);
				var o_fields = {
					fields: o_result,
					idProperty: ""
				};
				if (o_fields.fields) {
					Ext.Array.each(o_fields.fields, function(o_field) {
						if (o_field.type) {
							o_field.datatype = o_field.type;
						}
						if (o_field.isIdColumn) {
							o_fields.idProperty = o_field.name;
						}
					});
					f_callback(o_fields);
				}
			}
		});
	}
});
