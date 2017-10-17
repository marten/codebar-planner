class PastEvents
  def self.fetch_at_most(amount)
    events = []
    events << Workshop.includes(:sponsors, :chapter, :permissions).past.limit(amount)
    events << Course.includes(:sponsor, :chapter).past.limit(amount)
    events << Meeting.past.limit(amount)
    events << Event.past.limit(amount)
    events.compact.flatten.sort_by(&:date_and_time).reverse.first(amount)
  end
end
