var KB_PER_CHAR = 0.2;

FP.Views.App.Subsetter = Backbone.View.extend({
    
  events: {
    'click li.add':                       'addToSubset',
    'keyup .character-codes textarea':    'handleManualEnter',
    'click .character-codes .clear':      'clear',
    'click .button.export-subset':        'exportSubset',
    'click .exit-subsetter':              'exitSubsetter'
  },

  initialize: function(opts){
    this.id               = this.options.id;
    this.$select          = this.$el.find('.select');
    this.$characterCodes  = this.$el.find('.character-codes');
    this.$preview         = this.$el.find('.preview');
    this.$exportActions   = this.$el.find('.export-actions');
    this.$size            = this.$exportActions.find('.size');
    this.$total           = this.$exportActions.find('.total');
    this.subset           = []; // subset stored as decimals
    this.$el.data('view', this);
  },

  exitSubsetter: function(){
    this.$el.parents('.drawer').data('view').showViewer();
  },

  addToSubset: function(ev){
    var $el     = $(ev.target);

    if ( !$el.hasClass('add') )
      return;

    var range = null, 
        start = null, 
        end = null;

    if ( $el.hasClass('custom-range') ) {
      range   = $el.data('hex-range');
      start   = $el.find('.start').val();
      end     = $el.find('.end').val();
    } else {
      range   = $el.data('hex-range');
      start   = range.split('-')[0];
      end     = range.split('-')[1];
    }

    // Merge new subset in with current one, removing the duplicates...
    var newChars  = _.range( this.toDecimal(start),  this.toDecimal(end) + 1 )
    var subset    = _.union( this.subset, newChars );
    this.subset   = _.uniq(subset);
    
    this.$characterCodes.find('textarea')
                        .val( this.hexCodes().join(', ') );

    this.updatePreview();
  },

  updatePreview: function(){
    var html = this.hexEntities();
    html = html.join(' ')
    this.updateStats();

    this.$preview.find('.preview-characters')
                 .html( html );
  },

  updateStats: function(){
    var length = this.subset.length
    var size  = Math.round( (length*KB_PER_CHAR)*100 )/100;
    this.$size.html( size + " kb" );
    this.$total.html( length );
  },

  clear: function(ev){
    ev.preventDefault();
    this.subset = [];
    this.$characterCodes.find('textarea').val('')
    this.updatePreview();
  },

  handleManualEnter: function(ev){
    var self     = this;
    var $el      = $(ev.target); 
    var codes    = $el.val().split(',');

    codes = _.map( codes, function(val){
      val = self.toDecimal(val);
      if ( isNaN(val) )
        return -1;
      return val;
    });

    codes         = _.filter(codes, function(num){ return num !== -1 });
    this.subset   = _.uniq(codes);
    this.updatePreview();
  },

  exportSubset: function(ev){
    ev.preventDefault();
    
    $.post( FP.Routes.exportSubset, {id: this.id, characters: this.subset }, function(data){
      FP.Instances.Main.message("Exported " + data.name + " subset");
      Tipped.hideAll();
    })
  },

  toDecimal: function(hex){
    return parseInt(hex, 16);
  },

  toHex: function(decimal){
    return decimal.toString(16);
  },

  hexCodes: function(){
    var self    = this;

    var range       = _.map( this.subset, function(dec){
      var hex     = self.toHex(dec);
      var zeroes  = 4 - hex.length;
      hex         = "0x" + [0,0,0].slice(0,zeroes).join('') + hex   
      return hex;
    })

    return range; 
  },

  hexEntities: function(){
    var self    = this;

    this.subset = this.subset.sort(function(a,b){return a - b})

    var range     = _.map( this.subset, function(dec){
      var hex     = self.toHex(dec);
      hex         = "&#x" + hex + ";"   
      return hex;
    })

    return range; 
  }

});