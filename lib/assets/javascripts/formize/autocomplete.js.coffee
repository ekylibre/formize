(($) ->
  $(document).behave "load", "input[data-autocomplete]", ->
    element = $(this)
    element.autocomplete
      source: element.data("autocomplete")
      minLength: parseInt(element.data("min-length") or 1)

    return

  return
) jQuery
