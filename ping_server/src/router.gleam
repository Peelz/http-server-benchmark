import app/context.{type Context}
import gleam/bytes_tree
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/json
import mist.{type Connection, type ResponseData}

pub type PingResponse {
  PingResponse(meta: String, message: String)
}

pub fn encode_response(res: PingResponse) -> String {
  json.object([
    #("__type", json.string(res.meta)),
    #("message", json.string(res.message)),
  ])
  |> json.to_string()
}

pub fn ping(_req: Request(Connection), _ctx: Context) -> Response(ResponseData) {
  let res =
    PingResponse("Success", "pong")
    |> encode_response
    |> bytes_tree.from_string

  response.new(200)
  |> response.set_body(mist.Bytes(res))
}
