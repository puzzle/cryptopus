var Cryptopus = Cryptopus || function() {};

(function(exports, $) {

  function Search(input_field, result_area) {
    this.input_field = input_field;
    this.result_area = result_area;
    this.attachEvent();
  };

  Search.prototype.attachEvent = function() {
    var that = this;
    var input_field = this.input_field;
    input_field.keyup(function(event) {
      event.preventDefault();
      if (event.keyCode == 13) {
        term = input_field.val();
        that.doSearch(term);
      }
    });
  };

  Search.prototype.doSearch = function(term) {
    var that = this;
    $.get('/search/account.json', {search_string: term})
      .done( function(data) {
        that.updateResultArea(data);
      });
  };

  Search.prototype.updateResultArea = function(data) {
    content = '';
    //if (Array.isArray(data)) {
      //data.forEach(function(entry) {
        //alert('haha');
      //});
    //}
    this.result_area.replaceWith(content);
  };

  Search.prototype.printResult = function(result) {
    
  };

  exports.Search = Search;

})(Cryptopus, jQuery);
