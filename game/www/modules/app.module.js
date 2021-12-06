angular.module('app', [
    'ionic',
    'app.service',
    'app.manutenzione',
    'app.intro',
    'app.login',
    'app.dashboard',
    'app.instructions',
    'app.game',
    'app.summary',
    'app.classifica',
    'app.special_story',
    'app.special_instructions',
    'app.special_game',
    'app.right_answer',
    'app.special_summary',
    'app.device'
])

.run(function ($ionicPlatform) {
    $ionicPlatform.ready(function () {
        if (window.cordova && window.cordova.plugins.Keyboard) {
            // Hide the accessory bar by default (remove this to show the accessory bar above the keyboard
            // for form inputs)
            // Don't remove this line unless you know what you are doing. It stops the viewport
            // from snapping when text inputs are focused. Ionic handles this internally for
            // a much nicer keyboard experience.
            cordova.plugins.Keyboard.hideKeyboardAccessoryBar(true);
            cordova.plugins.Keyboard.disableScroll(true);
        }

        if (window.StatusBar) {
            StatusBar.styleDefault();
        }
    });
})

.config([
    '$stateProvider',
    '$cookiesProvider',
    '$urlRouterProvider',
    '$ionicConfigProvider',
    function(
        $stateProvider,
        $cookiesProvider,
        $urlRouterProvider,
        $ionicConfigProvider) {

            // Cookie Default
            var exp = new Date(new Date().getFullYear(), new Date().getMonth()+6, new Date().getDate());
            $cookiesProvider.defaults = { expires: exp };

            $ionicConfigProvider.views.transition('none');

            // disable Ionic View Chache
            $ionicConfigProvider.views.maxCache(0);

            $stateProvider

                .state('manutenzione', {
                    url: '/manutenzione',
                    templateUrl: "modules/manutenzione/view.manutenzione.html",
                    controller: "ManutenzioneController"
                })
            
                .state('intro', {
                    url: '/intro',
                    templateUrl: "modules/intro/view.intro.html",
                    controller: "IntroController"
                })

                .state('login', {
                    url: '/login',
                    templateUrl: "modules/login/view.login.html",
                    controller: "LoginController"
                })

                .state('dashboard', {
                    url: '/dashboard',
                    templateUrl: "modules/dashboard/view.dashboard.html",
                    controller: "DashboardController"
                })

                .state('instructions', {
                    url: '/level/:level/game/:game/instructions',
                    templateUrl: "modules/level/instructions/view.instructions.html",
                    controller: "InstructionsController"
                })

                .state('game', {
                    url: '/level/:level/game/:game/play',
                    templateUrl: "modules/level/game/view.game.html",
                    controller: "GameController"
                })

                .state('summary', {
                    url: '/level/:level/summary/:summary',
                    templateUrl: "modules/level/summary/view.summary.html",
                    controller: "SummaryController"
                })

                .state('classifica', {
                    url: '/classifica',
                    templateUrl: "modules/classifica/view.classifica.html",
                    controller: "ClassificaController"
                })

                .state('special_instrucitions', {
                    url: '/special/:special_level/instructions',
                    templateUrl: "modules/special/instructions/view.instructions.html",
                    controller: "SpecialInstructionsController"
                })

                 .state('special_instructions_2', {
                    url: '/special/:special_level/instructions_2',
                    templateUrl: "modules/special/instructions_2/view.instructions_2.html",
                    controller: "SpecialInstructionsController"
                })
                .state('special_story', {
                    url: '/special/:special_level/story',
                    templateUrl: "modules/special/story/view.story.html",
                    controller: "SpecialStoryController"
                })

                .state('special_game', {
                    url: '/special/:special_level/play',
                    templateUrl: "modules/special/game/view.game.html",
                    controller: "SpecialGameController"
                })
                .state('right_answer', {
                    url: '/special/:special_level/right_answer/?=:score',
                    templateUrl: "modules/special/right_answer/view.right_answer.html",
                    controller: "RightAnswerController"
                })

                .state('special_summary', {
                    url: '/special/:special_level/summary/?=:score',
                    templateUrl: "modules/special/summary/view.summary.html",
                    controller: "SpecialSummaryController"
                })

                .state('device', {
                    url: '/not-compatible',
                    templateUrl: "modules/device/view.device.html",
                    controller: "DeviceController"
                })

            $urlRouterProvider.otherwise('/intro');

    }
])

