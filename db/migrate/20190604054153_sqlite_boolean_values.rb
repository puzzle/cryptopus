class SqliteBooleanValues < ActiveRecord::Migration[5.2]

  # https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SQLite3Adapter.html#method-c-represent_boolean_as_integer

  def up
    require 'pry'; binding.pry unless $pstop
    return unless sqlite?

    User.where("locked = 't'").update_all(locked: 1)
    User.where("locked = 'f'").update_all(locked: 0)

    Team.where("visible = 't'").update_all(visible: 1)
    Team.where("visible = 'f'").update_all(visible: 0)

    Team.where("private = 't'").update_all(private: 1)
    Team.where("private = 'f'").update_all(private: 0)
  end

  private

  def sqlite?
    ActiveRecord::Base.connection.instance_of?(ActiveRecord::ConnectionAdapters::SQLite3Adapter)
  end

end
