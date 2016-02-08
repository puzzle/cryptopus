//  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
//  Cryptopus and licensed under the Affero General Public License version 3 or later.
//  See the COPYING file at the top-level directory or at
//  https://github.com/puzzle/cryptopus.

var Cryptopus = Cryptopus || function() {};

function checkIfFunctioningBrowser(){
  var ie10andbelow = navigator.userAgent.indexOf('MSIE') != -1 || /MSIE 10/i.test(navigator.userAgent) || /rv:11.0/i.test(navigator.userAgent);
  if(ie10andbelow){
    $('.clip_button_search').remove();
  }else{
    new ZeroClipboard( $('.clip_button_search') );
  }
}

(function(exports, $) {

  function Search(input_field, result_area) {
    this.input_field = input_field;
    this.result_area = result_area;
    this.attachEvent();
  };

  Search.prototype.attachEvent = function() {
    registerFieldActions();

    var term = "";
    var that = this;
    var input_field = this.input_field;
    input_field.keyup(function(event) {
      event.preventDefault();
      if (input_field.val() != term) {
        term = input_field.val();
        that.doSearch(term);
      }
      term = input_field.val();
    });
  };

  Search.prototype.doSearch = function(term) {
    $('.result-info').hide();
    var that = this;
    if (this.input_field.val().length > 2) {
      that.updateResultArea('');
      $.get('/search/account.json', {search_string: term})
        .done( function(data) {
          if (data.length > 0) {
            that.updateResultArea(data);
          } else {
            $('.result-info').show();
          }
        });
    }
  };

  Search.prototype.updateResultArea = function(data) {
    content = HandlebarsTemplates['search/result_entry'](data);
    this.result_area.html(content);
    this.registerActions();
  };

  Search.prototype.registerActions = function() {
    checkIfFunctioningBrowser();
    var that = this;
    $('.result-password .password-link').click(function(e) {
      e.preventDefault();
      var passLink = $(e.target),
        passInput = passLink.next('.password-hidden');

      passLink.hide();
      passInput.removeClass('hide');
      setTimeout(function(){
         passInput.select();
      }, 80);

      setTimeout(function(){
          passLink.show();
          passInput.addClass('hide');
      }, 5000);
    });
  };

  function registerFieldActions(){
    $(document).on("click", ".form-control", function (e) {
      e.target.select();
    });
  }

  exports.Search = Search;

})(Cryptopus, jQuery);
