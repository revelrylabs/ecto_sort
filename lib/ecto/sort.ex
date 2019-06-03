defmodule Ecto.Sort do
  @moduledoc """
  Ecto.Sort is a simple module which provides a macro for explicitly applying ecto order_by expressions.

  ### Example
  ```elixir
  defmodule Post do
    use Ecto.Schema

    schema "post" do
      field(:name, :string)
      field(:featured, :boolean)
      has_many(:comments, Comment)
      timestamps()
    end
  end

  defmodule Comment do
    use Ecto.Schema

    schema "comment" do
      field(:body, :string)
      timestamps()
    end
  end

  defmodule Posts do
    import Ecto.Query, warn: false
    use Ecto.Sort

    add_sort(:inserted_at)
    add_sort([:name, :featured])
    add_sort(:comments_inserted_at, fn direction, query ->
      query
      |> join(:left, [p], c in assoc(p, :comments), as: :comments)
      |> order_by([comments: comments], [{^direction, comments.inserted_at}])
    end)

    defp query(params \\ %{}) do
      apply_sorting(Post, params)
    end

    def list_posts(params \\ %{}), do: Repo.all(query_posts(params))
    def get_post(params \\ %{}), do: Repo.one(query_posts(params))
  end
  ```
  """

  defmacro add_sort(key) when is_atom(key) do
    quote location: :keep do
      add_sort([unquote(key)])
    end
  end

  defmacro add_sort(keys) when is_list(keys) do
    for key <- keys do
      quote location: :keep do
        defp sort({unquote(key), direction}, query) do
          order_by(query, {^String.to_existing_atom(direction), ^unquote(key)})
        end
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

      defp convert_params(%{"s" => params}), do: params |> Map.to_list() |> convert_params()
      defp convert_params(%{s: params}), do: params |> Map.to_list() |> convert_params()
      defp convert_params(s: params), do: convert_params(params)

      defp convert_params(params) when is_list(params) do
        Enum.map(params, fn
          {key, direction} when is_binary(key) and is_atom(direction) ->
            {String.to_atom(key), Atom.to_string(direction)}

          {key, direction} when is_atom(key) and is_atom(direction) ->
            {key, Atom.to_string(direction)}

          {key, direction} when is_binary(key) and is_binary(direction) ->
            {String.to_atom(key), direction}

          param ->
            param
        end)
      end

      defp convert_params(_), do: []
    end
  end
end
