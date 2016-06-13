class MigrationCreateTypeShowStatus < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE TYPE show_status AS ENUM ('airing', 'hiatus', 'closed');
    SQL
  end

  def down
    execute <<-SQL
    DROP TYPE show_status;
    SQL
  end
end
