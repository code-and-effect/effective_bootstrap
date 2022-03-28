$(document).ready(function() {
  var $tab_with_error = $(".form-control.is-invalid").first().closest('.tab-pane');

  if ($tab_with_error.length > 0) {
    $(".nav.nav-tabs").find("a[href^='#" + $tab_with_error.attr('id') + "']").tab('show');
    return true;

  } else if (document.location.search.length > 0) {
    var tab = new URLSearchParams(document.location.search).get('tab');
    if(tab.length == 0) { return false; }

    $('.nav.nav-tabs').find("a[href^='#" + tab + "']").tab('show');
  }
});

$(document).on('click', '[data-click-tab]', function(event) {
  event.preventDefault();

  var href = $(event.currentTarget).attr('href');
  $('.nav.nav-tabs').find("a[href^='" + href + "']").tab('show');
});
