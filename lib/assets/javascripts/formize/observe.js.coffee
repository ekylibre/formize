(($) ->
  
  # Observes fields comparing its value with fixed intervals of time
  # Compensates not quite sure "change" events.
  $(document).behave "load", "*[data-observe]", ->
    element = $(this)
    interval = parseInt(element.data("observe"))
    interval = 1000  if interval is null or interval is `undefined`
    if element.get(0).nodeName.toLowerCase() isnt "input"
      alert "data-observe attribute must be only used with <input>s."
      return false
    element.previousObservedValue = element.val()
    window.setInterval (->
      if element.val() isnt element.previousObservedValue
        element.trigger "emulated:change"
        element.previousObservedValue = element.val()
      return
    ), interval
    true

  return
) jQuery
