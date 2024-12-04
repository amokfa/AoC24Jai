#import "Basic";
#import "File";
#import "String";
#import "STL";
#import "Clipboard";
#import "Compiler";
#import "STL_CLI";

Arguments :: struct {
    day: s8 = -1;
    part: s8 = -1;
    clipboard: bool;
    input_file: string;
}

#run build();
build :: () {
    options := get_build_options();
    args: [..] string;
    array_add(*args, "bob the builder");
    for options.compile_time_command_line array_add(*args, it);
    success, parsed_args, is_set := parse_arguments_inner(Arguments, args, flags=.SHOW_HELP_ON_ERROR|.ALIGN_HELP);
    if !success {
        exit(1);
    }
    if parsed_args.day < 1 || parsed_args.day > 25 {
        println("invalid day");
        exit(1);
    }
    if parsed_args.part != 1 && parsed_args.part != 2 {
        println("invalid part");
        exit(1);
    }

    content: string;
    if (is_set.input_file) {
        file_content, status := read_entire_file(parsed_args.input_file, log_errors=false);
        if !status {
            exit(1);
        }
        content = file_content;
    } else if parsed_args.clipboard {
        #import "STL_Clipboard";
        success, clipboard := get_clipboard();
        content = clipboard;
    } else {
        make_directory_if_it_does_not_exist(".input_cache");
        input_file_path := sprint(".input_cache/%", parsed_args.day);
        file_content, status := read_entire_file(input_file_path, log_errors=false);
        if !status {
            println("Downloading input");
            status, result := download_input(cast(u8) parsed_args.day);
            if !status {
                println("Couldn't download input: %", result);
                exit(1);
            }
            status = write_entire_file(input_file_path, result);
            if !status {
                println("Couldn't write input to cache");
            }
            content = result;
        } else {
            content = file_content;
        }
        // figure out lifetimes
        // defer free(content);
    }

    {
        w := compiler_create_workspace();
        options.output_executable_name = "a.out";
        options.output_path = ".";
        set_build_options(options, w);
        file := sprint("src/day%/part%.jai", formatInt(parsed_args.day, minimum_digits=2), parsed_args.part);
        uuid :: "ecc7ccd1_0ec9_4da8_be26_79b8e7d49e2c";
        add_build_string(sprint("INPUT :: #string %\n%\n%", uuid, content, uuid), w);
        add_build_file(file, w);

        set_build_options_dc(.{do_output=false});
    }
}

generate_url :: (day: u8) -> string {
    url_builder: String_Builder;
    init_string_builder(*url_builder);
    append(*url_builder, "https://adventofcode.com/2024/day/");
    append(*url_builder, sprint("%", day));
    append(*url_builder, "/input");
    return builder_to_string(*url_builder);
}

generate_cookie :: () -> bool, string {
    cookie, success := read_entire_file(".apikey");
    if !success {
        return false, "";
    }
    defer free(cookie);
    sb: String_Builder;
    init_string_builder(*sb);
    append(*sb, "session=");
    append(*sb, cookie);
    return true, builder_to_string(*sb);
}

download_input :: (day: u8) -> bool, string {
    #import "STL_Curl"()(LINUX_USE_SYSTEM_LIBRARY=true);
    curl := curl_easy_init();
    if !curl {
        return false, "libcurl init failed";
    }
    url := generate_url(day);
    defer free(url);
    curl_easy_setopt(curl, .URL, temp_c_string(url));
    success, cookie := generate_cookie();
    if !success {
        return false, "";
    }
    defer free(cookie);
    curl_easy_setopt(curl, .COOKIE, temp_c_string(cookie));
    result: String_Builder;
    init_string_builder(*result);
    write_callback :: (contents: *u8, count: u64, size: u64, buf: *String_Builder) -> u64 #c_call {
        total_size := count * size;
        new_context: Context;
        push_context new_context {
            append(buf, contents, cast(s64) total_size);
        }
        return total_size;
    }
    curl_easy_setopt(curl, .WRITEFUNCTION, write_callback);
    curl_easy_setopt(curl, .WRITEDATA, *result);
    error_code := curl_easy_perform(curl);
    if error_code != .OK {
        error_message := to_string(curl_easy_strerror(error_code));
        return false, error_message;
    }
    status: u64;
    if curl_easy_getinfo(curl, .RESPONSE_CODE, *status) != .OK {
        return false, sprint("no response code!");
    }
    if status != 200 {
        return false, sprint("HTTP Response: %", status);
    }
    return true, builder_to_string(*result);
}
