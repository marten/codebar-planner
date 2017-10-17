class UpcomingEvents
  def self.fetch_all
    events = []
    events << Workshop.includes(:sponsors, :permissions, chapter: {permissions: [:members]}).upcoming.all
    events << Course.includes(:sponsor, :permissions, chapter: {permissions: [:members]}).upcoming.all
    events << Meeting.upcoming.all
    events << Event.upcoming.all
    events.compact.flatten.sort_by(&:date_and_time)
  end
end
