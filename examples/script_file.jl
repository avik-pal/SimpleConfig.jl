include("config.jl")

function main()
  cfg = define_configuration(ExperimentConfig, joinpath(@__DIR__, "defaults.yml"))
  println(cfg)

  return cfg
end

if abspath(PROGRAM_FILE) == @__FILE__
  main()
end
