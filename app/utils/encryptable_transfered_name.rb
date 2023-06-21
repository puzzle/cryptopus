# frozen_string_literal: true

class EncryptableTransferedName

  INCREMENT_REGEX = /\((\d+)\)/

  def initialize(name, existing_names, is_file)
    @name = name
    @existing_names = existing_names
    @is_file = is_file
  end

  def destination_name
    destination_name = @name
    if @existing_names.present?
      similar_names = find_similar_names
      if similar_names.present? && similar_names.include?(@name)
        latest_name = similar_names.last
        destination_name = copy_name(@name, latest_name)
      end
    end

    destination_name
  end

  def copy_name(name, latest_name)
    if @is_file
      suffix = File.extname(name)
      name = File.basename(name, '.*')
    end

    next_copy_name(name, latest_name, suffix)
  end

  def next_copy_name(name, latest_name, suffix)
    # Remove (NUMBER) if it already exists in name
    if INCREMENT_REGEX.match(name)
      name = name.sub(/\(\d+\)\z/, '')
    end

    # If last encryptable in inbox has (NUMBER) add (NUMBER + 1)
    name += if INCREMENT_REGEX.match(latest_name)
                          "(#{INCREMENT_REGEX.match(latest_name)[1].to_i + 1})"
                        else
                          '(1)'
                        end

    name += suffix if @is_file

    name
  end

  def find_similar_names
    suffix = File.extname(@name)
    name = File.basename(@name, '.*')

    # For the loop through inbox encryptables remove (NUMBER) from name
    name = basename_of_copy(name)

    regex_pattern = /\A#{Regexp.escape(name)}(\(\d+\))?\z/
    @existing_names.select do |name|
      current_suffix = File.extname(name)
      current_name = File.basename(name, '.*')
      current_name.match?(regex_pattern) && current_suffix == suffix
    end
  end

  def basename_of_copy(name)
    basename_regex = /\A.*\(\d+\)\z/

    if name.match?(basename_regex)
      name = name.gsub(/\(\d+\)\z/, '')
    end

    name
  end

end
