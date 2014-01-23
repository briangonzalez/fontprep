FP.Views.App.SettingsDrawer = Backbone.View.extend({

  el: '.settings.drawer',
    
  events: {
    'click input[type=checkbox]'  : 'set',
    'click .export-path'          : 'setPath',
    'change select#theme'         : 'setTheme',
    'click .button.delete'        : 'deleteLibrary'
  },

  initialize: function(){
    this.$exportPath = this.$el.find('.export-path')
  },

  set: function(ev){
    var $el = $(ev.target);

    var name    = $el.attr('name');
    var checked = $el.is(':checked') ? 1 : 0;

    $.post( FP.Routes.settingsSet, { key: name, value: checked }, function(data){
      // Success.
    })
  },

  setPath: function(ev){
    ev.preventDefault();
    var self = this;
    
    $.post( FP.Routes.settingsSetPath, function(data){  
      Tipped.hideAll();
      self.$exportPath.text(data.path)
    });
  },

  setTheme: function(ev){
    var $el     = $(ev.target)
    var theme   = $el.val();

    $.post( FP.Routes.settingsTheme, {theme: theme}, function(data){  
      // Success
    })
  },

  deleteLibrary: function(ev){


    FP.Instances.Modal.confirm(
      'Delete Entire Library?', 
      'Are you sure you want to send your entire font library to the system trash? This is potentially irreversible.', 
      function(){
        $("[data-id]").remove();
        $('.settings-toggle').click();

        $.post( FP.Routes.removeAll, function(data){  
          // stuff deleted
        });

        setTimeout(function(){
           FP.Instances.Modal.confirm('Library deleted', "Your font library has been deleted.", function(){
            FP.Instances.Main.handleZeroCase();
           }, true)
        }, 1000)

     })

  }

});