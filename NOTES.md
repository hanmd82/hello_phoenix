### Life-cycle of a Phoenix web request

```
connection                # Plug.Conn
|> endpoint               # lib/hello_phoenix/endpoint.ex
|> browser                # web/router.ex
|> HelloController.world  # web/controllers/hello_controller.ex
|> HelloView.render(      # web/views/hello_view.ex
       "index.html")      # web/templates/hello/index.html.eex
```

### Programming Phoenix - Chapter 2

- Phoenix is built using Erlang and OTP for the service layer, Elixir for the language, and Node.js for packaging static assets
- mix, the Elixir build tool, is used to create a new project and start our server
- Web applications in Phoenix are pipelines of plugs
- The basic flow of traditional web applications is endpoint, router, pipeline, controller
- Routers distribute requests, and Controllers call services and set up intermediate data for views.

### Programming Phoenix - Chapter 3

- Structs are Elixir’s main abstraction for working with structured data - built on top of maps
- maps only offer runtime protection from bad keys, when the keys are accessed. To know about such errors as soon as possible, e.g. at compilation time, we can use Structs
- syntax for structs and maps is nearly identical, except for the name of the struct. A struct is a map that has a `__struct__` key
- A repository is an API for holding things - it can be used to build a data interface
