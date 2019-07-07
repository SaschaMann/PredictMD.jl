##### Beginning of file

# This file was generated by PredictMD version 0.20.0
# For help, please visit https://www.predictmd.net

import PredictMD

### Begin project-specific settings

PredictMD.require_julia_version("v0.7.0")

PredictMD.require_predictmd_version("0.20.0")

# PredictMD.require_predictmd_version("0.20.0", "0.21.0-")

PROJECT_OUTPUT_DIRECTORY = PredictMD.project_directory(
    homedir(),
    "Desktop",
    "boston_housing_example",
    )

### End project-specific settings

### Begin linear regression code

display(linear_regression_plot_testing)

PredictMD.singlelabelregressionmetrics(
    linear_regression,
    training_features_df,
    training_labels_df,
    single_label_name,
    )

PredictMD.singlelabelregressionmetrics(
    linear_regression,
    testing_features_df,
    testing_labels_df,
    single_label_name,
    )

linear_regression_filename = joinpath(
    PROJECT_OUTPUT_DIRECTORY,
    "linear_regression.jld2",
    )

PredictMD.save_model(linear_regression_filename, linear_regression)

### End linear regression code

##### End of file

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
