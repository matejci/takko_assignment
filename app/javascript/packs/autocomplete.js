"use strict";

$(document).on('ready turbolinks:load', function() {
  function initializeAutocomplete() {
    var input = document.getElementById('address');
    var autocomplete = new google.maps.places.Autocomplete(input, { types: ['geocode'], componentRestrictions: { country: 'us' } });
    google.maps.event.addListener(autocomplete, 'place_changed', onPlaceChanged);
  }

  function onPlaceChanged() {
    var place = this.getPlace();
    var address_components = place.address_components;

    if (address_components) {
      address_components.forEach(function(item, index) {
        var postal_code_index = item['types'].indexOf('postal_code');
        if (postal_code_index != -1) {
          $("#postal_code").val(item['long_name']);
        }
      });
    }
  }
  google.maps.event.addDomListener(window, 'load', initializeAutocomplete);
});
