var Cryptopus = Cryptopus || function() {};

$(document).on("click", ".form-control", function (e) {
    e.target.select();
});

function checkIfFunctioningBrowser(){
  var ie10andbelow = navigator.userAgent.indexOf('MSIE') != -1 || /MSIE 10/i.test(navigator.userAgent) || /rv:11.0/i.test(navigator.userAgent);
  if(ie10andbelow){
    $('.clip_button').remove();
  }else{
    new ZeroClipboard( $('.clip_button') );
  }
}

(function(exports, $) {

  function Search(input_field, result_area) {
    this.input_field = input_field;
    this.result_area = result_area;
    this.attachEvent();
  };

  Search.prototype.attachEvent = function() {
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
    var that = this;
    if (this.input_field.val().length < 3){
      that.updateResultArea('');
    }else{
    $.get('/search/account.json', {search_string: term})
      .done( function(data) {
        that.updateResultArea(data);
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

  exports.Search = Search;

})(Cryptopus, jQuery);
