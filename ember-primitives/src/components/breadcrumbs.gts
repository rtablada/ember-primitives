// Breadcrumb Header
import Component from '@glimmer/component';
import { assert } from '@ember/debug';
import { hash } from '@ember/helper';
import { isDevelopingApp, macroCondition } from '@embroider/macros';

import { element } from 'ember-element-helper';
import { modifier } from 'ember-modifier';
import { cell } from 'ember-resources';
import { TrackedArray } from 'tracked-built-ins';

import { uniqueId } from '../utils.ts';
import { BreadcrumbContentTarget } from './breadcrumbs/content-target.gts';

import type { TOC } from '@ember/component/template-only';
import type { WithBoundArgs } from '@glint/template';

export interface BreadcrumbRendererSignature {
  Element: Element;
  Args: {
    /**
     * By default the breadcrumb renderer target is a div element.
     * You may change this by supplying the name of an element here.
     *
     * For example:
     * ```gjs
     * <BreadcrumbRenderer @as="header">
     * </BreadcrumbRenderer>
     * ```
     */
    as?: string;
  };
  Blocks: {
    item: [
      {
        BreadcrumbContentTarget: WithBoundArgs<typeof BreadcrumbContentTarget, 'breadcrumbId'>;
      },
    ];
    separator?: [];
  };
}

function getElementTag(tagName: undefined | string) {
  return tagName || 'div';
}

export function findNearestBreadcrumbRenderer(origin: Element) {
  assert(
    `first argument to \`findNearestBreadcrumbRenderer\` must be an element`,
    origin instanceof Element
  );

  let element: Element | null = null;
  let parent = origin.parentNode;

  while (!element && parent) {
    element = parent.querySelector(`[data-breadcrumb-id]`);
    if (element) break;
    parent = parent.parentNode;
  }

  if (macroCondition(isDevelopingApp())) {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (window as any).prime0 = origin;
  }

  assert(
    `Could not find any mounted BreadcrumbRenderer:` +
      `Double check that you have a BreadcrumbRenderer higher in your component tree. ` +
      `The element passed to \`findNearestBreadcrumbRenderer\` is stored on \`window.prime0\` ` +
      `You can debug in your browser's console via ` +
      `\`document.querySelector('[data-breadcrumb-id]')\``,
    element
  );

  return element;
}

function findBreadrumbTarget(
  parentBreadcrumbEl: Element,
  newTargetId: ReturnType<typeof uniqueId>
): Element | ShadowRoot {
  assert(
    `first argument to \`findNearestBreadcrumbRenderer\` must be an element`,
    parentBreadcrumbEl instanceof Element
  );

  const element = parentBreadcrumbEl.querySelector(`[data-breadcrumb-item="${newTargetId}"]`);

  assert(
    `Could not find a breadcrumb target in the element:` +
      `Double check that you have a BreadcrumbRenderer higher in your component tree. ` +
      `The element passed to \`findNearestBreadcrumbRenderer\` is stored on \`window.prime0\` ` +
      `You can debug in your browser's console via ` +
      `\`document.querySelector('[data-breadcrumb-id]')\``,
    element
  );

  return element;
}

const TEMP_BREADCRUMB_MAP = new Map<Element, BreadcrumbRenderer>();

const registerBreadcrumbToMount = modifier(
  (element: Element, [rendererInstance]: [BreadcrumbRenderer]) => {
    TEMP_BREADCRUMB_MAP.set(element, rendererInstance);

    return () => {
      TEMP_BREADCRUMB_MAP.delete(element);
    };
  }
);

export class BreadcrumbRenderer extends Component<BreadcrumbRendererSignature> {
  children = new TrackedArray<string>();

  addBreadcrumb() {
    let childId = uniqueId();

    this.children.push(childId);

    return childId;
  }

  isLast(index: number) {
    return this.children.length - 1 === index;
  }

  renderSeparator = (hasSeparatorBlock: boolean, index: number) => {
    return hasSeparatorBlock && !this.isLast(index);
  };

  <template>
    {{#let (uniqueId) as |id|}}
      {{#let (element (getElementTag @as)) as |El|}}
        <El {{registerBreadcrumbToMount this}} data-breadcrumb-id={{id}} ...attributes>
          {{#each this.children as |child index|}}
            {{yield
              (hash BreadcrumbContentTarget=(component BreadcrumbContentTarget breadcrumbId=child))
              to="item"
            }}
            {{#if (this.renderSeparator (has-block "separator") index)}}
              {{yield to="separator"}}
            {{/if}}
          {{/each}}
        </El>
      {{/let}}
    {{/let}}
  </template>
}

// Breadcrumb Child

export interface BreadcrumbSignature {
  Element: Element;
  Args: {};
  Blocks: {
    default: [];
  };
}

const mountToParent = modifier(
  (element: Element, [updateTarget]: [ReturnType<typeof ElementValue>['set']]) => {
    let parentBreadcrumbEl = findNearestBreadcrumbRenderer(element);
    let parentBreadcrumbComponent = TEMP_BREADCRUMB_MAP.get(parentBreadcrumbEl)!;
    let newTargetId = parentBreadcrumbComponent.addBreadcrumb();

    window.requestAnimationFrame(() => {
      let breadcrumbTargetEl = findBreadrumbTarget(parentBreadcrumbEl, newTargetId);

      updateTarget(breadcrumbTargetEl);
    });
  }
);

const ElementValue = () => cell<Element | ShadowRoot>();

export const Breadcrumb: TOC<BreadcrumbSignature> = <template>
  {{#let (ElementValue) as |target|}}
    {{! This div is always going to be empty,
          because it'll either find the portal and render content elsewhere,
          it it won't find the portal and won't render anything.
    }}
    {{! template-lint-disable no-inline-styles }}
    <div style="display:contents;" {{mountToParent target.set}}>
      {{#if target.current}}
        {{#in-element target.current}}
          {{yield}}
        {{/in-element}}
      {{/if}}
    </div>
  {{/let}}
</template>;
