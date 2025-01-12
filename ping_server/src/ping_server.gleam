import app/context
import dot_env
import dot_env/env
import gleam/bytes_tree
import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/http/response
import mist.{type Connection, type ResponseData}
import router

pub fn main() {
  dot_env.new()
  |> dot_env.set_path(".env")
  |> dot_env.set_debug(False)
  |> dot_env.load()

  let http_port = env.get_int_or("HTTP_PORT", 9000)
  let ctx = context.Context

  let assert Ok(_) =
    fn(req: Request(Connection)) -> response.Response(ResponseData) {
      case request.path_segments(req) {
        ["ping"] -> router.ping(req, ctx)
        _ ->
          response.new(404)
          |> response.set_body(mist.Bytes(bytes_tree.new()))
      }
    }
    |> mist.new()
    |> mist.bind("0.0.0.0")
    |> mist.port(http_port)
    |> mist.start_http()
  process.sleep_forever()
}
