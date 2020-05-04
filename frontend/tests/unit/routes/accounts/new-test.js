import { module, test } from 'qunit';
import { setupTest } from 'ember-qunit';

module('Unit | Route | accounts/new', function(hooks) {
  setupTest(hooks);

  test('it exists', function(assert) {
    let route = this.owner.lookup('route:accounts/new');
    assert.ok(route);
  });
});
