
describe('Web site availability', () => {
    const baseUrl = Cypress.env('FRONTEND_URL') || 'http://frontend:5173';

    after(() => {
      cy.contains("Delete").click({ force: true });
      }); 
      it('Sanity listings web site', () => {
        cy.visit(baseUrl);
        cy.contains('Create Employee').should('exist');
      });
      it('Test Adding Employee listings', () => {
        cy.visit(`${baseUrl}/create`);
        cy.get('#name').type("Employee1");
        cy.get('#position').type("Position1");
        cy.get("#positionIntern").click({ force: true });
        cy.contains("Save Employee Record").click({ force: true });
        cy.visit(baseUrl);
        cy.contains('Employee1').should('exist');
      });
     /* it('Test Editing Employee listings', () => {
        //cy.visit('http://frontend:3000');
        cy.contains('Edit').click({ force: true })
        cy.on('url:changed', url => {
                  cy.visit(url);
                  cy.get('#position').clear();
                  cy.get('#position').type("Position2");
                  cy.contains("Update Record").click({ force: true });
                  cy.visit('http://frontend:3000');
                  cy.contains('Position2').should('exist');
              });
       
        
        
      });*/
    });