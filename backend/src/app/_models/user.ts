export class User {
    constructor(
        public id: number,
        public name: string,
        public surname: string,
        public appCode: string,
        public teamCode: string,
        public areaCode: string,
        public role: number
    ) {}
}
