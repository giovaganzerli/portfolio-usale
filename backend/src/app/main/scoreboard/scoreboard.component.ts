import { Component, OnInit } from '@angular/core';

import { ScoreboardService } from '../../_services/scoreboard.service';
import { AlertService } from '../../_services/alert.service';
import {orderBy, process, SortDescriptor, State} from '@progress/kendo-data-query';
import {ExcelExportData} from '@progress/kendo-angular-excel-export';
import {AuthenticationService} from '../../_services/authentication.service';
import {Observable} from 'rxjs/Observable';

import {GridDataResult} from '@progress/kendo-angular-grid';
import {BehaviorSubject} from 'rxjs/BehaviorSubject';


@Component({
    moduleId: module.id,
    selector: 'app-scoreboard',
    templateUrl: 'scoreboard.component.html',
    styleUrls: ['scoreboard.component.sass']
})
export class ScoreboardComponent implements OnInit {

    public view: Observable<GridDataResult>;
    gridData: BehaviorSubject<any[]>;

    scoreboards: any;
    currScoreboard: any;
    scoreboardFilename: string;

    isAdmin = false;

    public gridState: State = {
        sort: [{field: 'coins', dir: 'desc'}],
        skip: 0,
        take: 10
    };

    public editedRowIndex: number;
    public editedProduct: any;

    get isGeneral() { return this.currScoreboard ? this.currScoreboard.name == 'general' : false; }
    get isTeams() { return this.currScoreboard ? this.currScoreboard.name == 'teams' : false; }
    get isAreas() { return this.currScoreboard ? this.currScoreboard.name == 'areas' : false; }

    constructor(
      public scoreboardService: ScoreboardService,
      public alertService: AlertService,
      public authService: AuthenticationService
    ) {
        this.allData = this.allData.bind(this);
        this.gridData = new BehaviorSubject<any[]>([]);
        this.view = this.gridData.map(data => process(data, this.gridState));
    }

    ngOnInit() {
        const user = this.authService.getUser();
        this.isAdmin = user && user.role === 4;

        this.reload();
    }

    reload(): Observable<any> {
        const request = this.scoreboardService.getScoreboard();

        request.subscribe(scoreboards => {
                this.scoreboards = scoreboards;
                this.scoreboards.forEach(scoreboard => {
                    scoreboard.rows.forEach(row => {
                        row.ptSec = row.points + '/' + Math.round(row.seconds);
                    });
                });

                this.showScoreboard(this.currScoreboard ? this.currScoreboard.name : this.scoreboards[0].name);
        }, error => {
                this.alertService.error('Errore nel caricamento dei dati.');
            });

        return request;
    }

    sortChange(sort: SortDescriptor[]): void {
        console.log('changing');
        this.gridState.sort = sort;
    }

    showScoreboard(name: string) {
        this.currScoreboard = this.scoreboards.find(s => s.name === name);
        this.gridData.next(this.currScoreboard.rows);

        if (this.currScoreboard.name === 'general') {
            this.scoreboardFilename = 'scoreboard_generale.xlsx';
        } else if (this.currScoreboard.name === 'teams') {
            this.scoreboardFilename = 'scoreboard_squadre.xlsx';
        } else if (this.currScoreboard.name === 'areas') {
            this.scoreboardFilename = 'scoreboard_aree.xlsx';
        } else {
            this.scoreboardFilename = 'scoreboard.xlsx';
        }

        // this.gridData = this.currScoreboard.rows;
    }

    hasScoreboard(name: string): boolean {
        return this.scoreboards ? this.scoreboards.some(s => s.name === name) : false;
    }

    public allData(): ExcelExportData {
        return {
            data: this.currScoreboard.rows
        };
    }

    public onStateChange(state: State) {
        const sort = this.gridState.sort;
        this.gridState = state;
        this.gridState.sort = sort;
    }

    public editHandler({sender, rowIndex, dataItem}) {
        this.closeEditor(sender);

        this.editedRowIndex = rowIndex;
        this.editedProduct = Object.assign({}, dataItem);

        sender.editRow(rowIndex);
    }

    public cancelHandler({sender, rowIndex}) {
        this.closeEditor(sender, rowIndex);
        this.reload();
    }

    public saveHandler({sender, rowIndex, dataItem, isNew}) {

        let obs: Observable<void>;


        if (this.currScoreboard.name === 'general') {
            obs = this.scoreboardService.updateUser(dataItem.id, dataItem);
        } else if (this.currScoreboard.name === 'teams') {
            obs = this.scoreboardService.updateTeam(dataItem.id, dataItem);
        } else if (this.currScoreboard.name === 'areas') {
            obs = this.scoreboardService.updateArea(dataItem.id, dataItem);
        } else {
            return;
        }

        obs.subscribe(() => {
            sender.closeRow(rowIndex);
            this.reload();

        }, (err) => {
            this.alertService.error('Errore nella modifica dell\'utente.');
            sender.closeRow(rowIndex);
            this.reload();

        });


        this.editedRowIndex = undefined;
        this.editedProduct = undefined;
    }

    public closeEditor(grid, rowIndex = this.editedRowIndex) {
        grid.closeRow(rowIndex);

        this.editedRowIndex = undefined;
        this.editedProduct = undefined;
    }
}
