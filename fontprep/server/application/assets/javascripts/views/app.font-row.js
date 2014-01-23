FP.Views.App.FontRow = Backbone.View.extend({
    
  events: {
    'click':                'expand',
    'click .export':        'export',
    'click .install':       'install',
    'click .view':          'view',
    'click .delete':        'destroy',
    'click .export-group':  'addToExportGroup'
  },

  initialize: function(){
    this.id             = this.$el.data('id')
    this.rawname        = this.$el.data('rawname'); 
    this.$drawer        = this.$el.next('li');
    this.$characters    = this.$drawer.find('.characters'); 
    this.$loaderWrap    = this.$drawer.find('.loader-wrap');
    this.$el.data('view', this)
            .addClass('shown')

    FP.Instances.Tipper.makeTips( this.$el.find('[data-tip]') );
  },

  expand: function(){
    this.closeOthers();
    this.createDrawerView();
    this.$el.toggleClass('expanded');
    this.showLoader();
    this.contentizeCharacters();
    return false;
  }, 

  showLoader: function(){
    if (this.styled)
      return;
  },

  closeOthers: function(){
    var self = this;
    var $expanded = $('li.expanded');
    $expanded = $expanded.filter(function(idx, el){
      return self.$el[0] !== el;
    })
    $expanded.removeClass('expanded');
    Tipped.hideAll();
  },

  contentizeCharacters: function(all, force){
    var self = this;
    all     = all   || 0;
    force   = force || false;

    this.contentized = this.$el.attr('data-contentized') == 1;

    if (this.contentized && !force) 
      return;

    this.$el.attr('data-contentized', '1');

    $.ajax({
      url:      FP.Routes.characters,
      data:     { id: this.id, all: all },
      success:  function(data){
        self.$characters.html(data.html);
        self.$drawer.find('.characters')
            .css('font-family', self.id)
            .addClass('shown');

        var initialTimeout = 3000;
        setTimeout(function(){ self.applyFontStyles();                                              }, initialTimeout) ;
        setTimeout(function(){ FP.Instances.Tipper.makeTips( self.$drawer.find('[data-tip]') );     }, initialTimeout*2) ;
      }
    })
  },

  applyFontStyles: function(){
    this.styled = this.$el.attr('data-styled') == 1;
    
    if (this.styled) 
      return; 

    this.$el.attr('data-styled', '1');

    WebFont.load({
      custom: {
        families: [this.id],
        urls:     ['/font/css?id=' + this.id + '&raw=1']
      }
    });

    this.$drawer.find('.characters')
                .css('font-family', this.id)
                .addClass('shown');
  },

  createDrawerView: function(){
    if (this.drawerView) return;
    this.drawerView = new FP.Views.App.FontDrawer({ el: this.$el.next('.drawer') });
  },

  "export": function(ev){
    // export is reserved, must use string literal.
    ev.stopPropagation();
    FP.Instances.FontActions.exportFont(ev);
  },

  install: function(ev){
    ev.stopPropagation();
    FP.Instances.FontActions.installFont(ev);
  },

  view: function(ev){
    ev.stopPropagation();
    FP.Instances.FontActions.viewInBrowser(ev);
  },

  destroy: function(ev){
    ev.stopPropagation();
    FP.Instances.FontActions.destroy(ev);
  },

  addToExportGroup: function(ev){
    ev.stopPropagation();
    FP.Instances.FontActions.addToExportGroup(ev);
  }

});