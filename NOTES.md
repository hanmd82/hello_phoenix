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
- A repository is an API for holding things - it can be used to build a data interface as simple hardcoded maps, which can be later replaced with a full database-backed repository
- Views are modules responsible for **rendering data** into a format for consumption, like HTML or JSON
- Templates are web pages or fragments that allow both static markup and native code to build **response pages**, compiled into a function
- Phoenix builds templates using linked lists rather than string concatenation (the way many imperative languages do), so Phoenix does not need to make huge copies of giant strings. Hardware caching, supported by most CPUs, can be used
- Plug breaks out the `params` part of the inbound `conn`, which can be used to extract the individual elements to pass to the controller `action`
- In Phoenix, a view is just a module, and templates are just functions. Rendering a template is a combination of pattern matching on the template name, and executing the function
- The following code snippet fetches a user from a repository and renders the template directly. Note that `render` returns a tuple, with contents stored in a list for performance:

    ```
    iex> user = HelloPhoenix.Repo.get HelloPhoenix.User, "1"
    %HelloPhoenix.User{id: "1", name: "José", password: "elixir", username: "josevalim"}
    iex> view = HelloPhoenix.UserView.render("user.html", user: user)
    {:safe, [[[[["" | "<b>"] | "José"] | "</b> ("] | "1"] | ")\n"]}
    iex> Phoenix.HTML.safe_to_string(view)
    "<b>José</b> (1)\n"
    ```

Summary:

- Actions are the main point of control for each request
- Views are for rendering templates
- Templates generate HTML for display
- Helpers are simple Phoenix functions used in templates
- Layouts are HTML templates that embed an action's HTML

### Programming Phoenix - Chapter 4

- Ecto is a data persistence wrapper, primarily intended for relational databases (default PostgreSQL), along with a built-in query language
- Ecto provides the concept of __changesets__ that hold all changes to be performed on the database, encapsulating the process of receiving external data, casting and validation, before writing to database
- Ecto has a DSL (implemented via Elixir macros) that specifies the fields in a struct, and the mapping between those fields and the database tables
- The `schema` and `field` macros specify both the underlying database table and the Elixir struct, as well as their corresponding fields. After the `schema` definition, Ecto defines the corresponding Elixir struct
- Phoenix models, controllers, and views are just layers of functions. Just as a `controller` is a layer to transform requests and responses according to a communication protocol, the `model` is nothing more than a group of functions to transform data according to business logic requirements
- Phoenix uses __migrations__ to make the database reflect the structure of the application. E.g. add a migration to create a `users` table with columns matching the fields in the `User` schema.
- Ecto migrations [cheatsheet](http://ricostacruz.com/cheatsheets/phoenix-migrations.html)
- Phoenix is built on top of OTP, a layer for reliably managing services. Use OTP to start key services like Ecto repositories in a supervised process so that Ecto and Phoenix can do the right thing in case the repository crashes
- Repositories provide one interface for many different implementations, and configurations, e.g. extract data records from memory, or fetch from database
- Changesets let Ecto manage data record changes, cast parameters, and perform validations. Use changesets to build customized strategies for dealing with each specific kind of change
- the `cast` command is used to specify necessary required fields, and subsequently cast all required and optional values to their schema types, rejecting everything else. Returns an `Ecto.Changeset`
- purpose of changesets is to accommodate various model update strategies - validations, error reporting, security etc. Decouple update policy from schema - each update policy can be handled in its own separate changeset function
- using a helper function to build forms, rather than HTML Tags, provides conveniences like security, UTF-8 encoding etc. The template engine returns everything in the template as a function
- `Ecto.Changeset` implements an Elixir protocol to convert its internal data to the structure required by Phoenix forms, as documented in the `Phoenix.HTML.FormData` contract
- implementation of a controller action is via chaining of simple `plug` functions that are used to transform the connection, one step at a time
- failed validations will return a result `{:error, changeset}` - this needs to be converted into relevant validation errors upon failure
- The `:action` field of a changeset indicates an action performed on it, such as `:insert`. By default it’s nil with a new changeset, so if the form is rendered with any truthy action, it indicates that validation errors have occurred
- Ecto changeset carries the validations and stores this information for later use. In addition to validation errors, the changesets also track changes. Ecto is using changesets as a bucket to hold everything related to a database change, before and after persistence
