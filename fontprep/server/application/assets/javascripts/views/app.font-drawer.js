FP.Views.App.FontDrawer = Backbone.View.extend({
    
  events: {
    'click .show-all':      'showAll',
    'click h1':             'copyID'
  },

  initialize: function(){
    this.id             = this.$el.data('id');
    this.row            = this.$el.prev('li').data('view');
    this.$viewer        = this.$el.find(".viewer") 
    this.$subsetter     = this.$el.find(".subsetter") 

    if ( this.$subsetter.length > 0 )
      this.subsetterView  = new FP.Views.App.Subsetter({ el: this.$subsetter, id: this.id }) 
    
    this.$el.data('view', this);
  },

  showAll: function(ev){
    ev.preventDefault();
    this.row.contentizeCharacters(true, true);
  },

  showSubsetter: function(){
    this.$viewer.removeClass('shown');
    this.$subsetter.addClass('shown');
  },

  showViewer: function(){
    this.$subsetter.removeClass('shown');
    this.$viewer.addClass('shown');
  },

  copyID: function(){
    $.post(FP.Routes.copyCharacter, { text: this.id })
    FP.Instances.Main.message("Copied " + this.id + " to the clipboard"); 
  }

});