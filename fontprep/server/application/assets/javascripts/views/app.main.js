FP.Views.App.Main = Backbone.View.extend({
    
  el: 'body.app',

  events: {
    'click .settings-toggle':   'toggleSettings',
    'keyup .filter':            'filter',
    'focus .filter':            'handleFilterFocus',
    'blur .filter':             'handleFilterBlur',
    'keyup form.box input':     'handleLicenseEnter',
  },

  initialize: function(){
    this.$settingsDrawer  = this.$el.find('.settings.drawer');
    this.$topBar          = this.$el.find('.top-bar');
    this.$message         = this.$el.find('.message');
    this.$filter          = this.$el.find('.top-bar.fixed .filter');
    this.$fontList        = this.$el.find('ul.fonts');
    this.$loadingOverlay  = this.$el.find('.overlay.loading')
    this.$uploaderOverlay = this.$el.find('.overlay.uploader')
    this.$licenseForm     = this.$el.find('.license form.box')
    this.$licenseOverlay  = this.$el.find('.overlay.license');
    this.$loaderWrap      = this.$el.find('.loader-wrap');

    this.ajaxFontRows();
  },

  ajaxFontRows: function(){
    var self = this;

    $.ajax({
      url: FP.Routes.fontrows, 
      success: function(data){
        self.$loadingOverlay.remove();
        self.handleAjaxFontRowsSuccess(data);
      }, 
      error: function(){
        self.$loadingOverlay.remove();
        FP.Instances.Modal.confirm(
          'Unable to load font library', 
          [ 'Oops! FontPrep was unable to load your font library.', 
            'Restart FontPrep and contact support@fontprep.com if the issue persists.' 
          ].join(' ')
        );
      }
    })
  },

  handleAjaxFontRowsSuccess: function(data){
    this.$fontList.append(data.html);

    this.refreshFontRows();
    this.$drawers         = this.$el.find('li.drawer').not('settings');
    
    // not sure why I need to do this...
    var self = this;
    setTimeout( function(){ 
      self.$fontRows.addClass('shown'); 
    }, 0);

    if (data.empty){
      this.$uploaderOverlay.addClass("shown");
    } else {
      this.$uploaderOverlay.removeClass("shown");
    }

    this.createFontRowViews();
  },

  refreshFontRows: function(){
    this.$fontRows = this.$el.find('li.font-row');
  },

  createFontRowViews: function(){
    _.each( this.$fontRows, function(obj){
      new FP.Views.App.FontRow({ el: $(obj) });
    });
  },

  toggleSettings: function(){
    this.$el.animate({ scrollTop: 0 }, 100);
    this.$settingsDrawer.toggleClass('expanded')
  },

  handleZeroCase: function(){
    var rows = this.$el.find('li.font-row').length
    
    if ( rows == 0 ){
      this.$uploaderOverlay.addClass('shown')
    }
  },

  filter: function(){
    var text  = this.$filter.val();
    text      = text.toLowerCase();
    pieces    = text.split(' ')

    if (text.length === 0){
      this.$fontRows.removeClass('hidden');
    }
    else{
      _.each(this.$fontRows, function(el){
        var $el = $(el)
        var name = $el.attr('data-name');
        var found = false;

        _.each(pieces, function(piece){
          if ( piece.length > 0 ){
            if ( name.toLowerCase().search( piece ) >= 0 ){ found = true; }
          }
        });

        if ( found ) {
          $el.removeClass('hidden');
        } else {
          $el.addClass('hidden').removeClass('expanded');
        }
      });
    }
  },

  handleFilterFocus: function(){
    if ( this.$filter.val() == this.$filter.attr('data-placeholder') )
      this.$filter.val('');
  },  

  handleFilterBlur: function(){
    if ( this.$filter.val().length == 0 ) {
      var p = this.$filter.attr('data-placeholder');
      this.$filter.val( p )
    }
  },

  handleLicenseEnter: function(ev){
    if ( ev.which == 13 ){
      var self = this;
      this.$licenseForm.removeClass('shake');

      $.ajax({
        type:     "POST",
        url:      FP.Routes.license,
        data:     self.$licenseForm.serialize(),
        success:  function(){
          self.$licenseOverlay.hide();
          FP.licensed = true;
        },
        error:    function(){
          self.$licenseForm.addClass('shake')
                           .find('.notice')
                           .text('Invalid email or license.');
        }
      })
    }
  },

  message: function(html, hideAfter){
    var self = this;
    this.$message.html(html).addClass('shown');

    // pass false to leave message up indefinitely.
    if ( hideAfter !== false ) {
      hideAfter = hideAfter || 2000;
      setTimeout(function(){
        self.removeMessage();
      }, hideAfter)
    }
  },

  removeMessage: function(){
    this.$message.removeClass('shown');
  }

});