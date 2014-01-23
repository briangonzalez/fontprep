FP.Views.App.FontActions = Backbone.View.extend({

  el: 'body.app',
    
  events: {
    'click [data-action-edit=delete]':        'destroy',
    'click [data-action-install]':            'installFont',
    'click [data-action-copy]':               'copyCharacter',
    'click [data-action-view]':               'viewInBrowser',
    'click [data-action-subset]':             'showSubsetter',
    'click [data-action-export]':             'exportFont',
    'click [data-action-export-group]':       'addToExportGroup',
    'click [data-action-export-group-go]':    'exportGroup',
    'click [data-action-export-group-clear]': 'clearExportGroup'
  },

  initialize: function(){
    FP.ExportGroup = {};
    this.$groupExport = this.$el.find('.group-export');
  },

  destroy: function(ev){
    ev.preventDefault();
    ev.stopPropagation();

    FP.Instances.Modal.confirm(
      'Delete Font', 
      'Are you sure you want to send this font to the system trash?', 
      function(){

        var $el = $(ev.target);
        var id  = $el.attr('data-id');

        $.post( FP.Routes.remove, {id: id }, function(data){

          $("[data-id="+ id +"]").remove();
          FP.Instances.Main.message("Deleted " + data.name);

          // If we've deleted our last font, show the overlay.
          FP.Instances.Main.handleZeroCase();

          Tipped.hideAll();

        });

     }
    )
  },

  viewInBrowser: function(ev){
    var $el = $(ev.target)
    var id  = $el.attr('data-id') 
    $.post( FP.Routes.openURL, {url: FP.Routes.viewer + "/" + id } )
  },

  showSubsetter: function(ev){
    var $el   = $(ev.target)
    var id    = $el.data('id');
    $(".drawer[data-id="+ id +"]").data('view').showSubsetter();
  },

  exportFont: function(ev){
    var $el   = $(ev.target)
    var id    = $el.data('id');
    var type  = $el.data('type');

    $.post( FP.Routes.exportFont, {id: id, type: type }, function(data){
      FP.Instances.Main.message("Exported " + data.name);
      Tipped.hideAll();
    })
  },

  installFont: function(ev){
    var $el   = $(ev.target)
    var id    = $el.data('id');

    $.post( FP.Routes.installFont, {id: id }, function(data){
      FP.Instances.Main.message("Installed " + data.name);
      Tipped.hideAll();
    })
  },

  addToExportGroup: function(ev){
    var $el       = $(ev.target);
    var id        = $el.data('id');
    var fontname  = $el.data('fontname');

    FP.ExportGroup[id] = fontname;
    FP.Instances.Main.message("Added " + fontname + " to export group", 1000);
    this.$groupExport.addClass('shown')
    Tipped.hideAll();
  },

  exportGroup: function(){
    var self = this;
    var ids = _.keys(FP.ExportGroup);
    
    $.post( FP.Routes.exportGroup, {ids: ids}, function(data){
      FP.ExportGroup = {};
      FP.Instances.Main.message("Export complete");
      self.$groupExport.removeClass('shown');
      Tipped.hideAll();
    })
  },

  clearExportGroup: function(){
    FP.ExportGroup = {};
    FP.Instances.Main.message("Cleared export group");
    this.$groupExport.removeClass('shown');
    Tipped.hideAll();
  },

  copyCharacter: function(ev){
    var $target   = $(ev.target);
    if (!$target.hasClass('action'))
      $target = $target.parents('.action');

    var text = $target.attr('data-raw') ? $target.text() : $target[0].innerText;
    $.post( FP.Routes.copyCharacter, {text: text || '' } )

    var $html = $("<code/>", {text: text});
    
    if ( $target.attr('data-raw') )
      $html.addClass( $target.attr("data-id") )

    FP.Instances.Main.message("Copied " + $html[0].outerHTML + " to the clipboard")

  }

});