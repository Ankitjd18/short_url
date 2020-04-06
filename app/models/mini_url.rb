class MiniUrl
  include Mongoid::Document

  field :url_code, type: String
  field :url, type: String
  field :redirect_count, type: Integer, default: 0
  field :expiry, type: Date

  belongs_to :user, optional: true

  validates :url_code, presence: true, uniqueness: true

  index({url_code: 1}, {name: 'url_code_index'})
  index({url: 1}, {name: 'url_index'})

  # generate unique url code and save the record
  def generate_unique_code
    loop do
      self.url_code = SecureRandom.alphanumeric(8)
      break unless self.class.find_by(url_code: self.url_code)
    end
    self.save
  end
end
