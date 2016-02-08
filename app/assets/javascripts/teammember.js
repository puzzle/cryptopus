//  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
//  Cryptopus and licensed under the Affero General Public License version 3 or later.
//  See the COPYING file at the top-level directory or at
//  https://github.com/puzzle/cryptopus.

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
      $('html, body').animate({scrollTop:$(document).height()}, 'slow');
    }else{
      $('.show_members').text(I18n.teammembers.show);
    }
  });
}