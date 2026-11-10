///|
fn[T] invalid(
  path : @json.JsonPath,
  message : String,
) -> T raise @json.JsonDecodeError {
  raise @json.JsonDecodeError((path, message))
}

///|
fn object(
  value : Json,
  path : @json.JsonPath,
) -> Map[String, Json] raise @json.JsonDecodeError {
  guard value is Object(fields) else { invalid(path, "需要 JSON 对象") }
  fields
}

///|
fn[T] required(
  fields : Map[String, Json],
  key : String,
  path : @json.JsonPath,
  decode : (Json, @json.JsonPath) -> T raise @json.JsonDecodeError,
) -> T raise @json.JsonDecodeError {
  let field_path = path.add_key(key)
  guard fields.get(key) is Some(value) else {
    invalid(field_path, "缺少必填字段")
  }
  decode(value, field_path)
}

///|
fn[T] optional(
  fields : Map[String, Json],
  key : String,
  path : @json.JsonPath,
  decode : (Json, @json.JsonPath) -> T raise @json.JsonDecodeError,
) -> T? raise @json.JsonDecodeError {
  match fields.get(key) {
    Some(value) => Some(decode(value, path.add_key(key)))
    None => None
  }
}

///|
fn[T] array_of(
  value : Json,
  path : @json.JsonPath,
  decode : (Json, @json.JsonPath) -> T raise @json.JsonDecodeError,
) -> Array[T] raise @json.JsonDecodeError {
  guard value is Array(items) else { invalid(path, "需要 JSON 数组") }
  let result = []
  for index, item in items {
    result.push(decode(item, path.add_index(index)))
  }
  result
}

///|
fn[T] map_of(
  value : Json,
  path : @json.JsonPath,
  decode : (Json, @json.JsonPath) -> T raise @json.JsonDecodeError,
) -> Map[String, T] raise @json.JsonDecodeError {
  let result = Map([])
  for key, item in object(value, path) {
    result.set(key, decode(item, path.add_key(key)))
  }
  result
}

///|
fn[T] map_to_json(fields : Map[String, T], encode : (T) -> Json) -> Json {
  let result = Map([])
  for key, value in fields {
    result.set(key, encode(value))
  }
  Json::object(result)
}

///|
fn number(
  value : Json,
  path : @json.JsonPath,
) -> Double raise @json.JsonDecodeError {
  guard value is Number(n, ..) && !n.is_inf() && !n.is_nan() else {
    invalid(path, "需要有限 JSON 数字")
  }
  n
}

///|
fn integer(
  value : Json,
  path : @json.JsonPath,
  min : Int64,
  max : Int64,
) -> Int64 raise @json.JsonDecodeError {
  let n = number(value, path)
  guard n >= min.to_double() && n <= max.to_double() && n == n.trunc() else {
    invalid(path, "需要范围内的 JSON 整数")
  }
  n.to_int64()
}

///|
fn wide_json(value : Int64) -> Json {
  Json::number(value.to_double(), repr=value.to_string())
}

///|
fn literal(
  value : Json,
  path : @json.JsonPath,
  expected : String,
) -> Unit raise @json.JsonDecodeError {
  guard value is String(actual) && actual == expected else {
    invalid(path, "需要固定标签 \{expected}")
  }
}

///|
fn extras(
  fields : Map[String, Json],
  known : Array[String],
) -> Map[String, Json] {
  let result = fields.copy()
  for key in known {
    result.remove(key)
  }
  result
}
