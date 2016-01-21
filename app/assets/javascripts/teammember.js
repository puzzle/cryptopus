$('.show_members').click(function(){
  toggle_members();
});

$('#search_member').focus(function(){
  if($('.members').is(':hidden')){
    toggle_members();
  }
});

function toggle_members(){
  $('.columns').slideToggle();

  $('.members').slideToggle().promise().done(function(){
    if($('.columns').is(':visible')){
      $('.show_members').text(I18n.teammembers.hide);
    }else{
      $('.show_members').text(I18n.teammembers.show);
    }
  });
}