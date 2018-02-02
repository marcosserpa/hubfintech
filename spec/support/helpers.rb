module Helpers
  def transfer_code
    [*('a'..'z'), *('0'..'9'), *('A'..'Z')].sample(62).join
  end
end