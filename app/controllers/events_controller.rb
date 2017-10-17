require 'services/ticket'

class EventsController < ApplicationController
  before_action :is_logged_in?, only: [:student, :coach]

  RECENT_EVENTS_DISPLAY_LIMIT = 40

  def index
    @past_events = present_events(PastEvents.fetch_at_most(RECENT_EVENTS_DISPLAY_LIMIT))
    @events = present_events(UpcomingEvents.fetch_all)
  end

  def present_events(events)
    events \
      .group_by(&:date)
      .map.inject({}) { |hash, (key, value)| hash[key] = EventPresenter.decorate_collection(value); hash}
  end

  def show
    event = Event.find_by_slug(params[:id])

    @event = EventPresenter.new(event)
    @host_address = AddressDecorator.new(@event.venue.address)

    if logged_in?
      invitation = Invitation.where(member: current_user, event: event, attending: true).try(:first)
      if invitation
        redirect_to event_invitation_path(@event, invitation) and return
      end
    end
  end

  def student
    find_invitation_and_redirect_to_event("Student")
  end

  def coach
    find_invitation_and_redirect_to_event("Coach")
  end

  def rsvp
    set_event
    ticket = Ticket.new(request, params)
    member = Member.find_by_email(ticket.email)
    invitation = member.invitations.where(event: @event, role: "Student").try(:first)
    invitation ||= Invitation.create(event: @event, member: member, role: "Student")

    invitation.update_attributes attending: true
    head :ok
  end

  private

  def find_invitation_and_redirect_to_event(role)
    set_event
    @invitation = Invitation.where(event: @event, member: current_user, role: role).try(:first)
    if @invitation.nil?
      @invitation = Invitation.new(event: @event, member: current_user, role: role)
      @invitation.save
    end

    redirect_to event_invitation_path(@event, @invitation)
  end

  def set_event
    @event = Event.find_by_slug(params[:event_id])
  end
end
