##### Beginning of file

"""
"""
function predictmd_package_directory end

function predictmd_package_directory()
    predictmd_root_dir = dirname( # PredictMD/
        dirname( # PredictMD/src/
            dirname( # PredictMD/src/./
                dirname( # PredictMD/src/./toplevel/
                    dirname( # PredictMD/src/./toplevel/utils/
                        @__FILE__ # PredictMD/src/./toplevel/utils/pkg_dir.jl
                        )
                    )
                )
            )
        )
    return predictmd_root_dir
end

function predictmd_package_directory(parts...)
    predictmd_root_dir = predictmd_package_directory()
    result = joinpath(predictmd_root_dir, parts...)
    return result
end

##### End of file
