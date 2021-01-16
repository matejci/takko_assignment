"use strict";

$(document).on('ready turbolinks:load', function() {
  $("#home_btn").on('click', handleHomeBtn);

});

function handleHomeBtn(e) {
  console.log(e);
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
