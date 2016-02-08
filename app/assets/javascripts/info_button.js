//  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
//  Cryptopus and licensed under the Affero General Public License version 3 or later.
//  See the COPYING file at the top-level directory or at
//  https://github.com/puzzle/cryptopus.

$(".no_root_info").click(function(){
  $(".no_root").css("display", "inline");

  setTimeout(function(){
    $(".no_root").hide();
    return;
  }, 10000);
});

$(".private_info").click(function(){
  $(".private").css("display", "inline");

  setTimeout(function(){
    $(".private").hide();
    return;
  }, 10000);
});