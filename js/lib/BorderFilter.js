var FilterGaussianX = function() {
    {
        PIXI.AbstractFilter.call(this);
    }

    {
        this.passes = [ this ];
    }

    {
        this.uniforms = {
            'vViewport': {
                'type': '2f',
                'value': {
                    'x': 1000, // TODO: ADAPT
                    'y': 0 // TODO: ADAPT
                }
            }
        };
    }

    {
        this.fragmentSrc = [];

        this.fragmentSrc.push('precision mediump float;');
        this.fragmentSrc.push('varying vec2 vTextureCoord;');
        this.fragmentSrc.push('uniform sampler2D uTexture;');
        this.fragmentSrc.push('uniform vec2 vViewport;');
        this.fragmentSrc.push('');
        this.fragmentSrc.push('void main(void) {');
            this.fragmentSrc.push('vec4 vColor = vec4(0.0);');
            this.fragmentSrc.push('');

            var dblSigma = 12.0;  // TODO: PARAMETERIZE
            var dblFractional = 1.0 / (dblSigma * 2.5066282746);
            var dblExponent = 1.0 / (2.0 * dblSigma * dblSigma);

            for (var intFor1 = -32; intFor1 <= 32; intFor1 += 1) { // TODO: PARAMETERIZE
                var dblGaussian = dblFractional * Math.exp(-1.0 * intFor1 * intFor1 * dblExponent);

                // TODO: NORMALIZE IF NECESSARY

                this.fragmentSrc.push('vColor += ');
                    this.fragmentSrc.push(dblGaussian + ' * texture2D(uTexture, vec2(vTextureCoord.x + (' + intFor1.toFixed(1) + ' / vViewport.x), vTextureCoord.y))');
                this.fragmentSrc.push(';');
            }

            this.fragmentSrc.push('');
            this.fragmentSrc.push('gl_FragColor = vColor;');
        this.fragmentSrc.push('}');
        this.fragmentSrc = this.fragmentSrc.join("")
    }
};

FilterGaussianX.prototype = Object.create(PIXI.AbstractFilter.prototype);
FilterGaussianX.prototype.constructor = FilterGaussianX;
