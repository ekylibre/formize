(($) ->
  "use strict"
  Formize = {}
  Formize.refreshDependents = (event) ->
    element = $(this)
    params = {}
    dependents = undefined
    paramName = undefined
    if element.val() isnt null and element.val() isnt `undefined`
      dependents = element.attr("data-dependents")
      paramName = element.attr("data-parameter-name") or element.attr("id") or "value"
      params[paramName] = element.val()
      $(dependents).each (index, item) ->
        
        # Replaces element
        url = $(item).attr("data-refresh")
        mode = $(item).attr("data-refresh-mode") or "replace"
        if url isnt null
          $.ajax url,
            data: params
            success: (data, textStatus, response) ->
              if mode is "update"
                $(item).html response.responseText
              else if mode is "update-value"
                if element.data("attribute")
                  $(item).val $.parseJSON(data)[element.data("attribute")]
                else
                  $(item).val response.responseText
              else
                $(item).replaceWith response.responseText
              return

            error: (jqXHR, textStatus, errorThrown) ->
              alert "FAILURE (Error " + textStatus + "): " + errorThrown
              return

        return

      return true
    false

  
  # Refresh dependents on changes
  $(document).behave "change emulated:change", "*[data-dependents]", Formize.refreshDependents
  
  # Compensate for changes made with keyboard
  $(document).behave "keypress", "select[data-dependents]", Formize.refreshDependents
  return
) jQuery
