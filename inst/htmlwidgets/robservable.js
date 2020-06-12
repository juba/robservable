HTMLWidgets.widget({

    name: 'robservable',
    type: 'output',
    inspector: class VariableInspector {
        fulfilled(value, name) {
            console.log(value, name)
            if (HTMLWidgets.shinyMode) {
                Shiny.setInputValue(
                    name,
                    value
                );
            }
        }
    },

    factory: function (el, width, height) {
        const inspector = new this.inspector;

        let module = null;
        return {

            renderValue: function (x) {
                (async () => {


                    // Load Runtime by overriding width stdlib method if fixed width is provided
                    const stdlib = new observablehq.Library;
                    let library;
                    let runtime;
                    if (x.robservable_width !== undefined) {
                        library = Object.assign(stdlib, { width: x.robservable_width });
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
                        output = observablehq.Inspector.into(el);
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

                    // module is at higher level of scope allowing a user to access later
                    //  set equal to main
                    module = main;

                    // If in Shiny mode and observers are set then set these up in Observable
                    if (x.observers !== null) {
                        // if only one observer then might not be an array so force to array
                        x.observers = !Array.isArray(x.observers) ? [x.observers] : x.observers;
                        x.observers.forEach((d, i) => {
                            main.variable(inspector).define(el.id + '_observer_' + d, [d], (x) => x);
                        });
                    }

                    // Update inputs
                    const inputs = x.input === null ? {} : x.input;
                    Object.entries(inputs).forEach(([key, value]) => {
                        main.redefine(key, value);
                    })

                    // Apply some styling to allow vertical scrolling when needed in RStudio
                    if (!HTMLWidgets.shinyMode) {
                        document.querySelector('body').style["overflow"] = "auto";
                        document.querySelector('body').style["width"] = "auto";
                    }

                })();

            },

            getModule: function () {
                return module;
            },

            resize: function (width, height) {
            }

        };
    }
});
