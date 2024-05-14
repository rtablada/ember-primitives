import type { uniqueId } from '../../utils.ts';
import type { TOC } from '@ember/component/template-only';

export interface BreadcrumbItemSignature {
  Element: Element;
  Args: {
    breadcrumbId: ReturnType<typeof uniqueId>;
  };
  Blocks: {
    default: [];
  };
}

/**
 *
 * This creates an element for #in-element to target and mount into
 * this should not be used by consuming applications
 *
 **/
export const BreadcrumbContentTarget: TOC<BreadcrumbItemSignature> = <template>
  <div data-breadcrumb-item={{@breadcrumbId}} ...attributes>{{yield}}</div>
</template>;
