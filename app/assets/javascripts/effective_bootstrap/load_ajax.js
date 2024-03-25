// Implements the jQuery load div pattern
// See effective_reports admin screen
$(document).on('change', "[data-load-ajax-url][data-load-ajax-div]", function(event) {
  let $input = $(event.currentTarget);

  let url = $input.data('load-ajax-url');
  let div = $input.data('load-ajax-div');

  let $container = $input.closest('form').find(div);
  if(div.length == 0) { console.error("Unable to find load ajax div " + div); return; }

  let name = $input.data('load-ajax-name') || '';
  if(name.length == 0) { name = ($input.attr('name').split(/\[|\]/)[1] || ''); }
  if(name.length == 0) { console.error("Unable to parse load ajax input name " + $input.attr('name')); return; }

  let value = ($input.val() || '');
  if(value.length == 0) { $container.html(''); return; }

  let joiner = (url.indexOf('?') == -1 ? '?' : '&');

  let input = {}
  input[name] = value;

  url = (url + joiner + $.param(input));

  // Include all form params?
  let all = $input.data('load-ajax-all');

  if(all) {
    let $form = $input.closest('form');
    let form = $form.serialize().replace(/authenticity_token=[^&]+&?/, "");

    url = url + '&' + form;
  }

  // Load it
  $container.html("<div class='load-ajax-loading'><p>Loading...</p></div>");

  let $content = $('<div></div>');

  $content.load(url + ' ' + div, function(response, status, xhr) {
    if(status == 'error') {
      $container.append("<div class='load-ajax-error'><p>Error: please refresh the page and try again.</p></div>");
    } else {
      $container.replaceWith($content.children(div));
      EffectiveBootstrap.initialize();
      $(document).trigger('effective-datatables:initialize');
    }
  });
});
