import AUC
import DataFrames
import MLBase
import Plots
import ScikitLearn

ScikitLearn.@sk_import metrics: auc

#############################################################################

struct ModelPerformance{M} <:
        AbstractModelPerformance{M}
    blobs::A where A <: Associative
end

function hastraining{M<:AbstractSingleLabelBinaryClassifier}(
        modelperf::ModelPerformance{M},
        )
    return haskey(modelperf.blobs[:subsetblobs], :training)
end

function hasvalidation{M<:AbstractSingleLabelBinaryClassifier}(
        modelperf::ModelPerformance{M},
        )
    return haskey(modelperf.blobs[:subsetblobs], :validation)
end

function hastesting{M<:AbstractSingleLabelBinaryClassifier}(
        modelperf::ModelPerformance{M},
        )
    return haskey(modelperf.blobs[:subsetblobs], :testing)
end

dataname(perf::ModelPerformance) = perf.blobs[:data_name]
modelname(perf::ModelPerformance) = perf.blobs[:model_name]

function ModelPerformance{M<:AbstractModelly}(
        model::M;
        kwargs...
        )
    error("not implemented for model type $(M)")
end

function ModelPerformance{M<:AbstractSingleLabelBinaryClassifier}(
        model::M;
        kwargs...
        )
    subsetblobs = Dict()
    #
    if hastraining(model)
        table_training, blobs_training = _modelperformancetablerow(
            model,
            :Training;
            kwargs...
            )
        subsetblobs[:training] = blobs_training
    else
        table_training = DataFrames.DataFrame()
    end
    #
    if hasvalidation(model)
        table_validation, blobs_validation = _modelperformancetablerow(
            model,
            :Validation;
            kwargs...
            )
        subsetblobs[:validation] = blobs_validation
    else
        table_validation = DataFrames.DataFrame()
    end
    #
    if hastesting(model)
        table_testing, blobs_testing = _modelperformancetablerow(
            model,
            :Testing;
            kwargs...
            )
        subsetblobs[:testing] = blobs_testing
    else
        table_testing = DataFrames.DataFrame()
    end
    #
    table = vcat(
        table_training,
        table_validation,
        table_testing,
        )
    #
    blobs = Dict()
    blobs[:table] = table
    blobs[:subsetblobs] = subsetblobs
    blobs[:model_name] = modelname(model)
    blobs[:data_name] = dataname(model)
    return ModelPerformance{M}(blobs)
end

function _modelperformancetablerow(
        model::M where M <: AbstractSingleLabelBinaryClassifier,
        subset::Symbol;
        kwargs...
        )
    table_subset = DataFrames.DataFrame()
    numrows, y_true, y_score = _get_numrows_y_true_y_score(model, subset)
    metricblobs = _binaryclassifiermetrics(
        ensurevector(y_true),
        ensurevector(y_score);
        kwargs...
        )
    table_subset[:Subset] = string(subset)
    table_subset[:N] = numrows
    table_subset[:AUROCC_trapz] = metricblobs[:AUROCC_trapz]
    table_subset[:AUPRC_trapz] = metricblobs[:AUPRC_trapz]
    table_subset[:Average_Precision] = metricblobs[:Average_Precision]
    threshold, ind = _selectbinaryclassifierthreshold(
        metricblobs;
        kwargs...
        )
    @assert(threshold == metricblobs[:all_thresholds][ind])
    table_subset[:Threshold] = threshold
    table_subset[:Accuracy] = metricblobs[:all_accuracy][ind]
    table_subset[:Sensitivity] = metricblobs[:all_sensitivity][ind]
    table_subset[:Specificity] = metricblobs[:all_specificity][ind]
    table_subset[:Precision] = metricblobs[:all_precision][ind]
    table_subset[:Recall] = metricblobs[:all_recall][ind]
    table_subset[:F1_Score] = metricblobs[:all_f1score][ind]
    table_subset[:F2_Score] = metricblobs[:all_f2score][ind]
    table_subset[:F0pt5_Score] = metricblobs[:all_f0pt5score][ind]
    return table_subset, metricblobs
end

