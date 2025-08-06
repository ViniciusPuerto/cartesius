# frozen_string_literal: true

# Ensure a board named "main" exists every time the app boots.
Rails.application.config.after_initialize do
  begin
    Board.find_or_create_by!(name: "main")
  rescue ActiveRecord::NoDatabaseError, ActiveRecord::ConnectionNotEstablished
    # During `rails db:create` or assets precompile there may be no DB; ignore.
  end
end
