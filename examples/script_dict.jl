include("config.jl")

function main()
  defaults = Dict("global_seed" => 0,
                  "optimizer" => Dict("name" => "adam", "learning_rate" => 3.0f-3,
                                      "scheduler" => Dict("name" => "cosine",
                                                          "min_learning_rate" => 1.0f-4)),
                  "model" => Dict("backbone" => "resnet18", "stage_size" => [2, 2, 2, 2]))

  cfg = define_configuration(ExperimentConfig, defaults)
  println(cfg)

  return cfg
end

if abspath(PROGRAM_FILE) == @__FILE__
  main()
end
