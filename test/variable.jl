#############################################################################
# JuMP
# An algebraic modelling langauge for Julia
# See http://github.com/JuliaOpt/JuMP.jl
#############################################################################
# test/expr.jl
# Testing for Variable
#############################################################################
using JuMP, FactCheck

facts("[variable] constructors") do
    # Constructors
    mcon = Model()
    @defVar(mcon, nobounds)
    @defVar(mcon, lbonly >= 0)
    @defVar(mcon, ubonly <= 1)
    @defVar(mcon, 0 <= bothb <= 1)
    @defVar(mcon, 0 <= onerange[-5:5] <= 10)
    @defVar(mcon, onerangeub[-7:1] <= 10, Int)
    @defVar(mcon, manyrangelb[0:1,10:20,1:1] >= 2)
    @fact getLower(manyrangelb[0,15,1]) => 2
    s = ["Green","Blue"]
    @defVar(mcon, x[i=-10:10,s] <= 5.5, Int, start=i+1)
    @fact getUpper(x[-4,"Green"]) => 5.5
    @fact getValue(x[-3,"Blue"]) => -2
end

facts("[variable] get and set bounds") do
    m = Model()
    @defVar(m, 0 <= x <= 2)
    @fact getLower(x) => 0
    @fact getUpper(x) => 2
    setLower(x, 1)
    @fact getLower(x) => 1
    setUpper(x, 3)
    @fact getUpper(x) => 3
    @defVar(m, y, Bin)
    @fact getLower(y) => 0
    @fact getUpper(y) => 1
    @defVar(m, 0 <= y <= 1, Bin)
    @fact getLower(y) => 0
    @fact getUpper(y) => 1
    @defVar(m, fixedvar == 2)
    @fact getValue(fixedvar) => 2
    @fact getLower(fixedvar) => 2
    @fact getUpper(fixedvar) => 2
    setValue(fixedvar, 5)
    @fact getValue(fixedvar) => 5
    @fact getLower(fixedvar) => 5
    @fact getUpper(fixedvar) => 5
end

facts("[variable] get and set category") do
    m = Model()
    @defVar(m, x[1:3])
    setCategory(x[2], :Int)
    @fact getCategory(x[3]) => :Cont
    @fact getCategory(x[2]) => :Int
end

facts("[variable] repeated elements in index set (issue #199)") do
    repeatmod = Model()
    s = [:x,:x,:y]
    @defVar(repeatmod, x[s])
    @fact getNumVars(repeatmod) => 3
end

# Test conditionals in variable definition
# condmod = Model()
# @defVar(condmod, x[i=1:10]; iseven(i))
# @defVar(condmod, y[j=1:10,k=3:2:9]; isodd(j+k) && k <= 8)
# @test JuMP.dictstring(x, :REPL)   == "x[i], for all i in {1..10} s.t. iseven(i) free"
# @test JuMP.dictstring(x, :IJulia) == "x_{i} \\quad \\forall i \\in \\{ 1..10 \\} s.t. iseven(i) free"
# @test JuMP.dictstring(y, :REPL)   == "y[i,j], for all i in {1..10}, j in {3,5..7,9} s.t. isodd(j + k) and k <= 8 free"
# @test JuMP.dictstring(y, :IJulia) == "y_{i,j} \\quad \\forall i \\in \\{ 1..10 \\}, j \\in \\{ 3,5..7,9 \\} s.t. isodd(j + k) and k <= 8 free"
# @test string(condmod) == "Min 0\nSubject to \nx[i], for all i in {1..10} s.t. iseven(i) free\ny[i,j], for all i in {1..10}, j in {3,5..7,9} s.t. isodd(j + k) and k <= 8 free\n" 
