class CreateAccounts < ActiveRecord::Migration

  def up
    create_table :accounts do |t|
      t.integer :balance, :default => 0, :null => false
      t.integer :_update_token, :default => nil , :null => false
    end

    execute <<-SQL

    CREATE OR REPLACE FUNCTION validate_update_token()
    RETURNS trigger
    AS $$
    DECLARE
      new_row RECORD;
    BEGIN
      IF OLD._update_token <> -  NEW._update_token THEN
        RAISE 'update token has expired';
        RETURN NULL;
      END IF;
      new_row := NEW;
      new_row._update_token := random_pos_int();
      RETURN  new_row;
    END $$
    LANGUAGE PLPGSQL;

    CREATE TRIGGER verify_update_token
      BEFORE UPDATE
      ON accounts
      FOR EACH ROW execute procedure validate_update_token();


    CREATE OR REPLACE FUNCTION create_update_token()
    RETURNS trigger
    AS $$
    DECLARE
      new_row RECORD;
    BEGIN
      new_row := NEW;
      new_row._update_token :=  random_pos_int();
      RETURN new_row;
    END $$
    LANGUAGE PLPGSQL;

    CREATE TRIGGER create_update_token
      BEFORE INSERT
      ON accounts
      FOR EACH ROW execute procedure create_update_token();


    CREATE OR REPLACE FUNCTION random_pos_int()
    RETURNS integer
    AS $$
    BEGIN
      RETURN floor(2147483646 * random() + 1)::int;
    END $$
    LANGUAGE PLPGSQL;

    SQL

  end

  def down
    drop_table :accounts
  end


end
