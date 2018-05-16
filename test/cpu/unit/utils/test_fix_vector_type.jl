import Base.Test

vector_1 = []
push!(vector_1, Float64(1.0))
push!(vector_1, Float64(2.0))
push!(vector_1, Float64(3.0))
Base.Test.@test(typeof(vector_1) <: Vector{Any})
Base.Test.@test(length(vector_1) == 3)
Base.Test.@test(size(vector_1) == (3,))

vector_2 = PredictMD.fix_vector_type(vector_1)
Base.Test.@test(typeof(vector_2) <: Vector{Float64})
Base.Test.@test(length(vector_2) == 3)
Base.Test.@test(size(vector_2) == (3,))
Base.Test.@test(vector_1[1] == 1.0)
Base.Test.@test(vector_1[2] == 2.0)
Base.Test.@test(vector_1[3] == 3.0)

vector_3 = PredictMD.fix_vector_type(vector_2)
Base.Test.@test(typeof(vector_3) <: Vector{Float64})
Base.Test.@test(length(vector_3) == 3)
Base.Test.@test(size(vector_3) == (3,))
Base.Test.@test(vector_1[1] == 1.0)
Base.Test.@test(vector_1[2] == 2.0)
Base.Test.@test(vector_1[3] == 3.0)

vector_4 = PredictMD.fix_vector_type(vector_3)
Base.Test.@test(length(vector_4) == 3)
Base.Test.@test(size(vector_4) == (3,))
Base.Test.@test(typeof(vector_4) <: Vector{Float64})
Base.Test.@test(vector_1[1] == 1.0)
Base.Test.@test(vector_1[2] == 2.0)
Base.Test.@test(vector_1[3] == 3.0)

##############################################################################

array_1 = Array{Any}(2,3,4)
array_1[1,1,1] = Float64(10)
array_1[1,1,2] = Float64(20)
array_1[1,1,3] = Float64(30)
array_1[1,1,4] = Float64(40)
array_1[1,2,1] = Float64(50)
array_1[1,2,2] = Float64(60)
array_1[1,2,3] = Float64(70)
array_1[1,2,4] = Float64(80)
array_1[1,3,1] = Float64(90)
array_1[1,3,2] = Float64(100)
array_1[1,3,3] = Float64(110)
array_1[1,3,4] = Float64(120)
array_1[2,1,1] = Float64(130)
array_1[2,1,2] = Float64(140)
array_1[2,1,3] = Float64(150)
array_1[2,1,4] = Float64(160)
array_1[2,2,1] = Float64(170)
array_1[2,2,2] = Float64(180)
array_1[2,2,3] = Float64(190)
array_1[2,2,4] = Float64(200)
array_1[2,3,1] = Float64(210)
array_1[2,3,2] = Float64(220)
array_1[2,3,3] = Float64(230)
array_1[2,3,4] = Float64(240)
Base.Test.@test(typeof(array_1) <: Array{Any, 3})
Base.Test.@test(length(array_1) == 24)
Base.Test.@test(size(array_1) == (2,3,4,))
Base.Test.@test(typeof(array_2) <: Array{Float64, 3})
Base.Test.@test(length(array_2) == 24)
Base.Test.@test(size(array_2) == (2,3,4,))
Base.Test.@test(array_2[1,1,1] == 10)
Base.Test.@test(array_2[1,1,2] == 20)
Base.Test.@test(array_2[1,1,3] == 30)
Base.Test.@test(array_2[1,1,4] == 40)
Base.Test.@test(array_2[1,2,1] == 50)
Base.Test.@test(array_2[1,2,2] == 60)
Base.Test.@test(array_2[1,2,3] == 70)
Base.Test.@test(array_2[1,2,4] == 80)
Base.Test.@test(array_2[1,3,1] == 90)
Base.Test.@test(array_2[1,3,2] == 100)
Base.Test.@test(array_2[1,3,3] == 110)
Base.Test.@test(array_2[1,3,4] == 120)
Base.Test.@test(array_2[2,1,1] == 130)
Base.Test.@test(array_2[2,1,2] == 140)
Base.Test.@test(array_2[2,1,3] == 150)
Base.Test.@test(array_2[2,1,4] == 160)
Base.Test.@test(array_2[2,2,1] == 170)
Base.Test.@test(array_2[2,2,2] == 180)
Base.Test.@test(array_2[2,2,3] == 190)
Base.Test.@test(array_2[2,2,4] == 200)
Base.Test.@test(array_2[2,3,1] == 210)
Base.Test.@test(array_2[2,3,2] == 220)
Base.Test.@test(array_2[2,3,3] == 230)
Base.Test.@test(array_2[2,3,4] == 240)

