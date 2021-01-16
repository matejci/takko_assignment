"use strict";

$(document).on('ready turbolinks:load', function() {
  $('#home_btn').on('click', handleHomeBtn);
  $('#main_form').on('keypress', preventMainFormSubmit);
});

function handleHomeBtn(e) {
  e.preventDefault();

  var url = e.currentTarget.attributes.href.value;
  var headers = prepareHeaders()
  var data =
    $.ajax({
      url: url,
      data: {},
      headers: prepareHeaders(),
      dataType: "script",
      success: function(data, status, xhr) {
        console.log(data, status, xhr);
      },
      error: function(jqXhr, textStatus, errorMessage) {
        console.log(jqXhr, textStatus, errorMessage);
      }
    });
}

function prepareHeaders() {
  var user_data = JSON.parse(sessionStorage.getItem('user_data'));

  return { 'Api-Token': user_data['api_token'] };
}

function preventMainFormSubmit(e) {
  if (e.keyCode == 13) { return false; }
}
