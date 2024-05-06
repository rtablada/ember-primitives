import Helper from '@ember/component/helper';
import type RouterService from '@ember/routing/router-service';
export interface Signature {
    Args: {
        Positional: [href: string];
        Named: {
            includeActiveQueryParams?: boolean | string[];
        };
    };
    Return: {
        isExternal: boolean;
        isActive: boolean;
        handleClick: (event: MouseEvent) => void;
    };
}
export default class Link extends Helper<Signature> {
    router: RouterService;
    compute([href]: [href: string], { includeActiveQueryParams }: {
        includeActiveQueryParams?: boolean | string[];
    }): {
        isExternal: boolean;
        readonly isActive: boolean;
        handleClick: (event: MouseEvent) => void;
    };
}
export declare const link: typeof Link;
//# sourceMappingURL=link.d.ts.map