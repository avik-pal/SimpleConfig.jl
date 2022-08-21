module SimpleConfig

import ArgParse, Configurations, Reexport
import JSON3, YAML

# Workaround to parse NTuple
function ArgParse.parse_item(::Type{<:NTuple{N, T}}, s::AbstractString) where {N, T}
  s_split = split(s, ',')
  if length(s_split) != N
    throw(ArgumentError("expected `$s` to have $N elements"))
  end
  return Tuple(parse.(T, s_split))
end

function ArgParse.parse_item(::Type{<:Vector{T}}, s::AbstractString) where {T}
  return parse.(T, split(s, ','))
end

function _should_descend(obj, fnames)
  return length(fnames) != 0 && !(typeof(obj) <: NTuple)
end

# Parses the `cfg` and returns a vector of `name`, type and defaults
function _parse_configuration(cfg::T, name="cfg") where {T}
  fnames = fieldnames(T)
  _should_descend(cfg, fnames) || return (name, T, cfg)
  d = ()
  for fname in fnames
    structure = _parse_configuration(getfield(cfg, fname), join((name, fname), "."))
    d = vcat(d..., structure)
  end
  return d
end

# Create a ArgParse settings from the cfg
function _generate_argparse_table(cfg)
  settings = ArgParse.ArgParseSettings()
  config = _parse_configuration(cfg)
  for (key, otype, default) in config
    settings = ArgParse.add_arg_table!(settings, "--" * key,
                                       Dict(:arg_type => otype, :default => default))
  end
  return settings
end

# Construct a nested dictionary by splitting the key by "."
function _to_dict(parsed_args::Dict{String, Any})
  d = Dict{String, Any}()
  for (k, v) in pairs(parsed_args)
    ks = split(k, '.')[2:end]
    _d = d
    for key in ks[1:(end - 1)]
      _d = get!(_d, key, Dict{String, Any}())
    end
    _d[ks[end]] = v
  end
  return d
end

"""
    flatten_configuration(cfg)

Flatten a deeply nested configuration struct into a single level dictionary, with the
nesting separated by ".".
"""
function flatten_configuration(cfg)
  structure = _parse_configuration(cfg)
  cfg_dict = Dict{String, Any}()
  for (name, _, val) in structure
    cfg_dict[name] = val
  end
  return cfg_dict
end

"""
    define_configuration([args,] cfg, defaults::Dict)
    define_configuration([args,] cfg, fname::String)

Creates a ArgParse Settings from `cfg` which is created using `Configurations.@cfg`.
The initial values / defaults can be specified using a dictionary (See
`Configurations.from_dict` for how to specify that). The other cfg is to pass a path
to a configuration file which can be of type -- `toml`, `yml` or `json`.
"""
function define_configuration(cfg, defaults::Dict)
  return define_configuration(ARGS, cfg, defaults)
end

function define_configuration(cfg, fname::String)
  return define_configuration(ARGS, cfg, fname)
end

function define_configuration(args, cfg, defaults::Dict)
  _cfg = Configurations.from_dict(cfg, defaults)
  settings = _generate_argparse_table(_cfg)
  parsed_args = ArgParse.parse_args(args, settings)
  return Configurations.from_dict(cfg, _to_dict(parsed_args))
end

function define_configuration(args, cfg, fname::String)
  if !isfile(fname)
    throw(ArgumentError("file not found: $fname"))
  end

  ext = last(splitext(fname))
  if ext == ".toml"
    _cfg = Configurations.from_toml(cfg, fname)
  elseif ext == ".yml"
    data = YAML.load_file(fname; dicttype=Dict{String, Any})
    _cfg = Configurations.from_dict(cfg, data)
  elseif ext == ".json"
    json_string = read(fname, String)
    data = JSON3.read(json_string, Dict{String, Any})
    _cfg = Configurations.from_dict(cfg, data)
  else
    throw(ArgumentError("unknown file extension: $ext. Supported extensions are: .toml," *
                        ".yml, and .json"))
  end

  settings = _generate_argparse_table(_cfg)
  parsed_args = ArgParse.parse_args(args, settings)
  return Configurations.from_dict(cfg, _to_dict(parsed_args))
end

Reexport.@reexport import Configurations.@option
export define_configuration, flatten_configuration

end
