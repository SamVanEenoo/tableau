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
          puts "COMPANY: #{company["id"]}"
          this_company = Company.find_or_initialize_by(id: company["id"], name: company["name"], firm_id: current_user.firm_id)
          this_company.save!
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
                  financial = Financial.find_or_initialize_by(company_id: company["id"])
                  results = api.get_reconciliation_results(company_id: company["id"], period_id: period["id"], reconciliation_id: reconciliation["id"])
                  results.each do |result|
                    case result[0]
                    when "ebitda"
                      financial.ebitda = result[1]
                    when "ebit"
                      financial.ebit = result[1]
                    end
                  end
                  financial.company_id = company["id"];
                  financial.save!
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


