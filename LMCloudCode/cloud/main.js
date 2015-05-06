
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

Parse.Cloud.define("checkIfUserHasAssociatedChat", function(request, response) {
  var query = new Parse.Query("LMChat");
  query.equalTo("groupId", request.params.groupId)
  query.equalTo("senderId", request.params.userId)

  query.find({
      success: function() {
        response.success();
      },
      error: function(user) {
        response.error
      }
  });
});

Parse.Cloud.define("createChatForUser", function(request, response){

});
