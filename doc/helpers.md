# Helper Functions

## Recipe DSL

### `netapp_ontap?`

Returns true if the detected platform is NetApp ONTAP.

## Provider/action_class

### Default Action extension

The abstract REST resource defines two default actions: `:configure` and `:delete`.

If you need additional code inside those actions, e.g. for calling nested resources, you can specify your own method for these actions:

```ruby
def action_configure
  super

  # Your additional code goes here
end
```

By specifying `super`, the base functionality of REST mapping and submission is executed. If you leave out the `super` call, all default functionality of the abstract REST resource will ber omitted.

### `conditionally_require_on_setting`

Helper function to be used inside the `define_resource_requirements` helper usually located into the Provider/`action_class`. This method is used for complex resource property validation beyond short `callbacks` statements.

The `conditionally_require_on_setting' helper allows shorthand syntax for cases where setting one property will result in multiple, dependent properties.

Example:

```ruby
def define_resource_requirements
  conditionally_require_on_setting :name_servers, %i[dns_domains]
end
```

These three lines in your Provider/`action_class` will make the `dns_domains` property required as soon as `name_servers` is set (truthy).

### `path_based_selection?`

If this resource uses URI path-based paths (`/api/v1/item/{name}`).

### `query_based_selection?`

If this resource uses URI query-based paths (`/api/v1/item/?name={name}`).

### `rest_arity`

Return Arity of current resource (needed number of inputs for unique identification).

### `rest_get_all`

Get a list of existing resources of current type from API.

### `rest_get`

Get current state of the REST resource identified by the `rest_url_document` with all identity properties set. Aka "the current resource as JSON".

### `rest_post(data)`

Send data to REST API as JSON (POST verb).

### `rest_patch(data)`

Send data to REST API as JSON (PATCH verb).

### `rest_put(data)`

Send data to REST API as JSON (PUT verb).

### `rest_delete`

Delete the REST resource identied by the `rest_url_document` with all identity properties set. Aka "the current resource as JSON".

### `rest_url_collection`

Returns the REST Resource collection URI, with RFC 6570 templates replaced by their mapped Chef properties' values.

### `rest_url_document`

Returns the REST Resource document URI, with RFC 6570 templates replaced by their mapped Chef properties' values.