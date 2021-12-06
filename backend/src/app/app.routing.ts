import { Routes, RouterModule } from '@angular/router';

import { PageNotFoundComponent } from './main/page-not-found/page-not-found.component';
import { OverviewComponent } from './main/overview/overview.component';
import { ScoreboardComponent } from './main/scoreboard/scoreboard.component';
import { UsersComponent } from './main/users/users.component';
import { MainComponent } from './main/main.component';

import { AuthGuard } from './_guards/auth.guard';
import { LoginComponent } from './login/login.component';
import { FaqComponent } from './main/faq/faq.component';
import {RulesComponent} from './main/rules/rules.component';
import {AdminGuard} from './_guards/admin.guard';

const appRoutes: Routes = [
    {
        path: 'login',
        component: LoginComponent
    },
    {
        path: 'logout',
        component: LoginComponent
    },
    {
        path: '',
        component: MainComponent,
        canActivate: [AuthGuard],
        children: [
            {
                path: 'home',
                component: OverviewComponent
            },
            {
                path: 'rules',
                component: RulesComponent
            },
            {
                path: 'faq',
                component: FaqComponent
            },
            {
                path: 'users',
                component: UsersComponent
            },
            {
                path: 'scoreboard',
                component: ScoreboardComponent,
                canActivate: [AdminGuard]
            },
            {
                path: '',
                redirectTo: '/home',
                pathMatch: 'full'
            },
        ]
    },
    {
        path: '**',
        component: PageNotFoundComponent
    }
];

export const routing = RouterModule.forRoot(appRoutes);
