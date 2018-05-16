import Base.Test

dict_1 = Dict()
dict_1[Symbol(:x)] = Float64(1.1)
dict_1[Symbol(:y)] = Float64(2.2)
dict_1[Symbol(:z)] = Float64(3.3)
Base.Test.@test(typeof(dict_1) <: Dict{Any, Any})

dict_2 = PredictMD.fix_dict_type(dict_1)
Base.Test.@test(typeof(dict_2) <: Dict{Symbol, Float64})

dict_3 = PredictMD.fix_dict_type(dict_2)
Base.Test.@test(typeof(dict_3) <: Dict{Symbol, Float64})

dict_4 = PredictMD.fix_dict_type(dict_3)
Base.Test.@test(typeof(dict_4) <: Dict{Symbol, Float64})
