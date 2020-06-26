import { module, test } from 'qunit';
import { setupTest } from 'ember-qunit';

module('Unit | Route | account-show', function(hooks) {
  setupTest(hooks);

  test('it exists', function(assert) {
    let route = this.owner.lookup('route:account-show');
    assert.ok(route);
  });
});
