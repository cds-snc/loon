defmodule LoonWeb.JobsControllerTest do
  use LoonWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    resp = json_response(conn, 200)
    assert Map.has_key?(resp, "test")
  end
end
