class SilverfinApi
  def initialize(user: nil, oauth_access_token: nil)
    @user = user
    @oauth_access_token = oauth_access_token
  end

  def self.authorize_url(scopes = [])
    oauth_client.auth_code.authorize_url(redirect_uri: Rails.application.secrets.silverfin[:redirect_url], scope: scopes.join(" "))
  end

  def self.get_token(code)
    oauth_client.auth_code.get_token(code, redirect_uri: Rails.application.secrets.silverfin[:redirect_url])
  end

  def get_firm
    make_request(:get, '/api/v3/user/firm')
  end

  def get_companies(page: 1)
    make_request(:get, '/api/v3/companies', page: page)
  end

  def get_company(company_id:)
    make_request(:get, "/api/v3/companies/#{company_id}")
  end

  def update_company(company_id:, year_end: nil, company_template_id: nil, periods_per_year: nil, custom: nil)
    make_request(:post, "/api/v3/companies/#{company_id}", {year_end: year_end, company_template_id: company_template_id, periods_per_year: periods_per_year, custom: custom}.compact)
  end

  def get_periods(company_id:)
    make_request(:get, "/api/v3/companies/#{company_id}/periods")
  end

  def get_reconciliations(company_id:, period_id:, page: 1)
    make_request(:get, "/api/v3/companies/#{company_id}/periods/#{period_id}/reconciliations", page: page, per_page: 200)
  end

  def get_workflows(company_id:, period_id:, page: 1)
    make_request(:get, "/api/v3/companies/#{company_id}/periods/#{period_id}/workflows", page: page, per_page: 200)
  end

  def get_reconciliation_results(company_id:, period_id:, reconciliation_id:)
    make_request(:get, "/api/v3/companies/#{company_id}/periods/#{period_id}/reconciliations/#{reconciliation_id}/results")
  end

  def update_reconciliations(company_id:, period_id:, reconciliation_id:, starred:)
    make_request(:post, "/api/v3/companies/#{company_id}/periods/#{period_id}/reconciliations/#{reconciliation_id}", body: {starred: starred}.to_json, headers: {'Content-Type' => 'application/json'})
  end

  def get_reconciliation_properties(company_id:, period_id:, reconciliation_id:)
    make_request(:get, "/api/v3/companies/#{company_id}/periods/#{period_id}/reconciliations/#{reconciliation_id}/custom")
  end

  def create_reconciliation_properties(company_id:, period_id:, reconciliation_id:, namespace:, key:, value:, documents: [])
    # documents should be an array of Faraday::UploadIO objects
    if documents != []
      documents.map! { |faraday_upload_io| {content: faraday_upload_io} }
      make_request(:post, "/api/v3/companies/#{company_id}/periods/#{period_id}/reconciliations/#{reconciliation_id}/custom",
        body: {
          properties: [
            {
              namespace: namespace,
              key: key,
              value: value,
              documents: documents
            }
          ]
        }
      )
    else
      make_request(:post, "/api/v3/companies/#{company_id}/periods/#{period_id}/reconciliations/#{reconciliation_id}/custom",
        body: {
          properties: [
            {
              namespace: namespace,
              key: key,
              value: value
            }
          ]
        }
      )
    end
  end

  def get_accounts(firm_id:, company_id:, page: 1)
    make_request(:get, "/api/v4/f/#{firm_id}/companies/#{company_id}/accounts", page: page, per_page: 200)
  end

  def get_account(firm_id:, company_id:, period_id:, account_id:, page: 1)
    make_request(:get, "/api/v4/f/#{firm_id}/companies/#{company_id}/periods/#{period_id}/accounts/#{account_id}", page: page)
  end

  def get_account_properties(company_id:, period_id:, account_id:, page: 1)
    make_request(:get, "/api/v3/companies/#{company_id}/periods/#{period_id}/accounts/#{account_id}/custom", page: page, per_page: 200)
  end

  def create_account_properties(company_id:, period_id:, account_id:, properties:)
    make_request(:post, "/api/v3/companies/#{company_id}/periods/#{period_id}/accounts/#{account_id}/custom", body: {properties: properties}.to_json, headers: {'Content-Type' => 'application/json'})
  end

  def get_links(page: 1)
    make_request(:get, '/api/v3/app/links', page: page)
  end

  def create_link(name:, target_url:, placement:, placement_options: {})
    make_request(:post, '/api/v3/app/links', {name: name, target_url: target_url, placement: placement, placement_options: placement_options})
  end

  def destroy_link(link_id:)
    make_request(:delete, "/api/v3/app/links/#{link_id}")
  end

  def get_pdf_for_permanent_text(company_id:, period_id:, permanent_text_id:)
    oauth_token.request(:get, "/api/v3/companies/#{company_id}/periods/#{period_id}/permanent_texts/#{permanent_text_id}.pdf").body
  end

  def get_export_files(company_id:, period_id:)
    make_request(:get, "/api/v3/companies/#{company_id}/periods/#{period_id}/export_files")
  end

  def get_export_file(company_id:, period_id:, export_file_id:)
    make_request(:get, "/api/v3/companies/#{company_id}/periods/#{period_id}/export_files/#{export_file_id}")
  end

  def get_export_file_instance(company_id:, period_id:, export_file_instance_id:)
    make_request(:get, "/api/v3/companies/#{company_id}/periods/#{period_id}/export_file_instances/#{export_file_instance_id}")
  end

  def get_sign_markers_for_permanent_text(company_id:, period_id:, permanent_text_id:)
    make_request(:get, "/api/v3/companies/#{company_id}/periods/#{period_id}/permanent_texts/#{permanent_text_id}/sign_markers")
  end

  def get_permanent_folder(company_id:, folder_id: 0)
    make_request(:get, "/api/v3/companies/#{company_id}/permanent_folders/#{folder_id}")
  end

  def update_permanent_document(company_id:, permanent_document_id:, parent_id: nil, name: nil)
    make_request(:post, "/api/v3/companies/#{company_id}/permanent_documents/#{permanent_document_id}", parent_id: parent_id, name: name)
  end

  def create_special_book_year(company_id:, start_date:, end_date:)
    special_book_years_params = {
      start_date: start_date,
      end_date: end_date
    }
    make_request(:post, "/api/v3/companies/#{company_id}/special_book_years", **special_book_years_params)
  end

  def create_webhook(company_id:, endpoint_url:)
    webhook_params = {
      url: endpoint_url,
      events: ['transaction_document.processed'],
    }
    make_request(:post, "/api/v3/companies/#{company_id}/webhooks", **webhook_params)
  end

  def destroy_webhook(company_id:, webhook_id:)
    make_request(:delete, "/api/v3/companies/#{company_id}/webhooks/#{Integer(webhook_id)}")
  end

  def create_remark(company_id:, period_id:, text:, owner_type: 'Company', owner_id: company_id, bot_name:, documents: [])
    # documents should be an array of Faraday::UploadIO objects
    documents.map! { |faraday_upload_io| {content: faraday_upload_io} }
    make_request(:post,
                 "/api/v3/companies/#{company_id}/periods/#{period_id}/remarks",
                 {
                   body:
                     {
                       text: text,
                       bot_name: bot_name,
                       owner: {type: owner_type, id: owner_id},
                       documents: documents
                     }
                   }
                )
  end

  def create_comment(company_id:, remark_id:, text:, bot_name:)
    make_request(:post,
                 "/api/v3/companies/#{company_id}/remarks/#{remark_id}/comments",
                 {
                   body:
                     {
                       text: text,
                       bot_name: bot_name
                     }
                   }
                )
  end

  def create_transaction_upload(company_id:, column_names:, csv_file:)
    make_request(:post,
                 "/api/v3/companies/#{company_id}/transaction_uploads",
                 {
                   body:
                     {
                       column_names: column_names,
                       content: csv_file
                     }
                   }
                )
  end

  def get_transaction_upload(company_id:, transaction_upload_id:)
    make_request(:get, "/api/v3/companies/#{company_id}/transaction_uploads/#{transaction_upload_id}")
  end

  private

  def oauth_client
    @oauth_client ||= OAuth2::Client.new(Rails.application.secrets.silverfin[:id], Rails.application.secrets.silverfin[:secret], site: Rails.application.secrets.silverfin[:url], authorize_url: 'oauth/authorize', token_url: 'oauth/token', parse_json: true) do |builder|
      builder.use Faraday::Request::Multipart
      builder.use Faraday::Request::UrlEncoded
      builder.adapter Faraday::Adapter::NetHttp
    end
  end

  def self.oauth_client
    OAuth2::Client.new(Rails.application.secrets.silverfin[:id], Rails.application.secrets.silverfin[:secret], site: Rails.application.secrets.silverfin[:url], authorize_url: 'oauth/authorize', token_url: 'oauth/token')
  end

  def oauth_token
    @oauth_token ||=
      if @oauth_access_token
        token = OAuth2::AccessToken.from_hash(oauth_client, @oauth_access_token)
        if token.expires? && (token.expires_at < Time.now.to_i+240)
          token = token.refresh!
          @user.update!(oauth_access_token: token.to_hash)
        end
        token
      end
  end

  def make_request(method, path, **params)
    if params[:body]
      response = oauth_token.request(method, path, body: params[:body], headers: params[:headers])
    else
      response = oauth_token.request(method, path, params: params)
    end

    if response.body.length > 0
      total    = response.headers["total"]
      per_page = response.headers["per-page"]

      total    = Integer(total)    if total
      per_page = Integer(per_page) if per_page

      data = response.parsed

      if total && per_page
        {data: data, total: total, per_page: per_page}
      else
        data
      end
    else
      (200..299).cover?(response.status)
    end
  end
end
