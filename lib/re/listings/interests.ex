defmodule Re.Listings.Interests do
  @moduledoc """
  Context to manage operation between users and listings
  """

  alias Re.{
    Listings.Interest,
    Repo
  }

  def show_interest(params) do
    IO.inspect params
    %Interest{}
    |> Interest.changeset(params)
    |> Repo.insert()
  end

end
