import { CocacolaBackendPage } from './app.po';

describe('cocacola-backend App', () => {
  let page: CocacolaBackendPage;

  beforeEach(() => {
    page = new CocacolaBackendPage();
  });

  it('should display welcome message', () => {
    page.navigateTo();
    expect(page.getParagraphText()).toEqual('Welcome to app!!');
  });
});
