# SimpleConfig

[![CI](https://github.com/avik-pal/SimpleConfig.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/avik-pal/SimpleConfig.jl/actions/workflows/CI.yml)
[![codecov](https://codecov.io/gh/avik-pal/SimpleConfig.jl/branch/main/graph/badge.svg?token=plksEh6pUG)](https://codecov.io/gh/avik-pal/SimpleConfig.jl)
[![ColPrac: Contributor's Guide on Collaborative Practices for Community Packages](https://img.shields.io/badge/ColPrac-Contributor's%20Guide-blueviolet)](https://github.com/SciML/ColPrac)
[![SciML Code Style](https://img.shields.io/static/v1?label=code%20style&message=SciML&color=9558b2&labelColor=389826)](https://github.com/SciML/SciMLStyle)
[![Package Downloads](https://shields.io/endpoint?url=https://pkgs.genieframework.com/api/v1/badge/SimpleConfig)](https://pkgs.genieframework.com?packages=SimpleConfig)

Composes [Configurations.jl](https://configurations.rogerluo.dev/dev/) with
[ArgParse.jl](https://carlobaldassi.github.io/ArgParse.jl/stable/) making it easier to
write config files.

For users from the python world, this is similar to the functionality provided by
[ml_collections](https://github.com/google/ml_collections#config-flags).

## Installation

To install the module, use Julia's package manager: start pkg mode by pressing ] and then
enter:

```julia
(v1.7) pkg> add SimpleConfig
```

## Usage

### QuickStart

This package simply extends `Configurations.jl`. Follow the tutorial in its
[documentation](https://configurations.rogerluo.dev/stable/quick-start/), to define a
configuration. For example:

```julia
using SimpleConfig

@option struct SchedulerConfig
  name::String = "cosine"
  min_learning_rate::Float32 = 1f-4
end

@option struct OptimizerConfig
  name::String = "adam"
  learning_rate::Float32 = 3f-3
  scheduler::SchedulerConfig
end

@option struct ModelConfig
  backbone::String = "resnet18"
  stage_size = [2, 2, 2, 2]
end

@option struct ExperimentConfig
  global_seed::Int64 = 0
  optimizer::OptimizerConfig
  model::ModelConfig
end
```

One way to initialize the configuration would be to use the `from_dict` function from
Configurations.jl. For example:

```julia
using Configurations

defaults = Dict("global_seed" => 0,
                "optimizer" => Dict("name" => "adam", "learning_rate" => 3f-3,
                                    "scheduler" => Dict("name" => "cosine",
                                                        "min_learning_rate" => 1f-4)),
                "model" => Dict("backbone" => "resnet18", "stage_size" => [2, 2, 2, 2]))

cfg = from_dict(ExperimentConfig, defaults)
```

The main problem with this approach is that it is hard to use use in scripts, or when
running batch experiments with different configurations. We provide a simple function
`define_configuration`, which automatically creates a argparse settings, so that the 
configurations can be updated using command line arguments.

```julia
cfg = define_configuration(ExperimentConfig, defaults)
```

This simple line in your script will allow you to update the configuration via command
line arguments. The structure is extremely self-explainatory, run the script using
`--help` to see the available options.

### Basic Example Script

If we run the script `examples/script_dict.jl` with the following command:

```julia
$ julia --project=. examples/script_dict.jl --help

usage: script_dict.jl [--cfg.global_seed CFG.GLOBAL_SEED]
                      [--cfg.optimizer.name CFG.OPTIMIZER.NAME]
                      [--cfg.optimizer.learning_rate CFG.OPTIMIZER.LEARNING_RATE]
                                            [--cfg.optimizer.scheduler.name CFG.OPTIMIZER.SCHEDULER.NAME]
                                            [--cfg.optimizer.scheduler.min_learning_rate CFG.OPTIMIZER.SCHEDULER.MIN_LEARNING_RATE]
                      [--cfg.model.backbone CFG.MODEL.BACKBONE]
                      [--cfg.model.stage_size CFG.MODEL.STAGE_SIZE]
                      [-h]

optional arguments:
  --cfg.global_seed CFG.GLOBAL_SEED
                        (type: Int64, default: 0)
  --cfg.optimizer.name CFG.OPTIMIZER.NAME
                        (default: "adam")
  --cfg.optimizer.learning_rate CFG.OPTIMIZER.LEARNING_RATE
                        (type: Float32, default: 0.003)
  --cfg.optimizer.scheduler.name CFG.OPTIMIZER.SCHEDULER.NAME
                        (default: "cosine")
  --cfg.optimizer.scheduler.min_learning_rate CFG.OPTIMIZER.SCHEDULER.MIN_LEARNING_RATE
                        (type: Float32, default: 0.0001)
  --cfg.model.backbone CFG.MODEL.BACKBONE
                        (default: "resnet18")
  --cfg.model.stage_size CFG.MODEL.STAGE_SIZE
                        (type: Vector{Int64}, default: [2, 2, 2, 2])
  -h, --help            show this help message and exit
```

### Specifying Defaults in Config Files

Specifying defaults in a dictionary in the script is not great for version controlling
experiments. Typically we recommend storing the defaults in config files, and use
command line arguments for hyper-parameters like `seed`. In this case, we need to make
a very simple change.

```julia
cfg = define_configuration(ExperimentConfig, filename)
```

where `filename` can be a `.toml`, `.yml` or `.json` file. See `examples/script_file.jl`
for an example script.

### Logging Configuration

Logging a deeply nested struct is typically not supported OOTB by most loggers. We provide
a simple function `flatten_configuration` which takes the configuration and returns a
single level dictionary which can be easily logged.

## Known Issues

1. Using field types like `Symbol` doesn't work with loading the defaults from a file.

2. `NTuple`s parsing is implemented via type piracy. 
