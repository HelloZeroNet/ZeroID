PIXI.BorderFilter = function() {
    PIXI.AbstractFilter.call(this);

    this.passes = [ this ];

    this.fragmentSrc = [
        'precision mediump float;',
        'void main(void) {',
        	'if((gl_FragCoord.x < 2.) || (gl_FragCoord.y < 2.)) {',
        		'gl_FragColor = vec4(1., 1., 1., 1.);',
        	'}',
        '}'
    ];
};