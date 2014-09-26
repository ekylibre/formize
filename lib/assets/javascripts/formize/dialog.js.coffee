#= require formize/behave

((F, $) ->
  "use strict"

  F.dialog =
    count: 0

  F.dialog.open = (url, settings) ->
    frame_id = "dialog-#{F.dialog.count}"
    width = $(document).width()
    defaultSettings =
      header: "X-Return-Code"
      width: 0.6
      height: 0.8
    settings = {} if settings is null or settings is `undefined`
    settings = $.extend({}, defaultSettings, settings)
    data = settings.data or {}
    data.dialog = frame_id
    $.ajax url,
      data: data
      success: (data, status, request) ->
        frame = $(document.createElement("div"))
        width = undefined
        height = undefined
        frame.attr
          id: frame_id
          class: "dialog ajax-dialog"
          style: "display:none;"

        $("body").append frame
        frame.html data
        frame.prop "dialogSettings", settings
        if settings.width is 0
          width = "auto"
        else if settings.width < 1
          width = $(window).width() * settings.width
        else
          width = settings.width
        if settings.height is 0
          height = "auto"
        else if settings.height < 1
          height = $(window).height() * settings.height
        else
          height = settings.height
        frame.dialog
          autoOpen: false
          show: "fade"
          modal: true
          width: width
          height: height
        F.dialog.initialize frame
        frame.dialog "open"

      error: (request, status, error) ->
        console.warn "Cannot get dialog content (#{status}): #{error}"
        frame = $("##{frame_id}")
        frame.dialog "close"
        frame.remove()

    F.dialog.count += 1


  F.dialog.initialize = (frame) ->
    frame_id = frame.attr("id")
    title = frame.prop("dialogSettings").title
    if title is null or title is `undefined`
      h1 = $("##{frame_id} h1")
      if h1[0] isnt null and h1[0] isnt `undefined`
        title = h1.text()
        h1.remove()
    frame.dialog "option", "title", title
    $("##{frame_id} form").each (index, form) ->
      $(form).attr "data-dialog", frame_id

  F.dialog.submitForm = ->
    form = $(this)
    frame_id = undefined
    frame = undefined
    settings = undefined
    field = undefined
    frame_id = form.data("dialog")
    frame = $("##{frame_id}")
    settings = frame.prop("dialogSettings")
    field = $(document.createElement("input"))
    field.attr
      type: "hidden"
      name: "dialog"
      value: frame_id

    form.append field
    $.ajax form.attr("action"),
      type: form.attr("method") or "POST"
      data: form.serialize()
      success: (data, status, request) ->
        returnCode = request.getResponseHeader(settings.header)
        returns = settings.returns
        unknownReturnCode = true
        code = undefined
        for code of returns
          if returns.hasOwnProperty(code) and returnCode is code and $.isFunction(returns[code])
            returns[code].call form, frame, data, status, request
            unknownReturnCode = false
            F.dialog.initialize frame
            break
        if unknownReturnCode
          if $.isFunction(settings.defaultReturn)
            settings.defaultReturn.call form, frame
          else
            alert "FAILURE (Unknown return code for header #{settings.header}): #{returnCode}"
      error: (request, status, error) ->
        alert "FAILURE (#{status}): #{error}"
        frame = $("##{frame_id}")
        frame.dialog "close"
        frame.remove()

    
    # if ($.isFunction(settings.error)) { settings.error.call(form, frame, request, status, errorThrown); }
    false

  
  # Submits dialog forms
  $(document).on "submit", ".form[data-dialog]", F.dialog.submitForm

) formize, jQuery
