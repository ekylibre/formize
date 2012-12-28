(function ($) {

    $.Behave = {};
    $.Behave.sequence = 0;
    $.Behave.loads = [];

    // Refresh one behaviour
    $.Behave.refreshOne = function (behaviour) {
	var element;
        behaviour.ref.find(behaviour.selector).each(function(index){
	    element = $(this);
            if (element.prop('alreadyBound'+behaviour.key) !== true) {
		behaviour.handler.call(element);
		element.prop('alreadyBound'+behaviour.key, true);
	    }
        });
    }

    // Refresh all behaviours
    $.Behave.refresh = function () {
	$.each($.Behave.loads, function (index, behaviour) {
	    $.Behave.refreshOne(behaviour);
        });
    }

    // Same API as .on(). Takes in account load events.
    $.fn.behave = function (events, selector, data, handler) {
	var ref = $(this);
	$.each(events.split(/\s+/ig), function(index, event) {
	    var behaviour;
            if (event === "load") {
		behaviour = {ref: ref, selector: selector, data: data, handler: handler, key: $.Behave.sequence*7};
                $.Behave.loads.push(behaviour);
		$.Behave.refreshOne(behaviour);
		$.Behave.sequence += 1;
            } else {
		this.on(events, selector, data, handler);
            }
        }
    }

    // Rebinds unbound elements on each ajax request.
    $(document).ajaxComplete($.Behave.refresh);

})(jQuery);
