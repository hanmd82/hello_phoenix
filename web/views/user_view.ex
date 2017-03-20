defmodule HelloPhoenix.UserView do
  use HelloPhoenix.Web, :view

  alias HelloPhoenix.User

  def first_name(%User{name: name}) do
    name
    |> String.split(" ")
    |> Enum.at(0)
  end
end
