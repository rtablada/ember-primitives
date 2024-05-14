import { render, setupOnerror } from '@ember/test-helpers';
import { settled } from '@ember/test-helpers';
import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';

import { Breadcrumb, BreadcrumbRenderer } from 'ember-primitives';

async function rafSettled() {
  // because of behavior: smooth
  await new Promise((resolve) => setTimeout(resolve, 100));
  await new Promise(requestAnimationFrame);
  await settled();
}

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
    await rafSettled();

    assert.dom('[data-test-breadcrumb-container]').exists({ count: 1 });
    assert.dom('[data-test-breadcrumb-container] [data-test-breadcrumb]').exists({ count: 3 });
  });

  test('can render basic renderer separators when block is defined', async function (assert) {
    setupOnerror((error) => {
      assert.matches(error.message, /Could not find element by the given name: `does-not-exist`/);
    });

    await render(
      <template>
        <BreadcrumbRenderer data-test-breadcrumb-container>
          <:item as |bc|>
            <bc.BreadcrumbContentTarget />
          </:item>
          <:separator>
            <span data-test-separator-example></span>
          </:separator>
        </BreadcrumbRenderer>

        <Breadcrumb><span data-test-breadcrumb="1">Home</span></Breadcrumb>
        <Breadcrumb><span data-test-breadcrumb="2">Forum</span></Breadcrumb>
        <Breadcrumb><span data-test-breadcrumb="3">Group 1</span></Breadcrumb>
      </template>
    );
    await rafSettled();

    assert.dom('[data-test-breadcrumb-container]').exists({ count: 1 });
    assert.dom('[data-test-breadcrumb-container] [data-test-breadcrumb]').exists({ count: 3 });
    assert
      .dom('[data-test-breadcrumb-container] [data-test-separator-example]')
      .exists({ count: 2 });
  });
});
