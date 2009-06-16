/*
 * Expands Redmine's current menu
 */
(function($) {
  $.menu_expand = function(options) {
      var opts = $.extend({
          menu: '#main-menu',
          menuItem: '.selected'
      }, options);

      $(opts.menu +' '+ opts.menuItem +' .toggler').click();

  }})(jQuery);