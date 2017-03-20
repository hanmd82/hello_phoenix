defmodule HelloPhoenix.UserController do
  use HelloPhoenix.Web, :controller

  def index(conn, _params) do
    users = Repo.all(HelloPhoenix.User)
    render conn, "index.html", users: users
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get(HelloPhoenix.User, id)
    render conn, "show.html", user: user
  end
end