function _get_numrows_y_true_y_score(
        model::M where M <: AbstractSingleLabelBinaryClassifier,
        subset::Symbol,
        )
    if subset == :Training
        if hastraining(model)
            numrows = numtraining(model)
            y_true = model.blobs[:true_labels_training]
            y_score = model.blobs[:predicted_proba_training]
            return numrows, y_true, y_score
        else
            error("model doesn't have a training subset")
        end
    elseif subset == :Validation
        if hasvalidation(model)
            numrows = numvalidation(model)
            y_true = model.blobs[:true_labels_validation]
            y_score = model.blobs[:predicted_proba_validation]
            return numrows, y_true, y_score
        else
            error("model doesn't have a validation subset")
        end
    elseif subset == :Testing
        if hastesting(model)
            numrows = numtesting(model)
            y_true = model.blobs[:true_labels_testing]
            y_score = model.blobs[:predicted_proba_testing]
            return numrows, y_true, y_score
        else
            error("model doesn't have a testing subset")
        end
    else
        error("subset must be one of :Training, :Validation, :Testing")
    end
end

function _binaryclassifiermetrics(
        y_true::StatsBase.IntegerVector,
        y_score::StatsBase.RealVector;
        kwargs...
        )
    metricblobs = Dict()
    metricblobs[:y_true] = y_true
    metricblobs[:y_score] = y_score
    #
    kwargs_dict = Dict(kwargs)
    if haskey(kwargs_dict, :threshold)
        additional_threshold = kwargs_dict[:threshold]
    else
        additional_threshold = 0
    end
    if length(y_true) != length(y_score)
        error("y_true and y_score must have the same length")
    end
    if length(y_true) == 0
        error("y_true must be non-empy")
    end
    y_true_uniqueset = Set(y_true)
    if y_true_uniqueset != Set([0, 1])
        if y_true_uniqueset == Set([0])
            warn("only one class (0) is present in y_true")
        elseif y_true_uniqueset == Set([1])
            warn("only one class (1) is present in y_true")
        else
            error("y_true contains values other than 0 and 1")
        end
    end
    if !all( 0 .<= y_score .<= 1  )
        error("every element in y_score must be >=0 and <=1")
    end
    #
    all_thresholds = sort(
        unique(
            vcat(
                y_score,
                additional_threshold,
                0 - eps(),
                0,
                0 + eps(),
                1 - eps(),
                1,
                1 + eps(),
                )
            )
        )
    metricblobs[:all_thresholds] = all_thresholds
    #
    all_rocnums = MLBase.roc(
        y_true,
        y_score,
        all_thresholds,
        MLBase.Forward,
        )
    metricblobs[:all_rocnums] = all_rocnums
    #
    all_accuracy =
        [accuracy_nanfixed(r) for r in all_rocnums]
    metricblobs[:all_accuracy] = all_accuracy
    #
    all_sensitivity =
        [true_positive_rate_nanfixed(r) for r in all_rocnums]
    metricblobs[:all_sensitivity] = all_sensitivity
    #
    all_specificity =
        [true_negative_rate_nanfixed(r) for r in all_rocnums]
    metricblobs[:all_specificity] = all_specificity
    #
    all_precision =
        [precision_nanfixed(r) for r in all_rocnums]
    metricblobs[:all_precision] = all_precision
    #
    all_recall =
        [recall_nanfixed(r) for r in all_rocnums]
    metricblobs[:all_recall] =all_recall
    #
    @assert( all( all_sensitivity .== all_recall ) )
    #
    all_f1score = fbetascore(all_precision, all_recall, 1)
    metricblobs[:all_f1score] = all_f1score
    #
    all_f2score = fbetascore(all_precision, all_recall, 2)
    metricblobs[:all_f2score] = all_f2score
    #
    all_f0pt5score = fbetascore(all_precision, all_recall, 0.5)
    metricblobs[:all_f0pt5score] = all_f0pt5score
    #
    all_fpr = 1 .- all_specificity
    all_tpr = all_sensitivity
    metricblobs[:all_fpr] = all_fpr
    metricblobs[:all_tpr] = all_tpr
    aurocc = trapz(; x=all_fpr, y=all_tpr)
    metricblobs[:AUROCC_trapz] = aurocc
    #
    auprc = trapz(; x=all_recall, y=all_precision)
    metricblobs[:AUPRC_trapz] = auprc
    #
    average_precision = "not_calculated"
    metricblobs[:Average_Precision] = average_precision
    return metricblobs
end

