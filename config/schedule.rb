every 1.minute do
  runner 'Event.update_events_status'
end
# run this "whenever -w"
