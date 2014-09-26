((F, $) ->
  "use strict"

  F.behave =
    sequence: 0
    loads: []
  
  # Refresh one behaviour
  F.behave.refreshOne = (behaviour) ->
    element = undefined
    behaviour.ref.find(behaviour.selector).each (index) ->
      item = $(this)
      if item.prop("alreadyBound" + behaviour.key) isnt true
        behaviour.handler.call item
        item.prop "alreadyBound" + behaviour.key, true

  
  # Refresh all behaviours
  F.behave.refresh = ->
    $.each F.behave.loads, (index, behaviour) ->
      F.behave.refreshOne behaviour

  
  # Same API as .on(). Takes in account load events.
  $.fn.behave = (events, selector, handler) ->
    ref = $(this)
    $.each events.split(/\s+/g), (index, event) ->
      behaviour = undefined
      if event is "load"
        behaviour =
          ref: ref
          selector: selector
          handler: handler
          key: F.behave.sequence

        F.behave.loads.push behaviour
        F.behave.refreshOne behaviour
        F.behave.sequence += 7
      else
        ref.on events, selector, handler

    
  # Retro-compatibility
  $.behave = (selector, events, handler) ->
    $(document).behave events, selector, handler
  
  # Rebinds unbound elements on each ajax request.
  $(document).ajaxComplete F.behave.refresh
  
  # Compatibility with Cocoon and Turbolinks
  $(document).on "cocoon:after-insert page:change", (event) ->
    F.behave.refresh()

) formize, jQuery
