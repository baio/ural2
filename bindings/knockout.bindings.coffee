define ->

  ko.bindingHandlers.validationCss =

    init: (element, valueAccessor) ->
      observable = valueAccessor()
      f = false
      _setClass = (val) ->
        if !val
          $(element).addClass "error"
        else
          $(element).removeClass "error"

      observable.isModified.subscribe ->
        f = true
        _setClass observable.isValid()

      observable.isValid.subscribe (val) ->
        #skip first apperance
        if f then _setClass val

      ko.utils.domNodeDisposal.addDisposeCallback element, ->
        $(element).removeClass "error"

  ko.bindingHandlers.validation =

    init: (element, valueAccessor, allBindingsAccessor) ->
      all = allBindingsAccessor()
      prop =
        if all.value
          all.value
        else if all.autocomplete
          all.autocomplete
        else if all.datetime
          all.datetime
      if prop
        validation = valueAccessor()
        validation = [validation] if !Array.isArray validation
        for v in validation
          prop.extend v

  ko.bindingHandlers.val =

    init: (element, valueAccessor, allBindingsAccessor) ->
      #http://stackoverflow.com/questions/12643455/knockout-js-extending-value-binding-with-interceptor
      underlyingObservable = valueAccessor()
      valOpts = allBindingsAccessor().valOpts
      #type = if valOpts and valOpts.type then valOpts.type else "int"
      #format = valOpts.format if valOpts and valOpts.type
      $(element).inputmask('decimal', radixPoint : ',', autoUnmask : true, clearMaskOnLostFocus: true )
      interceptor = ko.computed
        read: =>
          val = if ko.isObservable underlyingObservable then underlyingObservable() else underlyingObservable
          if val
            val = val.toString()
            val.replace ".", ","
        write: (val) =>
          fmtVal = parseFloat val.replace ",", "."
          underlyingObservable fmtVal
        deferEvaluation : true
      ko.applyBindingsToNode element, value : interceptor
