import DataFrames
import StatsModels

mutable struct MutableDataFrame2ClassificationKnetTransformer <:
        AbstractPrimitiveObject
    featurenames::T1 where T1 <: AbstractVector
    labelnames::T2 where T2 <: SymbolVector
    labellevels::T3 where T3 <: Associative
    index::T4 where T4 <: Integer
    transposefeatures::T5 where T5 <: Bool
    transposelabels::T6 where T6 <: Bool
    dffeaturecontrasts::T7 where T7 <: AbstractContrasts
    function MutableDataFrame2ClassificationKnetTransformer(
            featurenames::AbstractVector,
            labelnames::SymbolVector,
            labellevels::Associative,
            index::Integer;
            transposefeatures::Bool = true,
            transposelabels::Bool = false,
            )
        result = new(
            featurenames,
            labelnames,
            labellevels,
            index,
            transposefeatures,
            transposelabels,
            )
        return result
    end
end

function setfeaturecontrasts!(
        x::MutableDataFrame2ClassificationKnetTransformer,
        contrasts::AbstractContrasts,
        )
    x.dffeaturecontrasts = contrasts
    return nothing
end

function getunderlying(
        x::MutableDataFrame2ClassificationKnetTransformer;
        saving::Bool = false,
        loading::Bool = false,
        )
    result = x.dffeaturecontrasts
    return result
end

function setunderlying!(
        x::MutableDataFrame2ClassificationKnetTransformer,
        contrasts;
        saving::Bool = false,
        loading::Bool = false,
        )
    x.dffeaturecontrasts = contrasts
    return nothing
end

function gethistory(
        x::MutableDataFrame2ClassificationKnetTransformer;
        saving::Bool = false,
        loading::Bool = false,
        )
    return nothing
end

function sethistory!(
        x::MutableDataFrame2ClassificationKnetTransformer,
        h;
        saving::Bool = false,
        loading::Bool = false,
        )
    return nothing
end

function transform(
        transformer::MutableDataFrame2ClassificationKnetTransformer,
        featuresdf::DataFrames.AbstractDataFrame,
        labelsdf::DataFrames.AbstractDataFrame;
        kwargs...
        )
    if length(transformer.labelnames) == 0
        error("length(transformer.labelnames) == 0")
    elseif length(transformer.labelnames) == 1
        label_1 = transformer.labelnames[1]
        levels_1 = transformer.labellevels[label_1]
        labelstring2intmap_1 = _getlabelstring2intmap(
            levels_1,
            transformer.index,
            )
        labelsarray = [labelstring2intmap_1[y] for y in labelsdf[label_1]]
        @assert(typeof(labelsarray) <: AbstractVector)
        @assert(length(labelsarray) == size(labelsdf, 1))
    else
        labelsarray =
            -99 * ones(size(labelsdf, 1), length(transformer.labelnames))
        for j = 1:length(transformer.labelnames)
            label_j = transformer.labelnames[j]
            levels_j = transformer.labellevels[label_j]
            labelstring2intmap_j = _getlabelstring2intmap(
                levels_j,
                transformer.index,
                )
            labelsarray[:, j] =
                [labelstring2intmap_j[y] for y in labelsdf[label_j]]
        end
    end
    modelformula = makeformula(
        transformer.featurenames[1],
        transformer.featurenames;
        intercept = false
        )
    modelframe = StatsModels.ModelFrame(
        modelformula,
        featuresdf;
        contrasts = transformer.dffeaturecontrasts.featurecontrasts,
        )
    modelmatrix = StatsModels.ModelMatrix(modelframe)
    featuresarray = modelmatrix.m
    if transformer.transposefeatures
        featuresarray = transpose(featuresarray)
    end
    if transformer.transposelabels
        labelsarray = transpose(labelsarray)
    end
    featuresarray = convert(Array, featuresarray)
    labelsarray = convert(Array, labelsarray)
    return featuresarray, labelsarray
end

function transform(
        transformer::MutableDataFrame2ClassificationKnetTransformer,
        featuresdf::DataFrames.AbstractDataFrame,
        kwargs...
        )
    modelformula = makeformula(
        transformer.featurenames[1],
        transformer.featurenames;
        intercept = false
        )
    modelframe = StatsModels.ModelFrame(
        modelformula,
        featuresdf;
        contrasts = transformer.dffeaturecontrasts.featurecontrasts,
        )
    modelmatrix = StatsModels.ModelMatrix(modelframe)
    featuresarray = modelmatrix.m
    if transformer.transposefeatures
        featuresarray = transpose(featuresarray)
    end
    return featuresarray
end

