$(document).on('change', '.effective-select-or-text input', function(event) {
  $(event.currentTarget).closest('.effective-select-or-text').find('select').val('').trigger('change.select2');
});

$(document).on('change', '.effective-select-or-text select', function(event) {
  $(event.currentTarget).closest('.effective-select-or-text').find('input').val('');
});

// This is the icon that switches them
$(document).on('click', '[data-effective-select-or-text]', function(event) {
  $obj = $(event.currentTarget).closest('.effective-select-or-text');

  $visible = $obj.children('.form-group:visible').first();
  $hidden = $obj.children('.form-group:not(:visible)').first();

  visible_name = $visible.find('input,textarea,select').first().attr('name');
  hidden_name = $hidden.find('input,textarea,select').first().attr('name');

  if(visible_name == hidden_name) { $hidden.find('input,textarea,select').removeAttr('disabled'); }

  $visible.fadeOut('fast', function() {
    if(visible_name == hidden_name) { $(this).find('input,textarea,select').prop('disabled', true); }
    $hidden.fadeIn('fast');
  });

  return false; // This implicitly calls event.preventDefault() to cancel the action, and prevent the link from going somewhere.
});
