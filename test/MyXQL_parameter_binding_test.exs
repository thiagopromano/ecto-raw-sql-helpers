defmodule EctoRawSQLHelpers.MyXQLParameterBindingTest do
  use SQLCase

  alias EctoRawSQLHelpers.SQL

  test "MyXQL query with parameter binding" do
    {:ok, pid} = EctoRawSQLHelpers.MySQLRepoForTest.start_link(name: nil)
    SQL.affecting_statement(
      pid,
       "CREATE TABLE IF NOT EXISTS test (id INT PRIMARY KEY AUTO_INCREMENT, value VARCHAR(50))"
    )

    affected_rows = SQL.affecting_statement(
      EctoRawSQLHelpers.MySQLRepoForTest,
       "INSERT INTO test (id, value) VALUES (:id, :value), (10, 'test value')",
       %{id: 5, value: "some string"}
    )

    assert affected_rows == 2

    query_result = SQL.query_get_single_result(
      EctoRawSQLHelpers.MySQLRepoForTest,
       "SELECT * FROM test WHERE value = :value",
       %{value: "some string"},
       column_names_as_atoms: true
    )

    assert query_result == %{id: 5, value: "some string"}

    query_result = SQL.query(
      EctoRawSQLHelpers.MySQLRepoForTest,
       "SELECT id FROM test WHERE id IN(:ids) ORDER BY id",
       %{ids: {:in, [5, 10]}},
       column_names_as_atoms: true
    )

    assert query_result == [
      %{id: 5},
      %{id: 10},
    ]

  end

  setup do
    Application.put_env(:ecto_raw_sql_helper, :column_names_as_atoms, true)
    on_exit(fn ->
      Application.delete_env(:ecto_raw_sql_helper, :column_names_as_atoms)
    end)
    :ok
  end
end
