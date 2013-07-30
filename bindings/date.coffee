define ->

  ko.bindingHandlers.datetime =

    init: (element, valueAccessor, allBindingsAccessor) ->
      #initialize datepicker with some optional options
      if valueAccessor().extend and valueAccessor().extend().rules
        dminRule = valueAccessor().extend().rules().filter((f) -> f.rule == "min")[0]
        minDate = moment(dminRule.params).toDate() if dminRule
        dmaxRule = valueAccessor().extend().rules().filter((f) -> f.rule == "max")[0]
        maxDate = moment(dmaxRule.params).toDate() if dmaxRule

      opts = allBindingsAccessor().datetimeOpts

      dateFormat = if opts and opts.dateFormat then opts.dateFormat else "dd.mm.yy"

      $(element).datepicker
        minDate: minDate
        maxDate: maxDate
        dateFormat: dateFormat
        beforeShow: (el) ->
          return if $(el).attr('readonly') then false else true

      #handle the field changing
      ko.utils.registerEventHandler element, "change", ->
        observable = valueAccessor()
        date = $(element).datepicker "getDate"
        observable date

      #handle disposal (if KO removes by the template binding)
      ko.utils.domNodeDisposal.addDisposeCallback element, ->
        $(element).datepicker "destroy"

    update: (element, valueAccessor) ->
      value = ko.utils.unwrapObservable(valueAccessor())
      $(element).datepicker "setDate", if value then value else null
      valueAccessor()($(element).datepicker "getDate")

  _setDate = (element, date, format) ->
    format ?= "DD MMMM YYYY"
    $(element).text if date then moment(date).format(format) else ""

  ko.bindingHandlers.displaydate =
    init: (element, valueAccessor, allBindingsAccessor) ->
      option = allBindingsAccessor().ddateOpts
      format =  option.format if option
      valAccessor = valueAccessor()
      _setDate element, ko.utils.unwrapObservable(valAccessor), format
      if ko.isObservable valAccessor
        valAccessor.subscribe (newValue) ->
          _setDate element, newValue, format
