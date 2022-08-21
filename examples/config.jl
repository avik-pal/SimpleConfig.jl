using SimpleConfig

@option struct SchedulerConfig
  name::String = "cosine"
  min_learning_rate::Float32 = 1.0f-4
end

@option struct OptimizerConfig
  name::String = "adam"
  learning_rate::Float32 = 3.0f-3
  scheduler::SchedulerConfig
end

@option struct ModelConfig
  backbone::String = "resnet18"
  stage_size::Vector{<:Int} = [2, 2, 2, 2]
end

@option struct ExperimentConfig
  global_seed::Int64 = 0
  optimizer::OptimizerConfig
  model::ModelConfig
end
