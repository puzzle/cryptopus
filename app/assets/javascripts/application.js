//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require zeroclipboard
//= require handlebars.runtime
//= require search
//= require_tree ./templates

// Password hidden
$(document).ready(function(){

  $( ".select-click" ).on( "click", function(e) {
    if (e.target.tagName === 'INPUT') {
      return e.target.select();
    }
  });
});
