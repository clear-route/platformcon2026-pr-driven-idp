locals {
  envs = ["dev", "prod", "preview"]

  app_components = distinct([
    for f in fileset("${path.module}/../applications/", "**/src/*/*") : {
      app       = split("/", f)[0]
      component = split("/", f)[2]
    }
  ])

  matrix = flatten([
    for ac in local.app_components : [
      for env in local.envs : {
        app       = ac.app
        component = ac.component
        env       = env
      }
    ]
  ])
}
