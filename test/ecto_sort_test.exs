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

  def query(params \\ %{}) do
    apply_sorting(Post, params)
  end
end

defmodule Ecto.SortTest do
  use ExUnit.Case
  import Posts, only: [query: 1]

  describe "add_sort" do
    test "sort by name asc" do
      assert %Ecto.Query{order_bys: order_bys} =
               query(%{"s" => %{"featured" => "asc", "name" => "asc"}})

      assert [
               %{expr: [asc: {{_, _, [_, :featured]}, [], []}]},
               %{expr: [asc: {{_, _, [_, :name]}, [], []}]}
             ] = order_bys
    end

    test "sort by name desc" do
      assert %Ecto.Query{order_bys: order_bys} =
               query(%{"s" => %{"featured" => "desc", "name" => "desc"}})

      assert [
               %{expr: [desc: {{_, _, [_, :featured]}, [], []}]},
               %{expr: [desc: {{_, _, [_, :name]}, [], []}]}
             ] = order_bys
    end

    test "sort with keywords" do
      assert %Ecto.Query{order_bys: order_bys} = query(s: [name: :asc, featured: :asc])

      assert [
               %{expr: [asc: {{_, _, [_, :name]}, [], []}]},
               %{expr: [asc: {{_, _, [_, :featured]}, [], []}]}
             ] = order_bys
    end

    test "sort with map" do
      assert %Ecto.Query{order_bys: order_bys} = query(%{s: %{name: :asc}})
      assert [%{expr: [asc: {{_, _, [_, :name]}, [], []}]}] = order_bys
    end
  end

  describe "add_custom_sort" do
    test "sort by inserted comments" do
      assert %Ecto.Query{order_bys: order_bys, joins: joins} =
               query(s: [comments_inserted_at: :asc])

      assert [%{expr: [asc: {{_, _, [_, :inserted_at]}, [], []}]}] = order_bys
      assert [%{as: :comments, assoc: {0, :comments}}] = joins
    end
  end
end
