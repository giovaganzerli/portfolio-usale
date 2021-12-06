import { Component, OnInit } from '@angular/core';

@Component({
    moduleId: module.id,
    selector: 'app-overview',
    templateUrl: 'rules.component.html',
    styleUrls: ['rules.component.sass']
})
export class RulesComponent implements OnInit {

    pages = [
        'regolamento/v2/page1',
        'regolamento/v2/page2',
        'regolamento/v2/page3',
        'regolamento/v2/page4',
        'regolamento/v2/page5',
        'regolamento/v2/page6',
        'regolamento/v2/page7',
        'regolamento/v2/page8',
        'regolamento/v2/page9'
    ];

    currIndex = 0;
    currPage: string;

    constructor() {}
    ngOnInit() {
        this.currPage = this.pages[this.currIndex];
    }

    next() {
        this.currIndex = Math.min(this.currIndex + 1, this.pages.length - 1);
        this.currPage = this.pages[this.currIndex];
    }

    back() {
        this.currIndex = Math.max(this.currIndex - 1, 0);
        this.currPage = this.pages[this.currIndex];
    }

    select(page: string) {
        this.currPage = page;
    }
}
