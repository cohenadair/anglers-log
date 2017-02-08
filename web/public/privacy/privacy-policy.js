(function() {
    var app = angular.module("anglers-log", ['ngSanitize']);

    app.controller("AppController", function($scope) {
        $scope.effectiveDate;

        $.ajax({
            url: "https://anglerslog.ca/app-settings.json",
            type: "GET",
            dataType: "json",
            success: function(data) {
                $scope.effectiveDate = new Date(data.privacyPolicyEffectiveUtcDate);
            }
        });

        $scope.formatEffectiveDate = function() {
            return moment($scope.effectiveDate).format("MMMM Do, YYYY");
        }
    });
})();