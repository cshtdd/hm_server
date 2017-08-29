defmodule HMServerWeb.ApiBeatControllerTest do
  use HMServerWeb.ConnCase

  defp send_hostname(hostname \\ "host1"), do: [hostname: hostname] 

  defp authenticate(conn, username \\ default_user(), password \\ default_password()) do
    header_content = "Basic " <> Base.encode64("#{username}:#{password}")
    conn |> put_req_header("authorization", header_content)
  end

  test "POST /api/beat fails when no credentials are provided", %{conn: conn} do
    conn = post conn, "/api/beat", send_hostname()

    assert conn.status == 401
  end

  test "POST /api/beat fails when no credentials are in the db", %{conn: conn} do
    conn = conn
    |> authenticate
    |> post("/api/beat", send_hostname())

    assert conn.status == 401
  end

  test "POST /api/beat fails when credentials are incorrect", %{conn: conn} do
    insert!(:credential)

    conn = conn
    |> authenticate(default_user(), "incorrect")
    |> post("/api/beat", send_hostname())

    assert conn.status == 401
  end

  test "POST /api/beat fails when credentials are disabled", %{conn: conn} do
    insert!(:credential, %{client_disabled: true})

    conn = conn
    |> authenticate
    |> post("/api/beat", send_hostname())

    assert conn.status == 401
  end

  test "POST /api/beat succeeds when credentials are correct", %{conn: conn} do
    insert!(:credential)

    conn = conn
    |> authenticate
    |> post("/api/beat", send_hostname())

    assert json_response(conn, 200) == %{"success" => true}
  end

  test "POST /api/beat fails when no hostname is specified", %{conn: conn} do
    insert!(:credential)

    conn = conn
    |> authenticate
    |> post("/api/beat")

    assert conn.status == 400
  end
end