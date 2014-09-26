(function ($) {
    
    // Opens a dialog for a resource creation
    $(document).behave("click", "a[data-add-item]", function() {
        var element = $(this);
        var list_id = '#'+element.data('add-item'), list = $(list_id);
        var url = element.attr('href');
        $.ajaxDialog(url, {
            returns: {
                success: function (frame, data, textStatus, request) {
                    var record_id = request.getResponseHeader("X-Saved-Record-Id");
                    if (list[0] !== undefined) {
                        $.ajax(list.attr('data-refresh'), {
                            data: {selected: record_id},
                            success: function(data, textStatus, request) {
                                list.replaceWith(request.responseText);
                                $(list_id + ' input').trigger("emulated:change");
                            }
                        });
                    }
                    frame.dialog("close");
                },
                invalid: function (frame, data, textStatus, request) {
                    frame.html(request.responseText);
                }
            },
        });
        return false;
    });
    

})(jQuery);
