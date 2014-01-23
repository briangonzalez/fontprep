FP.Views.Viewer.Main = Backbone.View.extend({
    
  el: 'body.view',

  events: {
    'change .goto':                   'goto',
    'change .font-size input':        'changeFontSize',
    'change input.text-color':        'changeTextColor',
    'change input.background-color':  'changeBackgroundColor'
  },

  initialize: function(){
    if (this.$el.length == 0)
      return;
    
    this.currentFontID        = FP.currentFontID
    this.$text                = this.$el.find('p.text');
    this.$fontSizeIndicator   = this.$el.find('.font-size .indicator');
  },

  stylizeText: function(){
    if (!this.currentFontID)
        return;

    $("head").append("<link rel='stylesheet' type='text/css' href='/font/css?id="+ this.currentFontID +"&raw=1' />");
  },

  goto: function(ev){
    var id = $(ev.target).val();
    window.location = FP.Routes.viewer + "/" + id
  },

  changeFontSize: function(ev){
    var $el   = $(ev.target);
    var size  = parseInt($el.val());
    size  = size || 16;
    this.$fontSizeIndicator.text( size + "px" )
    this.$text.css({ 'font-size': size, 'line-height': (size+10) + "px" })
  },

  changeTextColor: function(ev){
    var $el = $(ev.target)
    this.$text.css({ color: $el.val() })
  },

  changeBackgroundColor: function(ev){
    var $el = $(ev.target)
    this.$el.css({ background: $el.val() })
  }

});