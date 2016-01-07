//////////////////
// some utility functions from shiny.js
//////////////

function formatDateUTC(date) {
  if (date instanceof Date) {
    return date.getUTCFullYear() + '-' +
           padZeros(date.getUTCMonth()+1, 2) + '-' +
           padZeros(date.getUTCDate(), 2);

  } else {
    return null;
  }
}

function padZeros(n, digits) {
  var str = n.toString();
  while (str.length < digits)
    str = "0" + str;
  return str;
}

///////////////
// customSliderInput
////////////////////

 var customSliderInputBinding = new Shiny.InputBinding();
$.extend(customSliderInputBinding, {
  find: function(scope) {
    // Check if ionRangeSlider plugin is loaded
    if (!$.fn.ionRangeSlider)
      return [];

    return $(scope).find('input.customSliderInput');
  },
  // modified from textInputBinding in shiny.js
  getId: function(el) {
    return Shiny.InputBinding.prototype.getId.call(this, el) || el.name;
  },
  // back to copying from shiny.js
  getType: function(el) {
    var dataType = $(el).data('data-type');
    if (dataType === 'date')
      return 'shiny.date';
    else if (dataType === 'datetime')
      return 'shiny.datetime';
    else
      return false;
  },
  getValue: function(el) {
    var $el = $(el);
    var result = $(el).data('ionRangeSlider').result;

    // Function for converting numeric value from slider to appropriate type.
    var convert;
    var dataType = $el.data('data-type');
    if (dataType === 'date') {
      convert = function(val) {
        return formatDateUTC(new Date(+val));
      };
    } else if (dataType === 'datetime') {
      convert = function(val) {
        // Convert ms to s
        return +val / 1000;
      };
    } else {
      convert = function(val) { return +val; };
    }

    if (this._numValues(el) == 2) {
      return [convert(result.from), convert(result.to)];
    }
    else {
      return convert(result.from);
    }

  },
  setValue: function(el, value) {
    var slider = $(el).data('ionRangeSlider');

    if (this._numValues(el) == 2 && value instanceof Array) {
      slider.update({ from: value[0], to: value[1] });
    } else {
      slider.update({ from: value });
    }
  },
  subscribe: function(el, callback) {
    $(el).on('change.customSliderInputBinding update.customSliderInputBinding', function(event) {
     callback(!$(el).data('updating') && !$(el).data('animating'));
    });
  },
  unsubscribe: function(el) {
    $(el).off('.customSliderInputBinding');
  },
  receiveMessage: function(el, data) {
    var $el = $(el);
    var slider = $el.data('ionRangeSlider');
    var msg = {};

    if (data.hasOwnProperty('value')) {
      if (this._numValues(el) == 2 && data.value instanceof Array) {
        msg.from = data.value[0];
        msg.to = data.value[1];
      } else {
        msg.from = data.value;
      }
    }
    if (data.hasOwnProperty('min'))  msg.min   = data.min;
    if (data.hasOwnProperty('max'))  msg.max   = data.max;
    if (data.hasOwnProperty('step')) msg.step  = data.step;

    if (data.hasOwnProperty('label'))
      $el.parent().find('label[for="' + $escape(el.id) + '"]').text(data.label);

    $el.data('updating', true);
    try {
      slider.update(msg);
    } finally {
      $el.data('updating', false);
    }
  },
  // here's the one we modify:
  getRatePolicy: function() {
    return {
      policy: customSliderPolicy,
      delay: customSliderDelay
    };
  },
  //back to copying
  getState: function(el) {
  },
  initialize: function(el) {
    var opts = {};
    var $el = $(el);
    var dataType = $el.data('data-type');
    var timeFormat = $el.data('time-format');
    var timeFormatter;

    // Set up formatting functions
    if (dataType === 'date') {
      timeFormatter = strftime.utc();
      opts.prettify = function(num) {
        return timeFormatter(timeFormat, new Date(num));
      };

    } else if (dataType === 'datetime') {
      var timezone = $el.data('timezone');
      if (timezone)
        timeFormatter = strftime.timezone(timezone);
      else
        timeFormatter = strftime;

      opts.prettify = function(num) {
        return timeFormatter(timeFormat, new Date(num));
      };
    }

    $el.ionRangeSlider(opts);
  },

  // Number of values; 1 for single slider, 2 for range slider
  _numValues: function(el) {
    if ($(el).data('ionRangeSlider').options.type === 'double')
      return 2;
    else
      return 1;
  }
});

// finally, we register::
Shiny.inputBindings.register(customSliderInputBinding, 'shiny.customSliderInput');


/////////////////
// custom numeric input
////////////////

var customNumberInputBinding = new Shiny.InputBinding();
$.extend(customNumberInputBinding, {
  find: function(scope) {
   // return $(scope).find('input[type="customNumber"]');
   return $(scope).find('input.customnumber');
  },
  getValue: function(el) {
    var numberVal = $(el).val();
    if (/^\s*$/.test(numberVal))  // Return null if all whitespace
      return null;
    else if (!isNaN(numberVal))   // If valid Javascript number string, coerce to number
      return +numberVal;
    else
      return numberVal;           // If other string like "1e6", send it unchanged
  },
  setValue: function(el, value) {
    el.value = value;
  },
  getType: function(el) {
    return "shiny.number";
  },
  receiveMessage: function(el, data) {
    if (data.hasOwnProperty('value'))  el.value = data.value;
    if (data.hasOwnProperty('min'))    el.min   = data.min;
    if (data.hasOwnProperty('max'))    el.max   = data.max;
    if (data.hasOwnProperty('step'))   el.step  = data.step;

    if (data.hasOwnProperty('label'))
      $(el).parent().find('label[for="' + $escape(el.id) + '"]').text(data.label);

    $(el).trigger('change');
  },
  getState: function(el) {
    return { label: $(el).parent().find('label[for="' + $escape(el.id) + '"]').text(),
             value: this.getValue(el),
             min:   Number(el.min),
             max:   Number(el.max),
             step:  Number(el.step) };
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
  }

});
Shiny.inputBindings.register(customNumberInputBinding, 'shiny.customNumericInput');

//////////////////////////////////////////
// custom textInput with limited reactivity,
// slightly modified from https://gist.github.com/xiaodaigh/7150112
//////////////////////////////////////////

var customTextInputBinding = new Shiny.InputBinding();
              $.extend(customTextInputBinding, {
              find: function(scope) {
              return $(scope).find('.customTextInput');
              },
              getId: function(el) {
              //return InputBinding.prototype.getId.call(this, el) || el.name;
              return $(el).attr('id');
              },
              getValue: function(el) {
              return el.value;
              },
              setValue: function(el, value) {
              el.value = value;
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
              receiveMessage: function(el, data) {
              if (data.hasOwnProperty('value'))
              this.setValue(el, data.value);

              if (data.hasOwnProperty('label'))
              $(el).parent().find('label[for=' + el.id + ']').text(data.label);

              $(el).trigger('change');
              },
              getState: function(el) {
              return {
              label: $(el).parent().find('label[for=' + el.id + ']').text(),
              value: el.value
              };
              },
              getRatePolicy: function() {
              return {
              policy: customTextPolicy,
              delay: customTextDelay
              };
              }
              });
              Shiny.inputBindings.register(customTextInputBinding, 'shiny.customTextInput');