Base.Test.@test(typeof(array_3) <: Array{Float64, 3})
Base.Test.@test(length(array_3) == 24)
Base.Test.@test(size(array_3) == (2,3,4,))
Base.Test.@test(array_3[1,1,1] == 10)
Base.Test.@test(array_3[1,1,2] == 20)
Base.Test.@test(array_3[1,1,3] == 30)
Base.Test.@test(array_3[1,1,4] == 40)
Base.Test.@test(array_3[1,2,1] == 50)
Base.Test.@test(array_3[1,2,2] == 60)
Base.Test.@test(array_3[1,2,3] == 70)
Base.Test.@test(array_3[1,2,4] == 80)
Base.Test.@test(array_3[1,3,1] == 90)
Base.Test.@test(array_3[1,3,2] == 100)
Base.Test.@test(array_3[1,3,3] == 110)
Base.Test.@test(array_3[1,3,4] == 120)
Base.Test.@test(array_3[2,1,1] == 130)
Base.Test.@test(array_3[2,1,2] == 140)
Base.Test.@test(array_3[2,1,3] == 150)
Base.Test.@test(array_3[2,1,4] == 160)
Base.Test.@test(array_3[2,2,1] == 170)
Base.Test.@test(array_3[2,2,2] == 180)
Base.Test.@test(array_3[2,2,3] == 190)
Base.Test.@test(array_3[2,2,4] == 200)
Base.Test.@test(array_3[2,3,1] == 210)
Base.Test.@test(array_3[2,3,2] == 220)
Base.Test.@test(array_3[2,3,3] == 230)
Base.Test.@test(array_3[2,3,4] == 240)

Base.Test.@test(typeof(array_4) <: Array{Float64, 3})
Base.Test.@test(length(array_4) == 24)
Base.Test.@test(size(array_4) == (2,3,4,))
Base.Test.@test(array_4[1,1,1] == 10)
Base.Test.@test(array_4[1,1,2] == 20)
Base.Test.@test(array_4[1,1,3] == 30)
Base.Test.@test(array_4[1,1,4] == 40)
Base.Test.@test(array_4[1,2,1] == 50)
Base.Test.@test(array_4[1,2,2] == 60)
Base.Test.@test(array_4[1,2,3] == 70)
Base.Test.@test(array_4[1,2,4] == 80)
Base.Test.@test(array_4[1,3,1] == 90)
Base.Test.@test(array_4[1,3,2] == 100)
Base.Test.@test(array_4[1,3,3] == 110)
Base.Test.@test(array_4[1,3,4] == 120)
Base.Test.@test(array_4[2,1,1] == 130)
Base.Test.@test(array_4[2,1,2] == 140)
Base.Test.@test(array_4[2,1,3] == 150)
Base.Test.@test(array_4[2,1,4] == 160)
Base.Test.@test(array_4[2,2,1] == 170)
Base.Test.@test(array_4[2,2,2] == 180)
Base.Test.@test(array_4[2,2,3] == 190)
Base.Test.@test(array_4[2,2,4] == 200)
Base.Test.@test(array_4[2,3,1] == 210)
Base.Test.@test(array_4[2,3,2] == 220)
Base.Test.@test(array_4[2,3,3] == 230)
Base.Test.@test(array_4[2,3,4] == 240)
