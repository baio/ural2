define  ["ural/modules/pubSub"], (pubSub) ->

  ko.bindingHandlers.link =

    init: (element, valueAccessor) ->

      $(element).bind "click", (e) ->
        e.preventDefault()
        href = $(element).attr "href"
        href = href.replace /^#/, ""
        value = ko.utils.unwrapObservable valueAccessor()
        if value and !$.isEmptyObject(value)
          value = JSON.stringify(value) if $.isPlainObject value
          href = href + "/" + value
        pubSub.pub "href", "change", href : href

      ko.utils.domNodeDisposal.addDisposeCallback element, ->
        $(element).unbind "click"