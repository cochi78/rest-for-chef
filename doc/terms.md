# Terms and Glossary

## Abstract Platform Resource

Chef custom resource which is not meant to be used directly by a user. It provides all platform-specific functionality which is then reused by the Primary Resource.

## Abstract REST Resource

Base class of Chef resources which deal with any REST-specifics. It provides REST-specific DSL extensions for configuring paths on the remote device, mappings between API JSON and Chef resource properties, default implementations for actions `:configure`/`:delete` and other helpers. It is not usable directly but intended to be subclassed by an Abstract Platform Resource.

## Custom Authenticator

An additional Train-REST authenticator included in the PSP to address any non-standard behaviour of the remote REST interface. This includes `login`, renewal of sessions and `logout` as well as passing in additional headers or other parameters.

## Ohai OS Detector Plugin

A bundled Ohai plugin which is the base dependency on all device specific plugins. It detects the type, device and version of the remote resource and adjusts Ohai's reported `os`/`platform_*` values. This enables Ohai Platform Plugins to use a collector statement like `collect_data(:platform)` which only get invoked on the corresponding platform. It publishes a new top-level key which Ohai Platform Plugins can depend on.

## Ohai Platform Plugin

Any Ohai plugin which is targeted at a specific platform, depending on the Ohai OS Detector Plugin namespace to be called after initial detection. They usually only have a `collect_data(:platform)` method, where `:platform` is the key returned by the base plugin, e.g. `collect_data(:ontap)`.

## Platform Support Pack (PSP)

A resource-oriented cookbook which consists of various target-platform specific Ohai plugins, helper libraries, custom authenticators, specialized InSpec resources, likely an abstract base resource and a number of primary resources.

## Primary/Platform Resource

Chef custom resource which configures a property of the remote system.

## Remote Ohai

Introduced with Chef 16.6. Ohai now has the capability to work with a Train transport to retrieve remote inventory.

## REST Resource Arity

Number of parameters needed by the REST API to identify a specific unique resource.

## REST Identity Mapping

Mapping of Chef resource properties to REST identity parameters. The mapping can either be implicit (by parsing the `rest_api_document` URI) or explicit (by specification in `rest_identity_map`)

## Target Mode

Introduced with Chef 15.1. This enables Chef to manage remote systems via a Train transport. Resources have to match the target OS/platform and, if not based on a standard transport like SSH/WinRM, need to be custom-written

## Train-REST

A Train transport to allow connecting software with a remote REST API. This transport is taking care of REST specific authentication and session keeping. As it cannot pass through OS-level commands, software has to use the provided HTTP-verb related functions `.get`, `.post` etc instead of the line-protocol specific `.run_command`