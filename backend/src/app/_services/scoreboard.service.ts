import { Injectable } from '@angular/core';
import { Http, Headers, Response } from '@angular/http';
import { Observable } from 'rxjs/Rx';
import 'rxjs/add/operator/map'
import { User } from '../_models/user';
import { AuthenticationService } from './authentication.service';

@Injectable()
export class ScoreboardService {

    scoreboardUrl = 'api/scoreboard';
    usersUrl = 'api/users';
    teamsUrl = 'api/teams';
    areasUrl = 'api/areas';

    constructor(
        private http: Http,
        private authenticationService: AuthenticationService
    ) { }

    getScoreboard(): Observable<User> {
        const headers = new Headers();
        headers.append('Authorization', 'Bearer ' + this.authenticationService.getCode());
        return this.http.get(this.scoreboardUrl, {headers: headers})
            .map((response: Response) => {
                return response.json();
            })
            .catch((error: any) => Observable.throw(error || 'Error'));
    }

    updateUser(id: number, data: any): Observable<void> {
        const headers = new Headers();
        headers.append('Authorization', 'Bearer ' + this.authenticationService.getCode());
        return this.http.put(this.usersUrl + '/' + id, {
            team_code: data.team_code,
            area_code: data.area_code,
            points: data.points,
            seconds: data.seconds
        }, {headers: headers})
            .map((response: Response) => {
                return response.json();
            })
            .catch((error: any) => Observable.throw(error || 'Error'));
    }

    updateTeam(id: number, data: any): Observable<void> {
        const headers = new Headers();
        headers.append('Authorization', 'Bearer ' + this.authenticationService.getCode());
        return this.http.put(this.teamsUrl + '/' + id, {
            team_code: data.team_code,
            area_code: data.area_code,
            points: data.points,
            seconds: data.seconds
        }, {headers: headers})
            .map((response: Response) => {
                return response.json();
            })
            .catch((error: any) => Observable.throw(error || 'Error'));
    }

    updateArea(id: number, data: any): Observable<void> {
        const headers = new Headers();
        headers.append('Authorization', 'Bearer ' + this.authenticationService.getCode());
        return this.http.put(this.areasUrl + '/' + id, {
            area_code: data.area_code,
            points: data.points,
            seconds: data.seconds
        }, {headers: headers})
            .map((response: Response) => {
                return response.json();
            })
            .catch((error: any) => Observable.throw(error || 'Error'));
    }
}
