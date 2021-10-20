# REST Resource DSL

## rest_api_collection

Defines the URI pattern for a collection of resources. This is commonly used to GET the list of currently defined REST resources and as endpoint to run POST (create) requests against.

The passed URI must be global (i.e. starting with a "/") and per REST recommendations not have a slash at the end.

```ruby
rest_api_collection '/api/v1/items'
```

Depending on the API definition, you might need to include an extension like `.json` for selecting JSON format as reply. Also, many APIs define various query parameters for sorting, field selection and other purposes. Refer to the vendor's API specification for the format needed.

## rest_api_document

The URI pattern defined in this property is used to reference one specific instance of a resource. It commonly uses one or more [RFC 6570](https://datatracker.ietf.org/doc/html/rfc6570#section-3.2.2) templates like:

```ruby
# Example for path-based resource selection
ruby_api_document '/api/v1/items/{name}'

# Example for query-based resource selection
ruby_api_document '/api/v1/items/?name={name}', first_element_only: true
```

Within REST resources, the `{name}` template will be replaced by the resource property of the same name (e.g. `{name}` will be replaced with the resource `:name` property).

### Arity of REST Resources

REST APIs have resources of different arity (or cardinality). In connection with Chef REST resources, this references the amount of input variables needed to uniquely reference a specific resource.

```ruby
# Example of a resource of arity 0 (unique element in API, no template variable needed)
ruby_api_document '/api/cluster'

# Example of a resource of arity 1 (one variable for identification)
ruby_api_document '/api/svm/?name={svm}', first_element_only: true

# Example of a resource of arity 3 (three variables)
ruby_api_document '/api/protocols/san/lun-maps?svm.name={svm}&igroup.name={igroup}&lun.name={lun}', first_element_only: true
```

For arity, it is important to select a set of variables which are known before creation (POST) or after creation (PATCH/DELETE). If the API usually refers to a resource using UUID, this cannot be matched against desired state in Chef. In those instances, use the API's search functionality like with the query-based examples above.

### Implicit Identity Mapping

When using templated `rest_api_document` URLs, REST resource implementation automatically detects the templated Chef properties as "identity" of the REST resource. This specification is especially important for constructing JSON payloads on PATCH requests, where sent data needs to include the changed resource properties AND all neccessary identity properties.

For path-based resources, implicit identity mapping will map template variables to identically named Chef properties. For query-based resources, it will map the URI query parameters to the Chef property from the template:

```ruby
# Path-based resource
ruby_api_document '/cluster/ntp/servers/{server}'

# Resulting implicit identity map (Chef Property => URI template variable)
# { server: "server" }

# Query-based resource
ruby_api_document '/api/protocols/san/lun-maps?svm.name={svm}&igroup.name={igroup}&lun.name={lun}', first_element_only: true

# Resulting implicit identity map (Chef Property => URI query variable/JSON field)
# { svm: "svm.name", igroup: "igroup.name", lun: "lun.name" }
```

If you want to explicitly state the mapping, see [rest_identity_map](#rest_identity_map). For the format of query variables/JSON fields, see [rest_property_map](#rest_property_map).

### Array Responses

When using query-based resource addressing, some API will return an Array and not the single match. If you have an API like this, adding the `first_element_only: true` option will only use the first entry of the REST API response.

## rest_property_map

REST APIs usually are designed so data sent to them and returned from them follow the same format. If you have a POST request to create a resource and then issue a GET request, the data structures will be largely the same:

Example for `POST /cluster`:

```json
{
  "name": "my-cluster",
  "location": "DC1"
}
```

Example for `GET /cluster`:

```json
{
  "name": "my-cluster",
  "location": "DC1",
  "uuid": "4b63a1ba-3054-11ec-8d3d-0242ac130003",
  "creation_time": "1470628800"
}
```

This structure allows mapping of Chef resource properties to JSON fields like `{ cluster_name: "name", cluster_location: "location" }`.

### 1:1 Mapping

If Chef properties and JSON documents are flat 1:1 mappings, you can also use an Array:

```ruby
rest_api_collection "/api/name-services/dns"
rest_api_document   "/api/name-services/dns?svm.name={name}&fields=*", first_element_only: true

rest_property_map   %w[domains servers]
```

### Nested Mapping

For nested resources, subkeys can be specified using JMESPath syntax which most often appends hierarchies using dots:

```json
{
  "svm": {
    "name": "svm1-iscsi"
  },
  "iscsi": true
}
```

The resulting map for this scheme would be `{ name: "svm.name", iscsi: "iscsi" }`

You can specify these mappings with the `rest_property_map` option of a Chef REST resource:

```ruby
rest_api_collection "/api/cluster"
rest_api_document   "/api/cluster"

rest_property_map ({
  name:         "name",
  contact:      "contact",
  dns_domains:  "dns_domains",
  location:     "location",
  name_servers: "name_servers",
  timezone:     "timezone.name"
})
```

### Custom Mapping

In the case of a neccessary mapping of data types, you can also tell Chef to use custom mapping functions:

```ruby
rest_api_collection "/api/support/ems/destinations"
rest_api_document   "/api/support/ems/destinations/{name}&fields=*"

rest_property_map   ({
  type:        "type",
  destination: "destination",
  filters:     :custom_mapping
})
```

This will call the Provider/`action_class` methods `filters_from_json` (getting state) and `filters_to_json` (creation/update/deletion) and use their output instead. Currently this will be the case on any symbol in the map, not just `:custom_mapping`.

## rest_identity_map

This is the explicit mapping of resource identity attributes. For a detailed description see [Implicit Identity Mapping](#implicit_identity_mapping).

```ruby
# Example mapping to map a 3-ary REST resource to Chef properties `svm`, `igroup` and `lun`
rest_identity_map ({
  svm:    "svm.name",
  igroup: "igroup.name",
  lun:    "lun.name"
})
```

## rest_post_only_properties

Some attributes in APIs can only be set on creation. For example, if you want to join a system to Active Directory the FQDN of the AD controller, the username and password will only be needed on creation (POST). On modification of the resource, these properties might not be used anymore (depending on the API).

If you want to include properties only on POST requests, add them:

```ruby
rest_post_only_properties %i[ad_domain_user ad_domain_password ad_domain_fqdn ad_domain_ou]
```

## resource_type

This is just a demo DSL method which exemplifies how a Chef Infra core-integrated REST resource could make writing Custom Resources easier by switching between normal OS-focused DSL to REST-focused DSL.

It currently has no functionality.
