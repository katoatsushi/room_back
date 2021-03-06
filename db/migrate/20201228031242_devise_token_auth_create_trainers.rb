class DeviseTokenAuthCreateTrainers < ActiveRecord::Migration[6.0]
  def change
    
    create_table(:trainers) do |t|
      t.integer :company_id
      ## Required
      t.string :provider, :null => false, :default => "email"
      t.string :uid, :null => false, :default => ""

      ## Database authenticatable
      t.string :encrypted_password, :null => false, :default => ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at
      t.boolean  :allow_password_change, :default => false

      ## Rememberable
      t.datetime :remember_created_at

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, :default => 0, :null => false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

      ## User Info
      t.string :first_name_kanji
      t.string :last_name_kanji
      t.string :first_name_kana
      t.string :last_name_kana

      # t.datetime :birthday
      # t.integer :age
      # t.string :gender
      # t.string :phonenumber
      # t.string :emergency_phonenumber
      t.string :email

      ## Tokens
      t.text :tokens

      t.timestamps
    end

    add_index :trainers, :email,                unique: true
    add_index :trainers, [:uid, :provider],     unique: true
    add_index :trainers, :reset_password_token, unique: true
    add_index :trainers, :confirmation_token,   unique: true
    # add_index :trainers, :unlock_token,       unique: true
  end
end
