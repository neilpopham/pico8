
/*
https://www.mapeditor.org/docs/scripting/modules/tiled.html#registerAction
https://www.mapeditor.org/docs/scripting/modules/tiled.html#registerTool
https://www.mapeditor.org/docs/scripting/modules/tiled.html#extendMenu
https://www.mapeditor.org/docs/scripting/interfaces/Action.html
https://www.mapeditor.org/docs/scripting/interfaces/Tool.html
*/

var action = tiled.registerAction("CustomAction", function(action) {
    tiled.log(action.text + " was " + (action.checked ? "checked" : "unchecked"))
})

action.text = "My Custom Action"
action.checkable = true
action.shortcut = "Ctrl+K"
action.iconVisibleInMenu = false

tiled.extendMenu("Map", [
    { action: "CustomAction", before: "SelectAll" },
    { separator: true }
]);

tiled.log(tiled.menus);