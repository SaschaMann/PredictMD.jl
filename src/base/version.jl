const VERSION = try
    convert(VersionNumber, "v0.17.0-DEV")
catch e
    warn("While creating PredictMD.VERSION, ignoring error $(e)")
    VersionNumber(0)
end

"""
    VERSION
"""
VERSION
