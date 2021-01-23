"use strict";

$(document).on('ready turbolinks:load', function() {
  $('#home_btn').on('click', handleHomeBtn);
  $('#search_form').on('keypress', preventMainFormEnterSubmit);
  $('#search_btn').on('click', search);
  $('body').on('click', '.see_more, .discard', handleSeeMoreDiscardBtns);
  $('#go_to_top_btn').on('click', handleTopBtn);
});

function handleHomeBtn(e) {
  e.preventDefault();

  var url = e.currentTarget.attributes.href.value;
  var headers = prepareHeaders();

  $.ajax({
    url: url,
    data: {},
    headers: prepareHeaders(),
    dataType: "script",
    success: function(data, status, xhr) {
      // console.log(data, status, xhr);
    },
    error: function(jqXhr, textStatus, errorMessage) {
      // console.log(jqXhr, textStatus, errorMessage);
    }
  });
}

function prepareHeaders() {
  var user_data = JSON.parse(sessionStorage.getItem('user_data'));

  return {
    'Api-Token': user_data['api_token'],
    'Email': user_data['email']
  };
}

function preventMainFormEnterSubmit(e) {
  if (e.keyCode == 13) { return false; }
}

function search(e) {
  e.preventDefault();
  $("#loader").show();

  $.ajax({
    url: $("#search_form").attr('action'),
    data: $("#search_form").serializeArray(),
    type: 'POST',
    headers: prepareHeaders(),
    dataType: 'script',
    success: function(data, status, xhr) {
      // console.log(data, status, xhr);
      $("#loader").hide();
    },
    error: function(jqXhr, textStatus, errorMessage) {
      // console.log("Error", errorMessage);
      $("#loader").hide();
      $('#flash_messages').html('Error: ' + errorMessage).attr('class', 'error').show().fadeOut(5000);
    }
  });
}

function handleSeeMoreDiscardBtns(e) {
  e.preventDefault();

  var element = $(e.currentTarget);
  var categories = element.parent().siblings()[1].textContent;
  var vote = element.hasClass('see_more');

  var req_data = { categories: categories.replace("Categories: ", ""), vote: vote };

  $.ajax({
    url: element.data('url'),
    data: req_data,
    type: 'POST',
    headers: prepareHeaders(),
    dataType: 'script',
    success: function(data, status, xhr) {
      // console.log(data, status, xhr);
      if (!vote) {
        var row = element.parents()[6];
        $(row).hide(1400);
      } else {
        var win = window.open(element.data('redirect-to'), '_blank');
        win.focus();
      }
    },
    error: function(jqXhr, textStatus, errorMessage) {
      // console.log("Error", errorMessage);
    }
  });
}

function handleTopBtn(e) {
  $('html, body').animate({ scrollTop: 0 }, 'slow');
  return false;
}

function checkLocation(update_url) {
  navigator.geolocation.getCurrentPosition(function(position) {
    console.log("position", position);

    $.ajax({
      url: update_url,
      data: { latitude: position['coords']['latitude'], longitude: position['coords']['longitude'], location_type: 'acquired' },
      type: 'POST',
      headers: prepareHeaders(),
      dataType: 'script',
      success: function(data, status, xhr) {
        console.log('sucs', data, status, xhr);
      },
      error: function(jqXhr, textStatus, errorMessage) {
        console.log("Error", errorMessage);
        // $('#flash_messages').html('Error: ' + errorMessage).attr('class', 'error').show().fadeOut(5000);
      }
    });


  }, function() {});
}

// 'export' function to be available from '*.erb.js' views
window.checkLocation = checkLocation;
