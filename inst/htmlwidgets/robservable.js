class RObservable {

    // Pattern taken from https://stackoverflow.com/a/43433773
    constructor(el, params, notebook) {
        // Throw error if notebook module has not been loaded asynchronously
        if (typeof notebook === 'undefined') {
            throw new Error('Cannot be called directly');
        }

        this.el = el;
        this._params = params;
        this._params.observers_variables = {};

        let runtime = this.build_runtime();
        let inspector = this.build_inspector();
        this.main = runtime.module(notebook, inspector);

    }

    // async builder to dynamically import notebook module
    static async build(el, params) {
        const url = `https://api.observablehq.com/${params.notebook}.js?v=3`;
        let nb = await import(url);
        return new RObservable(el, params, nb.default);
    }

    // Build observable runtime
    build_runtime() {
        // Load Runtime by overriding width stdlib method if fixed width is provided
        let library = new observablehq.Library;
        if (this.params.robservable_width !== undefined) {
            library = Object.assign(library, { width: this.params.robservable_width });
        }
        return new observablehq.Runtime(library);
    }

    // Build Observable inspector
    build_inspector() {
        if (this.params.cell !== null) {
            // If output is one or several cells
            let output_divs = this.create_output_divs(this.el, this.params);

            return (name) => {
                if (this.params.cell.includes(name)) {
                    return new observablehq.Inspector(output_divs.get(name));
                }
            }
        } else {
            // If output is the whole notebook
            return observablehq.Inspector.into(this.el);
        }
    }

    // params getter
    get params() {
        return this._params;
    }

    // params setter
    set params(value) {
        this._params = value;
        // Add observers and update variables
        this.set_variable_observers();
        this.update_variables();
    }

    // Create the <div> elements for each cell to render
    create_output_divs() {

        const cell = !Array.isArray(this.params.cell) ? [this.params.cell] : this.params.cell;
        const hide = !Array.isArray(this.params.hide) ? [this.params.hide] : this.params.hide;

        let output_divs = new Map();
        cell.forEach(name => {
            let div = document.createElement("div");
            div.className = css_safe(name);
            // hide cell if its name is in params.hide
            if (hide.includes(name)) div.style["display"] = "none";
            this.el.appendChild(div);
            output_divs.set(name, div);
        })
        return output_divs;
    }


    // Add an observer on a notebook variable that sync its value to a Shiny input
    add_observer(variable) {
        let obs_var = this.main.variable({
            fulfilled(value, name) {
                console.log(value, name)
                if (name !== null && HTMLWidgets.shinyMode) {
                    Shiny.setInputValue(
                        name.replace(/robservable_/, ""),
                        value
                    );
                }
            }
        })
            // el.id must be added to support Shiny modules
            // '_robservable_' is added to avoid name conflicts with notebook variables
            .define(this.el.id + '_robservable_' + variable, [variable], x => x);
        this.params.observers_variables[variable] = obs_var;
    }

    // Remove an existing observer
    remove_observer(variable) {
        this.params.observers_variables[variable].delete();
        delete this.params.observers_variables[variable];
    }

    // Add observers from params.observers to cells
    set_variable_observers() {
        let observers = !Array.isArray(this.params.observers) ? [this.params.observers] : this.params.observers;
        let previous_observers = Object.keys(this.params.observers_variables);
        previous_observers.forEach(variable => {
            // Remove previous observers that don't exist anymore
            if (!observers.includes(variable)) this.remove_observer(variable)
        })
        observers.forEach(variable => {
            // New observer
            if (!previous_observers.includes(variable)) {
                this.add_observer(variable);
            }
        })
    }

    // Update notebook variables from params.input
    update_variables() {
        let input = this.params.input
        input = input === null ? {} : input;
        Object.entries(input).forEach(([key, value]) => {
            this.main.redefine(key, value);
        })
    }

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

                // Check if module object already created
                let module = el.module;
                if (module === undefined || module.params.notebook !== params.notebook) {
                    // If not, create one
                    RObservable.build(el, params).then(mod => {
                        params.update = false;
                        mod.params = params;
                        el.module = mod;
                    });
                } else {
                    // Else, update params
                    params.update = true;
                    params.observers_variables = module.params.observers_variables;
                    console.log(params);
                    el.module.params = params;
                }

            },

            resize(width, height) {
            }

        };
    }
});
