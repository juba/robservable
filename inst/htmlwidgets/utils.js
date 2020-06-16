// Make a string "safe" as a CSS class name
function css_safe(str) {
    str = str.replace(/[!\"#$%&'\(\)\*\+,\.\/:;<=>\?\@\[\\\]\^`\{\|\}~\s]/g, '_');
    return (str);
}
