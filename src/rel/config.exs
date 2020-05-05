~w(rel plugins *.exs)
|> Path.join()
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Distillery.Releases.Config,
    default_release: :default,
    default_environment: Mix.env()

environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie: :"f0]<KlRo=3@0OHc>H<yO&5FxN*f@r!8SSp;(V*B}O_9:&C,{kxnZ<`/Fn1O<{6RS"
end

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :"nTt[[t<gKS(=1oMHlERRWBcei3i>ftvfe6,cSc(co)3Sv@WcX}b6IoFfou}2jL5;"
  set vm_args: "rel/vm.args"
end

release :phx do
  set version: "0.1.0"
  set config_providers: [
    ConfigTuples.Provider
  ]
  set applications: [
    :runtime_tools,
    frontend: :permanent
  ]
end

