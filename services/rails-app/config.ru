require "json"

app = lambda do |_env|
  body = JSON.generate(service: "rails-app")
  [200, { "content-type" => "application/json" }, [body]]
end

run app
