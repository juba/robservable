import { RObservable } from "../modules/robservable";
import { update_height_width } from "../modules/utils";
import 'widgets';
//import 'shiny';
import "@observablehq/inspector/dist/inspector.css";


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
