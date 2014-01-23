//= require "namespace"
//= require "routes"
//= require "lib/jquery-1.9.1"
//= require "lib/underscore"
//= require "lib/backbone"
//= require "lib/tipped"
//= require "lib/spinners"
//= require "lib/spectrum"
//= require "views/viewer.main"
//= require "template-fetcher"

//  Build everything out
// --------------------------------
$(document).ready(function(){
  FP.Instances                      = {}; 
  FP.Instances.Viewer               = new FP.Views.Viewer.Main();
});