function fit!(
        transformer::MutableDataFrame2ClassificationKnetTransformer,
        featuresdf::DataFrames.AbstractDataFrame,
        labelsdf::DataFrames.AbstractDataFrame;
        kwargs...
        )
    return transform(transformer, featuresdf, labelsdf)
end

function predict(
        transformer::MutableDataFrame2ClassificationKnetTransformer,
        featuresdf::DataFrames.AbstractDataFrame;
        kwargs...
        )
    return transform(transformer, featuresdf)
end

function predict_proba(
        transformer::MutableDataFrame2ClassificationKnetTransformer,
        featuresdf::DataFrames.AbstractDataFrame;
        kwargs...
        )
    return transform(transformer, featuresdf)
end

mutable struct MutableDataFrame2RegressionKnetTransformer <:
        AbstractPrimitiveObject
    featurenames::T1 where T1 <: AbstractVector
    labelnames::T2 where T2 <: SymbolVector
    transposefeatures::T3 where T3 <: Bool
    transposelabels::T4 where T4 <: Bool
    dffeaturecontrasts::T5 where T5 <: AbstractContrasts
    function MutableDataFrame2RegressionKnetTransformer(
            featurenames::AbstractVector,
            labelnames::SymbolVector;
            transposefeatures::Bool = true,
            transposelabels::Bool = false,
            )
        result = new(
            featurenames,
            labelnames,
            transposefeatures,
            transposelabels,
            )
        return result
    end
end

function setfeaturecontrasts!(
        x::MutableDataFrame2RegressionKnetTransformer,
        contrasts::AbstractContrasts,
        )
    x.dffeaturecontrasts = contrasts
    return nothing
end

function getunderlying(
        x::MutableDataFrame2RegressionKnetTransformer;
        saving::Bool = false,
        loading::Bool = false,
        )
    result = x.dffeaturecontrasts
    return result
end

function setunderlying!(
        x::MutableDataFrame2RegressionKnetTransformer,
        object;
        saving::Bool = false,
        loading::Bool = false,
        )
    x.dffeaturecontrasts = object
    return nothing
end

function gethistory(
        x::MutableDataFrame2RegressionKnetTransformer;
        saving::Bool = false,
        loading::Bool = false,
        )
    return nothing
end

function sethistory!(
        x::MutableDataFrame2RegressionKnetTransformer,
        h;
        saving::Bool = false,
        loading::Bool = false,
        )
    return nothing
end

function transform(
        transformer::MutableDataFrame2RegressionKnetTransformer,
        featuresdf::DataFrames.AbstractDataFrame,
        labelsdf::DataFrames.AbstractDataFrame;
        kwargs...
        )
    labelsarray = hcat(
        [
            labelsdf[label] for label in transformer.labelnames
            ]...
        )
    modelformula = makeformula(
        transformer.featurenames[1],
        transformer.featurenames;
        intercept = false
        )
    modelframe = StatsModels.ModelFrame(
        modelformula,
        featuresdf;
        contrasts = transformer.dffeaturecontrasts.featurecontrasts,
        )
    modelmatrix = StatsModels.ModelMatrix(modelframe)
    featuresarray = modelmatrix.m
    if transformer.transposefeatures
        featuresarray = transpose(featuresarray)
    end
    if transformer.transposelabels
        labelsarray = transpose(labelsarray)
    end
    featuresarray = convert(Array, featuresarray)
    labelsarray = convert(Array, labelsarray)
    return featuresarray, labelsarray
end

function transform(
        transformer::MutableDataFrame2RegressionKnetTransformer,
        featuresdf::DataFrames.AbstractDataFrame,
        kwargs...
        )
    modelformula = makeformula(
        transformer.featurenames[1],
        transformer.featurenames;
        intercept = false
        )
    modelframe = StatsModels.ModelFrame(
        modelformula,
        featuresdf;
        contrasts = transformer.dffeaturecontrasts.featurecontrasts,
        )
    modelmatrix = StatsModels.ModelMatrix(modelframe)
    featuresarray = modelmatrix.m
    if transformer.transposefeatures
        featuresarray = transpose(featuresarray)
    end
    return featuresarray
end

function fit!(
        transformer::MutableDataFrame2RegressionKnetTransformer,
        featuresdf::DataFrames.AbstractDataFrame,
        labelsdf::DataFrames.AbstractDataFrame;
        kwargs...
        )
    return transform(transformer, featuresdf, labelsdf)
end

function predict(
        transformer::MutableDataFrame2RegressionKnetTransformer,
        featuresdf::DataFrames.AbstractDataFrame;
        kwargs...
        )
    return transform(transformer, featuresdf)
end

function predict_proba(
        transformer::MutableDataFrame2RegressionKnetTransformer,
        featuresdf::DataFrames.AbstractDataFrame;
        kwargs...
        )
    return transform(transformer, featuresdf)
end