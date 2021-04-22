class HomeController < ApplicationController

  def index
    current_user = User.first_or_initialize(current_user)
    api = SilverfinApi.new(user: current_user,
                     oauth_access_token: current_user.oauth_access_token)
    recons = []

    company_page = 0
    loop do
      company_page += 1
        puts "company_page: #{company_page}"
        companies = api.get_companies(page: company_page)
        companies[:data].each do |company|
          this_company = Company.first_or_initialize(id: company["id"], name: company["name"], firm_id: current_user.firm_id)
          puts company["name"]
          periods = api.get_periods(company_id: company["id"])
          found = false
          if periods[:data].count > 0
            period = periods[:data].last
            reconciliation_page = 0
            loop do
              reconciliation_page += 1
              puts "reconciliation_page: #{reconciliation_page}"
              reconciliations = api.get_reconciliations(company_id: company["id"], period_id: period["id"], page: reconciliation_page)
              reconciliations[:data].each do |reconciliation|
                puts reconciliation["handle"]
                if reconciliation["handle"] == "fintrax_tableau"
                  results = api.get_reconciliation_results(company_id: company["id"], period_id: period["id"], reconciliation_id: reconciliation["id"])
                  results.each do |result|
                    financial = Financial.first_or_initialize(key: result[0])
                    financial.value = result[1]
                    financial.save!
                  end
                  break
                end
              end
            break if reconciliations[:data].count == 0 or found
            end
          end
        end
      break if companies[:data].count == 0
    end

  end

end
