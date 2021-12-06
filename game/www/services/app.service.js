angular.module('app.service', [])

.factory('$auth', ['$http', function($http) {
   
    return {
        login: function(name, surname, app_code, team_code, area_code) {
            return $http({
                method: 'POST',
                url: 'https://usale.it/api/user/login',
                headers: {
                    'Authorization': 'Bearer '+app_code,
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                },
                data: { name: name, surname: surname, app_code: app_code, team_code: team_code, area_code: area_code }
            });
        },
        updateUserGame: function(app_code, game_id, special_game_id) {
            return $http({
                method: 'PUT',
                url: 'https://usale.it/api/user',
                headers: {
                    'Authorization': 'Bearer '+app_code,
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                },
                data: { curr_game_id: game_id, curr_special_game_id: special_game_id }
            });
        },
        reserUser: function(app_code, user_id) {
            return $http({
                method: 'POST',
                url: 'https://usale.it/api/user/reset',
                headers: {
                    'Authorization': 'Bearer '+app_code,
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                },
                data: { name: name, surname: surname, app_code: app_code, team_code: team_code, area_code: area_code }
            });
        }
    }
    
}])

.factory('$level', ['$http', function($http) {
   
    return {
        getData: function() {
            return $http({
                method: 'GET',
                url: './services/data/game_step.json',
                headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                },
                data: {}
            });
        },
        createSession: function(app_code, id) {
            return $http({
                method: 'POST',
                url: 'https://usale.it/api/game-sessions?expand=taken_items_ids',
                headers: {
                    'Authorization': 'Bearer '+app_code,
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                },
                data: { game_id: id }
            });
        },
        updateSession: function(app_code, session_id) {
            return $http({
                method: 'PUT',
                url: 'https://usale.it/api/game-sessions/'+session_id,
                headers: {
                    'Authorization': 'Bearer '+app_code,
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                },
                data: {}
            });
        },
        getSession: function(app_code) {
            return $http({
                method: 'GET',
                url: 'https://usale.it/api/game-sessions',
                headers: {
                    'Authorization': 'Bearer '+app_code,
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                },
                data: {}
            });
        },
        addAction: function(app_code, game_id, item_id, points) {
            return $http({
                method: 'POST',
                url: 'https://usale.it/api/game-actions',
                headers: {
                    'Authorization': 'Bearer '+app_code,
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                },
                data: {game_id: game_id, item_id: item_id, points: points}
            });
        },
        getAction: function(app_code) {
            return $http({
                method: 'GET',
                url: 'https://usale.it/api/game-actions',
                headers: {
                    'Authorization': 'Bearer '+app_code,
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                },
                data: {}
            });
        }
    }
    
}])

.factory('$chart', ['$http', function($http) {
    
    return {
        getChart: function(app_code, name) {
            return $http({
                method: 'GET',
                url: 'https://usale.it/api/scoreboard',
                headers: {
                    'Authorization': 'Bearer '+app_code,
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                },
                data: { name: name }
            });
        }
    }
}])

.factory('$special', ['$http', function($http) {
   
    return {
        updateTeamScore: function(app_code, special_game_id, multiplier) {
            return $http({
                method: 'POST',
                url: 'https://usale.it/api/point-multipliers',
                headers: {
                    'Authorization': 'Bearer '+app_code,
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                },
                data: { special_game_id: special_game_id, multiplier: multiplier }
            });
        },
        getTeamMultiplier: function(app_code) {
            return $http({
                method: 'GET',
                url: 'https://usale.it/api/point-multipliers',
                headers: {
                    'Authorization': 'Bearer '+app_code,
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                },
                data: {}
            });
        }
    }
}]);
