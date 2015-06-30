// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

/* This will be run whenever the Pull Requests page or Deploy page (for some functionality)
 * is opened or refreshed. It will automatically call of the below functions on all of the
 * variables that are in the URL of the page. The below pieces are all about sorting
 * the data on the page based on state (open or closed), order (newest first
 * or oldest first), and the grouping (by repo or user).
 */
$(document).ready(function() {
  queryParameters = getUrlVars();
  setDefaults(queryParameters);
  activeLabels(queryParameters);
  initLabels(queryParameters)
  changeColors();

  $("#state-group > .btn").on("click", function(){
    updateQueryStringParameter(queryParameters,"state",$(this).attr('id'));
  });

  $("#sort-group > .btn").on("click", function(){
    updateQueryStringParameter(queryParameters,"order",$(this).attr('id'));
  });

  $("#group-by").on("change", function(){
    updateQueryStringParameter(queryParameters,"group",$(this)[0].value);
  });

  $("#repos").change(function() {
    var ids = $("#repos").val();
    updateQueryStringParameter(queryParameters,"repos",ids);
  });
  
  $("#users").change(function() {
    var ids = $("#users").val();
    updateQueryStringParameter(queryParameters,"users",ids);
  });
});

/**
 * updateQueryStringParameter
 * @params - queryParameters, key, value
 * Updates the string paramters based on the specifications in the URL.
 */
function updateQueryStringParameter(queryParameters, key, value) {
  var uri = document.location.pathname;
  if (!queryParameters[key])
    queryParameters.push(key)
  queryParameters[key] = value;

  var i;
  for (i = 0; i < queryParameters.length; i++) {
    var separator = uri.indexOf('?') !== -1 ? "&" : "?";
    var value = queryParameters[i];
    if (queryParameters[value].length >= 1)
      uri = (uri + separator + value + '=' + queryParameters[value]);
  }

  document.location.href = uri
}

/* getUrlVars
 * Gets all of the variables that are in the URL.
 */
function getUrlVars() {
  var vars = [], hash;
  if (window.location.href.indexOf('?') > 0) {
    var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');

    for (var i = 0; i < hashes.length; i++) {
      hash = hashes[i].split('=');
      vars.push(hash[0]);
      vars[hash[0]] = decodeURIComponent(hash[1]);
    }
  }
  return vars;
}

/* setDefaults
 * @params - queryParameters
 * Sets the state, order, and grouping to be 'default', or all, descending, and non-grouped.
 */
function setDefaults(queryParameters) {
  if (queryParameters["state"])
    $('#' + queryParameters["state"]).addClass('active');
  else 
    $('#all').addClass('active');

  if (queryParameters["order"])
    $('#' + queryParameters["order"]).addClass('active');
  else
    $('#desc').addClass('active');

  if (queryParameters["group"])
    $('#group-by').val(queryParameters["group"]);
}

/* initLabels
 * @params - queryParameters
 * Takes the query parameters and if there are labels as a parameter, then assigns 
 * the background colors to the labels that are highlighted.
 */
function initLabels (queryParameters) {
  if (queryParameters["label"]) {
    var labels = queryParameters["label"].split(',');

    $("#labels-container .btn-label").each( function() {
      var color = '#' + $(this).data("color");
      if ($.inArray( $(this).children().eq(1).data("label") , labels ) >= 0) {
        $(this).addClass("active");
        $(this).css('background-color',color);
        $(this).css("color", isDark($(this).css("background-color")) ? 'white' : 'black');
      }
    });
  }
}

/* changeColors
 * Adds the colors to the labels on the list of labels and when labeling the pull requests.
 */
function changeColors () {
  $(".color-label").each( function() {
    var color = '#' + $(this)[0].title;
    $(this).css('background-color',color)
    $(this).css("color", isDark($(this).css("background-color")) ? 'white' : 'black');
  });

  $("#labels-container .btn-label").each( function() {
    var color = '#' + $(this).data("color");
    $(this).children().eq(0).css('background-color',color);
  });
}

/* activeLabels
 * Shows only the labels that are assigned to a pull request that is currently being shown;
 * whether a PR is being shown is dependent on what state (closed, open, or all) the data is showing.
 */
function activeLabels () {
  $("#labels-container .btn-label").click(function () {
    $(this).toggleClass("active");

    var labels = '';
    $("#labels-container").children().each( function() {
      if ($(this).hasClass('active')) {
        var separator = (labels.length == 0 ? '' : ',');
        labels = labels + separator + $(this).children().eq(1).data('label');
      }
    });
    updateQueryStringParameter(queryParameters,"label",labels);
  });
}

/* isDark
 * @params - color
 * Edits the color of the text if the label color is dark.
 */
function isDark(color) {
    var match = /rgb\((\d+).*?(\d+).*?(\d+)\)/.exec(color);
    return parseFloat(match[1])
         + parseFloat(match[2])
         + parseFloat(match[3])
           < 3 * 256 / 2;
}
