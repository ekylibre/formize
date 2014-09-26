(function ($) {
    
    $(document).behave("load", "input[data-autocomplete]", function () {
        var element = $(this);
        element.autocomplete({
            source: element.data("autocomplete"),
            minLength: parseInt(element.data("min-length") || 1)
        });
    });

})(jQuery);
