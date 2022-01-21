// reveal_mail_to
$(document).on('click', '[data-mailto-rot13]', function(event) {
  event.preventDefault();

  var $link = $(event.currentTarget);

  var email = $link.data('mailto-rot13').replace(/[a-zA-Z]/g, function(c) {
    return String.fromCharCode((c <= 'Z' ? 90 : 122) >= (c = c.charCodeAt(0) + 13) ? c : c - 26);
  });

  $link.attr('href', 'mailto:' + email).html(email).removeAttr('data-mailto-rot13');
});
