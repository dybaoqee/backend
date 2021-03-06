defmodule Re.Listings.History.Statuses do
  @moduledoc """
  Context for handling listing's status history
  """
  alias Re.{
    Listings.StatusHistory,
    Repo
  }

  def insert(listing, status) do
    %StatusHistory{}
    |> StatusHistory.changeset(%{status: status, listing_id: listing.id})
    |> Repo.insert()
  end
end