.directive('customMd', function() {
    return {
        restrict: "A",
        link: function(scope, element, attrs) {
            scope.contentUrl = './partials/'+ attrs.type +'/_'+ attrs.name +'.html';
            attrs.$observe("name",function(name){
                scope.contentUrl = './partials/'+ attrs.type +'/_'+ name +'.html';
            });
        },
        template: '<div ng-include="contentUrl"></div>'
    };
})

.controller('AppController', [
    '$state',
    '$scope',
    '$cookies',
    '$auth',
    '$level',
    function (
        $state,
        $scope,
        $cookies,
        $auth,
        $level
    ) {

            // APP CONTROLLER
            
            var is_maintenance = false;

            $scope.currState = $scope.currView = $state;
            
            if(is_maintenance) $state.transitionTo('manutenzione', null, {reload: true});

            $scope.$watch('currState.current.name', function(newValue, oldValue) {

                var currState = $scope.currView = newValue;
                
                if(is_maintenance) $state.transitionTo('manutenzione', null, {reload: true});

                $(window).on('load', function(){
                    $("#app-frame").fadeTo(1400, 1);
                });

                if (typeof(Storage) === "undefined") {
                    // Sorry! No Web Storage support..
                    $state.transitionTo('device', null, {reload: true});
                }

                if(currState != 'login' && currState != 'intro' && currState != 'device' && currState != 'manutenzione') {

                    $level.getData().then(function(response) {

                        $scope.game_step_data = response.data;
                    });

                    if(localStorage.getItem('user_data')) {

                        $scope.user_data = JSON.parse(localStorage.getItem('user_data'));

                        $scope.level = Math.floor(($scope.user_data.curr_game_id - 1) / 2);
                        $scope.game = ($scope.user_data.curr_game_id - 1) % 2;

                        if($scope.user_data.role == 2 || ($scope.user_data.role == 3 && $scope.user_data.team_code != "") ) {

                            $scope.is_special_user = true;

                        } else {

                            $scope.is_special_user = false;
                        }

                        $auth.login($scope.user_data.name, $scope.user_data.surname, $scope.user_data.app_code, $scope.user_data.team_code, $scope.user_data.area_code).then(function(response) {

                            var user_data = response.data;
                            user_data.app_code = $scope.user_data.app_code;
                            user_data.points = parseInt(user_data.points);
                            user_data.seconds = parseInt(user_data.seconds);

                            $scope.user_data = user_data;
                            localStorage.setItem('user_data', JSON.stringify(user_data));

                        }, function(err) {

                            $state.go('login');
                        });

                    } else {

                        $state.go('login');
                    }
                }

                if(currState == 'login' || currState == 'intro' ||
                   currState == 'device' || currState == 'game' ||
                   currState == 'dashboard' || currState == 'special_game' ||
                   currState == 'manutenzione') {

                    $(".link_home").hide();

                } else {

                    $(".link_home").show();
                }

            });

            // Help Popup
            $scope.help = function() { $scope.showModal = true; }
            $scope.closeModal = function() { $scope.showModal = false; }

            var cachedWidth = $(window).width(),
                alert = false;

            if(cachedWidth < 1024) {
                $state.transitionTo('device', null, {reload: true});
            }

            $(window).resize(function() {

                var currentWidth = $(window).width();

                if(cachedWidth != currentWidth && currentWidth < 1024) {

                    alert = true;
                    $state.transitionTo('device', null, {reload: true});

                } else if(cachedWidth >= 1024 && alert) {

                    alert = false;
                    $("#app-frame").removeAttr('style');
                    $("#app-frame").css({ 'opacity': 1 });
                    $state.transitionTo('dashboard', null, {reload: true});
                }
                cachedWidth = currentWidth;
            });

            document.addEventListener("orientationchange", function(event){
                switch(window.orientation)
                {
                    case -90: case 90:
                        //landscape
                        $state.transitionTo('dashboard', null, {reload: true});
                        break;
                    default:
                        $state.transitionTo('device', null, {reload: true});
                        break;
                }
            });
    }
]);
