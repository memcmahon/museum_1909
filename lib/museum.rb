class Museum
  attr_reader :name,
              :patrons,
              :patrons_of_exhibits,
              :revenue

  def initialize(name)
    @name = name
    # @exhibits = []
    @patrons = []
    @patrons_of_exhibits = {}
    @revenue = 0
  end

  def exhibits
    @patrons_of_exhibits.keys
  end

  def add_exhibit(exhibit)
    # @exhibits << exhibit
    @patrons_of_exhibits[exhibit] = []
  end

  def admit(patron)
    @patrons << patron
    exhibits_by_cost.each do |exhibit|
      if patron.spending_money >= exhibit.cost && patron.interests.include?(exhibit.name)
        @patrons_of_exhibits[exhibit] << patron
        patron.spending_money -= exhibit.cost
        @revenue += exhibit.cost
      end
    end
  end

  def recommend_exhibits(patron)
    # need exhibit name, individually
    # does interests include the exhibit.name? If yes, recommend
    # recommended = []
    # @exhibits.each do |exhibit|
    #   if patron.interests.include?(exhibit.name)
    #     recommended << exhibit
    #   end
    # end
    # recommended

    exhibits.find_all do |exhibit|
      patron.interests.include?(exhibit.name)
    end

    # recommended = [] << This causes double iteration, so be careful!!
    # patron.interests.each do |interest|
    #   recommended << @exhibits.find { |exhibit| exhibit.name == interest }
    # end
    # recommended
  end

  def patrons_by_exhibit_interest
    # return a hash; keys: exhibits, values: array of patrons interested in that exhibit
    ##################
    # patrons_by_exhibit_interest = {}
    # @exhibits.each do |exhibit|
    #   interested_patrons = @patrons.find_all do |patron|
    #     patron.interests.include?(exhibit.name)
    #   end
    #   patrons_by_exhibit_interest[exhibit] = interested_patrons
    #   # for each exhibit, iterate over patrons and find the ones interested in exh
    # end
    # patrons_by_exhibit_interest
    ###################
    patrons_by_exhibit_interest = {}
    exhibits.each do |exhibit|
      patrons_by_exhibit_interest[exhibit] = interested_patrons(exhibit)
    end
    patrons_by_exhibit_interest
  end

  #HELPER METHODS
  def interested_patrons(exhibit)
    @patrons.find_all do |patron|
      patron.interests.include?(exhibit.name)
    end
  end

  def exhibits_by_cost
    exhibits.sort_by do |exhibit|
      exhibit.cost
    end.reverse
  end
end
