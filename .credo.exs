%{
  configs: [
    %{
      name: "default",
      strict: true,
      checks: %{
        extra: [
          # Docker.Commands.Run legitimately needs 40+ fields to cover
          # the full `docker run` CLI surface area.
          {Credo.Check.Warning.StructFieldAmount, max_fields: 50}
        ]
      }
    }
  ]
}
