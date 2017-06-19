defmodule Cryptofolio.Trade do
  def drop_ticks(trades) when is_list(trades) do
    # XXX: There ought to be a way for Poison to encode
    # conditionally (ticks needed in pie chart, not needed in line chart)
    Enum.map(trades, &drop_ticks/1)
  end

  def drop_ticks(trade) do
    map = trade
    |> Map.from_struct
    |> Map.drop([:__meta__, :__struct__, :currencies, :user])
    currency = map.currency
    |> Map.from_struct
    |> Map.drop([:__meta__, :__struct__])

    %{ map | currency: Map.drop(currency, [:ticks, :trades]) }
  end

  def total_cost(%{ cost: cost, amount: amount }) do
    Decimal.mult(cost, amount)
  end

  def current_value(%{ amount: amount, currency: %{ last_tick: last_tick } }) do
    Decimal.mult(amount, last_tick.cost_usd)
  end

  def profit_loss(trade) do
    Decimal.sub(current_value(trade), total_cost(trade))
  end

  def profit_loss_perc(trade) do
    Decimal.mult(Decimal.div(profit_loss(trade), total_cost(trade)), Decimal.new(100))
  end
end