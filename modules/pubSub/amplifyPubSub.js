// Generated by CoffeeScript 1.3.3
(function() {

  define(function() {
    return {
      pub: function(target, topic, data) {
        return amplify.publish("" + target + "_" + topic, data);
      },
      sub: function(target, topic, callback) {
        return amplify.subscribe("" + target + "_" + topic, callback);
      }
    };
  });

}).call(this);