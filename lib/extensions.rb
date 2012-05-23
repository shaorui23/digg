class Array
  # a = ["1002", "1003", "1004", "1005", "1006"]
  # a.random_num("1003") => "1004"
  def random_num id
    rand = rand(self.size)
    if id != temp
      temp = self.slice(rand)
    else
      temp = self.slice(rand+1)
    end
  end
end
