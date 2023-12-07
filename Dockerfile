FROM elixir:1.15.7

COPY . .

RUN mix local.hex --force

CMD [ "bash" ]