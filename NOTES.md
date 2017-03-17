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
