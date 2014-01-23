FP.UploaderQueue = function(opts){

  this.initialize = function(){
    this.url        = opts.url;
    this.chunkSize  = opts.chunkSize
  }

  this.process = function(files, opts){
    var self        = this;

    fontText = (files.length == 1) ? ' font' : ' fonts';
    FP.Instances.Main.message("Processing " + files.length + fontText, false);

    // Chunks the files so we get something back more quickly.
    chunks = []
    _.each(files, function(file){ chunks.push(file) })
    chunks = chunks.chunk(this.chunkSize);

    // Iterate ove the file chunks.
    _.each(chunks, function(files){

      var formData = new FormData();
      _.each( files, function(file, idx){
        formData.append('files[]', file )
      });

      $.ajax({
          url: self.url,
          data: formData,
          cache: false,
          contentType: false,
          processData: false,
          type: 'POST',
          success: function(data){
              if ( opts.success )
                  opts.success( data );
            FP.Instances.Main.removeMessage();
            FP.Instances.Main.refreshFontRows();
          },
          error: function(data){
              if ( opts.error )
                  opts.error( data );
            FP.Instances.Main.removeMessage();
              
          }
      });
    })

  }

  this.initialize();
    
};

Array.prototype.chunk = function(chunkSize) {
    var array=this;
    return [].concat.apply([],
        array.map(function(elem,i) {
            return i%chunkSize ? [] : [array.slice(i,i+chunkSize)];
        })
    );
}