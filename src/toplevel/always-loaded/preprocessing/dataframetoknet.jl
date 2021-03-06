import DataFrames
import StatsModels

function MutableDataFrame2ClassificationKnetTransformer(
        feature_names::AbstractVector,
        label_names::AbstractVector{Symbol},
        label_levels::AbstractDict,
        index::Integer;
        transposefeatures::Bool = true,
        transposelabels::Bool = false,
        )
    dffeaturecontrasts = FeatureContrastsNotYetGenerated()
    result = MutableDataFrame2ClassificationKnetTransformer(
        feature_names,
        label_names,
        label_levels,
        index,
        transposefeatures,
        transposelabels,
        dffeaturecontrasts,
        )
    return result
end

"""
"""
function get_underlying(
        x::MutableDataFrame2ClassificationKnetTransformer;
        saving::Bool = false,
        loading::Bool = false,
        )
    result = x.dffeaturecontrasts
    return result
end

"""
"""
function get_underlying(
        x::MutableDataFrame2RegressionKnetTransformer;
        saving::Bool = false,
        loading::Bool = false,
        )
    result = x.dffeaturecontrasts
    return result
end

"""
"""
function set_feature_contrasts!(
        x::MutableDataFrame2ClassificationKnetTransformer,
        feature_contrasts::AbstractFeatureContrasts,
        )
    x.dffeaturecontrasts = feature_contrasts
    return nothing
end

"""
"""
function set_feature_contrasts!(
        x::MutableDataFrame2RegressionKnetTransformer,
        contrasts::AbstractFeatureContrasts,
        )
    x.dffeaturecontrasts = contrasts
    return nothing
end

"""
"""
function fit!(
        transformer::MutableDataFrame2ClassificationKnetTransformer,
        training_features_df::DataFrames.AbstractDataFrame,
        training_labels_df::DataFrames.AbstractDataFrame,
        tuning_features_df::Union{Nothing, DataFrames.AbstractDataFrame} =
            nothing,
        tuning_labels_df::Union{Nothing, DataFrames.AbstractDataFrame} =
            nothing;
        kwargs...
        )
    result = transform(
        transformer,
        training_features_df,
        training_labels_df,
        tuning_features_df,
        tuning_labels_df;
        kwargs...
        )
    return result
end

"""
"""
function fit!(
        transformer::MutableDataFrame2RegressionKnetTransformer,
        training_features_df::DataFrames.AbstractDataFrame,
        training_labels_df::DataFrames.AbstractDataFrame,
        tuning_features_df::Union{Nothing, DataFrames.AbstractDataFrame} =
            nothing,
        tuning_labels_df::Union{Nothing, DataFrames.AbstractDataFrame} =
            nothing;
        kwargs...
        )
    result = transform(
        transformer,
        training_features_df,
        training_labels_df,
        tuning_features_df,
        tuning_labels_df;
        kwargs...
        )
    return result
end

"""
"""
function predict(
        transformer::MutableDataFrame2ClassificationKnetTransformer,
        features_df::DataFrames.AbstractDataFrame;
        kwargs...
        )
    return transform(transformer, features_df)
end

"""
"""
function transform(
        transformer::MutableDataFrame2ClassificationKnetTransformer,
        positive_class::AbstractString;
        kwargs...
        )
    if length(transformer.label_names) == 0
        error("length(transformer.label_names) == 0")
    elseif length(transformer.label_names) == 1
        label_1 = transformer.label_names[1]
        levels_1 = transformer.label_levels[label_1]
        labelstring2intmap_1 = getlabelstring2intmap(
            levels_1,
            transformer.index,
            )
        transformed_positive_class = labelstring2intmap_1[positive_class]
    else
        error("unsupported behavior")
        # training_labels_array = Array{Int}(
        #     size(training_labels_df, 1),
        #     length(transformer.label_names),
        #     )
        # for j = 1:length(transformer.label_names)
        #     label_j = transformer.label_names[j]
        #     levels_j = transformer.label_levels[label_j]
        #     labelstring2intmap_j = getlabelstring2intmap(
        #         levels_j,
        #         transformer.index,
        #         )
        #     training_labels_array[:, j] =
        #         [labelstring2intmap_j[y] for y in labels_df[label_j]]
        # end
    end
    return transformed_positive_class
end

"""
"""
function predict(
        transformer::MutableDataFrame2ClassificationKnetTransformer,
        features_df::DataFrames.AbstractDataFrame,
        positive_class::AbstractString,
        varargs...;
        kwargs...
        )
    result = (transform(transformer, features_df),
              transform(transformer, positive_class),
              varargs...)
    return result
end

"""
"""
function predict_proba(
        transformer::MutableDataFrame2ClassificationKnetTransformer,
        features_df::DataFrames.AbstractDataFrame;
        kwargs...
        )
    return transform(transformer, features_df)
end

"""
"""
function predict(
        transformer::MutableDataFrame2RegressionKnetTransformer,
        features_df::DataFrames.AbstractDataFrame;
        kwargs...
        )
    result = transform(
        transformer,
        features_df;
        kwargs...
        )
    return result
end

"""
"""
function predict_proba(
        transformer::MutableDataFrame2RegressionKnetTransformer,
        features_df::DataFrames.AbstractDataFrame;
        kwargs...
        )
    result = transform(
        transformer,
        features_df;
        kwargs...
        )
    return result
end

