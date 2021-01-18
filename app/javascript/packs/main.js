"use strict";

$(document).on('ready turbolinks:load', function() {
  $('#home_btn').on('click', handleHomeBtn);
  $('#search_form').on('keypress', preventMainFormEnterSubmit);
  $('#search_btn').on('click', search);
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

  $.ajax({
    url: $("#search_form").attr('action'),
    data: $("#search_form").serializeArray(),
    type: 'POST',
    headers: prepareHeaders(),
    dataType: 'script',
    success: function(data, status, xhr) {
      console.log(data, status, xhr);
    },
    error: function(jqXhr, textStatus, errorMessage) {
      console.log("Error", error);
      $('#flash_messages').html('Error: ' + errorMessage).attr('class', 'error').show().fadeOut(5000);
    }
  });
}
