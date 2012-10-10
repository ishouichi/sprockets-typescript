# This README needs some love. You can make it better!

## sprockets-typescript

This gem adds TypeScript support to [Sprockets](https://github.com/sstephenson/sprockets).

### How to use TypeScript with Sprockets?

Just add `.js.ts` extension to filename.

### How does TypeScript compiler extract type information from external files?

This gem adds all dependencies from sprockets directives (`require` and `depend_on_asset`),
`///<reference path="..."/>`, `import` declarations to the compiler.

### How to use sprockets-typescript and sprockets-commonjs together?

Example:

```js
// app/javascripts/bar.module.js.ts

export function bar(): string {
    return "bar";
}
```

```js
// app/javascripts/application.js.ts

import bar = module("bar.module.js");

bar.bar();
```

You need not add `//=require bar` directive in `application.js.ts`.
`bar.module.js.ts` is required automagically
(the compiler notifies sprockets about `import` declaration).

### Why Sprockets can't find `jquery.d.ts` file?

Rename the file to `jquery.d.js.ts`.
