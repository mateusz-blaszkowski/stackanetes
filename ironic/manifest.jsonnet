local kpm = import "kpm.libjsonnet";

function(
  params={}
)

kpm.package({
  package: {
    name: "stackanetes/ironic",
    expander: "jinja2",
    author: "Mateusz Blaszkowski",
    version: "0.1.0",
    description: "ironic",
    license: "Apache 2.0",
  },

  variables: {
    deployment: {
      control_node_label: "openstack-control-plane",
      replicas: 1,

      image: {
        base: "quay.io/stackanetes/stackanetes-%s:barcelona",
        init: $.variables.deployment.image.base % "kolla-toolbox",
      },
    },

    network: {
      ip_address: "{{ .IP }}",

      port: {
        api: 6385,
      },
    },

    database: {
      address: "mariadb-galera",
      port: 3306,
      root_user: "root",
      root_password: "password",

      ironic_user: "ironic",
      ironic_password: "password",
      ironic_database_name: "ironic",
    },

    keystone: {
      auth_uri: "http://keystone-api:5000",
      auth_url: "http://keystone-api:35357",
      admin_user: "admin",
      admin_password: "password",
      admin_project_name: "admin",
      admin_region_name: "RegionOne",
      auth: "{'auth_url':'%s', 'username':'%s','password':'%s','project_name':'%s','domain_name':'default'}" % [$.variables.keystone.auth_url, $.variables.keystone.admin_user, $.variables.keystone.admin_password, $.variables.keystone.admin_project_name],

      ironic_user: "ironic",
      ironic_password: "password",
      ironic_region_name: "RegionOne",
    },

    misc: {
      debug: false,
      workers: 8,
    },
  },

  resources: [
    // Config maps.
    {
      file: "configmaps/init.sh.yaml.j2",
      template: (importstr "templates/configmaps/init.sh.yaml.j2"),
      name: "ironic-initsh",
      type: "configmap",
    },

    // Init.
    {
      file: "init.yaml.j2",
      template: (importstr "templates/init.yaml.j2"),
      name: "ironic-init",
      type: "job",
    },
  ],

  deploy: [
    {
      name: "$self",
    },
  ]
}, params)
