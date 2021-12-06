import { Injectable } from '@angular/core';
import { Http, Headers, Response } from '@angular/http';
import { Observable } from 'rxjs/Rx';
import 'rxjs/add/operator/map'
import { User } from '../_models/user';

@Injectable()
export class AuthenticationService {

    loginUrl = 'api/user/backend-login';

    constructor(private http: Http) { }

    login(appCode: string): Observable<User> {
        const headers = new Headers();
        headers.append('Authorization', 'Bearer ' + appCode);
        return this.http.post(this.loginUrl, '', {headers: headers})
            .map((response: Response) => {
                const user = response.json();
                if (user && user.role) {
                    localStorage.setItem('currentUser', JSON.stringify(user));
                    localStorage.setItem('currentCode', appCode);
                }

                return user;
            })
            .catch((error: any) => Observable.throw(error || 'Error'));
    }

    getUser(): User {
        return JSON.parse(localStorage.getItem('currentUser'));
    }

    getCode(): string {
        return localStorage.getItem('currentCode')
    }

    logout() {
        localStorage.removeItem('currentUser');
        localStorage.removeItem('currentCode');
    }
}
