# What's Next

## Chef Shim

- making it part of the Custom Resource DSL, getting rid of `class...end` and using `resource_type`
- allow mapping on property-keywords directly (`, rest_property: "cluster.name"`)
- PR for Chef Compliance Phase and Target Mode
- extending the pattern for InSpec resources and integrating with Compliance Phase

## NetApp ONTAP PSP

- completing resource support
- developing InSpec profile + remediation cookbook based on TR-4754

## General

- Extending the PoC to auto-generate (or at least scaffold) from OpenAPI (`chef generate psp --from-file=myapi.yaml`)
