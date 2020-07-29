// Make a string "safe" as a CSS class name
function css_safe(str) {
    str = str.replace(/[!\"#$%&'\(\)\*\+,\.\/:;<=>\?\@\[\\\]\^`\{\|\}~\s]/g, '_');
    return (str);
}

// Update params height and width
function update_height_width(params, height, width) {
    if (params.input === null) params.input = {};
    if ((params.input.width === undefined || params.width_updated) && params.update_width) {
        params.input.width = width;
        params.width_updated = true;
    }
    if ((params.input.height === undefined || params.height_updated) && params.update_height) {
        params.input.height = height;
        params.height_updated = true;
    }
    return params;
}

// Return runtime API notebook URL from notebook id
function notebook_api_url(id) {
    if (id.slice(0,4) == "http") {
       // If id is an url
       return id.replace('://observablehq', '://api.observablehq') + '.js?v=3'
    }
    if (id.slice(0,1) == "@") {
       // If id is an identifier of a published notebook
       return `https://api.observablehq.com/${id}.js?v=3`;
    }
    if (id.slice(0,2) == "d/") {
       // If id is an identifier of a shared notebook with d/ prefix
       return `https://api.observablehq.com/${id}.js?v=3`;
    }
    // else, id should be an identifier of a shared notebook without d/ prefix
    return `https://api.observablehq.com/d/${id}.js?v=3`;
}
