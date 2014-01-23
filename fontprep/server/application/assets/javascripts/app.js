

//= require "namespace"
//= require "routes"
//= require "lib/jquery-1.9.1"
//= require "lib/underscore"
//= require "lib/backbone"
//= require "lib/tipped"
//= require "lib/spinners"
//= require "lib/spectrum"
//= require "lib/webfont"
//= require "views/app.main"
//= require "views/app.modal"
//= require "views/app.settings-drawer"
//= require "views/app.uploader"
//= require "views/app.uploader-queue"
//= require "views/app.font-row"
//= require "views/app.font-actions"
//= require "views/app.font-drawer"
//= require "views/app.subsetter"
//= require "views/viewer.main"
//= require "template-fetcher"
//= require "tipper"

//  Build everything out
// --------------------------------
$(document).ready(function(){
  FP.Instances                      = {};
  FP.Instances.Main                 = new FP.Views.App.Main(); 
  FP.Instances.Modal                = new FP.Views.App.Modal(); 
  FP.Instances.SettingsDrawer       = new FP.Views.App.SettingsDrawer(); 
  FP.Instances.Uploader             = new FP.Views.App.Uploader();  
  FP.Instances.FontActions          = new FP.Views.App.FontActions();  
  FP.Instances.Viewer               = new FP.Views.Viewer.Main();
  FP.Instances.TemplateFetcher      = new FP.TemplateFetcher();
  FP.Instances.Tipper               = new FP.Tipper();
});