#import "X11";
#import "Basic";

get_clipboard :: () -> bool, string {
    display := XOpenDisplay(null);
    if (!display) {
        print("Unable to open X display\n");
        return false, "";
    }

    window := XCreateSimpleWindow(display, DefaultRootWindow(display), 0, 0, 1, 1, 0, 0, 0);
    defer XDestroyWindow(display, window);
    defer XCloseDisplay(display);

    clipboard := XInternAtom(display, "CLIPBOARD", 0);
    utf8 := XInternAtom(display, "UTF8_STRING", 0);
    property := XInternAtom(display, "CLIP_TEMP", 0);

    // Request the clipboard contents
    XConvertSelection(display, clipboard, utf8, property, window, CurrentTime);
    XFlush(display);

    // Wait for the SelectionNotify event
    event: XEvent;
    XNextEvent(display, *event);

    if (event.type == SelectionNotify) {
        if (event.xselection.selection != clipboard) {
            print("Failed to get clipboard data\n");
            return false, "";
        }

        actual_type: Atom;
        actual_format: s32;
        nitems, bytes_after: u64;
        data: *u8 = null;

        // Retrieve the data from the property
        if (XGetWindowProperty(display, window, property, 0, -1, 0, utf8,
                               *actual_type, *actual_format, *nitems, *bytes_after, *data) == Success) {
            if (actual_type == utf8) {
                result: string = ---;
                result.data = data;
                result.count = cast(s64) nitems;
                return true, result;
            }
        }
    }
    return false, "";
}
