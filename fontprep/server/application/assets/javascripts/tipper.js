FP.Tipper = function Tipper(){

  this.makeTips = function($tips){
    $tips = $tips || $('[data-tip]');
    $tips = $tips.filter(function(idx,obj){ 
      return $(obj).attr('data-tipped') != 1 
    });

    $.each( $tips, function(idx, el){
      var $el = $(el);

      $el.attr('data-tipped', 1)

      var id        = $el.data('id') || $el.parents('.drawer').data('id') || -1;
      var fontname  = $el.data('fontname') || $el.parents('.drawer').data('fontname') || -1;
      var data      = $el.data('data') || "";
      var title     = $el.data('title');
      var template  = $el.data('jst') || false;
      var stem      = $el.data('stem') || false;
      var position  = $el.data('position') || 'topmiddle';
      var x         = $el.data('x') || 0;
      var y         = $el.data('y') || 0;

      var opts = {
        offset:         { x: x, y: y },
        hook:           position,
        hideOthers:     true,
        afterUpdate:    function(content, element){ },
        skin:           'fontprep'
      }

      if ( !stem )
          opts = _.extend(opts, {stem: false})

      // ==============================================================
      // Tip it 
      // ==============================================================
      Tipped.create( $el, function(){
        if ( template ){
          return FP.Instances.TemplateFetcher.getTemplate(template, {id: id, fontname: fontname, data: data})
        }
        else if ( title ){
          return $('<div>', { text: title }).css({ padding: "12px 20px" });
        }
        else{
          console.log('Unable to create tip.')
        }
      }, opts)

    });

  }

  this.makeTips();

}