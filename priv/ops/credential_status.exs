# Script to create a Credential
# It can be run like this
#    mix ops.credential.enable --client-id test
#    mix ops.credential.disable --client-id test
#

require Logger

Logger.info "Credential.Status"

argv = System.argv()
Logger.debug "argv=#{inspect argv}"

switches_spec = [enabled: :boolean, client_id: :string]
parsed_args = OptionParser.parse!(argv, strict: switches_spec)
Logger.debug "parsed_args=#{inspect parsed_args}"

case parsed_args do
  {[enabled: enabled, client_id: client_id], []} ->
    Logger.debug "enabled=#{enabled}; client_id=#{client_id};"

    client_id
    |> HMServer.Credential.get_by!
    |> Ecto.Changeset.change(disabled: !enabled)
    |> HMServer.Repo.update!

    Logger.info "Success!!"
  _ ->
    Logger.error "Received Invalid Arguments!!"
    exit(1)
end
