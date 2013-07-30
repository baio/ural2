define ->

  ko.bindingHandlers.tooltip =

    init: (element, valueAccessor) ->

      $(element).tooltip title : ->
        val = ko.utils.unwrapObservable valueAccessor()
        if $.isArray
          val.join ('\n')
        else
          val

      ko.utils.domNodeDisposal.addDisposeCallback element, ->
        $(element).tooltip "hide"
        $(element).triggerHandler("destroyed")



