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
      compute_node_label: "openstack-ironic-compute-node",
      replicas: 1,

      image: {
        base: "quay.io/stackanetes/stackanetes-%s:barcelona",
        init: $.variables.deployment.image.base % "kolla-toolbox",
        post: $.variables.deployment.image.base % "kolla-toolbox",
        # TODO:
        api: "10.91.96.87:5000/debian-source-ironic-api:mateuszb-ironic",
        db_sync: "10.91.96.87:5000/debian-source-ironic-api:mateuszb-ironic",
        conductor: "10.91.96.87:5000/debian-source-ironic-conductor:mateuszb-ironic",
        compute: "10.91.96.87:5000/debian-source-nova-compute-ironic:mateuszb-ironic",
        ironic_pxe: "10.91.96.87:5000/debian-source-ironic-pxe:mateuszb-ironic",
      },
    },

    network: {
      ip_address: "{{ .IP }}",

      port: {
        api: 6385,
      },

      api_url: "http://%s:6385/v1" % $.variables.network.ip_address,

      dns:  {
        servers: ["10.3.0.10"],
        kubernetes_domain: "cluster.local",
        other_domains: "",
      },

      ingress: {
        enabled: true,
        host: "%s.openstack.cluster",
        port: 30080,

        named_host: $.variables.network.ingress.host % "image",
      },
    },

    database: {
      address: "mariadb",
      port: 3306,
      root_user: "root",
      root_password: "password",

      ironic_user: "ironic",
      ironic_password: "password",
      ironic_database_name: "ironic",

      nova_user: "nova",
      nova_password: "password",
      nova_database_name: "nova",
      nova_api_database_name: "nova_api"
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

      nova_user: "nova",
      nova_password: "password",

      neutron_user: "neutron",
      neutron_password: "password",
    },

    glance: {
      api_url: "http://glance-api:9292",
    },

    neutron: {
      api_url: "http://neutron-server:9696",
      metadata_secret: "password",
    },

    rabbitmq: {
      address: "rabbitmq",
      admin_user: "rabbitmq",
      admin_password: "password",
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

    {
      file: "configmaps/post.sh.yaml.j2",
      template: (importstr "templates/configmaps/post.sh.yaml.j2"),
      name: "ironic-postsh",
      type: "configmap",
    },

    {
      file: "configmaps/start.sh.yaml.j2",
      template: (importstr "templates/configmaps/start.sh.yaml.j2"),
      name: "ironic-startsh",
      type: "configmap",
    },

    {
      file: "configmaps/db-sync.sh.yaml.j2",
      template: (importstr "templates/configmaps/db-sync.sh.yaml.j2"),
      name: "ironic-dbsyncsh",
      type: "configmap",
    },

    {
      file: "configmaps/ironic-pxe.sh.yaml.j2",
      template: (importstr "templates/configmaps/ironic-pxe.sh.yaml.j2"),
      name: "ironic-pxesh",
      type: "configmap",
    },

    {
      file: "configmaps/ironic.conf.yaml.j2",
      template: (importstr "templates/configmaps/ironic.conf.yaml.j2"),
      name: "ironic-conf",
      type: "configmap",
    },

    {
      file: "configmaps/nova-compute-ironic.sh.yaml.j2",
      template: (importstr "templates/configmaps/nova-compute-ironic.sh.yaml.j2"),
      name: "nova-compute-ironicsh",
      type: "configmap",
    },

    {
      file: "configmaps/resolv.conf.yaml.j2",
      template: (importstr "templates/configmaps/resolv.conf.yaml.j2"),
      name: "ironic-resolvconf",
      type: "configmap",
    },

    {
      file: "configmaps/nova.conf.yaml.j2",
      template: (importstr "templates/configmaps/nova.conf.yaml.j2"),
      name: "ironic-novaconf",
      type: "configmap",
    },

    // Init.
    {
      file: "init.yaml.j2",
      template: (importstr "templates/jobs/init.yaml.j2"),
      name: "ironic-init",
      type: "job",
    },

    {
      file: "db-sync.yaml.j2",
      template: (importstr "templates/jobs/db-sync.yaml.j2"),
      name: "ironic-db-sync",
      type: "job",
    },

    {
      file: "post.yaml.j2",
      template: (importstr "templates/jobs/post.yaml.j2"),
      name: "ironic-post",
      type: "job",
    },

    // Deployments.
    {
      file: "api/deployment.yaml.j2",
      template: (importstr "templates/api/deployment.yaml.j2"),
      name: "ironic-api",
      type: "deployment",
    },

    {
      file: "conductor/conductor.yaml.j2",
      template: (importstr "templates/conductor/conductor.yaml.j2"),
      name: "ironic-conductor",
      type: "deployment",
    },

    // Daemonsets.
    {
      file: "compute/daemonset.yaml.j2",
      template: (importstr "templates/compute/daemonset.yaml.j2"),
      name: "nova-compute-ironic",
      type: "daemonset",
    },

    // Services.
    {
      file: "api/service.yaml.j2",
      template: (importstr "templates/api/service.yaml.j2"),
      name: "ironic-api",
      type: "service",
    },
  ],

  deploy: [
    {
      name: "$self",
    },
  ]
}, params)
