#run build();
build :: () {
    set_build_options_dc(.{do_output=false});
    if !generate_bindings() {
        compiler_set_workspace_status(.FAILED);
        return;
    }
}

generate_bindings :: () -> bool {
    output_filename: string;
    opts: Generate_Bindings_Options;
    {
        using opts;

        output_filename          = "sqlite3.jai";

        array_add(*libpaths,       "/usr/lib/x86_64-linux-gnu");
        array_add(*libnames,      "libsqlite3");
        array_add(*source_files,  "/usr/include/sqlite3.h");
        // array_add(*extra_clang_arguments, "-x", "c++", "-DWIN32_LEAN_AND_MEAN");
    }

    return generate_bindings(opts, output_filename);
}

#scope_file

#import "Basic";
#import "Compiler";
#import "BuildCpp";
#import "Check";
#import "Bindings_Generator";
#import "File";
