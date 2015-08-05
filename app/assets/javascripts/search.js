var Cryptopus = Cryptopus || function() {};

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
      term = input_field.val()
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
    var that = this;
    $('.result-password .password-link').click(function(e) {
      var passLink = that.result_area.find('.password-link'),
          passInput = passLink.next('.password-hidden');
      passLink.hide();
      passInput.show();
      setTimeout(function(){
         passInput.select();
      }, 80);

      setTimeout(function(){
          passLink.show();
          passInput.hide();
      }, 5000);
    });
  };

  exports.Search = Search;

})(Cryptopus, jQuery);
