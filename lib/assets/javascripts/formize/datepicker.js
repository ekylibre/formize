//= require jquery-ui/datepicker
//= require jquery-ui/datepicker/af
//= require jquery-ui/datepicker/ar-DZ
//= require jquery-ui/datepicker/ar
//= require jquery-ui/datepicker/az
//= require jquery-ui/datepicker/be
//= require jquery-ui/datepicker/bg
//= require jquery-ui/datepicker/bs
//= require jquery-ui/datepicker/ca
//= require jquery-ui/datepicker/cs
//= require jquery-ui/datepicker/cy-GB
//= require jquery-ui/datepicker/da
//= require jquery-ui/datepicker/de-CH
//= require jquery-ui/datepicker/de
//= require jquery-ui/datepicker/el
//= require jquery-ui/datepicker/en-AU
//= require jquery-ui/datepicker/en-GB
//= require jquery-ui/datepicker/en-NZ
//= require jquery-ui/datepicker/eo
//= require jquery-ui/datepicker/es
//= require jquery-ui/datepicker/et
//= require jquery-ui/datepicker/eu
//= require jquery-ui/datepicker/fa
//= require jquery-ui/datepicker/fi
//= require jquery-ui/datepicker/fo
//= require jquery-ui/datepicker/fr-CA
//= require jquery-ui/datepicker/fr-CH
//= require jquery-ui/datepicker/fr
//= require jquery-ui/datepicker/gl
//= require jquery-ui/datepicker/he
//= require jquery-ui/datepicker/hi
//= require jquery-ui/datepicker/hr
//= require jquery-ui/datepicker/hu
//= require jquery-ui/datepicker/hy
//= require jquery-ui/datepicker/id
//= require jquery-ui/datepicker/is
//= require jquery-ui/datepicker/it
//= require jquery-ui/datepicker/ja
//= require jquery-ui/datepicker/ka
//= require jquery-ui/datepicker/kk
//= require jquery-ui/datepicker/km
//= require jquery-ui/datepicker/ko
//= require jquery-ui/datepicker/ky
//= require jquery-ui/datepicker/lb
//= require jquery-ui/datepicker/lt
//= require jquery-ui/datepicker/lv
//= require jquery-ui/datepicker/mk
//= require jquery-ui/datepicker/ml
//= require jquery-ui/datepicker/ms
//= require jquery-ui/datepicker/nb
//= require jquery-ui/datepicker/nl-BE
//= require jquery-ui/datepicker/nl
//= require jquery-ui/datepicker/nn
//= require jquery-ui/datepicker/no
//= require jquery-ui/datepicker/pl
//= require jquery-ui/datepicker/pt-BR
//= require jquery-ui/datepicker/pt
//= require jquery-ui/datepicker/rm
//= require jquery-ui/datepicker/ro
//= require jquery-ui/datepicker/ru
//= require jquery-ui/datepicker/sk
//= require jquery-ui/datepicker/sl
//= require jquery-ui/datepicker/sq
//= require jquery-ui/datepicker/sr
//= require jquery-ui/datepicker/sr-SR
//= require jquery-ui/datepicker/sv
//= require jquery-ui/datepicker/ta
//= require jquery-ui/datepicker/th
//= require jquery-ui/datepicker/tj
//= require jquery-ui/datepicker/tr
//= require jquery-ui/datepicker/uk
//= require jquery-ui/datepicker/vi
//= require jquery-ui/datepicker/zh-CN
//= require jquery-ui/datepicker/zh-HK
//= require jquery-ui/datepicker/zh-TW

(function ($) {
    'use strict';
/*
    $.datepicker.regional['en']  = $.datepicker.regional['en-GB'];

    $.datepicker.regional['arb'] = $.datepicker.regional['ar'];
    $.datepicker.regional['eng'] = $.datepicker.regional['en'];
    $.datepicker.regional['fra'] = $.datepicker.regional['fr'];
    $.datepicker.regional['jpn'] = $.datepicker.regional['ja'];
    $.datepicker.regional['spa'] = $.datepicker.regional['es'];
*/

    // Initializes date fields
    $(document).behave('focusin click keyup change', 'input[data-datepicker]', function() {
        var element = $(this), locale, options = {}, name, hidden;
        if (element.prop("datepickerLoaded") !== "Yes!") {
            locale = element.data("date-locale");
            if ($.datepicker.regional[locale] === null || $.datepicker.regional[locale] === undefined) {
                locale = "en";
            }
            $.datepicker.setDefaults( $.datepicker.regional[locale] );

	    hidden = $('#' + element.data('datepicker'));

            options['dateFormat']  = element.data("date-format");
            options['altField']    = hidden;
            options['altFormat']   = 'yy-mm-dd';
            options['defaultDate'] = element.val();

            // Check for dependents
            if (hidden.data('dependents') !== undefined && hidden.data('dependents') !== null) {
                if (hidden.data('observe') === undefined || hidden.data('observe') === null) {
	            hidden.attr('data-observe', '1000');
                }
            }
            element.datepicker(options);
            element.prop("datepickerLoaded", "Yes!");
        }
    });

    // Initializes date fields
		       /*
    $(document).behave('focusin click keyup change', 'input[data-datepicker]', function() {
	var element, locale, altField, triggered;
	element = $(this);
	locale = element.data('locale');
        if ($.datepicker.regional[locale] === null || $.datepicker.regional[locale] === undefined) {
            locale = 'en';
        }
        $.datepicker.setDefaults( $.datepicker.regional[locale] );
	element.datepicker();
	if (element.data('date-format') !== null) {
	    element.datepicker('option', 'dateFormat', element.data('date-format'));
	}
	altField = '#' + element.data('datepicker');
	element.datepicker('option', 'altField', altField);
	element.datepicker('option', 'altFormat', 'yy-mm-dd');
	element.datepicker('option', 'defaultDate', element.val());
	// Check for dependents
	triggered = $(altField);
	if (triggered.data('dependents') !== undefined && triggered.data('dependents') !== null) {
	    if (triggered.data('observe') === undefined || triggered.data('observe') === null) {
		triggered.attr('data-observe', '1000');
	    }
	}
    });
*/
})(jQuery);
