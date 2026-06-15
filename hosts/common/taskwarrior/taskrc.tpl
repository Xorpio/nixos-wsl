# Taskwarrior configuration with synced settings
dateformat=Y-M-D H:N
dateformat.info=Y-M-D H:N:S
dateformat.annotation=Y-M-D H:N

# Sync configuration (populated from secrets)
sync.server.url=$SYNC_SERVER_URL
sync.server.client_id=$SYNC_SERVER_CLIENT_ID
sync.encryption_secret=$SYNC_SERVER_ENCRYPTION_SECRET

uda.reviewed.type=date
uda.reviewed.label=Reviewed
uda.review.type=string
uda.review.label=Review
report._reviewed.description=Tasksh review report.  Adjust the filter to your needs.
report._reviewed.columns=uuid
report._reviewed.sort=reviewed+,modified+
report._reviewed.filter=( reviewed.none: or reviewed.before:now-6days ) and ( +PENDING or +WAITING ) and review.not:none

news.version=3.4.1

# New
