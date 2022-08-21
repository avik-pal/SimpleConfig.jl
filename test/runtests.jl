using SimpleConfig, Test

# Load the configuration
include(joinpath(@__DIR__, "../examples/config.jl"))

@testset "SimpleConfig.jl" begin
  @testset "Defaults Dictionary" begin
    defaults = Dict("global_seed" => 0,
                    "optimizer" => Dict("name" => "adam", "learning_rate" => 3.0f-3,
                                        "scheduler" => Dict("name" => "cosine",
                                                            "min_learning_rate" => 1.0f-4)),
                    "model" => Dict("backbone" => "resnet18", "stage_size" => [2, 2, 2, 2]))

    cfg = define_configuration(ExperimentConfig, defaults)

    @test cfg.global_seed == 0
    @test cfg.optimizer.name == "adam"
    @test cfg.optimizer.learning_rate == 3.0f-3
    @test cfg.optimizer.scheduler.name == "cosine"
    @test cfg.optimizer.scheduler.min_learning_rate == 1.0f-4
    @test cfg.model.backbone == "resnet18"
    @test cfg.model.stage_size == [2, 2, 2, 2]

    cfg = define_configuration(["--cfg.global_seed=1234", "--cfg.model.stage_size=1,2,3,4"],
                               ExperimentConfig, defaults)

    @test cfg.global_seed == 1234
    @test cfg.optimizer.name == "adam"
    @test cfg.optimizer.learning_rate == 3.0f-3
    @test cfg.optimizer.scheduler.name == "cosine"
    @test cfg.optimizer.scheduler.min_learning_rate == 1.0f-4
    @test cfg.model.backbone == "resnet18"
    @test cfg.model.stage_size == [1, 2, 3, 4]

    cfg_dict = flatten_configuration(cfg)

    @test cfg_dict["cfg.global_seed"] == 1234
    @test cfg_dict["cfg.optimizer.name"] == "adam"
    @test cfg_dict["cfg.optimizer.learning_rate"] == 3.0f-3
    @test cfg_dict["cfg.optimizer.scheduler.name"] == "cosine"
    @test cfg_dict["cfg.optimizer.scheduler.min_learning_rate"] == 1.0f-4
    @test cfg_dict["cfg.model.backbone"] == "resnet18"
    @test cfg_dict["cfg.model.stage_size"] == [1, 2, 3, 4]
  end

  @testset "TOML Configuration" begin
    cfg = define_configuration(ExperimentConfig, joinpath(@__DIR__, "defaults.toml"))

    @test cfg.global_seed == 12345
    @test cfg.optimizer.name == "adam"
    @test cfg.optimizer.learning_rate == 3.0f-3
    @test cfg.optimizer.scheduler.name == "cosine"
    @test cfg.optimizer.scheduler.min_learning_rate == 1.0f-4
    @test cfg.model.backbone == "resnet18"
    @test cfg.model.stage_size == [2, 5, 2, 2]

    cfg = define_configuration(["--cfg.global_seed=1234", "--cfg.model.stage_size=1,2,3,4"],
                               ExperimentConfig, joinpath(@__DIR__, "defaults.toml"))

    @test cfg.global_seed == 1234
    @test cfg.optimizer.name == "adam"
    @test cfg.optimizer.learning_rate == 3.0f-3
    @test cfg.optimizer.scheduler.name == "cosine"
    @test cfg.optimizer.scheduler.min_learning_rate == 1.0f-4
    @test cfg.model.backbone == "resnet18"
    @test cfg.model.stage_size == [1, 2, 3, 4]
  end

  @testset "YAML Configuration" begin
    cfg = define_configuration(ExperimentConfig,
                               joinpath(@__DIR__, "../examples/defaults.yml"))

    @test cfg.global_seed == 12345
    @test cfg.optimizer.name == "adam"
    @test cfg.optimizer.learning_rate == 3.0f-3
    @test cfg.optimizer.scheduler.name == "cosine"
    @test cfg.optimizer.scheduler.min_learning_rate == 1.0f-4
    @test cfg.model.backbone == "resnet18"
    @test cfg.model.stage_size == [2, 2, 2, 2]

    cfg = define_configuration([
                                 "--cfg.global_seed=1234",
                                 "--cfg.model.stage_size=1,2,3,4",
                                 "--cfg.optimizer.scheduler.min_learning_rate=1.0e-5",
                               ], ExperimentConfig,
                               joinpath(@__DIR__, "../examples/defaults.yml"))

    @test cfg.global_seed == 1234
    @test cfg.optimizer.name == "adam"
    @test cfg.optimizer.learning_rate == 3.0f-3
    @test cfg.optimizer.scheduler.name == "cosine"
    @test cfg.optimizer.scheduler.min_learning_rate == 1.0f-5
    @test cfg.model.backbone == "resnet18"
    @test cfg.model.stage_size == [1, 2, 3, 4]
  end

  @testset "JSON Configuration" begin
    cfg = define_configuration(ExperimentConfig, joinpath(@__DIR__, "defaults.json"))

    @test cfg.global_seed == 1234
    @test cfg.optimizer.name == "adam"
    @test cfg.optimizer.learning_rate == 0.001f0
    @test cfg.optimizer.scheduler.name == "cosine"
    @test cfg.optimizer.scheduler.min_learning_rate == 1.0f-4
    @test cfg.model.backbone == "resnet18"
    @test cfg.model.stage_size == [3, 4, 6, 3]

    cfg = define_configuration([
                                 "--cfg.global_seed=12314",
                                 "--cfg.model.stage_size=1,2,3,4",
                                 "--cfg.optimizer.scheduler.min_learning_rate=1.0e-5",
                               ], ExperimentConfig, joinpath(@__DIR__, "defaults.json"))

    @test cfg.global_seed == 12314
    @test cfg.optimizer.name == "adam"
    @test cfg.optimizer.learning_rate == 0.001f0
    @test cfg.optimizer.scheduler.name == "cosine"
    @test cfg.optimizer.scheduler.min_learning_rate == 1.0f-5
    @test cfg.model.backbone == "resnet18"
    @test cfg.model.stage_size == [1, 2, 3, 4]
  end

  @testset "Exception Handling" begin
    @test_throws ArgumentError define_configuration(ExperimentConfig, "not_found.toml")
    @test_throws ArgumentError define_configuration(ExperimentConfig, "defaults.txt")
  end
end
