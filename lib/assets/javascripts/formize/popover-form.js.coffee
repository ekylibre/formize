(($) ->
  
  # Opens a dialog for a resource creation
  $(document).behave "click", "a[data-add-item]", ->
    element = $(this)
    list_id = "#" + element.data("add-item")
    list = $(list_id)
    url = element.attr("href")
    $.ajaxDialog url,
      returns:
        success: (frame, data, textStatus, request) ->
          record_id = request.getResponseHeader("X-Saved-Record-Id")
          if list[0] isnt `undefined`
            $.ajax list.attr("data-refresh"),
              data:
                selected: record_id

              success: (data, textStatus, request) ->
                list.replaceWith request.responseText
                $(list_id + " input").trigger "emulated:change"
                return

          frame.dialog "close"
          return

        invalid: (frame, data, textStatus, request) ->
          frame.html request.responseText
          return

    false

  return
) jQuery
