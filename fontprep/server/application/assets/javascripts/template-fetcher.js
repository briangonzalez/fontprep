
FP.TemplateFetcher = function TemplateFetcher(){

  this.templatePath         = "/templates/";
  this.templates            = {};

  // Alter underscore template delimiter;
  _.templateSettings.interpolate  = /\{\{(.+?)\}\}/g ;
  _.templateSettings.escape       = /\{\{\{([\s\S]+?)\}\}\}/g,
  _.templateSettings.evaluate     = /\{\%([\s\S]+?)\%\}/g,

  this.ajaxTemplate = function(name) {
    var raw = '';
    $.ajax({  
      url: this.templatePath + name + '.jst?' + new Date().getTime(), 
      async: false, 
      success:function(data){ raw = data; }, 
      error:function(data){ console.log('Error loading template: '+ name ); }
    });
    return raw;
  };

  this.getTemplate = function(name, opts) {
    opts = opts || {}
    if ( this.templates.hasOwnProperty(name) ) {
      return this.templates[name](opts); 
    }

    var t  = this.ajaxTemplate(name);
    this.templates[name] = _.template(t);
    return this.templates[name](opts);
  };

}