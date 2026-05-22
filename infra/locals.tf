locals {
  envs = ["dev", "prod", "preview"]

  apps = toset([
    for f in fileset("${path.module}/../applications/", "*/**") : split("/", f)[0]
  ])

  matrix = flatten([
    for app in local.apps : [
      for env in local.envs : {
        app = app
        env = env
      }
    ]
  ])
}
