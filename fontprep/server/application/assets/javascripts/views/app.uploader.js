FP.Views.App.Uploader = Backbone.View.extend({
    
  el: document,

  events: {
    'dragover':   'over',
    'dragleave':  'leave',
    'drop':       'drop'
  },

  initialize: function(){
    var self = this;
    this.importCount          = 0;
    this.importSkipped        = 0
    this.uploadURL            = FP.Routes.upload;
    this.uploaderQueue        = new FP.UploaderQueue({ url: this.uploadURL, chunkSize: 6 })
    this.$overlay             = this.$el.find('.overlay.uploader');
    this.$loaderWrap          = this.$el.find('.loader-wrap');
    this.preventDefaults();
    this.handleAjaxStartStop();
    $.event.props.push('dataTransfer');

    setTimeout(function(){ self.activateLoader(); }, 2000)
  },

  render: function() {
    return this;
  },

  preventDefaults: function(){
    this.$el.on('drop',     function(ev){ ev.preventDefault() });
    this.$el.on('dragover', function(ev){ ev.preventDefault() });
  },

  over: function(ev){
    ev.preventDefault();
    this.$overlay.addClass('shown');
  },

  leave: function(ev){
    ev.preventDefault();
    var self = this;
    this.$overlay.removeClass('shown')
  },

  drop: function(ev){
    if (!FP.licensed)
      return;

    ev.preventDefault();
    var self = this;

    this.$overlay.removeClass('shown');
    this.activateLoader();

    this.uploaderQueue.process( ev.dataTransfer.files , {
      success: function(response){
        self.uploadSuccess(response);
      }, 
      error: function(){
        self.$loaderWrap.removeClass('shown');
      }
    })
  },

  uploadSuccess: function(responseData){
    var self = this;
    var $html = $(responseData.html);

    this.importMessage(responseData.count, responseData.skipped);
    this.$el.find('body.app ul.fonts').append( $html );
    this.$loaderWrap.removeClass('shown');

    $html.each(function(idx, obj){ 
      if ( $(obj).hasClass('font-row') ){
        new FP.Views.App.FontRow({ el: $(obj) });
      }

      if ( $(obj).hasClass('drawer') ){
        new FP.Views.App.FontDrawer({ el: $(obj) });      
      }

    })

    this.scrollToBottom();

    // If we have zero, show the overlay.
    FP.Instances.Main.handleZeroCase();
  },

  importMessage: function(count, skipped){
    var self    = this;
    this.importCount    += count;
    this.importSkipped  += skipped;

    if (this.importTimeout) 
      clearTimeout(this.importTimeout);

    this.importTimeout = setTimeout(function(){  
      
      if ( self.importCount > 0 && self.importSkipped > 0 ){
        FP.Instances.Main.message("Imported " + self.importCount + ", unable to process " + self.importSkipped, 2000);
      }
      else if ( self.importCount > 0 ) {
        FP.Instances.Main.message("Imported " + self.importCount, 2000);
      }
      else if ( self.importSkipped > 0 ) {
        FP.Instances.Main.message("Unable to process " + self.importSkipped, 2000);
      }
      
      self.importCount = 0;
      self.importSkipped = 0;
    }, 3000);

  },

  handleAjaxStartStop: function(){
    var self = this;
    this.$el.ajaxStart(function(){ self.activateLoader() })
    this.$el.ajaxStop(function(){
      self.$loaderWrap.removeClass('active'); 
    })
  },

  scrollToBottom: function(){
    this.$el.find("body").animate({ scrollTop: this.$el.height() }, 500);    
  },

  activateLoader: function(){
    this.$loaderWrap.addClass('active');
  }
});