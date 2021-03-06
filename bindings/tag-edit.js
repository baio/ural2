// Generated by CoffeeScript 1.6.2
(function() {
  var __hasProp = {}.hasOwnProperty;

  define(function() {
    var gOpts, _filterFields, _filterParams;

    gOpts = {
      baseUrl: null,
      data: {
        term: "Trem"
      },
      fields: {
        label: function(d) {
          if (d.FullName) {
            return d.FullName;
          } else {
            return d.Name;
          }
        },
        value: "Name",
        key: "Id"
      }
    };
    _filterFields = function(viewModel, fields) {
      var data, field;

      data = {};
      for (field in fields) {
        if (!__hasProp.call(fields, field)) continue;
        data[field] = viewModel[fields[field]]();
      }
      return data;
    };
    _filterParams = function(filterParams) {
      var data, field;

      data = {};
      for (field in filterParams) {
        if (!__hasProp.call(filterParams, field)) continue;
        data[field] = filterParams[field]();
      }
      return data;
    };
    ko.bindingHandlers.tagedit = {
      init: function(element, valueAccessor, allBindingsAccessor, viewModel) {
        var gopts, opts, _data;

        gopts = gOpts;
        opts = allBindingsAccessor().tageditOpts;
        gopts = $.extend(gopts, opts);
        _data = [];
        $(element).tagit({
          tagSource: function(req, res) {
            var data;

            data = {};
            data[gopts.data.term] = req.term;
            if (opts.filterFields) {
              data = $.extend(false, data, _filterFields(viewModel, opts.filterFields));
            }
            if (opts.filterParams) {
              data = $.extend(false, data, _filterParams(opts.filterParams));
            }
            return $.ajax({
              url: gopts.baseUrl + opts.url,
              data: data,
              dataType: "json",
              success: function(data) {
                var m;

                m = data.map(function(d) {
                  return {
                    data: d,
                    label: $.isFunction(gopts.fields.label) ? gopts.fields.label(d) : ko.utils.unwrapObservable(d[gopts.fields.label]),
                    value: $.isFunction(gopts.fields.value) ? gopts.fields.value(d) : ko.utils.unwrapObservable(d[gopts.fields.value]),
                    key: $.isFunction(gopts.fields.key) ? gopts.fields.key(d) : ko.utils.unwrapObservable(d[gopts.fields.key])
                  };
                });
                _data = m;
                return res(m);
              },
              minLength: 2
            });
          },
          afterTagAdded: function(event, ui) {
            var d;

            if (ui.duringInitialization) {
              return;
            }
            console.log("tag added " + ui.duringInitialization);
            d = _data.filter(function(f) {
              return f.value === ui.tagLabel;
            })[0];
            if (!d) {
              if (gopts.getDefault) {
                d = gopts.getDefault(ui.tagLabel);
              } else {
                d = ui.tagLabel;
              }
            }
            if (gopts.toData) {
              d = gopts.toData(d);
            }
            $(element).data("tag-it.frozen", true);
            valueAccessor().push(d);
            $(element).data("tag-it.frozen", false);
            return console.log(d);
          },
          afterTagRemoved: function(event, ui) {
            var d;

            if (gopts.fields.label) {
              d = ko.utils.arrayFirst(valueAccessor()(), function(item) {
                return item[gopts.fields.label]() === ui.tagLabel;
              });
              $(element).data("tag-it.frozen", true);
              valueAccessor().remove(d);
              $(element).data("tag-it.frozen", false);
            }
            return console.log(ui);
          }
        });
        return ko.utils.domNodeDisposal.addDisposeCallback(element, function() {
          console.log("destroy");
          return $(element).tagit("destroy");
        });
      },
      update: function(element, valueAccessor, allBindingsAccessor) {
        var assignedTags, gopts, label, opts, valLabels, value, _i, _j, _len, _len1, _results;

        if ($(element).data("tag-it.frozen")) {
          return;
        }
        gopts = gOpts;
        opts = allBindingsAccessor().tageditOpts;
        gopts = $.extend(gopts, opts);
        value = ko.utils.unwrapObservable(valueAccessor());
        if (value.length) {
          valLabels = value.map(function(m) {
            if ($.isFunction(gopts.fields.label)) {
              return gopts.fields.label(m);
            } else {
              return m[gopts.fields.label]();
            }
          });
          assignedTags = $(element).tagit("assignedTags");
          for (_i = 0, _len = assignedTags.length; _i < _len; _i++) {
            label = assignedTags[_i];
            if (valLabels.indexOf(label) === -1) {
              $(element).tagit("removeTag", label, null, true);
            }
          }
          assignedTags = $(element).tagit("assignedTags");
          _results = [];
          for (_j = 0, _len1 = valLabels.length; _j < _len1; _j++) {
            label = valLabels[_j];
            if (assignedTags.indexOf(label) === -1) {
              _results.push($(element).tagit("createTag", label, null, true));
            } else {
              _results.push(void 0);
            }
          }
          return _results;
        } else {
          return $(element).tagit("removeAll");
        }
      }
    };
    return gOpts;
  });

}).call(this);

/*
//@ sourceMappingURL=tag-edit.map
*/
