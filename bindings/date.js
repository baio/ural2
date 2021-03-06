// Generated by CoffeeScript 1.6.2
(function() {
  define(function() {
    var _setDate;

    ko.bindingHandlers.datetime = {
      init: function(element, valueAccessor, allBindingsAccessor) {
        var dateFormat, dmaxRule, dminRule, maxDate, minDate, opts;

        if (valueAccessor().extend && valueAccessor().extend().rules) {
          dminRule = valueAccessor().extend().rules().filter(function(f) {
            return f.rule === "min";
          })[0];
          if (dminRule) {
            minDate = moment(dminRule.params).toDate();
          }
          dmaxRule = valueAccessor().extend().rules().filter(function(f) {
            return f.rule === "max";
          })[0];
          if (dmaxRule) {
            maxDate = moment(dmaxRule.params).toDate();
          }
        }
        opts = allBindingsAccessor().datetimeOpts;
        dateFormat = opts && opts.dateFormat ? opts.dateFormat : "dd.mm.yy";
        $(element).datepicker({
          minDate: minDate,
          maxDate: maxDate,
          dateFormat: dateFormat,
          beforeShow: function(el) {
            if ($(el).attr('readonly')) {
              return false;
            } else {
              return true;
            }
          }
        });
        ko.utils.registerEventHandler(element, "change", function() {
          var date, observable;

          observable = valueAccessor();
          date = $(element).datepicker("getDate");
          return observable(date);
        });
        return ko.utils.domNodeDisposal.addDisposeCallback(element, function() {
          return $(element).datepicker("destroy");
        });
      },
      update: function(element, valueAccessor) {
        var value;

        value = ko.utils.unwrapObservable(valueAccessor());
        $(element).datepicker("setDate", value ? value : null);
        return valueAccessor()($(element).datepicker("getDate"));
      }
    };
    _setDate = function(element, date, format) {
      if (format == null) {
        format = "DD MMMM YYYY";
      }
      return $(element).text(date ? moment(date).format(format) : "");
    };
    return ko.bindingHandlers.displaydate = {
      init: function(element, valueAccessor, allBindingsAccessor) {
        var format, option, valAccessor;

        option = allBindingsAccessor().ddateOpts;
        if (option) {
          format = option.format;
        }
        valAccessor = valueAccessor();
        _setDate(element, ko.utils.unwrapObservable(valAccessor), format);
        if (ko.isObservable(valAccessor)) {
          return valAccessor.subscribe(function(newValue) {
            return _setDate(element, newValue, format);
          });
        }
      }
    };
  });

}).call(this);

/*
//@ sourceMappingURL=date.map
*/
