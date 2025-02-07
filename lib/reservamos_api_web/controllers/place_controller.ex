defmodule ReservamosApiWeb.PlaceController do
  use ReservamosApiWeb, :controller
  import Ecto.Query, only: [from: 2]
  alias HTTPoison
  alias Jason
  alias ReservamosApi.{Hospedaje, Repo}

  @places_api "https://search.reservamos.mx/api/v2/places"

  def search(conn, params) do
    # 1. Validar y normalizar los parámetros importantes
    validated_params = validate_params(params)
    query = validated_params["q"]
    url = "#{@places_api}?q=#{URI.encode(query)}"

    # 2. Llamada al servicio externo con manejo de errores
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 201, body: body}} ->
        case Jason.decode(body) do
          {:ok, places} ->
            # Filtrar solo lugares de tipo "city"
            places = Enum.filter(places, fn place -> place["result_type"] == "city" end)
            # Fusionar parámetros originales con los validados (para mantener otros filtros como "amenities")
            merged_params = Map.merge(params, validated_params)
            filtered_hospedajes = apply_filters(Hospedaje, merged_params) |> Repo.all()
            results = build_results(places, filtered_hospedajes)
            json(conn, %{results: results})

          {:error, _} ->
            conn
            |> put_status(:bad_request)
            |> json(%{error: "Error al procesar la respuesta del servidor externo"})
        end

      {:ok, %HTTPoison.Response{status_code: status}} ->
        conn
        |> put_status(:bad_gateway)
        |> json(%{error: "El servicio externo respondió con un código no esperado: #{status}"})

      {:error, %HTTPoison.Error{reason: reason}} ->
        conn
        |> put_status(:service_unavailable)
        |> json(%{error: "Error de conexión con el servicio externo: #{reason}"})
    end
  end

  # ----------------------------------------------------------------
  # Validación de parámetros: "q", "price_min", "price_max" y "rating_min"
  # Se normalizan para usarlos en la consulta y en la construcción de filtros.
  # ----------------------------------------------------------------
  defp validate_params(params) do
    %{
      "q" => Map.get(params, "q", "") |> String.trim(),
      "price_min" => safe_to_float(Map.get(params, "price_min", "0")),
      "price_max" => safe_to_float(Map.get(params, "price_max", "10000")),  # Límite razonable
      "rating_min" => safe_to_float(Map.get(params, "rating_min", "0"))
    }
  end

  # ----------------------------------------------------------------
  # Construcción de la respuesta:
  # Por cada ciudad (place) se asocia un mapa que contiene:
  #   - "city": la información de la ciudad.
  #   - "hospedajes": un arreglo con los hospedajes filtrados correspondientes.
  # Esto asegura que en la respuesta JSON se muestre primero la ciudad y debajo sus hospedajes.
  # ----------------------------------------------------------------
  defp build_results(places, hospedajes) do
    Enum.map(places, fn place ->
      city_hospedajes =
        hospedajes
        |> Enum.filter(fn h ->
          String.downcase(h.city) == String.downcase(place["city_name"])
        end)
        |> Enum.map(fn h ->
          %{
            title: h.title,
            price_per_night: h.price_per_night,
            amenities: (if h.amenities == [""], do: [], else: h.amenities),
            rating_cleanliness: h.rating_cleanliness,
            rating_accuracy: h.rating_accuracy,
            rating_check_in: h.rating_check_in,
            rating_communication: h.rating_communication,
            rating_location: h.rating_location,
            rating_value: h.rating_value,
            rating_overall: h.rating_overall
          }
        end)

      # Se utiliza un mapa con claves de _string_ para preservar el formato esperado.
      %{"city" => place, "hospedajes" => city_hospedajes}
    end)
  end

  # ----------------------------------------------------------------
  # Aplicación de filtros a la consulta de hospedajes.
  # Se encadenan los filtros de precio, rating y amenities.
  # ----------------------------------------------------------------
  defp apply_filters(query, params) do
    query
    |> filter_by_price(params)
    |> filter_by_rating(params)
    |> filter_by_amenities(params)
  end

  defp filter_by_price(query, %{"price_min" => min, "price_max" => max}) do
    from(h in query, where: h.price_per_night >= ^min and h.price_per_night <= ^max)
  end
  defp filter_by_price(query, _), do: query

  defp filter_by_rating(query, %{"rating_min" => min}) do
    from(h in query, where: h.rating_overall >= ^min)
  end
  defp filter_by_rating(query, _), do: query

  defp filter_by_amenities(query, %{"amenities" => amenities}) do
    amenities_list =
      amenities
      |> String.split(",", trim: true)
      |> Enum.map(&String.downcase/1)

    Enum.reduce(amenities_list, query, fn amenity, q ->
      from(h in q, where: fragment("EXISTS (SELECT 1 FROM unnest(?) AS a WHERE lower(a) ILIKE ?)", h.amenities, ^"%#{amenity}%"))
    end)
  end
  defp filter_by_amenities(query, _), do: query

  # ----------------------------------------------------------------
  # Conversión segura de valores a float.
  # Se manejan tanto cadenas como números.
  # ----------------------------------------------------------------
  defp safe_to_float(value) when is_binary(value) do
    case Float.parse(value) do
      {num, _} -> num
      :error -> 0.0
    end
  end
  defp safe_to_float(value) when is_number(value), do: value
  defp safe_to_float(_), do: 0.0
end
