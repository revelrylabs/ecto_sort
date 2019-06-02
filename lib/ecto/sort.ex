defmodule Ecto.Sort do
  defmacro add_sort(key) do
    quote location: :keep do
      defp sort({unquote(key), direction}, query) do
        order_by(query, {^String.to_existing_atom(direction), ^unquote(key)})
      end
    end
  end

  defmacro add_sort(key, fun) do
    quote location: :keep do
      defp sort({unquote(key), direction}, query) do
        unquote(fun).(String.to_existing_atom(direction), query)
      end
    end
  end

  defmacro __using__(_opts) do
    quote location: :keep do
      import Ecto.Sort
      defp apply_sorting(original_query, params) do
        params = convert_params(params)

        Enum.reduce(params, original_query, fn {key, value}, query ->
          try do
            sort({key, value}, query)
          rescue
            _ -> query
          end
        end)
      end


      defp convert_params(%{"s" => params}), do: Map.to_list(params) |> convert_params()
      defp convert_params(%{s: params}), do: Map.to_list(params) |> convert_params()
      defp convert_params(s: params), do: convert_params(params)

      defp convert_params(params) when is_list(params) do
        Enum.map(params, fn
          {key, direction} when is_binary(key) and is_atom(direction) ->
            {String.to_atom(key), Atom.to_string(direction)}
          {key, direction} when is_atom(key) and is_atom(direction) ->
            {key, Atom.to_string(direction)}
          {key, direction} when is_binary(key) and is_binary(direction) ->
            {String.to_atom(key), direction}
          param -> param
        end)
      end

      defp convert_params(_), do: []
    end
  end
end
