import Config

config :coronabot,
  children: [
    {Coronabot.State.LatestDataDate, [initial: Date.utc_today(), reschedule_in: 1_000 * 60 * 60]},
    {Coronabot.State.PublishResults, [reschedule_in: 5_000]}
  ]
