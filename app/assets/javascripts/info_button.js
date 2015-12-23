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