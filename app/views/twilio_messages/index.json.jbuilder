json.array!(@twilio_messages) do |twilio_message|
  json.extract! twilio_message, :message_sid, :date_created, :date_updated, :date_sent, :account_sid, :from, :to, :body, :status, :error_code, :error_message, :direction, :from_city, :from_state, :from_zip, :wufoo_formid, :conversation_count
  json.url twilio_message_url(twilio_message, format: :json)
end