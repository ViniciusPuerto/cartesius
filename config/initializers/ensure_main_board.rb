# frozen_string_literal: true

# Ensure a board named "main" exists every time the app boots.
Rails.application.config.after_initialize do
  begin
    conn = ActiveRecord::Base.connection
    if conn.data_source_exists?("boards")
      Board.find_or_create_by!(name: "main")
    end
  rescue ActiveRecord::NoDatabaseError, ActiveRecord::ConnectionNotEstablished, ActiveRecord::StatementInvalid
    # Database or table not available yet (during db:prepare). Skip.
  end
end
