class RemoveGeneralPrefixSettings < ActiveRecord::Migration[6.1]
  def up
    return if Setting.count.zero?

    ['country_source_whitelist', 'ip_whitelist'].each do |key|
      if legacy_setting_exists?(key)
        if new_setting_exists?(key)
          Setting.find_by(key: legacy_key(key)).destroy!
        else
          Setting.find_by(key: legacy_key(key)).update!(key: new_key(key))
        end
      end
    end
  end

  def down
    return if Setting.count.zero?

    ['country_source_whitelist', 'ip_whitelist'].each do |key|
      if new_setting_exists?(key)
        if legacy_setting_exists?(key)
          Setting.find_by(key: new_key(key)).destroy!
        else
          Setting.find_by(key: new_key(key)).update!(key: legacy_key(key))
        end
      end
    end
  end

  private

  def legacy_setting_exists?(key)
    Setting.exists?(key: legacy_key(key))
  end

  def new_setting_exists?(key)
    Setting.exists?(key: new_key(key))
  end

  def legacy_key(key)
    legacy_key?(key) ? key : "general_#{key}"
  end

  def new_key(key)
    new_key?(key) ? key : key.sub('general_', '')
  end

  def legacy_key?(key)
    key.starts_with?('general_')
  end

  def new_key?(key)
    !legacy_key?(key)
  end
end
