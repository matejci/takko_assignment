# frozen_string_literal: true

class ApiConstraints
  ACCEPT = 'ACCEPT'

  def initialize(options)
    @version = options[:version]
    @default = options[:default]
  end

  def matches?(req)
    if req.headers[ACCEPT]
      @default || req.headers[ACCEPT].include?("application/vnd.takko_app.v#{@version}")
    else
      @default
    end
  end
end
