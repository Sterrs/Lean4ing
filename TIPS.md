# Lean 4 Tips and Tricks

 - Ctrl+Shift+X will cause Lean to reload the current file
 - If imports don't appear to be working, it might be because you added something to the importee file after the importer file had already loaded, try reloading the file as above
 - Notation generally won't reduce definitions, you can mark abbreviations with @[reducible] to get all of the original notation working