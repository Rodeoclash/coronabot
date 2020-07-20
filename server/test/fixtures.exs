defmodule Coronabot.Fixtures do
  def covid_data() do
    """
    FIPS,Admin2,Province_State,Country_Region,Last_Update,Lat,Long_,Confirmed,Deaths,Recovered,Active,Combined_Key,Incidence_Rate,Case-Fatality_Ratio
    ,,Victoria,Australia,2020-07-20 05:34:40,-37.8136,144.9631,5942,39,2933,2970,"Victoria, Australia",89.62427789257757,0.6563446650959273
    """
  end
end
