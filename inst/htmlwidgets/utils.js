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