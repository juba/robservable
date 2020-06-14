// Make a string "safe" as a CSS class name
function css_safe(str) {
    str = str.replace(/[!\"#$%&'\(\)\*\+,\.\/:;<=>\?\@\[\\\]\^`\{\|\}~\s]/g, '_');
    return (str);
}

// Create the <div> elements for each cell to render
function create_output_divs(el, cell, hide) {

    cell = !Array.isArray(cell) ? [cell] : cell;
    hide = !Array.isArray(hide) ? [hide] : hide;

    let output_divs = new Map();
    cell.forEach(name => {
        let div = document.createElement("div");
        div.className = css_safe(name);
        // hide cell if its name is in x.hide
        if (hide.includes(name)) div.style["display"] = "none";
        el.appendChild(div);
        output_divs.set(name, div);
    })
    return output_divs;
}



HTMLWidgets.widget({

    name: 'robservable',
    type: 'output',

    factory: function (el, width, height) {

        let module = null;

        return {

            renderValue: function (x) {

                (async () => {

                    let main = this.getModule();

                    if (main === null) {

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

                        if (x.cell !== null) {
                            // If output is one or several cells
                            let output_divs = create_output_divs(el, x.cell, x.hide);

                            output = (name) => {
                                if (x.cell.includes(name)) {
                                    return new observablehq.Inspector(output_divs.get(name));
                                }
                            }
                        } else {
                            // If output is the whole notebook
                            output = observablehq.Inspector.into(el);
                        }

                        // Run main
                        main = runtime.module(notebook, output);

                        // module is at higher level of scope allowing a user to access later
                        //  set equal to main
                        module = main;

                        // Apply some styling to allow vertical scrolling when needed in RStudio
                        if (!HTMLWidgets.shinyMode) {
                            document.querySelector('body').style["overflow"] = "auto";
                            document.querySelector('body').style["width"] = "auto";
                        }


                        // If in Shiny mode and observers are set then set these up in Observable
                        if (x.observers !== null) {
                            // if only one observer and string then force to array
                            x.observers = !Array.isArray(x.observers) && typeof(x.observers) === "string" ? [x.observers] : x.observers;
                            if(Array.isArray(x.observers)) {
                                x.observers.forEach((d, i) => {
                                    main
                                        .variable({
                                            fulfilled(value, name) {
                                                console.log(value, name)
                                                if (HTMLWidgets.shinyMode) {
                                                    Shiny.setInputValue(
                                                        name.replace(/_observer/, ""),
                                                        value
                                                    );
                                                }
                                            }
                                        })
                                        .define(el.id + '_observer_' + d, [d], (x) => x);
                                });
                            }
                            if(!Array.isArray(x.observers) && typeof(x.observers) === "object") {
                                Object.keys(x.observers).forEach((ky) => {
                                    main
                                        .variable({
                                            fulfilled(value, name) {
                                                console.log(value, name)
                                                if (HTMLWidgets.shinyMode) {
                                                    Shiny.setInputValue(
                                                        name.replace(/_observer/, ""),
                                                        value
                                                    );
                                                }
                                            }
                                        })
                                        .define(el.id + '_observer_' + ky, [x.observers[ky]], (x) => x);
                                })
                            }
                        }

                    }

                    // Update inputs
                    const inputs = x.input === null ? {} : x.input;
                    Object.entries(inputs).forEach(([key, value]) => {
                        main.redefine(key, value);
                    })

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
