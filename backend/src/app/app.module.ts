import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { HttpModule } from '@angular/http';

import { AppComponent } from './app.component';
import { routing } from './app.routing';

import { AuthGuard } from './_guards/auth.guard';
import { AuthenticationService } from './_services/authentication.service';
import { ScoreboardService } from './_services/scoreboard.service';
import { AlertService } from './_services/alert.service';

import { HeaderComponent } from './header/header.component';
import { SidebarComponent } from './sidebar/sidebar.component';
import { PageNotFoundComponent } from './main/page-not-found/page-not-found.component';
import { OverviewComponent } from './main/overview/overview.component';
import { UsersComponent } from './main/users/users.component';
import { MainComponent } from './main/main.component';
import { LoginComponent } from './login/login.component';
import { AlertComponent } from './_directives/alert.directive';
import { ScoreboardComponent } from './main/scoreboard/scoreboard.component';

import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { ButtonsModule } from '@progress/kendo-angular-buttons';
import {ExcelModule, GridModule} from '@progress/kendo-angular-grid';

import '@progress/kendo-angular-intl/locales/it/all'
import {FaqComponent} from './main/faq/faq.component';
import {RulesComponent} from './main/rules/rules.component';
import {AdminGuard} from './_guards/admin.guard';

@NgModule({
  declarations: [
    AppComponent,
    HeaderComponent,
    SidebarComponent,
    PageNotFoundComponent,
    OverviewComponent,
    FaqComponent,
    RulesComponent,
    UsersComponent,
    MainComponent,
    LoginComponent,
    AlertComponent,
    ScoreboardComponent
  ],
  imports: [
    BrowserModule,
    FormsModule,
    HttpModule,
    routing,

    BrowserAnimationsModule,
    ButtonsModule,
    GridModule,
    ExcelModule
  ],
  providers: [
    AuthGuard,
    AdminGuard,
    AuthenticationService,
    ScoreboardService,
    AlertService
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
