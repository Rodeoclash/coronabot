defmodule Coronabot.CovidData.RecordsTest do
  alias Coronabot.{CovidData.Records, CovidData.Records.Record}
  use ExUnit.Case

  doctest Records

  describe "find/1" do
    test "fetches record based on search critera" do
      data = %Records{
        data: [
          [
            "45001",
            "Abbeville",
            "South Carolina",
            "US",
            "2020-07-18 04:34:45",
            "34.22333378",
            "-82.46170658",
            "176",
            "2",
            "0",
            "174",
            "Abbeville, South Carolina, US",
            "717.5765482937172",
            "1.1363636363636365"
          ],
          [
            "22001",
            "Acadia",
            "Louisiana",
            "US",
            "2020-07-18 04:34:45",
            "30.2950649",
            "-92.41419698",
            "1610",
            "48",
            "0",
            "1562",
            "Acadia, Louisiana, US",
            "2594.890805060843",
            "2.981366459627329"
          ],
          [
            "",
            "",
            "Victoria",
            "Australia",
            "2020-07-18 04:34:45",
            "-37.8136",
            "144.9631",
            "5353",
            "34",
            "2709",
            "2610",
            "Victoria, Australia",
            "80.74028265886362",
            "0.6351578554081824"
          ],
          [
            "16003",
            "Adams",
            "Idaho",
            "US",
            "2020-07-18 04:34:45",
            "44.89333571",
            "-116.4545247",
            "13",
            "0",
            "0",
            "13",
            "Adams, Idaho, US",
            "302.74802049371215",
            "0.0"
          ]
        ]
      }

      assert %Record{
               province_state: "Victoria",
               country_region: "Australia",
               last_update: ~N[2020-07-18 04:34:45],
               lat: "-37.8136",
               lng: "144.9631",
               confirmed: 5353,
               deaths: 34,
               recovered: 2709,
               active: 2610,
               combined_key: "Victoria, Australia",
               incidence_rate: 80.74028265886362,
               case_fatality_ratio: 0.6351578554081824
             } == Records.find(data, province_state: "Victoria", country_region: "Australia")
    end
  end
end
