(($) ->
  
  # Initializes unroll inputs
  $(document).behave "load", "input[data-unroll]", ->
    element = $(this)
    choices = undefined
    paramName = undefined
    element.unrollCache = element.val()
    element.autocompleteType = "text"
    element.valueField = $("#" + element.attr("data-value-container"))[0]
    if $.isEmptyObject(element.valueField)
      alert "An input " + element.id + " with a \"data-unroll\" attribute must contain a \"data-value-container\" attribute"
      element.autocompleteType = "id"
    element.maxResize = parseInt(element.attr("data-max-resize"))
    element.maxResize = 64  if isNaN(element.maxResize) or element.maxResize is 0
    element.size = ((if element.unrollCache.length < 32 then 32 else (if element.unrollCache.length > element.maxResize then element.maxResize else element.unrollCache.length)))
    element.autocomplete
      source: element.attr("data-unroll")
      minLength: 1
      select: (event, ui) ->
        selected = ui.item
        element.valueField.value = selected.id
        element.unrollCache = selected.label
        element.attr "size", ((if element.unrollCache.length < 32 then 32 else (if element.unrollCache.length > element.maxResize then element.maxResize else element.unrollCache.length)))
        $(element.valueField).trigger "emulated:change"
        true

    return

  return
) jQuery
