// Generated by CoffeeScript 1.6.2
(function() {
  define(["ural/vm/itemVM", "ural/modules/pubSub"], function(itemVM, pubSub) {
    var ViewModel;

    return ViewModel = (function() {
      function ViewModel(resource) {
        var _this = this;

        this.resource = resource;
        this.list = ko.observableArray();
        pubSub.sub("crud", "complete_create", function(item) {
          return _this.completeCreate(item);
        });
        pubSub.sub("crud", "complete_delete", function(item) {
          return _this.completeDelete(item);
        });
        this.initHotKeys();
      }

      ViewModel.prototype.completeDelete = function(item) {
        if (item.resource === this.resource) {
          return this.list.remove(item.src.item);
        }
      };

      ViewModel.prototype.completeCreate = function(item) {
        if (item.resource === this.resource) {
          item.setSrc(null, null);
          return this.list.push(item);
        }
      };

      ViewModel.prototype.add = function(data, idx) {
        var item;

        item = this.createItem(data);
        item.startEdit();
        if (idx === !void 0) {
          idx = this.list().length - 1;
        }
        this.list.splice(idx, 0, item);
        this.updateIsModifyed();
        return this.listenItemIsModifyed(item);
      };

      ViewModel.prototype.map = function(data) {
        var d, underlyingArray, _i, _len;

        underlyingArray = this.list();
        underlyingArray.splice(0, underlyingArray.length);
        for (_i = 0, _len = data.length; _i < _len; _i++) {
          d = data[_i];
          underlyingArray.push(this.createItem(d));
        }
        return this.list.valueHasMutated();
      };

      ViewModel.prototype.load = function(filter, done) {
        var _this = this;

        return this.onLoad(filter, function(err, data) {
          if (!err) {
            _this.map(data);
          }
          return done(err, _this);
        });
      };

      ViewModel.prototype.onLoad = function(filter, done) {
        return done(null, []);
      };

      ViewModel.prototype.save = function() {
        return this.update(function() {});
      };

      ViewModel.prototype.update = function(done) {
        var item, list, res, _i, _len,
          _this = this;

        res = [];
        this.list.remove(function(item) {
          return item._isAdded() && item._isRemoved();
        });
        list = this._isModifyedActivated ? this.getModifyedItems() : this.list();
        if (!list.length) {
          done();
          return;
        }
        for (_i = 0, _len = list.length; _i < _len; _i++) {
          item = list[_i];
          if (item.toData) {
            res.push(item.toData());
          } else {
            res.push(item);
          }
        }
        return this.onUpdate(res, function(err, r) {
          var i, _j, _ref;

          if (!err) {
            for (i = _j = 0, _ref = r.length - 1; 0 <= _ref ? _j <= _ref : _j >= _ref; i = 0 <= _ref ? ++_j : --_j) {
              item = list[i];
              if (r[i].err.length === 0) {
                if (item._isRemoved()) {
                  _this.list.remove(item);
                } else {
                  if (itemVM.KeyFieldName) {
                    item[itemVM.KeyFieldName](r[i][itemVM.KeyFieldName]);
                  }
                  item.startEdit();
                }
              } else {
                item.setErrors(err);
              }
            }
            _this.updateIsModifyed();
          }
          return done(err);
        });
      };

      ViewModel.prototype.onUpdate = function(data, done) {
        return done(null);
      };

      ViewModel.prototype.createItem = function(data, status) {
        var vm;

        vm = this.onCreateItem();
        if (data) {
          vm.map(data);
        }
        if (status) {
          vm.setSrc(null, status);
        }
        return vm;
      };

      ViewModel.prototype.onCreateItem = function() {
        return new itemVM(this.resource, this);
      };

      ViewModel.prototype.startCreate = function(some, event) {
        if (event) {
          event.preventDefault();
        }
        return pubSub.pub("crud", "start", {
          resource: this.resource,
          item: this.createItem(this.resource, "create"),
          type: "create"
        });
      };

      ViewModel.prototype.activateIsModifyed = function() {
        var item, _i, _len, _ref, _results;

        this._isModifyed(false);
        _ref = this.list();
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          item = _ref[_i];
          item.activateIsModifyed();
          _results.push(this.listenItemIsModifyed(item));
        }
        return _results;
      };

      ViewModel.prototype.listenItemIsModifyed = function(item) {
        var _this = this;

        if (this._isModifyedActivated) {
          return item._isModifyed.subscribe(function(val) {
            return _this.updateIsModifyed(val);
          });
        }
      };

      ViewModel.prototype.updateIsModifyed = function(val) {
        var f;

        if (this._isModifyedActivated) {
          f = val || this.getIsModifyed();
          return this._isModifyed(f);
        }
      };

      ViewModel.prototype.getIsModifyed = function() {
        var item, _i, _len, _ref;

        _ref = this.list();
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          item = _ref[_i];
          if (item._isModifyed()) {
            return true;
          }
        }
        return false;
      };

      ViewModel.prototype.getModifyedItems = function() {
        var item, res, _i, _len, _ref;

        res = [];
        _ref = this.list();
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          item = _ref[_i];
          if (item._isModifyed()) {
            res.push(item);
          }
        }
        return res;
      };

      ViewModel.prototype.startEdit = function() {
        if (ko.isObservable(this._isModifyed)) {
          if (!this._isModifyedActivated) {
            this._isModifyedActivated = true;
            return this.activateIsModifyed();
          }
        }
      };

      ViewModel.prototype.initHotKeys = function() {
        var _this = this;

        return Mousetrap.bindGlobal('+', function() {
          _this.startCreate();
          return false;
        });
      };

      return ViewModel;

    })();
  });

}).call(this);

/*
//@ sourceMappingURL=indexVM.map
*/