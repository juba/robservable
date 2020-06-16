<<<<<<< HEAD
class RObservable {

    // Instance fields
    params

    // Constructor
    async constructor(el, params) {

        this.el = el;
        this.params = params;

        // Load Runtime by overriding width stdlib method if fixed width is provided
        const stdlib = new observablehq.Library;
        let library;
        let runtime;
        if (params.robservable_width !== undefined) {
            library = Object.assign(stdlib, { width: params.robservable_width });
            runtime = new observablehq.Runtime(library);
        } else {
            runtime = new observablehq.Runtime();
        }

        // Dynamically import notebook module
        const url = `https://api.observablehq.com/${params.notebook}.js?v=3`;
        let nb = await import(url);
        let notebook = nb.default;
        let output;

        if (params.cell !== null) {
            // If output is one or several cells
            let output_divs = create_output_divs(el, params.cell, params.hide);

            output = (name) => {
                if (params.cell.includes(name)) {
                    return new observablehq.Inspector(output_divs.get(name));
                }
            }
        } else {
            // If output is the whole notebook
            output = observablehq.Inspector.into(el);
        }

        // Run main
        this.main = runtime.module(notebook, output);

    }

    // Add an observer on a notebook variable that sync its value to a Shiny input
    add_observer(name, variable) {
        this.module.variable({
            fulfilled(value, name) {
                console.log(value, name)
                if (HTMLWidgets.shinyMode) {
                    Shiny.setInputValue(
                        name.replace(/robservable_/, ""),
                        value
                    );
                }
            }
        })
            .define(el.id + '_robservable_' + name, [variable], x => x);
    }

    // Observers setter
    set observers(observers) {

        // If in Shiny mode and observers are set then set these up in Observable
        if (observers !== null) {
            // if only one observer and string then force to array
            observers = !Array.isArray(observers) && typeof (observers) === "string" ? [observers] : observers;
            // If source is an R character vector
            if (Array.isArray(observers)) {
                observers.forEach((d) => add_observer(d, d));
            }
            // If source is an R named list
            if (!Array.isArray(observers) && typeof (observers) === "object") {
                Object.entries(observers).forEach(([key, value]) => add_observer(key, value));
            }
        }


    }

    // Variables setter
    set variables(inputs) {
        inputs = inputs === null ? {} : inputs;
        Object.entries(inputs).forEach(([key, value]) => {
            this.module.redefine(key, value);
        })
    }


}
=======
>>>>>>> master



// Create the <div> elements for each cell to render
function create_output_divs(el, cell, hide) {

    cell = !Array.isArray(cell) ? [cell] : cell;
    hide = !Array.isArray(hide) ? [hide] : hide;

    let output_divs = new Map();
    cell.forEach(name => {
        let div = document.createElement("div");
        div.className = css_safe(name);
        // hide cell if its name is in params.hide
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

        // Apply some styling to allow vertical scrolling when needed in RStudio
        if (!HTMLWidgets.shinyMode) {
            document.querySelector('body').style["overflow"] = "auto";
            document.querySelector('body').style["width"] = "auto";
        }

        return {

            renderValue(params) {

                let module = el.module;
                if (module === null || module.params.notebook !== params.notebook) {
                    module = new RObservable(el, params);
                    el.module = module;
                } else {
                    el.module.params = params;
                }

                // Add observers 
                module.observers = params.observers;
                // Update variables
                module.variables = params.input;


            },

            resize(width, height) {
            }

        };
    }
});
