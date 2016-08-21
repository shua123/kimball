# TODO: needs a spec. The acceptance
# spec 'SMS invitation to phone call' covers it,
# but a unit test would make coverage more robust
class EventInvitationSms < ApplicationSms
  attr_reader :to, :event

  def initialize(to:, event:)
    super
    @to = to
    @event = event
  end

  def send
    client.messages.create(
      from: application_number,
      to:   to.phone_number,
      body: body
    )
  end

  private

    # rubocop:disable Metrics/MethodLength,
    def body
      body = "Hello #{to.first_name},\n"
      body << "#{event.description}\n"
      body << "If you're available, would you so kind to select one of the possible times below,"
      body << " by texting back its respective number?\n\n"
      event.available_time_slots(to).each_with_index do |slot, i|
        body << "'#{event.id}#{slot_id_to_char(i)}' for #{slot.to_time_and_weekday}\n"
      end
      body << "Or visit https://#{ENV['PRODUCTION_SERVER']}/calendar/?token=#{@to.token} to pick a time.\n"
      body << "If none of these times work, please respond with: #{@event.id}0)  to decline\n"
      body << "\nThanks in advance for you time!\n\n"
      body << 'Best, Kimball team' # TODO: signature should be configurable
    end
  # rubocop:enable Metrics/MethodLength,
end
