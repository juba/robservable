HTMLWidgets.widget({

    name: 'robservable',
    type: 'output',

    factory: function (el, width, height) {

        return {

            renderValue: function (x) {
                (async () => {


                    // Load Runtime by overriding width stdlib method if fixed width is provided
                    const stdlib = new observablehq.Library;
                    let library;
                    let runtime;
                    if (x.robservable_width !== undefined) {
                        library = Object.assign(stdlib, {width: x.robservable_width});
                        runtime = new observablehq.Runtime(library);
                    } else {
                        runtime = new observablehq.Runtime();
                    }

                    // Dynamically import notebook module
                    const url = `https://api.observablehq.com/${x.notebook}.js?v=3`;
                    let nb = await import(url);
                    let notebook = nb.default;

                    let output;
                    // If output is the whole notebook
                    if (x.cell === null) {
                        output = observablehq.Inspector.into(document.body);
                        // Apply some styling
                        document.getElementById('htmlwidget_container').style["display"] = "none";
                        document.querySelector('body').style["overflow"] = "auto";
                    }
                    // If output is one cell
                    if (typeof x.cell == "string") {
                        output = name => {
                            if (name === x.cell) {
                                return new observablehq.Inspector(el);
                            }
                        }
                    }
 
                    // Run main
                    const main = runtime.module(notebook, output);

                    // Update inputs
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
