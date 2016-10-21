local kpm = import "kpm.libjsonnet";

function(
  params={}
)

kpm.package({
  package: {
    name: "stackanetes/rgw",
    expander: "jinja2",
    author: "Mateusz Blaszkowski",
    version: "0.2.0",
    description: "rgw",
    license: "Apache 2.0",
  },

  variables: {
    deployment: {
      control_node_label: "openstack-control-plane",

      image: {
        rgw: "ceph/daemon:tag-build-master-jewel-ubuntu-16.04",
      },
    },

    network: {
      ip_address: "{{ .IP }}",

      port: {
        rgw: 6000,
      },
    },

    ceph: {
      monitors: [],
      rgw_user: "",
      admin_keyring: "",
      secret_uuid: "",
    },

    rgw: {
      user: "",
      subuser: "",
      temp_url_key: "",
    },
  },

  resources: [
    // Config maps.
    {
      file: "configmaps/ceph.conf.yaml.j2",
      template: (importstr "templates/configmaps/ceph.conf.yaml.j2"),
      name: "rgw-cephconf",
      type: "configmap",
    },

    {
      file: "configmaps/ceph.client.admin.keyring.yaml.j2",
      template: (importstr "templates/configmaps/ceph.client.admin.keyring.yaml.j2"),
      name: "rgw-cephclientadminkeyring",
      type: "configmap",
    },

    {
      file: "configmaps/init.sh.yaml.j2",
      template: (importstr "templates/configmaps/init.sh.yaml.j2"),
      name: "rgw-initsh",
      type: "configmap",
    },

    // Deployment
    {
      file: "deployment.yaml.j2",
      template: (importstr "templates/deployment.yaml.j2"),
      name: "rgw",
      type: "deployment",
    },

    // Services.
    {
      file: "service.yaml.j2",
      template: (importstr "templates/service.yaml.j2"),
      name: "rgw",
      type: "service",
    }
  ],

  deploy: [
    {
      name: "$self",
    },
  ]
}, params)