function _getparametertouseforselectingthreshold(
        ;
        kwargs...
        )
    kwargs_dict = Dict(kwargs)
    possible_to_maximize = [
        :precision,
        :f1score,
        :f2score,
        :f0pt5score,
        ]
    possible_parameters = [
        :maximize,
        :threshold,
        :sensitivity,
        :specificity,
        :precision,
        :recall,
        :f1score,
        :f0pt5score,
        ]
    num_possible_parameters = length(possible_parameters)
    parameters_provided = trues(num_possible_parameters)
    for i = 1:num_possible_parameters
        parameters_provided[i] = haskey(kwargs_dict, possible_parameters[i])
    end
    num_parameters_actuallyprovided = sum(parameters_provided)
    if num_parameters_actuallyprovided == 0
        return :sensitivity, 0.9
    elseif num_parameters_actuallyprovided == 1
        sel_param_index = find(parameters_provided)[1]
        sel_param = possible_parameters[sel_param_index]
        sel_param_val = kwargs_dict[sel_param]
        if sel_param==:maximize && !(sel_param_val in possible_to_maximize)
            error("$(sel_param_val) is not a valid value for :maximize")
        end
        return sel_param, sel_param_val
    else
        error("you cannot provide more than one threshold-tuning param.")
    end
end

function _selectbinaryclassifierthreshold(
        metricblobs;
        kwargs...
        )
    parameter, parameter_value = _getparametertouseforselectingthreshold(
        ;
        kwargs...
        )
    if parameter == :maximize
        if parameter_value == :precision
            ind = indmax(metricblobs[:all_precision])
        elseif parameter_value == :f1score
            ind = indmax(metricblobs[:all_f1score])
        elseif parameter_value == :f2score
            ind = indmax(metricblobs[:all_f2score])
        elseif parameter_value == :f0pt5score
            ind = indmax(metricblobs[:all_f0pt5score])
        else
            error("whoops something bad happened")
        end
    elseif parameter == :threshold
        ind = findnearest(metricblobs[:all_thresholds], parameter_value)[1]
    elseif parameter == :sensitivity
        ind = findnearest(metricblobs[:all_sensitivity], parameter_value)[1]
    elseif parameter == :specificity
        ind = findnearest(metricblobs[:all_specificity], parameter_value)[1]
    elseif parameter == :precision
        ind = findnearest(metricblobs[:all_precision], parameter_value)[1]
    elseif parameter == :recall
        ind = findnearest(metricblobs[:all_recall], parameter_value)[1]
    elseif parameter == :f1score
        ind = findnearest(metricblobs[:all_f1score], parameter_value)[1]
    else
        error("oh no something bad happened")
    end
    threshold = metricblobs[:all_thresholds][ind]
    return threshold, ind
end

function Base.show(
        io::IO,
        mp::ModelPerformance,
        )
    hrule = repeat("*", 79)
    println(io, hrule)
    println(io, typeof(mp))
    println(io, hrule)
    return DataFrames.showall(io,mp.blobs[:table],false,Symbol(""),false)
end

#############################################################################

function classifierhistograms{M<:AbstractModelly}(
        modelperf::ModelPerformance{M};
        kwargs...
        )
    error("not implemented for model type $(M)")
end

function classifierhistograms(
        modelperf::ModelPerformance{M};
        showtraining = hastraining(modelperf),
        showvalidation = hasvalidation(modelperf),
        showtesting = hastesting(modelperf),
        numbins = 50,
        bins = linspace(0, 1, numbins),
        ) where
        M<:AbstractSingleLabelBinaryClassifier
    #
    if showtraining && !hastraining(modelperf)
        error("showtraining is true but model doesn't have training data")
    end
    if showvalidation && !hasvalidation(modelperf)
        error("showvalidation is true but model doesn't have validation data")
    end
    if showtesting && !hastesting(modelperf)
        error("showtesting is true but model doesn't have testing data")
    end
    #
    if showtraining + showvalidation + showtesting == 0
        error("must select at least one of training, validation, testing")
    end
    #
    if hastraining(modelperf)
        y_true_training =
            modelperf.blobs[:subsetblobs][:training][:y_true]
        y_score_training =
            modelperf.blobs[:subsetblobs][:training][:y_score]
    else
        y_true_training = []
        y_score_training = []
    end
    if hasvalidation(modelperf)
        y_true_validation =
            modelperf.blobs[:subsetblobs][:validation][:y_true]
        y_score_validation =
            modelperf.blobs[:subsetblobs][:validation][:y_score]
    else
        y_true_validation = []
        y_score_validation = []
    end
    if hastesting(modelperf)
        y_true_testing =
            modelperf.blobs[:subsetblobs][:testing][:y_true]
        y_score_testing =
            modelperf.blobs[:subsetblobs][:testing][:y_score]
    else
        y_true_testing = []
        y_score_testing = []
    end
    y_true_all = vcat(y_true_training, y_true_validation, y_true_testing)
    classes = sort(collect(unique(y_true_all)))
    num_classes = length(classes)
    if num_classes != 2
        error("num_classes != 2")
    end
    #
    subplots_arr = []
    if showtraining && hastraining(modelperf)
        h = Plots.histogram(
            y_score_training[ y_true_training .== classes[1] ],
            label = "class = " * string(classes[1]),
            title = "Scores (training set)",
            xlabel = "score",
            ylabel = "frequency",
            # legend = :outertopright,
            bins = bins,
            )
        Plots.histogram!(
            h,
            y_score_training[ y_true_training .== classes[2] ],
            label = "class = " * string(classes[2]),
            bins = bins,
            )
        push!(subplots_arr, h)
    end
    if showvalidation && hasvalidation(modelperf)
        h = Plots.histogram(
            y_score_validation[ y_true_validation .== classes[1] ],
            label = "class = " * string(classes[1]),
            title = "Scores (validation set)",
            xlabel = "score",
            ylabel = "frequency",
            # legend = :outertopright,
            bins = bins,
            )
        Plots.histogram!(
            h,
            y_score_validation[ y_true_validation .== classes[2] ],
            label = "class = " * string(classes[2]),
            bins = bins,
            )
        push!(subplots_arr, h)
    end
    if showtesting && hastesting(modelperf)
        h = Plots.histogram(
            y_score_testing[ y_true_testing .== classes[1] ],
            label = "class = " * string(classes[1]),
            title = "Scores (testing set)",
            xlabel = "score",
            ylabel = "frequency",
            # legend = :outertopright,
            bins = bins,
            )
        Plots.histogram!(
            h,
            y_score_testing[ y_true_testing .== classes[2] ],
            label = "class = " * string(classes[2]),
            bins = bins,
            )
        push!(subplots_arr, h)
    end
    finalplot = Plots.plot(subplots_arr...)
    return finalplot
