import { render, setupOnerror } from '@ember/test-helpers';
import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';

import { Breadcrumb, BreadcrumbRenderer } from 'ember-primitives';

module('Rendering | <Breadcrumb>', function (hooks) {
  setupRenderingTest(hooks);

  test('can render basic renderer and a few breadcrumbs', async function (assert) {
    setupOnerror((error) => {
      assert.matches(error.message, /Could not find element by the given name: `does-not-exist`/);
    });

    await render(
      <template>
        <BreadcrumbRenderer data-test-breadcrumb-container>
          <:item as |bc|>
            <bc.BreadcrumbContentTarget />
          </:item>
        </BreadcrumbRenderer>

        <Breadcrumb><span data-test-breadcrumb="1">Home</span></Breadcrumb>
        <Breadcrumb><span data-test-breadcrumb="2">Forum</span></Breadcrumb>
        <Breadcrumb><span data-test-breadcrumb="3">Group 1</span></Breadcrumb>
      </template>
    );

    assert.dom('[data-test-breadcrumb-container]').exists({ count: 1 });
    assert.dom('[data-test-breadcrumb-container] [data-test-breadcrumb]').exists({ count: 3 });
  });
});
