// Set the document hash to the tab href
$(document).on('show.bs.tab', function (e) {
  history.replaceState(null, null, '#' + e.target.getAttribute('id'));
});

// Display the tab based on form errors, the document hash, or ?tab= params
$(document).ready(function() {
  var href = '';

  var $tab_with_error = $(".form-control.is-invalid").first().closest('.tab-pane')

  if ($tab_with_error.length > 0) {
    href = $tab_with_error.attr('id')
  } else if (document.location.hash.length > 0) {
    var hash = document.location.hash
    if(hash.startsWith('#tab-')) { href = hash.replace('#tab-', '') }
  } else if (document.location.search.length > 0) {
    var param = new URLSearchParams(document.location.search).get('tab') || ''
    if(param.length > 0) { href = param }
  }

  if (href.length > 0) {
    var $tab = $(".nav.nav-tabs").find("a[href^='#" + href + "']")

    $tab.parents('.tab-pane').each (function() {
      $('.nav.nav-tabs').find("a[href^='#" + $(this).attr('id') + "']").tab('show')
    })

    $tab.tab('show')
  }
});


// Click tab button
$(document).on('click', '[data-click-tab]', function(event) {
  event.preventDefault();

  var href = $(event.currentTarget).attr('href');
  $('.nav.nav-tabs').find("a[href^='" + href + "']").tab('show');
});
