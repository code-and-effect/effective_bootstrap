// Bootstrap's data-ride initializer only runs on a full window load.
$(document).on('turbolinks:load turbo:load', function() {
  $('[data-ride="carousel"]').carousel();
});

$(document).on('turbolinks:before-cache turbo:before-cache', function() {
  $('.carousel').each(function() {
    var $carousel = $(this);
    if (!$carousel.data('bs.carousel')) return;

    $carousel.carousel('pause');
    // Finish an in-progress slide before Turbo clones its transition classes.
    if ($carousel.find('.carousel-item-next, .carousel-item-prev').length) {
      $carousel.find('.carousel-item.active').trigger('transitionend');
    }
  });
});
