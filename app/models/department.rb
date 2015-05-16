class Department < ActiveRecord::Base
  validates :dept_name, presence: true, uniqueness: true

  has_many :users, dependent: :destroy
  has_many :addresses, through: :users

  searchable do
    text :dept_name
    text :location
  end
end
