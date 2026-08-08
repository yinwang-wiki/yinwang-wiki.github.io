#!/usr/bin/env ruby

require "date"
require "yaml"

REQUIRED_FIELDS = %w[
  title date original_date author content_type topic source_status
  fact_checked rights permalink
].freeze
ALLOWED_SOURCE_STATUSES = %w[documented unavailable].freeze
UNRESOLVED_LINK_PHRASES = [
  "你可以在这里下载",
  "可以在这里看到它的全文",
  "如果想不出来，可以看这里",
  "想了解这个手段，可以看这篇文章"
].freeze

errors = []
posts = Dir.glob(File.join(__dir__, "..", "_posts", "*.md")).sort

posts.each do |path|
  relative_path = path.sub(%r{\A#{Regexp.escape(File.join(__dir__, ".."))}/?}, "")
  body = File.read(path, encoding: "UTF-8")
  match = body.match(/\A---\s*\n(.*?)\n---\s*\n/m)

  unless match
    errors << "#{relative_path}: missing YAML front matter"
    next
  end

  begin
    data = YAML.safe_load(match[1], permitted_classes: [Date, Time], aliases: true) || {}
  rescue Psych::SyntaxError => e
    errors << "#{relative_path}: invalid YAML (#{e.message.lines.first.strip})"
    next
  end

  REQUIRED_FIELDS.each do |field|
    errors << "#{relative_path}: missing #{field}" unless data.key?(field) && !data[field].nil? && data[field] != ""
  end

  original_date = data["original_date"].to_s
  filename_date = File.basename(path)[0, 10]
  errors << "#{relative_path}: original_date must match filename date" unless original_date == filename_date

  archive_date = data["date"]
  unless archive_date.is_a?(Time) && archive_date.strftime("%Y-%m-%d") == original_date && archive_date.utc_offset == 8 * 60 * 60 && archive_date.hour == 12
    errors << "#{relative_path}: date must be original_date at 12:00:00 +0800"
  end

  errors << "#{relative_path}: content_type must be historical_archive" unless data["content_type"] == "historical_archive"
  errors << "#{relative_path}: fact_checked must be false for archived text" unless data["fact_checked"] == false

  source_status = data["source_status"].to_s
  errors << "#{relative_path}: invalid source_status #{source_status.inspect}" unless ALLOWED_SOURCE_STATUSES.include?(source_status)
  if source_status == "documented" && data["source_url"].to_s.empty?
    errors << "#{relative_path}: documented source requires source_url"
  end

  expected_path = original_date.tr("-", "/")
  unless data["permalink"].to_s.include?("/#{expected_path}/")
    errors << "#{relative_path}: permalink must contain /#{expected_path}/"
  end

  UNRESOLVED_LINK_PHRASES.each do |phrase|
    errors << "#{relative_path}: unresolved link phrase #{phrase.inspect}" if body.include?(phrase)
  end
end

if posts.empty?
  warn "No archived posts found"
  exit 1
end

if errors.any?
  warn errors.join("\n")
  warn "\nContent validation failed with #{errors.length} error(s)."
  exit 1
end

puts "Validated #{posts.length} archived posts."
