// QP-01: verify restrictions, anonymous rating rejection and admin visibility.
function stamp() {
  const d = new Date()
  const two = n => String(n).padStart(2, '0')
  return d.getFullYear() + two(d.getMonth() + 1) + two(d.getDate()) +
    '-' + two(d.getHours()) + two(d.getMinutes()) + two(d.getSeconds())
}

describe('QP-01 A custom pizza reaches the admin list', () => {
  it('follows all seven steps in the same browser session', () => {
    // Step 1: open QuickPizza.
    cy.visit('https://quickpizza.grafana.com')
    cy.get('h1').should('have.text', 'Looking to break out of your pizza routine?')
    // Step 2: show the advanced fields.
    cy.contains('label', 'Advanced').click()
    for (const label of ['Max Calories per Slice', 'Excluded tools', 'Must be vegetarian', 'Custom Pizza Name']) {
      cy.contains('label', label).should('be.visible')
    }
    // Step 3: fill and check the restrictions.
    const pizzaName = 'Lab Pizza ' + stamp()
    cy.contains('label', 'Max Calories per Slice').siblings('input').clear().type('600').should('have.value', '600')
    cy.get('select').select('Knife')
    cy.contains('option', 'Knife').should('be.selected')
    cy.get('#default-checkbox').check().should('be.checked')
    cy.get('input#pizza-name').clear().type(pizzaName).should('have.value', pizzaName)
    // Step 4: observe the real request; do not stub the response.
    cy.intercept('POST', '/api/pizza').as('pizza')
    cy.get('button[name="pizza-please"]').click()
    cy.wait('@pizza').its('response.statusCode').should('eq', 200)
    cy.get('@pizza').then(({ request, response }) => {
      expect(request.body.maxCaloriesPerSlice).to.equal(600)
      const { pizza, calories } = response.body
      cy.contains('#recommendations p', 'Tool:').should('have.text', 'Tool: ' + pizza.tool)
      cy.contains('#recommendations p', 'Calories per slice:').should('have.text', 'Calories per slice: ' + calories)
      cy.wrap(pizza.tool).as('tool')
      cy.task('evidence', { step: 4, pizzaName, tool: pizza.tool, calories })
    })
    cy.get('#recommendations').should('contain', 'Name: ' + pizzaName)
    cy.contains('#recommendations p', 'Tool:').should('not.contain', 'Knife')
    cy.contains('#recommendations p', 'Calories per slice:').should($p => {
      const calories = Number($p.text().replace('Calories per slice:', '').trim())
      expect(Number.isFinite(calories)).to.equal(true)
      expect(calories).to.be.within(0, 600)
    })
    cy.screenshot('qp01-step4-recommendation')
    // Step 5: rating without login is rejected.
    cy.get('button[name="rate-5"]').click()
    cy.get('#rate-result').should('have.text', 'Please log in first.')
    cy.screenshot('qp01-step5-login-needed')
    // Step 6: preserve the cookie by staying in this test.
    cy.adminLogin('admin', 'admin')
    cy.contains('Latest pizza recommendations').should('be.visible')
    // Step 7: search the list rather than assuming the first row is ours.
    cy.get('@tool').then(tool => {
      cy.contains('li', pizzaName).should('contain', '(tool=' + tool + ',')
        .invoke('text').then(adminLine => cy.task('evidence', { step: 7, pizzaName, adminLine }))
    })
    cy.screenshot('qp01-step7-admin-list')
  })
})
