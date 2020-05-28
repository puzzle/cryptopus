import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import { hbs } from 'ember-cli-htmlbars';


module('Integration | Component | password-strength-meter', function(hooks) {
  setupRenderingTest(hooks);


  test('it renders', async function(assert) {

    this.set('password', 'red');

    await render(hbs`<PasswordStrengthMeter @password=this.password/>`);

    assert.equal(this.element.textContent.trim(), 'Password Strength');

    assert.equal(this.element.querySelector('.progress-bar').getAttribute('class'), 'progress-bar progress-bar-0');

  });
});
