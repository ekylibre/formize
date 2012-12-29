(function ($) {
    "use strict";

    var Formize = {};

    Formize.refreshDependents = function (event) {
        var element = $(this), params = {}, dependents, paramName;

        if (element.val() !== null && element.val() !== undefined) {
            dependents = element.attr('data-dependents');
            paramName = element.attr('data-parameter-name') || element.attr('id') || 'value';
            params[paramName] = element.val();
            $(dependents).each(function (index, item) {
                // Replaces element
                var url = $(item).attr('data-refresh'), mode = $(item).attr('data-refresh-mode') || 'replace';
                if (url !== null) {
                    $.ajax(url, {
                        data: params,
                        success: function (data, textStatus, response) {
                            if (mode === 'update') {
                                $(item).html(response.responseText);
                            } else if (mode === 'update-value') {
                                if (element.data("attribute")) {
                                    $(item).val($.parseJSON(data)[element.data("attribute")]);
                                } else {
                                    $(item).val(response.responseText);
                                }
                            } else {
                                $(item).replaceWith(response.responseText);
                            }
                        },
                        error: function (jqXHR, textStatus, errorThrown) {
                            alert("FAILURE (Error " + textStatus + "): " + errorThrown);
                        }
                    });
                }
            });
            return true;
        }
        return false;
    };

    // Refresh dependents on changes
    $(document).behave("change emulated:change", "*[data-dependents]", Formize.refreshDependents);
    // Compensate for changes made with keyboard
    $(document).behave("keypress", "select[data-dependents]", Formize.refreshDependents);

})(jQuery);


