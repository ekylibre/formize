(function($) {
    // Initializes unroll inputs
    $(document).behave('load', 'input[data-unroll]', function() {
        var element = $(this), choices, paramName;
        
        element.unrollCache = element.val();
        element.autocompleteType = "text";
        element.valueField = $('#'+element.attr('data-value-container'))[0];
        if ($.isEmptyObject(element.valueField)) {
            alert('An input '+element.id+' with a "data-unroll" attribute must contain a "data-value-container" attribute');
            element.autocompleteType = "id";
        }
        element.maxResize = parseInt(element.attr('data-max-resize'));
        if (isNaN(element.maxResize) || element.maxResize === 0) { element.maxResize = 64; }
        element.size = (element.unrollCache.length < 32 ? 32 : element.unrollCache.length > element.maxResize ? element.maxResize : element.unrollCache.length);
        
        element.autocomplete({
            source: element.attr('data-unroll'),
            minLength: 1,
            select: function(event, ui) {
                var selected = ui.item;
                element.valueField.value = selected.id;
                element.unrollCache = selected.label;
                element.attr("size", (element.unrollCache.length < 32 ? 32 : element.unrollCache.length > element.maxResize ? element.maxResize : element.unrollCache.length));
                $(element.valueField).trigger("emulated:change");
                return true;
            }
        });
    });
})(jQuery);
