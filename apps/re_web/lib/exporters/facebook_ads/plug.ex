defmodule ReWeb.Exporters.FacebookAds.Plug do
  @moduledoc """
  Plug to handle FacebookAds load integration
  """
  import Plug.Conn

  alias Re.{
    Exporters.FacebookAds,
    Listings.Exporter
  }

  def init(args), do: args

  def call(
        %Plug.Conn{path_info: ["real-estate", state_slug, city_slug], query_params: query_params} =
          conn,
        _args
      ) do
    filters = %{cities_slug: [city_slug], states_slug: [state_slug]}

    xml_listings =
      filters
      |> Exporter.exportable(query_params)
      |> FacebookAds.RealEstate.export_listings_xml()

    conn
    |> put_resp_content_type("application/xml")
    |> send_resp(200, xml_listings)
  end

  def call(
        %Plug.Conn{path_info: ["product", state_slug, city_slug], query_params: query_params} =
          conn,
        _args
      ) do
    filters = %{cities_slug: [city_slug], states_slug: [state_slug]}

    xml_listings =
      filters
      |> Exporter.exportable(query_params)
      |> FacebookAds.Product.export_listings_xml()

    conn
    |> put_resp_content_type("application/xml")
    |> send_resp(200, xml_listings)
  end

  def call(conn, _args) do
    error_response =
      {"error", "Expect FacebookAds type, state and city on path"}
      |> XmlBuilder.document()
      |> XmlBuilder.generate(format: :none)

    conn
    |> put_resp_content_type("application/xml")
    |> send_resp(404, error_response)
  end
end
