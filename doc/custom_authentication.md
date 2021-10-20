# Custom Authentication

Most APIs do not allow anonymous access, but require one of the various forms of authentication. While some have been standardized in RFCs, others are industry best pracices - or vendor/API specific ones.

This section gives an overview over the standard authenticators included in train-rest and then details how to bundle a vendor/API-specific authorizer within an PSP.

## Train-REST Authenticators

As of version 0.4.0, the Train REST Transport comes with six different authorizers:

* anonymous
* authtype-apikey (`Authorization: APIkey ...` header)
* basic (`Authorization: Basic ...` header)
* bearer (`Authorization: Bearer ...` header)
* header (any custom header)
* redfish (Redfish 1.0 compatible)

Most APIs do not require a dedicated Login call but carry the authentication information or token along each requests (stateless nature).

Some APIs diverge from the REST-implied stateless interface and require dedicated `login` or `logout` actions to recieve temporary tokens for a session. Especially the `logout` action is important to not run into concurrency limitations of the APIs (e.g. RedFish).

APIs such as F5 even include session expiries and need periodic refresh of credentials to not time out.

All these actions can be handled under the hood by Train REST.

## PSP Custom Authenticator

To not only depend on the Train REST Transport gem or other third-party modules, PSP can include a custom authenticator for the API they are addressing.

They can be put inside `libraries/` to be automatically loaded on Chef's start but need to be wired up within both Remote Ohai as well as the API-related base resource. This is due to Chef (up to version 17.7 at least) instatiating the connection twice, once for each tool.

While connection parameters can be specified in an RFC099 credentials file (`~/.chef/credentials` or `/etc/chef/NODE/credentials`), Train REST initialization comes before loading `libraries/`, thus needing a runtime swap of the used authenticator before the first requests.

### Authenticator Switching for Ohai

Ideally inside the first platform specific Ohai plugin (Ohai OS Detector Plugin), the following line at the start of `collect_data(:rest)` will switch to the bundled plugin:

```ruby
  collect_data(:rest) do
    transport_connection.switch_auth_handler(:ontap_basic)

    # ...
  end
```

Please note, that ONTAP follows a standardized Basic authentication, which would be possible with stock Train REST. For the sake of demonstrating the capability to switch over, a renamed version of the generic `:basic` authenticator was bundled.

### Authenticator Switching for Chef Custom Resources

Ideally in the constructor of the Abstract Platform Resource, the same line as in Ohai will switch the auth handler if that has not been done already. As the `switch_auth_handler` method does not change the handler if it is already as desired, this does not have any impact on previously established sessions etc.

Due to helpers in the Abstract REST Resource, the following generic constructor enables the specified Custom Authenticator:

```ruby
  def initialize(new_resource, run_context)
    super

    api_connection.switch_auth_handler(:my_custom_handler)
  end
```