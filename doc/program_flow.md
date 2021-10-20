# Program Flow

This repository contains three separate entities of code

1. __Chef Shim__<br>
   Code which extends Chef to support REST resources. Purposely put into `Chef::` namespace, as these components could be ported to be part of the Chef Infra core product to enable rapid development of platform support packs.
1. __Platform Support Pack (PSP) for NetApp ONTAP__<br>
   Demo PSP which realizes around 25 resources to configure NetApp ONTAP clusters. All resources are written with the Chef Shim-supported new DSL methods and generic implementation. Usual time between starting on a new resource and its usability is <10 minutes.
   For background on the PSP concept see my [PSP post on aws-blog.de (EN)](https://aws-blog.de/2021/10/third-party-platform-support-for-chef.html)
1. __Demo Cluster Recipe__<br>
   Example of a small cookbook to provision a base NetApp ONTAP cluster with fileshares and SAN protocols.

## Order of Execution

- Chef startup
- Train invocation (Target Mode)
- Cookbook segment parsing
  - `libraries/`
    - Chef Shim
      - `rest_resource.rb` (Abstract REST Resource)
        - `rest_errors.rb`
        - `dsl_rest_resources.rb` (REST specific DSL)
    - NetApp PSP
      - `ontap_basic.rb` (Custom Authenticator demo)
      - `ontap_rest_resource.rb` (Abstract Platform Resource)
      - `chef_ontap_helpers.rb` (Helpers and DSL functions)
      - `ontap_resources/*` (Primary resources)
  - `ohai/`
    - `netapp_ontap_os.rb` (Ohai OS Detector Plugin, switching from platform `:rest` to `:ontap`)
    - `netapp_ontap_*` (depending on Ohai OS Detector namespace, executing `collect_data(:ontap)`)
  - `recipe/`
    - Demo Cluster recipe
