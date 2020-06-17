// Make a string "safe" as a CSS class name
function css_safe(str) {
    str = str.replace(/[!\"#$%&'\(\)\*\+,\.\/:;<=>\?\@\[\\\]\^`\{\|\}~\s]/g, '_');
    return (str);
}

// Update params height and width
function update_height_width(params, height, width) {
    if (params.input === null) {
        params.input = {width: width, height: height};
    } else {
        if (params.input.width === undefined) {
            params.input.width = width;
        }
        if (params.input.height === undefined) {
            params.input.height = height;
        }
    }
    return params;
}