"""
"""
function transform(
        transformer::MutableDataFrame2ClassificationKnetTransformer,
        training_features_df::DataFrames.AbstractDataFrame,
        training_labels_df::DataFrames.AbstractDataFrame,
        tuning_features_df::Union{Nothing, DataFrames.AbstractDataFrame} =
            nothing,
        tuning_labels_df::Union{Nothing, DataFrames.AbstractDataFrame} =
            nothing;
        kwargs...
        )
    if is_nothing(tuning_features_df) &&
            is_nothing(tuning_labels_df)
        has_tuning_data = false
    elseif !is_nothing(tuning_features_df) &&
            !is_nothing(tuning_labels_df)
        has_tuning_data = true
    else
        error(
            string(
                "Either both tuning_features_df ",
                "and tuning_labels_df ",
                "must be defined, or neither can be defined."
                )
            )
    end
    if length(transformer.label_names) == 0
        error("length(transformer.label_names) == 0")
    elseif length(transformer.label_names) == 1
        label_1 = transformer.label_names[1]
        levels_1 = transformer.label_levels[label_1]
        labelstring2intmap_1 = getlabelstring2intmap(
            levels_1,
            transformer.index,
            )
        training_labels_array =
            [labelstring2intmap_1[y] for y in training_labels_df[label_1]]
    else
        training_labels_array = Array{Int}(
            size(training_labels_df, 1),
            length(transformer.label_names),
            )
        for j = 1:length(transformer.label_names)
            label_j = transformer.label_names[j]
            levels_j = transformer.label_levels[label_j]
            labelstring2intmap_j = getlabelstring2intmap(
                levels_j,
                transformer.index,
                )
            training_labels_array[:, j] =
                [labelstring2intmap_j[y] for y in labels_df[label_j]]
        end
    end
    my_formula = transformer.dffeaturecontrasts.formula_without_intercept
    my_schema = transformer.dffeaturecontrasts.schema_without_intercept
    my_formula = StatsModels.apply_schema(my_formula, my_schema)
    response, training_features_array = StatsModels.modelcols(my_formula,
                                                 training_features_df)
    if transformer.transposefeatures
        training_features_array = transpose(training_features_array)
    end
    if transformer.transposelabels
        training_labels_array = transpose(training_labels_array)
    end
    training_features_array = convert(Array, training_features_array)
    training_labels_array = convert(Array, training_labels_array)
    if has_tuning_data
        tuning_features_array, tuning_labels_array = transform(
            transformer,
            tuning_features_df,
            tuning_labels_df;
            kwargs...
            )
        return training_features_array,
            training_labels_array,
            tuning_features_array,
            tuning_labels_array
    else
        return training_features_array,
            training_labels_array
    end
end

"""
"""
function transform(
        transformer::MutableDataFrame2ClassificationKnetTransformer,
        features_df::DataFrames.AbstractDataFrame;
        kwargs...
        )
    my_formula = transformer.dffeaturecontrasts.formula_without_intercept
    my_schema = transformer.dffeaturecontrasts.schema_without_intercept
    my_formula = StatsModels.apply_schema(my_formula, my_schema)
    response, featuresarray = StatsModels.modelcols(my_formula,
                                                    features_df)
    if transformer.transposefeatures
        featuresarray = transpose(featuresarray)
    end
    return featuresarray
end

"""
"""
function transform(
        transformer::MutableDataFrame2RegressionKnetTransformer,
        training_features_df::DataFrames.AbstractDataFrame,
        training_labels_df::DataFrames.AbstractDataFrame,
        tuning_features_df::Union{Nothing, DataFrames.AbstractDataFrame} =
            nothing,
        tuning_labels_df::Union{Nothing, DataFrames.AbstractDataFrame} =
            nothing;
        kwargs...
        )
    if is_nothing(tuning_features_df) &&
            is_nothing(tuning_labels_df)
        has_tuning_data = false
    elseif !is_nothing(tuning_features_df) &&
            !is_nothing(tuning_labels_df)
        has_tuning_data = true
    else
        error(
            string(
                "Either both tuning_features_df ",
                "and tuning_labels_df ",
                "must be defined, or neither can be defined.",
                )
            )
    end
    training_labels_array = hcat(
        [
            training_labels_df[label] for label in transformer.label_names
            ]...
        )
    my_formula = transformer.dffeaturecontrasts.formula_without_intercept
    my_schema = transformer.dffeaturecontrasts.schema_without_intercept
    my_formula = StatsModels.apply_schema(my_formula, my_schema)
    response, training_features_array = StatsModels.modelcols(my_formula,
                                                 training_features_df)
    if transformer.transposefeatures
        training_features_array = transpose(training_features_array)
    end
    if transformer.transposelabels
        training_labels_array = transpose(training_labels_array)
    end
    training_features_array = convert(Array, training_features_array)
    training_labels_array = convert(Array, training_labels_array)
    if has_tuning_data
        tuning_features_array, tuning_labels_array = transform(
            transformer,
            tuning_features_df,
            tuning_labels_df;
            kwargs...
            )
        return training_features_array,
            training_labels_array,
            tuning_features_array,
            tuning_labels_array
    else
        return training_features_array,
            training_labels_array
    end
end

"""
"""
function transform(
        transformer::MutableDataFrame2RegressionKnetTransformer,
        features_df::DataFrames.AbstractDataFrame,
        kwargs...
        )
    my_formula = transformer.dffeaturecontrasts.formula_without_intercept
    my_schema = transformer.dffeaturecontrasts.schema_without_intercept
    my_formula = StatsModels.apply_schema(my_formula, my_schema)
    response, featuresarray = StatsModels.modelcols(my_formula,
                                                    features_df)
    if transformer.transposefeatures
        featuresarray = transpose(featuresarray)
    end
    return featuresarray
end
