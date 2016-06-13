class CreateSubtype < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE TYPE subtype AS ENUM ('episode', 'season');
    SQL
  end

  def down
    execute <<-SQL
    DROP TYPE subtype;
    SQL
  end
end
