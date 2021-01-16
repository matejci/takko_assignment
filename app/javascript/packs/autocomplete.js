"use strict";

$(document).on('ready turbolinks:load', function() {
  function initializeAutocomplete() {
    var input = document.getElementById('address');
    var autocomplete = new google.maps.places.Autocomplete(input, { types: ['geocode'], componentRestrictions: { country: 'us' } });
    google.maps.event.addListener(autocomplete, 'place_changed', onPlaceChanged);
  }

  function onPlaceChanged() {
    var place = this.getPlace();

    // console.log(place);

    var address_components = place.address_components;

    $("#town").val(address_components[1]['long_name']);
    $("#county").val(address_components[2]['long_name']);

    // sometimes postal_code is not returned by google api
    if (address_components[5]) {
      $("#postal_code").val(address_components[5]['long_name']);
    }
  }

  google.maps.event.addDomListener(window, 'load', initializeAutocomplete);
});
