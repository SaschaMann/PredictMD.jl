##### Beginning of file

# Parts of this file are based on:
# 1. https://github.com/JuliaPlots/Plots.jl/blob/master/src/backends/web.jl
# 2. https://github.com/JuliaGraphics/Luxor.jl/blob/master/src/Luxor.jl

import FileIO

"""
"""
function open_browser_window(filename::Void, a::Associative = ENV)
    warn("no filename to open!")
    return filename
end

"""
"""
function open_browser_window(filename::AbstractString, a::Associative = ENV)
    extension = filename_extension(filename)
    is_svg_file = extension == ".svg"
    is_png_file = extension == ".png"
    is_svg_or_png_file = is_svg_file || is_png_file
    is_ijulia = isdefined(Main, :IJulia) && Main.IJulia.inited
    if is_ijulia && is_svg_or_png_file
        Main.IJulia.clear_output(true)
        if is_svg_file
            open(filename) do f
                display(
                    "image/svg+xml",
                    readstring(f),
                    )
            end
        elseif is_png_file
            # We use Base.invokelatest to avoid world age errors
            Base.invokelatest(
                display,
                "image/png",
                FileIO.load(filename),
                )
        end
    elseif (is_make_examples(a)) ||
            (is_make_docs(a)) ||
            (is_runtests(a) && !open_plots_during_tests(a))
        info(
            string(
                "DEBUG: Skipping opening file: ",
                filename,
                )
            )
    else
        info(string("DEBUG: Opening file ",filename,))
        if is_apple()
            try
                run(`open $(filename)`)
            catch e
                warn(string("ignoring error: ", e))
            end
        elseif is_linux() || is_bsd()
            try
                run(`xdg-open $(filename)`)
            catch e
                warn(string("ignoring error: ", e))
            end
        elseif is_windows()
            try
                run(`$(ENV["COMSPEC"]) /c start "" "$(filename)"`)
            catch e
                warn(string("ignoring error: ", e))
            end
        else
            warn(
                string(
                    "unknown operating system; could not open file ",
                    filename,
                    )
                )
        end
    end
    return filename
end

##### End of file
