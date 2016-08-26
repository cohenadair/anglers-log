(function() {
     var app = angular.module("anglers-log", ['ngSanitize']);
    
     app.controller("AppController", ["$anchorScroll", function($anchorScroll) {
          this.name = "Anglers' Log";
          this.description = "Track, analyze, share.";
          this.appleUrl = "https://itunes.apple.com/CA/app/id959989008";
          this.appleBadge = "img/appstore.svg";
          this.androidUrl = "https://play.google.com/store/apps/details?id=com.cohenadair.anglerslog";
          this.playBadge = "img/googleplay.png"
          this.deviceUrl = "img/phones.png";
          this.socialUrl = "social/social-icons.html";
          this.currentPlatform = "android";
          this.navItems = [
               {
                    name: "Contact",
                    href: "#contact"
               },
               {
                    name: "FAQ",
                    href: "#faq"
               }
          ];
          this.platformNav = [
               {
                    name: "iOS",
                    isActive: false
               },
               {
                    name: "Android",
                    isActive: true
               }
          ];
          this.contentItems = [
               {
                    name: "Frequently Asked Questions",
                    id: "faq",
                    tableOfContents: true,
                    infoItems: [
                         {
                              title: "How do I provide feedback, request features, or report a bug?",
                              template: "faq/in-app-feedback-ios.html",
                              id: "in-app-feedback",
                              platform: "ios"
                         },
                         {
                              title: "How do I provide feedback, request features, or report a bug?",
                              template: "faq/in-app-feedback-android.html",
                              id: "in-app-feedback",
                              platform: "android"
                         },
                         {
                              title: "My camera just shows a black screen. What do I do?",
                              template: "faq/black-camera.html",
                              id: "black-camera",
                              platform: "ios"
                         },
                         {
                              title: "How do I transfer my entries to a new device?",
                              template: "faq/data-transfer-ios.html",
                              id: "data-transfer",
                              platform: "ios"
                         },
                         {
                              title: "How do I transfer my data to a new device?",
                              template: "faq/data-transfer-android.html",
                              id: "data-transfer",
                              platform: "android"
                         },
                         {
                              title: "How do I export or import my entries?",
                              template: "faq/import-export-ios.html",
                              id: "import-export",
                              platform: "ios"
                         },
                         {
                              title: "How do I export or import my data?",
                              template: "faq/import-export-android.html",
                              id: "import-export",
                              platform: "android"
                         },
                         {
                              title: "Importing and Exporting Errors",
                              template: "faq/import-export-errors.html",
                              id: "backup-errors",
                              platform: "ios"
                         },
                         {
                              title: "I'm getting an error code message. What do I do?",
                              template: "faq/other-errors.html",
                              id: "other-errors",
                              platform: "ios"
                         },
                         {
                              title: "How can I sign up for Anglers' Log beta testing?",
                              template: "faq/beta-testing_new.html",
                              id: "beta-testing",
                              platform: "both"
                         },
                         {
                              title: "Is Anglers' Log going to be available for Windows Phone or Blackberry?",
                              template: "faq/windows-blackberry.html",
                              id: "windows-blackberry",
                              platform: "both"
                         }
                    ]
               },
               {
                    name: "Contact",
                    id: "contact",
                    tableOfContents: false,
                    infoItems: [
                         {
                              title: "Bugs, Suggestions, or Feedback",
                              template: "faq/in-app-feedback-ios.html",
                              id: "",
                              platform: "ios"
                         },
                         {
                              title: "Bugs, Suggestions, or Feedback",
                              template: "faq/in-app-feedback-android.html",
                              id: "",
                              platform: "android"
                         },
                         {
                              title: "Direct Contact",
                              template: "faq/direct-contact.html",
                              id: "",
                              platform: "both"
                         }
                    ]
               }
          ];

          this.scrollTo = function(anchor) {
               $('html, body').animate({scrollTop: $(anchor).offset().top - 15}, 'slow');
          };

          this.shouldShowItem = function(item) {
               return item.platform == "both" || item.platform == this.currentPlatform;
          };

          this.onClickPlatform = function(index) {
               // set all nav items to inactive
               for (var i in this.platformNav)
                    this.platformNav[i].isActive = false;
                    
               // activate the one that was clicked
               this.platformNav[index].isActive = true;

               // reset current platform so the correct items are displayed
               this.currentPlatform = this.platformNav[index].name.toLowerCase();
          };
     }]);
})();




