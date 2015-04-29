
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});

Parse.Cloud.define("getUser", function(request, response) {
  var query = new Parse.Query(Parse.User);
  query.equalTo("objectId", request.params.userId)

  query.find({
    success: function(user) {
      response.success(user)
    },
    error: function(error) {
      response.error(error);
    }
  });
});
