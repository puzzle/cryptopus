class ChangelogEntry
  attr_reader :version
  attr_reader :log_entries

  def initialize(version)
    @version = version
    @log_entries = []
  end

  def add(change)
    @log_entries << change
  end
end
