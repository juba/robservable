class RObservable {

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
        let nb = await import(url);
        return new RObservable(el, params, nb.default);
    }

    // Build Observable inspector
    build_inspector() {
        if (this.params.include !== null) {
            const cell = !Array.isArray(this.params.include) ? [this.params.include] : this.params.include;

            return (name) => {
                let name_safe = "";
                let div;

                if (cell.includes(name)) {
                    div = this.create_output_div(name);
                    return new observablehq.Inspector(div);
                }
                if (
                    (typeof(name) === "undefined" || name === "") &&
                    // num_cell increments so check to see if user included matching number
                    //   check both String and numeric since R will convert to character
                    //   if in a vector that includes any character cell names
                    (cell.includes(this.num_cells) || cell.includes(String(this.num_cells)))
                )
                {
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
        let name_safe = (typeof(name) === "undefined" || name === "") ?
            css_safe("unnamed-" + this.num_cells) :
            css_safe(name);

        const hide = !Array.isArray(this.params.hide) ? [this.params.hide] : this.params.hide;

        let div = document.createElement("div");
        div.className = name_safe;
        if(hide.includes(name) || hide.includes(num) || hide.includes(String(num))) {
            div.style.display = "none";
        }
        this.el.appendChild(div);
        // add to our output_divs tracker
        this.output_divs.set(name, div);
        // increment counter
        this.num_cells ++;
        return div;
    }

    hide_cells() {
        const hide = !Array.isArray(this.params.hide) ? [this.params.hide] : this.params.hide;
        const cells = this.el.querySelectorAll(".observablehq");
        hide.forEach(num => {
            try {
              cells[num].style.display = "none";
            } catch(e) {}
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
                this.main.redefine(key, value);
            } catch (error) {
                console.warn(`Can't update ${key} variable : ${error.message}`);
            }
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

        el.width = width;
        el.height = height;

        return {

            renderValue(params) {

                // Check if module object already created
                let module = el.module;
                if (module === undefined || module.params.notebook !== params.notebook) {
                    // If not, create one
                    RObservable.build(el, params).then(mod => {
                        params = update_height_width(params, el.height, el.width)
                        mod.params = params;
                        el.module = mod;
                        // run any queued methods sent prior to construction
                        if(this.queuedMethods.length > 0) {
                          this.queuedMethods.forEach(method => {
                            if(this[method.method]) {
                              this[method.method](method.args);
                            }
                          })
                          // clear any queued methods
                          this.queuedMethods = [];
                        }
                    });
                } else {
                    // Else, update params
                    params.current_observers = module.params.current_observers;
                    // Update widgets
                    el.module.params = params;
                }

            },

            resize(width, height) {

                if (el.module === undefined) return;

                // Get params and update width and height
                el.width = width;
                el.height = height;
                let params = el.module.params;
                params = update_height_width(params, el.height, el.width)

                // Update widgets
                el.module.params = params;

            },

            // update proxy method
            update(variables) {
                // set params.input to new values
                // update variables
                if(el.hasOwnProperty("module")) {
                    el.module.params.input = variables;
                    el.module.update_variables();
                } else {
                  this.queuedMethods.push({method: "update", args: variables});
                }
            },

            // add observers
            observe(variables) {
                // set params.input to new values
                // update variables
                if(el.hasOwnProperty("module")) {
                    el.module.params.observers = variables;
                    el.module.set_variable_observers();
                } else {
                  this.queuedMethods.push({method: "observe", args: variables});
                }
            },

            queuedMethods: []

        };
    }
});

// receive and handle robservable proxy messages with Shiny
if (HTMLWidgets.shinyMode) {
  Shiny.addCustomMessageHandler("robservable-calls", function(data) {
    var id = data.id;
    var el = document.getElementById(id);
    var robs = el ? HTMLWidgets.find("#" + id) : null;

    if (!robs) {
      console.log("Couldn't find robservable with id " + id);
      return;
    }

    for (var i = 0; i < data.calls.length; i++) {
      var call = data.calls[i];
      if (call.dependencies) {
        Shiny.renderDependencies(call.dependencies);
      }
      if (robs[call.method])
        robs[call.method](call.args);
      else
        console.log("Unknown method " + call.method);
    }
  });
}
