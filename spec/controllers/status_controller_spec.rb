# frozen_string_literal: true

require 'rails_helper'

describe StatusController do
  it 'tests health endpoint' do
    endpoint_test :health
  end

  it 'tests readiness endpoint successfully' do
    endpoint_test :readiness
  end

  it 'fails readiness endpoint when database not ready' do
    db_connection = double
    expect(ActiveRecord::Base).to receive(:connection).and_return(db_connection)
    expect(db_connection).to receive(:execute).and_raise(Mysql2::Error.new('error'))

    endpoint_test(:readiness, :internal_server_error, /service_unavailable/)
  end

  private

  def endpoint_test(endpoint, status = :success, matcher = /ok/)
    get endpoint
    expect(response).to have_http_status(status)
    expect(response.body.to_s).to match(matcher)
  end
end
