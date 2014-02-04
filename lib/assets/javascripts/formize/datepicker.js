//= require jquery.ui.datepicker
//= require locales/jquery.ui.datepicker-af
//= require locales/jquery.ui.datepicker-ar-DZ
//= require locales/jquery.ui.datepicker-ar
//= require locales/jquery.ui.datepicker-az
//= require locales/jquery.ui.datepicker-be
//= require locales/jquery.ui.datepicker-bg
//= require locales/jquery.ui.datepicker-bs
//= require locales/jquery.ui.datepicker-ca
//= require locales/jquery.ui.datepicker-cs
//= require locales/jquery.ui.datepicker-cy-GB
//= require locales/jquery.ui.datepicker-da
//= require locales/jquery.ui.datepicker-de-CH
//= require locales/jquery.ui.datepicker-de
//= require locales/jquery.ui.datepicker-el
//= require locales/jquery.ui.datepicker-en-AU
//= require locales/jquery.ui.datepicker-en-GB
//= require locales/jquery.ui.datepicker-en-NZ
//= require locales/jquery.ui.datepicker-eo
//= require locales/jquery.ui.datepicker-es
//= require locales/jquery.ui.datepicker-et
//= require locales/jquery.ui.datepicker-eu
//= require locales/jquery.ui.datepicker-fa
//= require locales/jquery.ui.datepicker-fi
//= require locales/jquery.ui.datepicker-fo
//= require locales/jquery.ui.datepicker-fr-CA
//= require locales/jquery.ui.datepicker-fr-CH
//= require locales/jquery.ui.datepicker-fr
//= require locales/jquery.ui.datepicker-gl
//= require locales/jquery.ui.datepicker-he
//= require locales/jquery.ui.datepicker-hi
//= require locales/jquery.ui.datepicker-hr
//= require locales/jquery.ui.datepicker-hu
//= require locales/jquery.ui.datepicker-hy
//= require locales/jquery.ui.datepicker-id
//= require locales/jquery.ui.datepicker-is
//= require locales/jquery.ui.datepicker-it
//= require locales/jquery.ui.datepicker-ja
//= require locales/jquery.ui.datepicker-ka
//= require locales/jquery.ui.datepicker-kk
//= require locales/jquery.ui.datepicker-km
//= require locales/jquery.ui.datepicker-ko
//= require locales/jquery.ui.datepicker-ky
//= require locales/jquery.ui.datepicker-lb
//= require locales/jquery.ui.datepicker-lt
//= require locales/jquery.ui.datepicker-lv
//= require locales/jquery.ui.datepicker-mk
//= require locales/jquery.ui.datepicker-ml
//= require locales/jquery.ui.datepicker-ms
//= require locales/jquery.ui.datepicker-nb
//= require locales/jquery.ui.datepicker-nl-BE
//= require locales/jquery.ui.datepicker-nl
//= require locales/jquery.ui.datepicker-nn
//= require locales/jquery.ui.datepicker-no
//= require locales/jquery.ui.datepicker-pl
//= require locales/jquery.ui.datepicker-pt-BR
//= require locales/jquery.ui.datepicker-pt
//= require locales/jquery.ui.datepicker-rm
//= require locales/jquery.ui.datepicker-ro
//= require locales/jquery.ui.datepicker-ru
//= require locales/jquery.ui.datepicker-sk
//= require locales/jquery.ui.datepicker-sl
//= require locales/jquery.ui.datepicker-sq
//= require locales/jquery.ui.datepicker-sr
//= require locales/jquery.ui.datepicker-sr-SR
//= require locales/jquery.ui.datepicker-sv
//= require locales/jquery.ui.datepicker-ta
//= require locales/jquery.ui.datepicker-th
//= require locales/jquery.ui.datepicker-tj
//= require locales/jquery.ui.datepicker-tr
//= require locales/jquery.ui.datepicker-uk
//= require locales/jquery.ui.datepicker-vi
//= require locales/jquery.ui.datepicker-zh-CN
//= require locales/jquery.ui.datepicker-zh-HK
//= require locales/jquery.ui.datepicker-zh-TW

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