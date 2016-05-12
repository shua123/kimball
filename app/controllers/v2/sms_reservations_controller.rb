# FIXME: Refactor and re-enable cop
# rubocop:disable ClassLength
class V2::SmsReservationsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, only: [:create]
  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def create
    send_error_notification && return unless person
    # FIXME: this needs a refactor badly.
    if letters_and_numbers_only? # they are trying to accept!
      reservation = V2::Reservation.new(generate_reservation_params)
      if reservation.save
        send_new_reservation_notifications(person, reservation)
      else
        resend_available_slots(person, event)
      end
    elsif declined? # currently not used.
      send_decline_notifications(person, event)
    elsif confirm? # confirmation for the days reservations
      if person.v2_reservations.for_today.size > 0
        person.v2_reservations.for_today.each(&:confirm!)
      else
        ::ReservationReminderSms.new(to: person, reservations: person.v2_reservations.for_today).send
      end
    elsif cancel?
      if person.v2_reservations.for_today.size > 0
        person.v2_reservations.for_today.each(&:cancel!)
      else
        ::ReservationReminderSms.new(to: person, reservations: person.v2_reservations.for_today).send
      end
    elsif change?
      if person.v2_reservations.for_today.size > 0
        person.v2_reservations.for_today.each(&:reschedule!)
      else
        ::ReservationReminderSms.new(to: person, reservations: person.v2_reservations.for_today).send
      end
    elsif calendar?
      ::ReservationReminderSms.new(to: person, reservations: person.v2_reservations.for_today_and_tomorrow).send
    else
      send_error_notification && return
    end
    render text: 'OK'
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  private

    def message
      sms_params[:Body]
    end

    def person
      @person ||= Person.find_by(phone_number: sms_params[:From])
    end

    # TODO: need to handle more than 26 slots
    def selection
      slot_letter = message.downcase.delete('^a-z')
      # "a".ord - ("A".ord + 32) == 0
      # "b".ord - ("A".ord + 32) == 1
      # (0 + 97).chr == a
      # (1 + 97).chr == b
      slot_letter.ord - ('A'.ord + 32)
    end

    def event
      event_id = message.delete('^0-9').to_i
      @event ||= V2::Event.includes(:event_invitation, :user, :time_slots).find_by(id: event_id)
    end

    def event_invitation
      @event_invitation ||= event.event_invitation
    end

    def user
      @user ||= event_invitation.user
    end

    def time_slot
      @event.time_slots[selection]
    end

    def generate_reservation_params
      { user: user,
        person: person,
        event: event,
        event_invitation: event_invitation,
        time_slot: time_slot }
    end

    def send_new_reservation_notifications(person, reservation)
      ::ReservationSms.new(to: person, reservation: reservation).send
      ReservationNotifier.notify(email_address: reservation.user.email, reservation: reservation).deliver_later
    end

    def send_decline_notifications(person, event)
      ::DeclineInvitationSms.new(to: person, event: event).send
    end

    def send_error_notification
      ::InvalidOptionSms.new(to: sms_params[:From]).send

      render text: 'OK'
    end

    def resend_available_slots(person, event)
      ::TimeSlotNotAvailableSms.new(to: person, event: event).send
    end

    def declined?
      # this is no longer in use. still might be handt though...
      # up to 10k events.
      message.downcase =~ /^\d{1,5}-decline?/
    end

    def confirm?
      message.downcase.include?('confirm')
    end

    def cancel?
      message.downcase.include?('cancel')
    end

    def change?
      message.downcase.include?('change') || message.downcase.include?('reschedule')
    end

    def calendar?
      message.downcase.include?('calendar')
    end

    def letters_and_numbers_only?
      # this is for accepting only. many messages now won't pass.
      # up to 10k events
      message.downcase =~ /\b\d{1,5}[a-z]\b/
    end

    def sms_params
      params.permit(:From, :Body)
    end
end
# rubocop:enable ClassLength
