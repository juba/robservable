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
                    if (x.output_cell === null) {
                        output = observablehq.Inspector.into(document.body);
                    }
                    if (typeof x.output_cell == "string") {
                        output = name => {
                            if (name === x.output_cell) {
                                return new observablehq.Inspector(el);
                            }
                        }
                    }
 
                    const main = runtime.module(notebook, output);

                    const df_inputs = x.input_df === null ? {} : x.input_df;
                    Object.entries(df_inputs).forEach(([key, value]) => {
                        value = HTMLWidgets.dataframeToD3(value);
                        main.redefine(key, value);
                    })

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