end

#############################################################################

function plots(
        mp::T;
        kwargs...
        ) where
        T<:ModelPerformance{M} where
        M<:AbstractModelly
    result = plots(
        vcat(mp);
        kwargs...
        )
    return result
end

function plots(
        perflist::AbstractVector{T};
        kwargs...
        ) where
        T<:ModelPerformance{M} where
        M<:AbstractModelly
    #
    num_perfs = length(perflist)
    if num_perfs == 0
        error("perflist must be nonempty")
    end
    #
    error("not implemented for model type $(M)")
end

function plots(
        perflist::AbstractVector{T};
        showtraining::Bool = false,
        showvalidation::Bool = false,
        showtesting::Bool = true,
        roccurve::Bool = true,
        prcurve::Bool = true,
        ) where
        T<:ModelPerformance{M} where
        M<:AbstractSingleLabelBinaryClassifier
    #
    num_perfs = length(perflist)
    if num_perfs == 0
        error("perflist must be nonempty")
    end
    #
    if showtraining + showvalidation + showtesting == 0
        error("must select at least one of training, validation, testing")
    end
    if roccurve + prcurve == 0
        error("at least one of roccurve, prcurve must be true")
    end
    #
    if showtraining && !all([hastraining(perf) for perf in perflist])
        error("showtraining is true but not all models have training data")
    end
    if showvalidation && !all([hasvalidation(perf) for perf in perflist])
        error("showvalidation is true but not all models have validation data")
    end
    if showtesting && !all([hastesting(perf) for perf in perflist])
        error("showtesting is true but not all models have testing data")
    end
    #
    subplots_arr = []
    #
    if roccurve
        if showtraining
            perf = perflist[1]
            model_name = modelname(perf)
            fpr = perf.blobs[:subsetblobs][:training][:all_fpr]
            tpr = perf.blobs[:subsetblobs][:training][:all_tpr]
            p = Plots.plot(
                fpr,
                tpr,
                label = string(model_name),
                title = "ROC curve (training set)",
                xlabel = "1 - specificity",
                ylabel = "sensitivity",
                )
            if num_perfs > 1
                for i = 2:num_perfs
                    perf = perflist[i]
                    model_name = modelname(perf)
                    fpr = perf.blobs[:subsetblobs][:training][:all_fpr]
                    tpr = perf.blobs[:subsetblobs][:training][:all_tpr]
                    Plots.plot!(
                        p,
                        fpr,
                        tpr,
                        label = string(model_name),
                        )
                end
            end
            push!(subplots_arr, p)
        end
        if showvalidation
            perf = perflist[1]
            model_name = modelname(perf)
            fpr = perf.blobs[:subsetblobs][:validation][:all_fpr]
            tpr = perf.blobs[:subsetblobs][:validation][:all_tpr]
            p = Plots.plot(
                fpr,
                tpr,
                label = string(model_name),
                title = "ROC curve (validation set)",
                xlabel = "1 - specificity",
                ylabel = "sensitivity",
                )
            if num_perfs > 1
                for i = 2:num_perfs
                    perf = perflist[i]
                    model_name = modelname(perf)
                    fpr = perf.blobs[:subsetblobs][:validation][:all_fpr]
                    tpr = perf.blobs[:subsetblobs][:validation][:all_tpr]
                    Plots.plot!(
                        p,
                        fpr,
                        tpr,
                        label = string(model_name),
                        )
                end
            end
            push!(subplots_arr, p)
        end
        if showtesting
            perf = perflist[1]
            model_name = modelname(perf)
            fpr = perf.blobs[:subsetblobs][:testing][:all_fpr]
            tpr = perf.blobs[:subsetblobs][:testing][:all_tpr]
            p = Plots.plot(
                fpr,
                tpr,
                label = string(model_name),
                title = "ROC curve (testing set)",
                xlabel = "1 - specificity",
                ylabel = "sensitivity",
                )
            if num_perfs > 1
                for i = 2:num_perfs
                    perf = perflist[i]
                    model_name = modelname(perf)
                    fpr = perf.blobs[:subsetblobs][:testing][:all_fpr]
                    tpr = perf.blobs[:subsetblobs][:testing][:all_tpr]
                    Plots.plot!(
                        p,
                        fpr,
                        tpr,
                        label = string(model_name),
                        )
                end
            end
            push!(subplots_arr, p)
        end
    end
    #
    if prcurve
        if showtraining
            perf = perflist[1]
            model_name = modelname(perf)
            recall = perf.blobs[:subsetblobs][:training][:all_recall]
            precision = perf.blobs[:subsetblobs][:training][:all_precision]
            p = Plots.plot(
                recall,
                precision,
                label = string(model_name),
                title = "PR curve (training set)",
                xlabel = "recall",
                ylabel = "precision",
                )
            if num_perfs > 1
                for i = 2:num_perfs
                    perf = perflist[i]
                    model_name = modelname(perf)
                    recall = perf.blobs[:subsetblobs][:training][:all_recall]
                    precision = perf.blobs[:subsetblobs][:training][:all_precision]
                    Plots.plot!(
                        p,
                        recall,
                        precision,
                        label = string(model_name),
                        )
                end
            end
            push!(subplots_arr, p)
        end
        if showvalidation
            perf = perflist[1]
            model_name = modelname(perf)
            recall = perf.blobs[:subsetblobs][:validation][:all_recall]
            precision = perf.blobs[:subsetblobs][:validation][:all_precision]
            p = Plots.plot(
                recall,
                precision,
                label = string(model_name),
                title = "PR curve (validation set)",
                xlabel = "recall",
                ylabel = "precision",
                )
            if num_perfs > 1
                for i = 2:num_perfs
                    perf = perflist[i]
                    model_name = modelname(perf)
                    recall = perf.blobs[:subsetblobs][:validation][:all_recall]
                    precision = perf.blobs[:subsetblobs][:validation][:all_precision]
                    Plots.plot!(
                        p,
                        recall,
                        precision,
                        label = string(model_name),
                        title = "PR curve (validation set)",
                        )
                end
            end
            push!(subplots_arr, p)
        end
        if showtesting
            perf = perflist[1]
            model_name = modelname(perf)
            recall = perf.blobs[:subsetblobs][:testing][:all_recall]
            precision = perf.blobs[:subsetblobs][:testing][:all_precision]
            p = Plots.plot(
                recall,
                precision,
                label = string(model_name),
                title = "PR curve (testing set)",
                xlabel = "recall",
                ylabel = "precision",
                )
            if num_perfs > 1
                for i = 2:num_perfs
                    perf = perflist[i]
                    model_name = modelname(perf)
                    recall = perf.blobs[:subsetblobs][:testing][:all_recall]
                    precision = perf.blobs[:subsetblobs][:testing][:all_precision]
                    Plots.plot!(
                        p,
                        recall,
                        precision,
                        label = string(model_name),
                        title = "PR curve (testing set)",
                        )
                end
            end
            push!(subplots_arr, p)
        end
    end
    #
    finalplot = Plots.plot(subplots_arr...)
    return finalplot
end

#############################################################################

function learningcurves{M<:AbstractModelly}(
        modelperf::ModelPerformance{M};
        kwargs...
        )
    error("not implemented for model type $(M)")
end

#############################################################################