HTMLWidgets.widget({

    name: 'robservable',
    type: 'output',

    factory: function (el, width, height) {

        return {

            renderValue: function (x) {
                (async () => {


                    const runtime = new observablehq.Runtime();

                    const url = `https://api.observablehq.com/${x.notebook}.js?v=3`;
                    let nb = await import(url);
                    let notebook = nb.default;

                    let output;
                    if (x.cell === null) {
                        output = observablehq.Inspector.into(document.body);
                        document.getElementById('htmlwidget_container').style["display"] = "none";
                        document.querySelector('body').style["overflow"] = "auto";
                    }
                    if (typeof x.cell == "string") {
                        output = name => {
                            if (name === x.cell) {
                                return new observablehq.Inspector(el);
                            }
                        }
                    }
 
                    const main = runtime.module(notebook, output);

                    const inputs = x.input === null ? {} : x.input;
                    Object.entries(inputs).forEach(([key, value]) => {
                        main.redefine(key, value);
                    })

                })();

            },

            resize: function (width, height) {
            }

        };
    }
});
