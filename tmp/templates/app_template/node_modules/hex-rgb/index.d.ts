declare namespace hexRgb {
	interface Options {
		readonly format?: 'array';
	}

	interface RgbaObject {
		red: number;
		green: number;
		blue: number;
		alpha: number;
	}

	type RgbaTuple = [number, number, number, number];
}

/**
Convert HEX color to RGBA.

@param hex

@example
```
import hexRgb = require('hex-rgb');

hexRgb('4183c4');
//=> {red: 65, green: 131, blue: 196, alpha: 1}

hexRgb('#4183c4');
//=> {red: 65, green: 131, blue: 196, alpha: 1}

hexRgb('#fff');
//=> {red: 255, green: 255, blue: 255, alpha: 1}

hexRgb('#22222299');
//=> {red: 34, green: 34, blue: 34, alpha: 0.6}

hexRgb('#0006');
//=> {red: 0, green: 0, blue: 0, alpha: 0.4}

hexRgb('#cd2222cc');
//=> {red: 205, green: 34, blue: 34, alpha: 0.8}

hexRgb('#cd2222cc', {format: 'array'});
//=> [205, 34, 34, 0.8]
```
*/
declare function hexRgb(hex: string): hexRgb.RgbaObject;
declare function hexRgb(hex: string, options: hexRgb.Options): hexRgb.RgbaTuple;

export = hexRgb;
