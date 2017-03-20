defmodule HelloPhoenix.UserController do
  use HelloPhoenix.Web, :controller

  def index(conn, _params) do
    users = Repo.all(HelloPhoenix.User)
    render conn, "index.html", users: users
  end
end
