

///////////////
// customSliderInput
////////////////////

 var customSliderInputBinding = $.extend({}, Shiny.inputBindings.bindingNames['shiny.sliderInput'].binding, {
  find: function(scope) {
    // Check if ionRangeSlider plugin is loaded
    if (!$.fn.ionRangeSlider)
      return [];

    return $(scope).find('input.customSliderInput');
  },
    subscribe: function(el, callback) {
    $(el).on('focusout.customSliderInputBinding', function(event) {
      callback(!$(el).data('immediate') && !$(el).data('animating'));
});
  },
  unsubscribe: function(el) {
    $(el).off('.customSliderInputBinding');
  },
  getRatePolicy: function() {
    return {
      policy: customSliderPolicy,
      delay: customSliderDelay
    };
}});

Shiny.inputBindings.register(customSliderInputBinding, 'shiny.customSliderInput');

$(document).on('focusout', '.irs', function(event) {
  var sliderInput = this.nextSibling;
  $(sliderInput).trigger("focusout");
});


/////////////////
// custom numeric input
////////////////

var customNumberInputBinding = $.extend({}, Shiny.inputBindings.bindingNames['shiny.numberInput'].binding, {
  find: function(scope) {
   return $(scope).find('input.customNumericInput');
  },
  subscribe: function(el, callback) {
  $(el).on('keyup.customNumberInputBinding input.customNumberInputBinding', function(event) {
               if(event.keyCode == 13) { //if enter
                callback();
               }
             });
            $(el).on('focusout.customNumberInputBinding', function(event) { // on losing focus
              callback();
            });
            },
  unsubscribe: function(el) {
            $(el).off('.customNumberInputBinding');
            },
  getRatePolicy: function() {
    return {
      policy: customNumericPolicy,
      delay: customNumericDelay
    };
}});

Shiny.inputBindings.register(customNumberInputBinding, 'shiny.customNumericInput');

//////////////////////////////////////////
// custom textInput with limited reactivity,
// inspired by https://gist.github.com/xiaodaigh/7150112
//////////////////////////////////////////

var customTextInputBinding = $.extend({}, Shiny.inputBindings.bindingNames['shiny.textInput'].binding, {
              find: function(scope) {
                return $(scope).find('input.customTextInput');
              },
              subscribe: function(el, callback) {
                $(el).on('keyup.customTextInputBinding input.customTextInputBinding', function(event) {
                  if(event.keyCode == 13) { //if enter
              callback();
                }
                });
              $(el).on('focusout.customTextInputBinding', function(event) { // on losing focus
                  callback();
                });
              },
              unsubscribe: function(el) {
                $(el).off('.customTextInputBinding');
              },
              getRatePolicy: function() {
                return {
                  policy: customTextPolicy,
                  delay: customTextDelay
                };
              }
});

Shiny.inputBindings.register(customTextInputBinding, 'shiny.customTextInput');
