defmodule Re.Images do
  @moduledoc """
  This module interfaces calls to Image data.
  """

  import Ecto.Query

  alias Re.{
    Image,
    Repo
  }
  alias Ecto.Changeset

  def all(listing_id) do
    q = from i in Image,
      where: i.listing_id == ^listing_id,
      order_by: [asc: i.position]

    {:ok, Repo.all(q)}
  end

  def get_per_listing(listing_id, image_id) do
    case Repo.get_by(Image, id: image_id, listing_id: listing_id) do
      nil -> {:error, :not_found}
      image -> {:ok, image}
    end
  end

  def insert(image_params, listing_id) do
    %Image{}
    |> Image.changeset(image_params)
    |> Changeset.change(listing_id: listing_id)
    |> Changeset.change(position: calculate_position(listing_id))
    |> Repo.insert()
  end

  defp calculate_position(listing_id) do
    case all(listing_id) do
      {:ok, []} -> 1
      {:ok, [top_image | _]} -> top_image.position - 1
    end
  end

  def update_per_listing(_listing, images_param) do
    Enum.each(images_param, &update_image/1)
  end

  defp update_image(%{"id" => id} = params) do
    image = Repo.get(Image, id)

    image
    |> Image.changeset(params)
    |> Repo.update()
  end

  def delete(image), do: Repo.delete(image)

end
