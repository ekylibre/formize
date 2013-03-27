//= require formize-behave

(function ($) {
    "use strict";

    $.ajaxDialogCount = 0;

    $.ajaxDialog = function (url, settings) {
        var frame_id = "dialog-" + $.ajaxDialogCount, width = $(document).width(), data, defaultSettings;
        defaultSettings = {
            header: "X-Return-Code",
            width: 0.6,
            height: 0.8
        };
        if (settings === null || settings === undefined) { settings = {}; }
        settings = $.extend({}, defaultSettings, settings);
	data = settings.data || {};
	data.dialog = frame_id;
        $.ajax(url, {
            data: data,
            success: function(data, textStatus, jqXHR) {
                var frame = $(document.createElement('div')), width, height;
                frame.attr({id: frame_id, 'class': 'dialog ajax-dialog', style: 'display:none;'});
                $('body').append(frame);
                frame.html(data);
                frame.prop("dialogSettings", settings);
                if (settings.width === 0) {
                    width = 'auto';
                } else if (settings.width < 1) {
                    width = $(window).width() * settings.width;
                } else {
                    width = settings.width;
                }
                if (settings.height === 0) {
                    height = 'auto';
                } else if (settings.height < 1) {
                    height = $(window).height() * settings.height;
                } else {
                    height = settings.height;
                }
                frame.dialog({
                    autoOpen: false,
                    show: 'fade',
                    modal: true,
                    width: width,
                    height: height
                });
                $.ajaxDialogInitialize(frame);
                frame.dialog("open");
            },
            error: function(jqXHR, textStatus, errorThrown) {
                alert("FAILURE (Error " + textStatus + "): " + errorThrown);
                var frame = $("#" + frame_id);
                frame.dialog("close");
                frame.remove();                
            }
        });
        $.ajaxDialogCount += 1;
    };

    $.ajaxDialogInitialize = function(frame) {
        var frame_id = frame.attr("id"), title = frame.prop("dialogSettings").title, h1;
        if (title === null || title === undefined) {
            h1 = $("#" + frame_id + " h1");
            if (h1[0] !== null && h1[0] !== undefined) {
                title = h1.text();
                h1.remove();
            }
        }
        frame.dialog("option", "title", title);
        
        $("#" + frame_id + " form").each(function (index, form) {
            $(form).attr('data-dialog', frame_id);
        });
        
    };

    $.submitAjaxForm = function () {
        var form = $(this), frame_id, frame, settings, field;
        frame_id = form.attr('data-dialog');
        frame = $('#'+frame_id);
        settings = frame.prop("dialogSettings");
        
        field = $(document.createElement('input'));
        field.attr({ type: 'hidden', name: 'dialog', value: frame_id });
        form.append(field);

        $.ajax(form.attr('action'), {
            type: form.attr('method') || 'POST',
            data: form.serialize(),
            success: function(data, textStatus, request) {
                var returnCode = request.getResponseHeader(settings.header), returns = settings.returns, unknownReturnCode = true, code;
                for (code in returns) {
                    if (returns.hasOwnProperty(code) && returnCode === code && $.isFunction(returns[code])) {
                        returns[code].call(form, frame, data, textStatus, request);
                        unknownReturnCode = false;
                        $.ajaxDialogInitialize(frame);
                        break;
                    }
                }
                if (unknownReturnCode) {
                    if ($.isFunction(settings.defaultReturn)) {
                        settings.defaultReturn.call(form, frame);
                    } else {
                        alert("FAILURE (Unknown return code for header " + settings.header + "): " + returnCode);
                    }
                }
            },
            error: function(jqXHR, textStatus, errorThrown) {
                alert("FAILURE (Error " + textStatus + "): " + errorThrown);
                var frame = $("#" + frame_id);
                frame.dialog("close");
                frame.remove();                
                // if ($.isFunction(settings.error)) { settings.error.call(form, frame, jqXHR, textStatus, errorThrown); }
            }
        });
        return false;
    };

    // Submits dialog forms
    $(document).behave("submit", ".ajax-dialog form[data-dialog]", $.submitAjaxForm);


})(jQuery);
