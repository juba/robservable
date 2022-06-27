import * as observablehq from "@observablehq/runtime";
import { css_safe, notebook_api_url } from "./utils";


export class RObservable {

    // Pattern taken from https://stackoverflow.com/a/43433773
    constructor(el, params, notebook) {
        // Throw error if notebook module has not been loaded asynchronously
        if (typeof notebook === 'undefined') {
            throw new Error('Cannot be called directly');
        }

        this.el = el;
        this._params = params;
        this._params.current_observers = {};

        // set up a Map container to keep track of output <div>
        this.output_divs = new Map();
        // set up a counter so we can reference unnamed cells
        this.num_cells = 1;

        let runtime = new observablehq.Runtime();
        let inspector = this.build_inspector();
        this.main = runtime.module(notebook, inspector);

        // if whole notebook is rendered hide cells if user has requested
        if (this.params.include === null && this.params.hide !== null) {
            this.hide_cells();
        }
    }

    // async builder to dynamically import notebook module
    static async build(el, params) {
        const url = notebook_api_url(params.notebook);
        let nb = await import(/* webpackIgnore: true */ url);
        return new RObservable(el, params, nb.default);
    }

    // Build Observable inspector
    build_inspector() {
        if (this.params.include !== null) {
            const cell = !Array.isArray(this.params.include) ? [this.params.include] : this.params.include;

            return (name) => {
                let div;

                if (cell.includes(name)) {
                    div = this.create_output_div(name);
                    const i = new observablehq.Inspector(div);
                    // If named cell, emit events at different cell states
                    return {
                        pending() {
                            const event = new Event('robservable-' + name + '-pending');
                            i.pending();
                            document.dispatchEvent(event);
                        },
                        fulfilled(value) {
                            const event = new Event('robservable-' + name + '-fulfilled');
                            i.fulfilled(value);
                            document.dispatchEvent(event);
                        },
                        rejected(error) {
                            const event = new Event('robservable-' + name + '-rejected');
                            i.rejected(error);
                            document.dispatchEvent(event);
                        },
                    };
                }
                if (
                    (typeof (name) === "undefined" || name === "") &&
                    // num_cell increments so check to see if user included matching number
                    //   check both String and numeric since R will convert to character
                    //   if in a vector that includes any character cell names
                    (cell.includes(this.num_cells) || cell.includes(String(this.num_cells)))
                ) {
                    // will not have a name so call unnamed-1
                    //   so we/user can reference later
                    //   this is not ideal but hopefully better than nothing
                    div = this.create_output_div();
                    return new observablehq.Inspector(div);
                }
                this.num_cells++;
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

    // Create the <div> elements for each cell to render and append to el
    create_output_div(name) {
        const num = this.num_cells;
        let name_safe = (typeof (name) === "undefined" || name === "") ?
            css_safe("unnamed-" + this.num_cells) :
            css_safe(name);

        const hide = !Array.isArray(this.params.hide) ? [this.params.hide] : this.params.hide;

        let div = document.createElement("div");
        div.className = name_safe;
        if (hide.includes(name) || hide.includes(num) || hide.includes(String(num))) {
            div.style.display = "none";
        }
        this.el.appendChild(div);
        // add to our output_divs tracker
        this.output_divs.set(name, div);
        // increment counter
        this.num_cells++;
        return div;
    }

    hide_cells() {
        const hide = !Array.isArray(this.params.hide) ? [this.params.hide] : this.params.hide;
        const cells = this.el.querySelectorAll(".observablehq");
        hide.forEach(num => {
            try {
                cells[num].style.display = "none";
            } catch (e) { }
        });
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
        this.params.current_observers[variable] = obs_var;
    }

    // Add observers from params.observers to cells
    set_variable_observers() {
        let observers = !Array.isArray(this.params.observers) ? [this.params.observers] : this.params.observers;
        if (!this.params.observers) observers = [];
        let previous_observers = Object.keys(this.params.current_observers);
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
            try {
                try {
                    this.main.redefine(key, value);
                } catch (error) {
                    this.main.define(key, value);
                }
            } catch (error) {
                console.warn(`Can't update ${key} variable : ${error.message}`);
            }
        })
        let input_js = this.params.input_js
        input_js = input_js === null ? {} : input_js;
        Object.entries(input_js).forEach(([key, value]) => {
            if (value.inputs === null) value.inputs = [];
            if (!Array.isArray(value.inputs)) value.inputs = [value.inputs];
            try {
                this.main.redefine(key, value.inputs, value.definition);
            } catch (error) {
                console.warn(`Can't update ${key} cell : ${error.message}`);
            }
        })
    }

}