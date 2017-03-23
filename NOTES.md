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

### Programming Phoenix - Chapter 5

- Changesets can be chained/composed, and change policies do not have to be strongly coupled with database persistence
- Inside a module, we can define functions with `def/2` and private functions with `defp/2`. A function defined with `def/2` can be invoked from other modules while a private function can only be invoked locally
- Changesets can be used to insulate controllers from change policies specified in the model layer, while keeping models free of side effects
- Validations are a pipeline of functions that transform the changeset. The changeset is a data structure that explicitly tracks changes and their validity
- Plugs provide a common data structure for piped functions
    - **module plugs**: specify by providing the module name. A module plug must provide two functions: `init` and `call`
        ```
        defmodule NothingPlug do
          def init(opts) do
            opts
          end
          def call(conn, _opts) do
            conn
          end
        end
        ```
    - The `init` function is triggered at compile time - suitable for validating and transforming options. The `call` function is triggered at runtime, to do the main work and change the behavior of the plug
    - **function plugs**: specify by providing the name of the function as an atom
    - All plugs take a `conn` and return a `conn`. A `conn` begins almost blank, and is filled out progressively by different plugs in the pipeline
- create an authentication service as a plug, that can be added to any pipeline in the router, so that other controllers can re-use it
    - in the `init` function, take the given options and extract the repository, raising an exception if the `:repo` key doesn't exist
    - in the `call` function, use `assign` (a function imported from `Plug.Conn`) to transform the connection, by storing the user extracted from the session and repo (or `nil`) in `:current_user`
- use the authentication plug to find out whether a user is logged in, to restrict access to pages which list or show user information
- use `halt(conn)` to stop any downstream transformations to the `conn`
- make the `authenticate` function a **function plug** that receives two arguments: the `conn` and a set of options, and returns the `conn`
- Plug pipelines explicitly check for `halted: true` between every plug invocation
- when creating forms that are not backed by a changeset, pass in a `%Plug.Conn{}` struct
- Everything stored in `conn.assigns` is made available to the views, e.g. an authenticated user stored in `conn.assigns.current_user` is made available as `@current_user`
- passing the `:method` option to `link` generates a form tag instead of an anchor tag. Links without a specified HTTP method will default to `GET` and a simple link will be rendered

Summary:

- implemented the authentication layer and created the functionality to store users in the session
- built the associated changesets to handle password validation and restrict user access
- created a module plug that loads user information from the session and made it part of the browser pipeline
- created a function plug that can be shared across different actions in the controller pipeline

### Programming Phoenix - Chapter 6

- use generators to build the skeleton—including the migration, controllers, and templates to bootstrap the process
    - `phoenix.gen.html` creates a simple HTTP scaffold with HTML pages
    - `phoenix.gen.json` creates a REST-based API using JSON
- Example: `mix phoenix.gen.html Video videos user_id:references:users url:string title:string description:text` specifies:
    - the name of the module that defines the model
    - the plural form of the model name
    - each field, with some type information
- Phoenix consistently uses singular forms in models, controllers, and views
- Applications can use as many plugs and pipelines as needed, organizing them in scopes using `pipe_through`
- Ecto associations need to be explicitly loaded, e.g. `user = Repo.preload(user, :videos)`. `Repo.preload` accepts one or a collection of association names, and it can fetch all associated data
- Use `Ecto.build_assoc` to build a struct, with the proper relationship fields already set
- Associate the current user from the session to each new video - grab the current user from the conection and scope operations against the user
- Every controller has its own default `action` function, which is a plug that dispatches to the proper action at the end of the controller pipeline. Use the `__MODULE__` directive to expand to the current module, in atom form
- API for controller actions can be changed/over-written to receive new arguments, e.g. connection, parameters, and current user
