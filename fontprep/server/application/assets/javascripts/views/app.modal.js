FP.Views.App.Modal = Backbone.View.extend({
  
  el: '.fp-modal',

  events: {
    'click .ok':      'ok',
    'click .cancel':  'hide'
  },

  initialize: function(){
    this.confirmFunction  = function(){};
  },

  confirm: function(title, text, confirm, noCancel){
    this.$el.find('.content h2').text(title)
    this.$el.find('.content .text').text(text);

    if ( confirm ) {
      this.confirmFunction = confirm;
      this.$el.find('.content .controls').show();

      if ( noCancel ){
        this.$el.find('.content .controls .cancel').hide();
      } else {
        this.$el.find('.content .controls .cancel').show();
      }
    } else {
      this.confirmFunction  = function(){};
      this.$el.find('.content .controls').hide()
    }

    this.show()
  },

  ok: function(e){
    e.preventDefault();

    if ( this.confirmFunction )
      this.confirmFunction();

    this.hide();
  }, 

  show: function(){
    Tipped.hideAll();
    this.$el.addClass('shown')
  },

  hide: function(e){
    if (e)
      e.preventDefault();
    this.$el.removeClass('shown')
  }

});